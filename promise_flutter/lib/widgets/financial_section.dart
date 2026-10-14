import 'package:flutter/material.dart';
import 'package:promise_client/promise_client.dart';
import 'package:promise_currency/promise_currency.dart';

import '../client.dart';
import 'financial_dialogs.dart';

/// Main mobile-first Financial Section widget embedded on [PromiseDetailsScreen].
class FinancialSection extends StatefulWidget {
  final Promise promise;
  final String currentUserId;
  final PromiseFinancialSummary? summary;
  final GroupFinancialSummary? groupSummary;
  final PromiseFinancialTerms? terms;
  final List<PromisePaymentSchedule> schedules;
  final List<PromisePaymentRecord> records;
  final VoidCallback onRefreshNeeded;

  const FinancialSection({
    super.key,
    required this.promise,
    required this.currentUserId,
    this.summary,
    this.groupSummary,
    this.terms,
    this.schedules = const [],
    this.records = const [],
    required this.onRefreshNeeded,
  });

  @override
  State<FinancialSection> createState() => _FinancialSectionState();
}

class _FinancialSectionState extends State<FinancialSection> {
  bool _isActionLoading = false;

  bool get _isCreator => widget.promise.creatorUserId == widget.currentUserId;

  Future<void> _confirmRecord(PromisePaymentRecord record) async {
    setState(() => _isActionLoading = true);
    try {
      await client.financial.confirmPaymentRecord(record.id!);
      widget.onRefreshNeeded();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _disputeRecord(PromisePaymentRecord record) async {
    final success = await DisputeRecordDialog.show(
      context,
      paymentRecordId: record.id!,
    );
    if (success == true) {
      widget.onRefreshNeeded();
    }
  }

  Future<void> _cancelRecord(PromisePaymentRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Payment Record?'),
        content: const Text(
          'Are you sure you want to cancel this pending payment entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isActionLoading = true);
      try {
        await client.financial.cancelPaymentRecord(
          record.id!,
          'Cancelled by recorder',
        );
        widget.onRefreshNeeded();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isActionLoading = false);
      }
    }
  }

  Widget _buildStatusBadge(String status, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettlementBadge(String status) {
    switch (status) {
      case 'paid':
        return _buildStatusBadge(status, Colors.green, 'PAID IN FULL');
      case 'partially_paid':
        return _buildStatusBadge(status, Colors.blue, 'PARTIALLY PAID');
      case 'overpaid':
        return _buildStatusBadge(status, Colors.purple, 'OVERPAID');
      case 'unpaid':
      default:
        return _buildStatusBadge(status, Colors.orange, 'UNPAID');
    }
  }

  Widget _buildRefundBadge(String status) {
    if (status == 'fully_refunded') {
      return _buildStatusBadge(status, Colors.deepOrange, 'FULLY REFUNDED');
    } else if (status == 'partially_refunded') {
      return _buildStatusBadge(
        status,
        Colors.amber.shade900,
        'PARTIALLY REFUNDED',
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildGroupSummaryCard(ThemeData theme) {
    final group = widget.groupSummary!;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Group Financial Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!group.hasFinancials || group.currencySummaries.isEmpty)
              Text(
                'No financial terms configured on child milestones.',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              )
            else
              ...group.currencySummaries.map((s) {
                final curr =
                    IsoCurrencyCatalogue.findByCode(s.currency) ??
                    IsoCurrencyCatalogue.findByCode('USD')!;
                final agreedStr = CurrencyUtils.formatMinorUnits(
                  s.totalAgreedMinorUnits ?? 0,
                  curr,
                );
                final netStr = CurrencyUtils.formatMinorUnits(
                  s.netConfirmedSettlementMinorUnits ?? 0,
                  curr,
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total (${s.currency}):',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '$netStr net / $agreedStr agreed',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.promise.isGroupParent) {
      if (widget.groupSummary == null) return const SizedBox.shrink();
      return _buildGroupSummaryCard(theme);
    }

    final summary = widget.summary;
    final hasFinancials = summary?.hasFinancials ?? false;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Financials & Payments',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (hasFinancials) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildSettlementBadge(summary!.settlementStatus),
                      if (summary.refundStatus != 'none')
                        _buildRefundBadge(summary.refundStatus),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            if (!hasFinancials) ...[
              Text(
                'No financial terms configured for this commitment.',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              if (_isCreator) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final refresh = await SetFinancialTermsDialog.show(
                      context,
                      promiseId: widget.promise.id!,
                      creatorUserId: widget.promise.creatorUserId!,
                      recipientUserId: widget.promise.recipientUserId!,
                      initialTerms: widget.terms,
                    );
                    if (refresh == true) widget.onRefreshNeeded();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Configure Financial Terms'),
                ),
              ],
            ] else ...[
              // Configured Financial Overview
              if (summary!.hasActiveDispute) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Payment record under dispute. Please review pending actions below.',
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Amounts & Progress
              Builder(
                builder: (context) {
                  final curr =
                      IsoCurrencyCatalogue.findByCode(summary.currency) ??
                      IsoCurrencyCatalogue.findByCode('USD')!;
                  final agreedStr = CurrencyUtils.formatMinorUnits(
                    summary.totalAgreedMinorUnits ?? 0,
                    curr,
                  );
                  final netStr = CurrencyUtils.formatMinorUnits(
                    summary.netConfirmedSettlementMinorUnits ?? 0,
                    curr,
                  );
                  final dueStr = CurrencyUtils.formatMinorUnits(
                    summary.outstandingBalanceMinorUnits ?? 0,
                    curr,
                  );

                  final progressRatio = (summary.totalAgreedMinorUnits ?? 0) > 0
                      ? ((summary.netConfirmedSettlementMinorUnits ?? 0) /
                                (summary.totalAgreedMinorUnits!))
                            .clamp(0.0, 1.0)
                      : 0.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            'Net Confirmed: $netStr',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Agreed: $agreedStr',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          minHeight: 8,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Outstanding Due: $dueStr',
                        style: TextStyle(
                          color: (summary.outstandingBalanceMinorUnits ?? 0) > 0
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Actions
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      final refresh = await RecordPaymentDialog.show(
                        context,
                        promiseId: widget.promise.id!,
                        currency: summary.currency ?? 'USD',
                        schedules: widget.schedules,
                      );
                      if (refresh == true) widget.onRefreshNeeded();
                    },
                    icon: const Icon(Icons.add_card),
                    label: const Text('Record Payment'),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Installment Schedule Section
              if (widget.schedules.isNotEmpty) ...[
                Text(
                  'Payment Schedule',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.schedules.map((s) {
                  final curr =
                      IsoCurrencyCatalogue.findByCode(s.currency) ??
                      IsoCurrencyCatalogue.findByCode('USD')!;
                  final amountStr = CurrencyUtils.formatMinorUnits(
                    s.amountMinorUnits,
                    curr,
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#${s.installmentOrder} — $amountStr',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          s.cancelledAt != null
                              ? 'Cancelled'
                              : 'Due ${s.dueDate.day}/${s.dueDate.month}/${s.dueDate.year}',
                          style: TextStyle(
                            color: s.cancelledAt != null
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],

              // Payment Records History
              Text(
                'Payment History',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.records.isEmpty)
                Text(
                  'No payment records logged yet.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                )
              else
                ...widget.records.map((r) {
                  final curr =
                      IsoCurrencyCatalogue.findByCode(r.currency) ??
                      IsoCurrencyCatalogue.findByCode('USD')!;
                  final amountStr = CurrencyUtils.formatMinorUnits(
                    r.amountMinorUnits,
                    curr,
                  );
                  final isRefund = r.recordKind == 'refund';
                  final isPending = r.status == 'pending_confirmation';
                  final isConfirmed = r.status == 'confirmed';
                  final isDisputed = r.status == 'disputed';

                  final canConfirmDispute =
                      isPending && r.recorderUserId != widget.currentUserId;
                  final canCancel =
                      isPending && r.recorderUserId == widget.currentUserId;
                  final canRefund =
                      isConfirmed &&
                      !isRefund &&
                      r.recorderUserId != widget.currentUserId;

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isRefund
                                      ? Colors.amber.withValues(alpha: 0.2)
                                      : Colors.green.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isRefund ? 'REFUND' : 'PAYMENT',
                                  style: TextStyle(
                                    color: isRefund
                                        ? Colors.amber.shade900
                                        : Colors.green.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Text(
                                '${isRefund ? '-' : '+'}$amountStr',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              _buildStatusBadge(
                                r.status,
                                isConfirmed
                                    ? Colors.green
                                    : isDisputed
                                    ? Colors.red
                                    : Colors.orange,
                                r.status.replaceAll('_', ' ').toUpperCase(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Method: ${r.paymentMethod.replaceAll('_', ' ').toUpperCase()}${r.externalReference != null ? ' (Ref: ${r.externalReference})' : ''}',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          if (r.disputeReason != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Dispute Reason: ${r.disputeReason}',
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (canConfirmDispute || canCancel || canRefund) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.end,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (canConfirmDispute) ...[
                                  OutlinedButton(
                                    onPressed: _isActionLoading
                                        ? null
                                        : () => _disputeRecord(r),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: theme.colorScheme.error,
                                    ),
                                    child: const Text('Dispute'),
                                  ),
                                  FilledButton(
                                    onPressed: _isActionLoading
                                        ? null
                                        : () => _confirmRecord(r),
                                    child: const Text('Confirm'),
                                  ),
                                ],
                                if (canCancel) ...[
                                  OutlinedButton(
                                    onPressed: _isActionLoading
                                        ? null
                                        : () => _cancelRecord(r),
                                    child: const Text('Cancel Entry'),
                                  ),
                                ],
                                if (canRefund) ...[
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final refresh =
                                          await RecordPaymentDialog.show(
                                            context,
                                            promiseId: widget.promise.id!,
                                            currency: r.currency,
                                            recordKind: 'refund',
                                            originalPaymentRecordId: r.id!,
                                          );
                                      if (refresh == true) {
                                        widget.onRefreshNeeded();
                                      }
                                    },
                                    icon: const Icon(Icons.undo, size: 16),
                                    label: const Text('Record Refund'),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }
}
