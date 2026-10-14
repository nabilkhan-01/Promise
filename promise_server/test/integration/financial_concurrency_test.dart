import 'dart:async';

import 'package:promise_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  const creatorId = '11111111-1111-4111-a111-111111111111';
  const recipientId = '22222222-2222-4222-a222-222222222222';

  withServerpod(
    'Given FinancialEndpoint Real PostgreSQL Concurrency Locking',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      late Promise testPromise;

      setUp(() async {
        final session = sessionBuilder.build();

        // Create accepted friendship
        await Friendship.db.insertRow(
          session,
          Friendship(
            senderUserId: creatorId,
            receiverUserId: recipientId,
            status: 'accepted',
            createdAt: DateTime.now().toUtc(),
          ),
        );

        // Create accepted 1-on-1 promise
        testPromise = await Promise.db.insertRow(
          session,
          Promise(
            title: 'Concurrency Test Contract',
            promisedTo: 'Freelancer',
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
        'real PostgreSQL row locking serializes concurrent refund confirmation requests and enforces ceiling limit without partial mutations',
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

          // 1. Set financial terms of $5,000.00 USD
          await endpoints.financial.setFinancialTerms(
            creatorSession,
            testPromise.id!,
            500000,
            'USD',
            creatorId,
            recipientId,
            null,
          );

          // 2. Record & confirm original payment of $3,000.00 USD
          final payment = await endpoints.financial.recordPayment(
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
            payment.id!,
          );

          // 3. Log two competing pending refund entries of $2,000.00 USD each
          // Both refunds target original payment $3,000.00 (total $4,000.00 refund requests)
          final ref1 = await endpoints.financial.recordRefund(
            recipientSession,
            testPromise.id!,
            payment.id!,
            200000,
            DateTime.now().toUtc(),
            'bank_transfer',
            'REF-1',
            null,
            null,
          );

          final ref2 = await endpoints.financial.recordRefund(
            recipientSession,
            testPromise.id!,
            payment.id!,
            200000,
            DateTime.now().toUtc(),
            'bank_transfer',
            'REF-2',
            null,
            null,
          );

          // 4. Fire parallel concurrent confirmPaymentRecord requests
          final results = await Future.wait([
            endpoints.financial
                .confirmPaymentRecord(creatorSession, ref1.id!)
                .then((v) => 'success')
                .catchError((e) => 'failed: ${e.toString()}'),
            endpoints.financial
                .confirmPaymentRecord(creatorSession, ref2.id!)
                .then((v) => 'success')
                .catchError((e) => 'failed: ${e.toString()}'),
          ]);

          // Assertions:
          // One confirmation succeeded, and one was rejected by row-locked ceiling check
          expect(results, contains('success'));
          expect(
            results.any((r) => r.contains('Refund amount exceeds')),
            isTrue,
            reason: 'Results: $results',
          );

          // Verify total confirmed refunds in DB is exactly $2,000.00 (not $4,000.00)
          final summary = await endpoints.financial.getFinancialSummary(
            creatorSession,
            testPromise.id!,
          );

          expect(summary.totalConfirmedPaymentMinorUnits, equals(300000));
          expect(summary.totalConfirmedRefundMinorUnits, equals(200000));
          expect(summary.netConfirmedSettlementMinorUnits, equals(100000));
          expect(summary.outstandingBalanceMinorUnits, equals(400000));
        },
      );
    },
  );
}
