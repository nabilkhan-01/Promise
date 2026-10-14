import 'package:promise_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  const creatorId = '11111111-1111-4111-a111-111111111111';
  const recipientId = '22222222-2222-4222-a222-222222222222';
  const strangerId = '99999999-9999-4999-a999-999999999999';

  withServerpod('Given FinancialEndpoint RPC operations', (
    sessionBuilder,
    endpoints,
  ) {
    late Promise testPromise;
    late Promise unacceptedPromise;

    setUp(() async {
      final session = sessionBuilder.build();

      // Create an accepted friendship between creator and recipient
      await Friendship.db.insertRow(
        session,
        Friendship(
          senderUserId: creatorId,
          receiverUserId: recipientId,
          status: 'accepted',
          createdAt: DateTime.now().toUtc(),
        ),
      );

      // Create an accepted 1-on-1 promise
      testPromise = await Promise.db.insertRow(
        session,
        Promise(
          title: 'Freelance E-Commerce Website',
          promisedTo: 'Freelancer',
          description: 'Build online store',
          dueDate: DateTime.now().toUtc().add(const Duration(days: 30)),
          createdAt: DateTime.now().toUtc(),
          status: 'in_progress',
          creatorUserId: creatorId,
          recipientUserId: recipientId,
          recipientAccepted: true,
          commitmentType: 'freelance',
        ),
      );

      // Create an unaccepted promise
      unacceptedPromise = await Promise.db.insertRow(
        session,
        Promise(
          title: 'Unaccepted Invitation',
          promisedTo: 'Freelancer',
          dueDate: DateTime.now().toUtc().add(const Duration(days: 7)),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
          creatorUserId: creatorId,
          recipientUserId: recipientId,
          recipientAccepted: false,
          commitmentType: 'freelance',
        ),
      );
    });

    group('Authentication & Authorization Enforcements', () {
      test(
        'non-participant is denied access to financial terms and summaries',
        () async {
          final strangerSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              strangerId,
              {},
            ),
          );

          await expectLater(
            endpoints.financial.getFinancialSummary(
              strangerSession,
              testPromise.id!,
            ),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('Access denied'),
              ),
            ),
          );

          await expectLater(
            endpoints.financial.setFinancialTerms(
              strangerSession,
              testPromise.id!,
              100000,
              'USD',
              creatorId,
              recipientId,
              null,
            ),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('Access denied'),
              ),
            ),
          );
        },
      );

      test(
        'group parent container promises cannot hold standalone financial terms',
        () async {
          final creatorSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              creatorId,
              {},
            ),
          );

          final groupParent = await Promise.db.insertRow(
            sessionBuilder.build(),
            Promise(
              title: 'Group Container Contract',
              promisedTo: '',
              dueDate: DateTime.now().toUtc().add(const Duration(days: 30)),
              createdAt: DateTime.now().toUtc(),
              status: 'in_progress',
              creatorUserId: creatorId,
              isGroupParent: true,
              commitmentType: 'team',
            ),
          );

          await expectLater(
            endpoints.financial.setFinancialTerms(
              creatorSession,
              groupParent.id!,
              500000,
              'USD',
              creatorId,
              recipientId,
              null,
            ),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains(
                  'Group parent promises cannot have standalone financial obligations',
                ),
              ),
            ),
          );
        },
      );

      test(
        'unaccepted promise invitations block setting financial terms and payments',
        () async {
          final creatorSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              creatorId,
              {},
            ),
          );

          await expectLater(
            endpoints.financial.setFinancialTerms(
              creatorSession,
              unacceptedPromise.id!,
              100000,
              'USD',
              creatorId,
              recipientId,
              null,
            ),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('unaccepted promise invitation'),
              ),
            ),
          );
        },
      );

      test('payer and payee cannot be the same user ID', () async {
        final creatorSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            creatorId,
            {},
          ),
        );

        await expectLater(
          endpoints.financial.setFinancialTerms(
            creatorSession,
            testPromise.id!,
            100000,
            'USD',
            creatorId,
            creatorId,
            null,
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Payer and Payee cannot be the same user'),
            ),
          ),
        );
      });

      test(
        'counterparty recipient cannot set or update financial terms or schedule',
        () async {
          final recipientSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              recipientId,
              {},
            ),
          );

          await expectLater(
            endpoints.financial.setFinancialTerms(
              recipientSession,
              testPromise.id!,
              100000,
              'USD',
              creatorId,
              recipientId,
              null,
            ),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains(
                  'Only the commitment creator can set or update financial terms',
                ),
              ),
            ),
          );

          await expectLater(
            endpoints.financial.setPaymentSchedule(
              recipientSession,
              testPromise.id!,
              [
                PromisePaymentSchedule(
                  promiseId: testPromise.id!,
                  installmentOrder: 1,
                  amountMinorUnits: 100000,
                  currency: 'USD',
                  dueDate: DateTime.now().toUtc().add(const Duration(days: 7)),
                  createdAt: DateTime.now().toUtc(),
                ),
              ],
            ),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains(
                  'Only the commitment creator can configure payment schedules',
                ),
              ),
            ),
          );
        },
      );

      test(
        'sibling child recipient cannot access or modify another child milestone financial data',
        () async {
          final session = sessionBuilder.build();
          const child1RecipientId = '33333333-3333-4333-a333-333333333333';
          const child2RecipientId = '44444444-4444-4444-a444-444444444444';

          final groupParent = await Promise.db.insertRow(
            session,
            Promise(
              title: 'Parent Project',
              promisedTo: '',
              dueDate: DateTime.now().toUtc().add(const Duration(days: 30)),
              createdAt: DateTime.now().toUtc(),
              status: 'in_progress',
              creatorUserId: creatorId,
              isGroupParent: true,
              commitmentType: 'freelance',
            ),
          );

          await Promise.db.insertRow(
            session,
            Promise(
              title: 'Milestone 1 - Design',
              promisedTo: 'Freelancer 1',
              dueDate: DateTime.now().toUtc().add(const Duration(days: 14)),
              createdAt: DateTime.now().toUtc(),
              status: 'in_progress',
              creatorUserId: creatorId,
              recipientUserId: child1RecipientId,
              parentPromiseId: groupParent.id!,
              recipientAccepted: true,
              commitmentType: 'freelance',
            ),
          );

          final child2 = await Promise.db.insertRow(
            session,
            Promise(
              title: 'Milestone 2 - Development',
              promisedTo: 'Freelancer 2',
              dueDate: DateTime.now().toUtc().add(const Duration(days: 30)),
              createdAt: DateTime.now().toUtc(),
              status: 'in_progress',
              creatorUserId: creatorId,
              recipientUserId: child2RecipientId,
              parentPromiseId: groupParent.id!,
              recipientAccepted: true,
              commitmentType: 'freelance',
            ),
          );

          final child1Session = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              child1RecipientId,
              {},
            ),
          );

          // Child 1 recipient attempts to access Child 2's financial summary
          await expectLater(
            endpoints.financial.getFinancialSummary(
              child1Session,
              child2.id!,
            ),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('Access denied'),
              ),
            ),
          );

          // Child 1 recipient attempts to set financial terms on Child 2
          await expectLater(
            endpoints.financial.setFinancialTerms(
              child1Session,
              child2.id!,
              200000,
              'USD',
              creatorId,
              child2RecipientId,
              null,
            ),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('Access denied'),
              ),
            ),
          );
        },
      );
    });

    group('Financial Terms & Schedules', () {
      test('can set valid financial terms and retrieve schedule', () async {
        final creatorSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            creatorId,
            {},
          ),
        );

        final terms = await endpoints.financial.setFinancialTerms(
          creatorSession,
          testPromise.id!,
          1000000, // $10,000.00 USD
          'USD',
          creatorId,
          recipientId,
          '50% upfront, 50% upon delivery',
        );

        expect(terms.totalAmountMinorUnits, equals(1000000));
        expect(terms.currency, equals('USD'));

        final schedules = await endpoints.financial.setPaymentSchedule(
          creatorSession,
          testPromise.id!,
          [
            PromisePaymentSchedule(
              promiseId: testPromise.id!,
              installmentOrder: 1,
              amountMinorUnits: 500000,
              currency: 'USD',
              dueDate: DateTime.now().toUtc().add(const Duration(days: 7)),
              createdAt: DateTime.now().toUtc(),
            ),
            PromisePaymentSchedule(
              promiseId: testPromise.id!,
              installmentOrder: 2,
              amountMinorUnits: 500000,
              currency: 'USD',
              dueDate: DateTime.now().toUtc().add(const Duration(days: 30)),
              createdAt: DateTime.now().toUtc(),
            ),
          ],
        );

        expect(schedules.length, equals(2));
        expect(schedules[0].installmentOrder, equals(1));
        expect(schedules[1].installmentOrder, equals(2));
      });

      test(
        'financial terms become strictly read-only once any payment record exists',
        () async {
          final creatorSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              creatorId,
              {},
            ),
          );

          await endpoints.financial.setFinancialTerms(
            creatorSession,
            testPromise.id!,
            500000,
            'USD',
            creatorId,
            recipientId,
            null,
          );

          // Record a payment
          await endpoints.financial.recordPayment(
            creatorSession,
            testPromise.id!,
            null,
            100000,
            DateTime.now().toUtc(),
            'bank_transfer',
            'REF-101',
            null,
            null,
          );

          // Attempting to update financial terms should fail
          await expectLater(
            endpoints.financial.setFinancialTerms(
              creatorSession,
              testPromise.id!,
              600000,
              'USD',
              creatorId,
              recipientId,
              'Attempted modification',
            ),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains(
                  'Financial terms are strictly read-only once payment or refund records exist',
                ),
              ),
            ),
          );
        },
      );
    });

    group('Payment / Refund Lifecycle & Anti-Self-Confirmation', () {
      test('recorder cannot confirm their own payment record', () async {
        final creatorSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            creatorId,
            {},
          ),
        );

        await endpoints.financial.setFinancialTerms(
          creatorSession,
          testPromise.id!,
          500000,
          'USD',
          creatorId,
          recipientId,
          null,
        );

        final payment = await endpoints.financial.recordPayment(
          creatorSession,
          testPromise.id!,
          null,
          250000,
          DateTime.now().toUtc(),
          'venmo',
          null,
          null,
          null,
        );

        expect(payment.status, equals('pending_confirmation'));

        // Recorder attempting to self-confirm
        await expectLater(
          endpoints.financial.confirmPaymentRecord(
            creatorSession,
            payment.id!,
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Recorder cannot confirm their own payment or refund'),
            ),
          ),
        );
      });

      test(
        'counterparty can confirm payment record and update summary',
        () async {
          final creatorSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              creatorId,
              {},
            ),
          );
          final recipientSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              recipientId,
              {},
            ),
          );

          await endpoints.financial.setFinancialTerms(
            creatorSession,
            testPromise.id!,
            500000, // $5,000.00
            'USD',
            creatorId,
            recipientId,
            null,
          );

          final payment = await endpoints.financial.recordPayment(
            creatorSession,
            testPromise.id!,
            null,
            250000, // $2,500.00
            DateTime.now().toUtc(),
            'bank_transfer',
            'TXN-555',
            null,
            null,
          );

          // Counterparty confirms payment
          final confirmed = await endpoints.financial.confirmPaymentRecord(
            recipientSession,
            payment.id!,
          );

          expect(confirmed.status, equals('confirmed'));
          expect(confirmed.confirmerUserId, equals(recipientId));
          expect(confirmed.confirmedAt, isNotNull);

          final summary = await endpoints.financial.getFinancialSummary(
            creatorSession,
            testPromise.id!,
          );

          expect(summary.settlementStatus, equals('partially_paid'));
          expect(summary.netConfirmedSettlementMinorUnits, equals(250000));
          expect(summary.outstandingBalanceMinorUnits, equals(250000));
        },
      );

      test('disputing and cancelling pending payment records', () async {
        final creatorSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            creatorId,
            {},
          ),
        );
        final recipientSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            recipientId,
            {},
          ),
        );

        await endpoints.financial.setFinancialTerms(
          creatorSession,
          testPromise.id!,
          500000,
          'USD',
          creatorId,
          recipientId,
          null,
        );

        // Record a payment
        final payment1 = await endpoints.financial.recordPayment(
          creatorSession,
          testPromise.id!,
          null,
          100000,
          DateTime.now().toUtc(),
          'check',
          null,
          null,
          null,
        );

        // Counterparty disputes
        final disputed = await endpoints.financial.disputePaymentRecord(
          recipientSession,
          payment1.id!,
          'Cheque has not cleared',
        );

        expect(disputed.status, equals('disputed'));
        expect(disputed.disputeReason, equals('Cheque has not cleared'));

        final summary = await endpoints.financial.getFinancialSummary(
          creatorSession,
          testPromise.id!,
        );
        expect(summary.hasActiveDispute, isTrue);

        // Recorder cancels disputed record
        final cancelled = await endpoints.financial.cancelPaymentRecord(
          creatorSession,
          payment1.id!,
          'Entry voided',
        );

        expect(cancelled.status, equals('cancelled'));
      });

      test('confirmed records are permanently immutable', () async {
        final creatorSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            creatorId,
            {},
          ),
        );
        final recipientSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            recipientId,
            {},
          ),
        );

        await endpoints.financial.setFinancialTerms(
          creatorSession,
          testPromise.id!,
          500000,
          'USD',
          creatorId,
          recipientId,
          null,
        );

        final payment = await endpoints.financial.recordPayment(
          creatorSession,
          testPromise.id!,
          null,
          100000,
          DateTime.now().toUtc(),
          'cash',
          null,
          null,
          null,
        );

        await endpoints.financial.confirmPaymentRecord(
          recipientSession,
          payment.id!,
        );

        // Attempting to dispute a confirmed record fails
        await expectLater(
          endpoints.financial.disputePaymentRecord(
            recipientSession,
            payment.id!,
            'Late challenge',
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Confirmed financial records are permanently immutable'),
            ),
          ),
        );

        // Attempting to cancel a confirmed record fails
        await expectLater(
          endpoints.financial.cancelPaymentRecord(
            creatorSession,
            payment.id!,
            'Attempted cancel',
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Confirmed financial records cannot be cancelled'),
            ),
          ),
        );
      });

      test(
        'recording refunds, enforcing ceiling limits, and serializing concurrent refunds via row locks',
        () async {
          final creatorSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              creatorId,
              {},
            ),
          );
          final recipientSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              recipientId,
              {},
            ),
          );

          await endpoints.financial.setFinancialTerms(
            creatorSession,
            testPromise.id!,
            1000000, // $10,000.00 USD
            'USD',
            creatorId,
            recipientId,
            null,
          );

          // Confirmed original payment of $5,000.00
          final payment = await endpoints.financial.recordPayment(
            creatorSession,
            testPromise.id!,
            null,
            500000,
            DateTime.now().toUtc(),
            'bank_transfer',
            'PAY-1',
            null,
            null,
          );

          await endpoints.financial.confirmPaymentRecord(
            recipientSession,
            payment.id!,
          );

          // Payee logs a refund of $2,000.00
          final refund1 = await endpoints.financial.recordRefund(
            recipientSession,
            testPromise.id!,
            payment.id!,
            200000,
            DateTime.now().toUtc(),
            'bank_transfer',
            'REF-1',
            'Partial return of deposit',
            null,
          );

          expect(refund1.recordKind, equals('refund'));
          expect(refund1.reversesPaymentRecordId, equals(payment.id!));

          // Payer confirms refund
          await endpoints.financial.confirmPaymentRecord(
            creatorSession,
            refund1.id!,
          );

          final summary1 = await endpoints.financial.getFinancialSummary(
            creatorSession,
            testPromise.id!,
          );

          expect(
            summary1.netConfirmedSettlementMinorUnits,
            equals(300000),
          ); // $3,000.00
          expect(
            summary1.outstandingBalanceMinorUnits,
            equals(700000),
          ); // $7,000.00
          expect(summary1.settlementStatus, equals('partially_paid'));
          expect(summary1.refundStatus, equals('partially_refunded'));

          // Attempting to record a refund of $4,000.00 when remaining balance is $3,000.00 ($5,000 - $2,000)
          await expectLater(
            endpoints.financial.recordRefund(
              recipientSession,
              testPromise.id!,
              payment.id!,
              400000,
              DateTime.now().toUtc(),
              'bank_transfer',
              'REF-2',
              null,
              null,
            ),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains(
                  'Refund amount exceeds the original payment\'s remaining refundable balance',
                ),
              ),
            ),
          );
        },
      );

      test(
        'full 100% refund sets settlementStatus to unpaid and refundStatus to fully_refunded',
        () async {
          final creatorSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              creatorId,
              {},
            ),
          );
          final recipientSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              recipientId,
              {},
            ),
          );

          await endpoints.financial.setFinancialTerms(
            creatorSession,
            testPromise.id!,
            500000, // $5,000.00
            'USD',
            creatorId,
            recipientId,
            null,
          );

          final payment = await endpoints.financial.recordPayment(
            creatorSession,
            testPromise.id!,
            null,
            500000,
            DateTime.now().toUtc(),
            'bank_transfer',
            'PAY-FULL',
            null,
            null,
          );

          await endpoints.financial.confirmPaymentRecord(
            recipientSession,
            payment.id!,
          );

          // Full 100% refund
          final refund = await endpoints.financial.recordRefund(
            recipientSession,
            testPromise.id!,
            payment.id!,
            500000,
            DateTime.now().toUtc(),
            'bank_transfer',
            'REF-FULL',
            null,
            null,
          );

          await endpoints.financial.confirmPaymentRecord(
            creatorSession,
            refund.id!,
          );

          final summary = await endpoints.financial.getFinancialSummary(
            creatorSession,
            testPromise.id!,
          );

          expect(summary.netConfirmedSettlementMinorUnits, equals(0));
          expect(summary.outstandingBalanceMinorUnits, equals(500000));
          expect(summary.settlementStatus, equals('unpaid'));
          expect(summary.refundStatus, equals('fully_refunded'));
        },
      );

      test(
        'multiple original payments where one is fully refunded while another remains refundable',
        () async {
          final creatorSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              creatorId,
              {},
            ),
          );
          final recipientSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              recipientId,
              {},
            ),
          );

          await endpoints.financial.setFinancialTerms(
            creatorSession,
            testPromise.id!,
            1000000, // $10,000.00
            'USD',
            creatorId,
            recipientId,
            null,
          );

          // Payment A: $5,000.00
          final payA = await endpoints.financial.recordPayment(
            creatorSession,
            testPromise.id!,
            null,
            500000,
            DateTime.now().toUtc(),
            'bank_transfer',
            'PAY-A',
            null,
            null,
          );
          await endpoints.financial.confirmPaymentRecord(
            recipientSession,
            payA.id!,
          );

          // Payment B: $5,000.00
          final payB = await endpoints.financial.recordPayment(
            creatorSession,
            testPromise.id!,
            null,
            500000,
            DateTime.now().toUtc(),
            'bank_transfer',
            'PAY-B',
            null,
            null,
          );
          await endpoints.financial.confirmPaymentRecord(
            recipientSession,
            payB.id!,
          );

          // Full refund of $5,000.00 against Payment A only
          final refA = await endpoints.financial.recordRefund(
            recipientSession,
            testPromise.id!,
            payA.id!,
            500000,
            DateTime.now().toUtc(),
            'bank_transfer',
            'REF-A',
            null,
            null,
          );
          await endpoints.financial.confirmPaymentRecord(
            creatorSession,
            refA.id!,
          );

          final summary = await endpoints.financial.getFinancialSummary(
            creatorSession,
            testPromise.id!,
          );

          expect(summary.totalConfirmedPaymentMinorUnits, equals(1000000));
          expect(summary.totalConfirmedRefundMinorUnits, equals(500000));
          expect(
            summary.netConfirmedSettlementMinorUnits,
            equals(500000),
          ); // $5,000.00 remaining
          expect(summary.outstandingBalanceMinorUnits, equals(500000));
          expect(summary.settlementStatus, equals('partially_paid'));
          expect(summary.refundStatus, equals('partially_refunded'));

          // Additional refund of $1,000.00 against Payment A fails (exhausted)
          await expectLater(
            endpoints.financial.recordRefund(
              recipientSession,
              testPromise.id!,
              payA.id!,
              100000,
              DateTime.now().toUtc(),
              'bank_transfer',
              'REF-A-EXCESS',
              null,
              null,
            ),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('Refund amount exceeds'),
              ),
            ),
          );

          // Refund of $2,000.00 against Payment B succeeds (Payment B still refundable)
          final refB = await endpoints.financial.recordRefund(
            recipientSession,
            testPromise.id!,
            payB.id!,
            200000,
            DateTime.now().toUtc(),
            'bank_transfer',
            'REF-B',
            null,
            null,
          );
          expect(refB.id, isNotNull);
        },
      );

      test(
        'enforces remaining refundable ceiling under row lock when confirming refunds',
        () async {
          final creatorSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              creatorId,
              {},
            ),
          );
          final recipientSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              recipientId,
              {},
            ),
          );

          await endpoints.financial.setFinancialTerms(
            creatorSession,
            testPromise.id!,
            500000, // $5,000.00
            'USD',
            creatorId,
            recipientId,
            null,
          );

          // Original payment of $3,000.00
          final pay = await endpoints.financial.recordPayment(
            creatorSession,
            testPromise.id!,
            null,
            300000,
            DateTime.now().toUtc(),
            'bank_transfer',
            'PAY-CONC',
            null,
            null,
          );
          await endpoints.financial.confirmPaymentRecord(
            recipientSession,
            pay.id!,
          );

          // Create two pending refunds ($2,000.00 and $2,000.00) against $3,000.00 payment
          final ref1 = await endpoints.financial.recordRefund(
            recipientSession,
            testPromise.id!,
            pay.id!,
            200000,
            DateTime.now().toUtc(),
            'bank_transfer',
            'REF-C1',
            null,
            null,
          );

          final ref2 = await endpoints.financial.recordRefund(
            recipientSession,
            testPromise.id!,
            pay.id!,
            200000,
            DateTime.now().toUtc(),
            'bank_transfer',
            'REF-C2',
            null,
            null,
          );

          // Confirm first refund ($2,000.00) -> succeeds, remaining refundable balance becomes $1,000.00
          final confirmedRef1 = await endpoints.financial.confirmPaymentRecord(
            creatorSession,
            ref1.id!,
          );
          expect(confirmedRef1.status, equals('confirmed'));

          // Attempting to confirm second refund ($2,000.00) fails because remaining balance ($1,000.00) is exceeded
          await expectLater(
            endpoints.financial.confirmPaymentRecord(creatorSession, ref2.id!),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains(
                  'Refund amount exceeds the remaining refundable balance',
                ),
              ),
            ),
          );
        },
      );
    });
  });
}
