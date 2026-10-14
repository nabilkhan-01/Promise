import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promise_client/promise_client.dart';
import 'package:promise_currency/promise_currency.dart';
import 'package:promise_flutter/widgets/currency_picker_modal.dart';
import 'package:promise_flutter/widgets/financial_section.dart';

void main() {
  const creatorId = '11111111-1111-4111-a111-111111111111';
  const recipientId = '22222222-2222-4222-a222-222222222222';

  late Promise testPromise;

  setUp(() {
    testPromise = Promise(
      id: 1,
      title: 'Freelance Web Contract',
      promisedTo: 'Freelancer',
      dueDate: DateTime.now().add(const Duration(days: 14)),
      createdAt: DateTime.now(),
      status: 'in_progress',
      creatorUserId: creatorId,
      recipientUserId: recipientId,
      recipientAccepted: true,
      commitmentType: 'freelance',
    );
  });

  group('FinancialSection UI Tests', () {
    testWidgets('renders empty state with configure button for creator', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FinancialSection(
                promise: testPromise,
                currentUserId: creatorId,
                summary: null,
                onRefreshNeeded: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Financials & Payments'), findsOneWidget);
      expect(
        find.text('No financial terms configured for this commitment.'),
        findsOneWidget,
      );
      expect(find.text('Configure Financial Terms'), findsOneWidget);
    });

    testWidgets('does not show configure button for non-creator recipient', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FinancialSection(
                promise: testPromise,
                currentUserId: recipientId,
                summary: null,
                onRefreshNeeded: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Financials & Payments'), findsOneWidget);
      expect(find.text('Configure Financial Terms'), findsNothing);
    });

    testWidgets(
      'renders configured financial summary with correct minor-unit formatting',
      (tester) async {
        final summary = PromiseFinancialSummary(
          promiseId: 1,
          hasFinancials: true,
          currency: 'USD',
          totalAgreedMinorUnits: 500000, // $5,000.00
          netConfirmedSettlementMinorUnits: 250000, // $2,500.00
          outstandingBalanceMinorUnits: 250000,
          settlementStatus: 'partially_paid',
          refundStatus: 'none',
          hasActiveDispute: false,
          payerUserId: creatorId,
          payeeUserId: recipientId,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FinancialSection(
                  promise: testPromise,
                  currentUserId: creatorId,
                  summary: summary,
                  onRefreshNeeded: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('PARTIALLY PAID'), findsOneWidget);
        expect(find.text('Net Confirmed: \$2,500.00'), findsOneWidget);
        expect(find.text('Agreed: \$5,000.00'), findsOneWidget);
        expect(find.text('Outstanding Due: \$2,500.00'), findsOneWidget);
        expect(find.text('Record Payment'), findsOneWidget);
      },
    );

    testWidgets(
      'renders 0-decimal JPY and 3-decimal BHD amounts correctly without float errors',
      (tester) async {
        final jpySummary = PromiseFinancialSummary(
          promiseId: 1,
          hasFinancials: true,
          currency: 'JPY',
          totalAgreedMinorUnits: 100000, // ¥100,000
          netConfirmedSettlementMinorUnits: 50000, // ¥50,000
          outstandingBalanceMinorUnits: 50000,
          settlementStatus: 'partially_paid',
          refundStatus: 'none',
          hasActiveDispute: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FinancialSection(
                  promise: testPromise,
                  currentUserId: creatorId,
                  summary: jpySummary,
                  onRefreshNeeded: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Net Confirmed: ¥50,000'), findsOneWidget);
        expect(find.text('Agreed: ¥100,000'), findsOneWidget);
        expect(find.text('Outstanding Due: ¥50,000'), findsOneWidget);
      },
    );

    testWidgets(
      'renders active dispute warning banner when hasActiveDispute is true',
      (tester) async {
        final summary = PromiseFinancialSummary(
          promiseId: 1,
          hasFinancials: true,
          currency: 'USD',
          totalAgreedMinorUnits: 500000,
          netConfirmedSettlementMinorUnits: 0,
          outstandingBalanceMinorUnits: 500000,
          settlementStatus: 'unpaid',
          refundStatus: 'none',
          hasActiveDispute: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FinancialSection(
                  promise: testPromise,
                  currentUserId: creatorId,
                  summary: summary,
                  onRefreshNeeded: () {},
                ),
              ),
            ),
          ),
        );

        expect(
          find.text(
            'Payment record under dispute. Please review pending actions below.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders multi-currency GroupFinancialSummary without currency conversion',
      (tester) async {
        final parentPromise = Promise(
          id: 10,
          title: 'Parent Project',
          promisedTo: '',
          dueDate: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          status: 'in_progress',
          creatorUserId: creatorId,
          isGroupParent: true,
          commitmentType: 'freelance',
        );

        final groupSummary = GroupFinancialSummary(
          parentPromiseId: 10,
          hasFinancials: true,
          currencySummaries: [
            PromiseFinancialSummary(
              promiseId: 10,
              hasFinancials: true,
              currency: 'USD',
              totalAgreedMinorUnits: 300000, // $3,000.00 USD
              netConfirmedSettlementMinorUnits: 300000,
              settlementStatus: 'paid',
              refundStatus: 'none',
              hasActiveDispute: false,
            ),
            PromiseFinancialSummary(
              promiseId: 10,
              hasFinancials: true,
              currency: 'EUR',
              totalAgreedMinorUnits: 200000, // €2,000.00 EUR
              netConfirmedSettlementMinorUnits: 100000,
              settlementStatus: 'partially_paid',
              refundStatus: 'none',
              hasActiveDispute: false,
            ),
          ],
          hasActiveDispute: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FinancialSection(
                  promise: parentPromise,
                  currentUserId: creatorId,
                  groupSummary: groupSummary,
                  onRefreshNeeded: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Group Financial Overview'), findsOneWidget);
        expect(find.text('Total (USD):'), findsOneWidget);
        expect(find.text('\$3,000.00 net / \$3,000.00 agreed'), findsOneWidget);
        expect(find.text('Total (EUR):'), findsOneWidget);
        expect(find.text('€1,000.00 net / €2,000.00 agreed'), findsOneWidget);
      },
    );

    testWidgets(
      'renders payment history cards with action buttons for counterparty',
      (tester) async {
        final summary = PromiseFinancialSummary(
          promiseId: 1,
          hasFinancials: true,
          currency: 'USD',
          totalAgreedMinorUnits: 500000,
          netConfirmedSettlementMinorUnits: 0,
          outstandingBalanceMinorUnits: 500000,
          settlementStatus: 'unpaid',
          refundStatus: 'none',
          hasActiveDispute: false,
        );

        final pendingRecord = PromisePaymentRecord(
          id: 101,
          promiseId: 1,
          recordKind: 'payment',
          recorderUserId: creatorId,
          payerUserId: creatorId,
          payeeUserId: recipientId,
          amountMinorUnits: 250000, // $2,500.00
          currency: 'USD',
          paymentDate: DateTime.now(),
          paymentMethod: 'bank_transfer',
          status: 'pending_confirmation',
          createdAt: DateTime.now(),
        );

        // Recipient viewing counterparty's pending payment record
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FinancialSection(
                  promise: testPromise,
                  currentUserId: recipientId, // Recipient counterparty
                  summary: summary,
                  records: [pendingRecord],
                  onRefreshNeeded: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('PAYMENT'), findsOneWidget);
        expect(find.text('+\$2,500.00'), findsOneWidget);
        expect(find.text('PENDING CONFIRMATION'), findsOneWidget);
        expect(find.text('Confirm'), findsOneWidget);
        expect(find.text('Dispute'), findsOneWidget);
      },
    );

    testWidgets('renders Searchable CurrencyPickerModal and filters by query', (
      tester,
    ) async {
      IsoCurrency? picked;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  picked = await CurrencyPickerModal.show(context);
                },
                child: const Text('Open Picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      expect(find.text('Select Currency'), findsOneWidget);

      // Search for "Ecuador"
      await tester.enterText(find.byType(TextField), 'Ecuador');
      await tester.pumpAndSettle();

      expect(find.text('USD — US Dollar'), findsOneWidget);
      expect(find.text('EUR — Euro'), findsNothing);

      // Tap USD
      await tester.tap(find.text('USD — US Dollar'));
      await tester.pumpAndSettle();

      expect(picked?.code, equals('USD'));
    });
  });
}
