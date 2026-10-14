import 'package:promise_currency/promise_currency.dart';
import 'package:promise_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  const creatorId = '11111111-1111-4111-a111-111111111111';
  const recipientId = '22222222-2222-4222-a222-222222222222';

  withServerpod('Given Financial ORM models and schema', (
    sessionBuilder,
    endpoints,
  ) {
    late Promise testPromise;

    setUp(() async {
      final session = sessionBuilder.build();

      // Create an accepted friendship
      await Friendship.db.insertRow(
        session,
        Friendship(
          senderUserId: creatorId,
          receiverUserId: recipientId,
          status: 'accepted',
          createdAt: DateTime.now().toUtc(),
        ),
      );

      // Create a test 1-on-1 promise
      testPromise = await Promise.db.insertRow(
        session,
        Promise(
          title: 'Freelance Web Design',
          promisedTo: 'Friend',
          description: 'Build landing page',
          dueDate: DateTime.now().toUtc().add(const Duration(days: 14)),
          createdAt: DateTime.now().toUtc(),
          status: 'in_progress',
          creatorUserId: creatorId,
          recipientUserId: recipientId,
          recipientAccepted: true,
          commitmentType: 'freelance',
        ),
      );
    });

    test(
      'legacy or non-financial promises have no financial terms row by default',
      () async {
        final session = sessionBuilder.build();

        final terms = await PromiseFinancialTerms.db.findFirstRow(
          session,
          where: (t) => t.promiseId.equals(testPromise.id!),
        );

        expect(terms, isNull);
      },
    );

    test(
      'can insert and retrieve valid PromiseFinancialTerms with minor units and ISO currency',
      () async {
        final session = sessionBuilder.build();

        // Validate currency code using promise_currency
        final currency = CurrencyUtils.validateCurrencyCode('USD');
        final amountMinorUnits = CurrencyUtils.parseToMinorUnits(
          '1500.00',
          currency,
        ); // 150000 cents

        final insertedTerms = await PromiseFinancialTerms.db.insertRow(
          session,
          PromiseFinancialTerms(
            promiseId: testPromise.id!,
            totalAmountMinorUnits: amountMinorUnits,
            currency: currency.code,
            payerUserId: creatorId,
            payeeUserId: recipientId,
            notes: 'Milestone contract terms',
            createdAt: DateTime.now().toUtc(),
          ),
        );

        expect(insertedTerms.id, isNotNull);
        expect(insertedTerms.promiseId, equals(testPromise.id!));
        expect(insertedTerms.totalAmountMinorUnits, equals(150000));
        expect(insertedTerms.currency, equals('USD'));
        expect(insertedTerms.payerUserId, equals(creatorId));
        expect(insertedTerms.payeeUserId, equals(recipientId));
      },
    );

    test(
      'can insert and manage PromisePaymentSchedule installments with cancellation metadata',
      () async {
        final session = sessionBuilder.build();
        final currency = CurrencyUtils.validateCurrencyCode('EUR');

        final inst1 = await PromisePaymentSchedule.db.insertRow(
          session,
          PromisePaymentSchedule(
            promiseId: testPromise.id!,
            installmentOrder: 1,
            amountMinorUnits: 50000, // 500.00 EUR
            currency: currency.code,
            dueDate: DateTime.now().toUtc().add(const Duration(days: 7)),
            createdAt: DateTime.now().toUtc(),
          ),
        );

        final inst2 = await PromisePaymentSchedule.db.insertRow(
          session,
          PromisePaymentSchedule(
            promiseId: testPromise.id!,
            installmentOrder: 2,
            amountMinorUnits: 50000,
            currency: currency.code,
            dueDate: DateTime.now().toUtc().add(const Duration(days: 14)),
            cancelledAt: DateTime.now().toUtc(),
            cancelledByUserId: creatorId,
            cancellationReason: 'Scope reduction agreed',
            createdAt: DateTime.now().toUtc(),
          ),
        );

        expect(inst1.id, isNotNull);
        expect(inst1.cancelledAt, isNull);

        expect(inst2.id, isNotNull);
        expect(inst2.cancelledAt, isNotNull);
        expect(inst2.cancelledByUserId, equals(creatorId));
        expect(inst2.cancellationReason, equals('Scope reduction agreed'));
      },
    );

    test(
      'can record payment/refund entries with complete audit metadata (confirmation, dispute, cancellation)',
      () async {
        final session = sessionBuilder.build();
        final currency = CurrencyUtils.validateCurrencyCode('BHD');

        // 1. Confirmed Payment Record
        final paymentRecord = await PromisePaymentRecord.db.insertRow(
          session,
          PromisePaymentRecord(
            promiseId: testPromise.id!,
            recordKind: 'payment',
            recorderUserId: creatorId,
            payerUserId: creatorId,
            payeeUserId: recipientId,
            amountMinorUnits: 10500, // 10.500 BHD (3 decimals)
            currency: currency.code,
            paymentDate: DateTime.now().toUtc(),
            paymentMethod: 'bank_transfer',
            externalReference: 'TXN-987654',
            status: 'confirmed',
            confirmedAt: DateTime.now().toUtc(),
            confirmerUserId: recipientId,
            createdAt: DateTime.now().toUtc(),
          ),
        );

        expect(paymentRecord.id, isNotNull);
        expect(paymentRecord.recordKind, equals('payment'));
        expect(paymentRecord.status, equals('confirmed'));
        expect(paymentRecord.confirmerUserId, equals(recipientId));

        // 2. Disputed Payment Record with dispute metadata
        final disputedRecord = await PromisePaymentRecord.db.insertRow(
          session,
          PromisePaymentRecord(
            promiseId: testPromise.id!,
            recordKind: 'payment',
            recorderUserId: creatorId,
            payerUserId: creatorId,
            payeeUserId: recipientId,
            amountMinorUnits: 5000,
            currency: currency.code,
            paymentDate: DateTime.now().toUtc(),
            paymentMethod: 'venmo',
            status: 'disputed',
            disputedAt: DateTime.now().toUtc(),
            disputerUserId: recipientId,
            disputeReason: 'Payment not received in account',
            createdAt: DateTime.now().toUtc(),
          ),
        );

        expect(disputedRecord.status, equals('disputed'));
        expect(disputedRecord.disputerUserId, equals(recipientId));
        expect(disputedRecord.disputeReason, contains('not received'));

        // 3. Cancelled Payment Record with cancellation metadata
        final cancelledRecord = await PromisePaymentRecord.db.insertRow(
          session,
          PromisePaymentRecord(
            promiseId: testPromise.id!,
            recordKind: 'payment',
            recorderUserId: creatorId,
            payerUserId: creatorId,
            payeeUserId: recipientId,
            amountMinorUnits: 2000,
            currency: currency.code,
            paymentDate: DateTime.now().toUtc(),
            paymentMethod: 'cash',
            status: 'cancelled',
            cancelledAt: DateTime.now().toUtc(),
            cancellerUserId: creatorId,
            cancellationReason: 'Entered by mistake before transfer',
            createdAt: DateTime.now().toUtc(),
          ),
        );

        expect(cancelledRecord.status, equals('cancelled'));
        expect(cancelledRecord.cancellerUserId, equals(creatorId));
        expect(cancelledRecord.cancellationReason, contains('mistake'));

        // 4. Confirmed Refund Record linked via reversesPaymentRecordId
        final refundRecord = await PromisePaymentRecord.db.insertRow(
          session,
          PromisePaymentRecord(
            promiseId: testPromise.id!,
            recordKind: 'refund',
            reversesPaymentRecordId: paymentRecord.id!,
            recorderUserId: recipientId,
            payerUserId: creatorId,
            payeeUserId: recipientId,
            amountMinorUnits: 2500, // 2.500 BHD partial refund
            currency: currency.code,
            paymentDate: DateTime.now().toUtc(),
            paymentMethod: 'bank_transfer',
            externalReference: 'REF-123456',
            status: 'confirmed',
            confirmedAt: DateTime.now().toUtc(),
            confirmerUserId: creatorId,
            createdAt: DateTime.now().toUtc(),
          ),
        );

        expect(refundRecord.id, isNotNull);
        expect(refundRecord.recordKind, equals('refund'));
        expect(refundRecord.reversesPaymentRecordId, equals(paymentRecord.id!));
      },
    );

    test(
      'can construct GroupFinancialSummary holding multi-currency PromiseFinancialSummary DTOs',
      () {
        final usdSummary = PromiseFinancialSummary(
          promiseId: 101,
          hasFinancials: true,
          currency: 'USD',
          totalAgreedMinorUnits: 300000, // $3,000.00 USD
          netConfirmedSettlementMinorUnits: 300000,
          outstandingBalanceMinorUnits: 0,
          settlementStatus: 'paid',
          refundStatus: 'none',
          hasActiveDispute: false,
        );

        final eurSummary = PromiseFinancialSummary(
          promiseId: 102,
          hasFinancials: true,
          currency: 'EUR',
          totalAgreedMinorUnits: 200000, // €2,000.00 EUR
          netConfirmedSettlementMinorUnits: 100000,
          outstandingBalanceMinorUnits: 100000,
          settlementStatus: 'partially_paid',
          refundStatus: 'none',
          hasActiveDispute: false,
        );

        final groupSummary = GroupFinancialSummary(
          parentPromiseId: testPromise.id!,
          hasFinancials: true,
          currencySummaries: [usdSummary, eurSummary],
          hasActiveDispute: false,
        );

        expect(groupSummary.parentPromiseId, equals(testPromise.id!));
        expect(groupSummary.hasFinancials, isTrue);
        expect(groupSummary.currencySummaries.length, equals(2));
        expect(groupSummary.currencySummaries[0].currency, equals('USD'));
        expect(groupSummary.currencySummaries[1].currency, equals('EUR'));
        expect(groupSummary.hasActiveDispute, isFalse);
      },
    );
  });
}
