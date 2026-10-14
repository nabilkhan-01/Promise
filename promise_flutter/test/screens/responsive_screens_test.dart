import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promise_client/promise_client.dart';

import 'package:promise_flutter/widgets/financial_section.dart';

void main() {
  const creatorId = '11111111-1111-4111-a111-111111111111';
  const recipientId = '22222222-2222-4222-a222-222222222222';

  Widget buildTestApp(
    Widget home, {
    double width = 390,
    double height = 844,
    double textScaleFactor = 1.0,
  }) {
    return MediaQuery(
      data: MediaQueryData(
        size: Size(width, height),
        textScaler: TextScaler.linear(textScaleFactor),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        ),
        home: home,
      ),
    );
  }

  group(
    'Mobile Responsive Layout Tests across 320px, 360px, 390px, and 430px Viewports',
    () {
      final viewports = [
        {
          'width': 320.0,
          'height': 568.0,
          'name': '320px Narrow Phone (iPhone SE)',
        },
        {
          'width': 360.0,
          'height': 640.0,
          'name': '360px Compact Phone (Galaxy S10e)',
        },
        {
          'width': 390.0,
          'height': 844.0,
          'name': '390px Modern Phone (iPhone 13)',
        },
        {
          'width': 430.0,
          'height': 932.0,
          'name': '430px Large Phone (Pixel 7 Pro)',
        },
      ];

      for (var vp in viewports) {
        final width = vp['width'] as double;
        final height = vp['height'] as double;
        final vpName = vp['name'] as String;

        testWidgets(
          'renders FinancialSection at $vpName without RenderFlex overflow',
          (tester) async {
            tester.view.physicalSize = Size(width * 2, height * 2);
            tester.view.devicePixelRatio = 2.0;
            addTearDown(tester.view.resetPhysicalSize);

            final testPromise = Promise(
              id: 1,
              title:
                  'Comprehensive Mobile Responsiveness Verification Contract For Extremely Long Product Names',
              promisedTo:
                  'very.long.email.address.for.testing.overflow@example.com',
              description:
                  'A detailed description that exercises multi-line text wrapping across narrow and wide mobile phone screens.',
              dueDate: DateTime.now().add(const Duration(days: 14)),
              createdAt: DateTime.now(),
              status: 'in_progress',
              creatorUserId: creatorId,
              recipientUserId: recipientId,
              recipientAccepted: true,
              commitmentType: 'freelance',
            );

            final summary = PromiseFinancialSummary(
              promiseId: 1,
              hasFinancials: true,
              currency: 'USD',
              totalAgreedMinorUnits: 1000000, // $10,000.00
              netConfirmedSettlementMinorUnits: 400000, // $4,000.00
              outstandingBalanceMinorUnits: 600000, // $6,000.00
              settlementStatus: 'partially_paid',
              refundStatus: 'partially_refunded',
              hasActiveDispute: true,
            );

            final records = <PromisePaymentRecord>[
              PromisePaymentRecord(
                id: 10,
                promiseId: 1,
                recordKind: 'payment',
                recorderUserId: creatorId,
                payerUserId: creatorId,
                payeeUserId: recipientId,
                amountMinorUnits: 500000,
                currency: 'USD',
                paymentDate: DateTime.now(),
                paymentMethod: 'bank_transfer',
                externalReference: 'TXN-LONG-REFERENCE-NUMBER-987654321',
                status: 'confirmed',
                confirmedAt: DateTime.now(),
                createdAt: DateTime.now(),
              ),
              PromisePaymentRecord(
                id: 11,
                promiseId: 1,
                recordKind: 'refund',
                reversesPaymentRecordId: 10,
                recorderUserId: recipientId,
                payerUserId: creatorId,
                payeeUserId: recipientId,
                amountMinorUnits: 100000,
                currency: 'USD',
                paymentDate: DateTime.now(),
                paymentMethod: 'bank_transfer',
                externalReference: 'REF-LONG-REF-12345',
                status: 'confirmed',
                confirmedAt: DateTime.now(),
                createdAt: DateTime.now(),
              ),
            ];

            await tester.pumpWidget(
              buildTestApp(
                Scaffold(
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: FinancialSection(
                        promise: testPromise,
                        currentUserId: recipientId,
                        summary: summary,
                        records: records,
                        onRefreshNeeded: () {},
                      ),
                    ),
                  ),
                ),
                width: width,
                height: height,
              ),
            );

            await tester.pumpAndSettle();

            // Verify key text elements render without overflow
            expect(find.text('Financials & Payments'), findsOneWidget);
            expect(find.text('PARTIALLY PAID'), findsOneWidget);
            expect(find.text('PARTIALLY REFUNDED'), findsOneWidget);
            expect(
              find.text(
                'Payment record under dispute. Please review pending actions below.',
              ),
              findsOneWidget,
            );
            expect(find.byType(LinearProgressIndicator), findsOneWidget);
          },
        );
      }

      testWidgets(
        'renders FinancialSection under 1.3x system text scaling without overflow at 360px',
        (tester) async {
          tester.view.physicalSize = const Size(360 * 2, 640 * 2);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.resetPhysicalSize);

          final testPromise = Promise(
            id: 1,
            title: 'Scaled Text Testing Commitment',
            promisedTo: 'Freelancer',
            dueDate: DateTime.now().add(const Duration(days: 7)),
            createdAt: DateTime.now(),
            status: 'in_progress',
            creatorUserId: creatorId,
            recipientUserId: recipientId,
            recipientAccepted: true,
          );

          final summary = PromiseFinancialSummary(
            promiseId: 1,
            hasFinancials: true,
            currency: 'EUR',
            totalAgreedMinorUnits: 250000, // €2,500.00
            netConfirmedSettlementMinorUnits: 250000,
            outstandingBalanceMinorUnits: 0,
            settlementStatus: 'paid',
            refundStatus: 'none',
            hasActiveDispute: false,
          );

          await tester.pumpWidget(
            buildTestApp(
              Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FinancialSection(
                      promise: testPromise,
                      currentUserId: creatorId,
                      summary: summary,
                      onRefreshNeeded: () {},
                    ),
                  ),
                ),
              ),
              width: 360,
              height: 640,
              textScaleFactor: 1.3,
            ),
          );

          await tester.pumpAndSettle();

          expect(find.text('PAID IN FULL'), findsOneWidget);
          expect(find.text('Net Confirmed: €2,500.00'), findsOneWidget);
          expect(find.text('Agreed: €2,500.00'), findsOneWidget);
        },
      );
    },
  );
}
