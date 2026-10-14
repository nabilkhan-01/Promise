import 'dart:math';

import 'package:promise_currency/promise_currency.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../generated/protocol.dart';
import '../generated/serverpod.dart';
import '../notifications/notification_helper.dart';

/// Serverpod endpoint for Stage 3 Financial RPC operations,
/// enforcing exact minor-unit arithmetic, two-party confirmation state machine,
/// immutable confirmed history, refund ceiling limits, PostgreSQL row locking,
/// and sibling financial isolation.
class FinancialEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  String _getAuthUserId(Session session) {
    final authUserId = session.authenticated?.authUserId.toString();
    if (authUserId == null) {
      throw ArgumentError('Authentication required.');
    }
    return authUserId;
  }

  Future<String> _getUserDisplayName(Session session) async {
    UserProfileModel? userProfile;
    try {
      userProfile = await session.authenticated?.userProfile(session);
    } catch (_) {}
    if (userProfile == null) return 'User';
    final name = userProfile.userName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = userProfile.email?.trim();
    if (email != null && email.isNotEmpty) return email;
    return 'User';
  }

  Future<String> _getUserEmail(Session session) async {
    UserProfileModel? userProfile;
    try {
      userProfile = await session.authenticated?.userProfile(session);
    } catch (_) {}
    return userProfile?.email?.trim().toLowerCase() ?? '';
  }

  bool _isDirectParticipant(
    Promise promise,
    String authUserId,
    String userEmail,
  ) {
    final isCreator = promise.creatorUserId == authUserId;
    final isRecipient =
        promise.recipientUserId == authUserId ||
        (!promise.isGroupParent &&
            promise.recipientUserId == null &&
            userEmail.isNotEmpty &&
            promise.promisedTo.trim().toLowerCase() == userEmail);
    return isCreator || isRecipient;
  }

  Future<Promise> _loadAuthorizedPromise(
    Session session,
    int promiseId, {
    bool allowGroupParent = false,
  }) async {
    final authUserId = _getAuthUserId(session);
    final userEmail = await _getUserEmail(session);

    final promise = await Promise.db.findById(session, promiseId);
    if (promise == null) {
      throw ArgumentError('Promise not found.');
    }

    if (promise.isGroupParent && !allowGroupParent) {
      throw ArgumentError(
        'Group parent promises cannot have standalone financial obligations. Financial terms attach to individual child milestones.',
      );
    }

    if (!_isDirectParticipant(promise, authUserId, userEmail)) {
      throw ArgumentError(
        'Access denied: You are not a direct participant of this commitment.',
      );
    }

    return promise;
  }

  /// Row-level locking helper for PostgreSQL transactions
  Future<void> _acquirePaymentRecordLock(
    Session session,
    Transaction tx,
    int paymentRecordId,
  ) async {
    await session.db.unsafeQuery(
      'SELECT id FROM promise_payment_record WHERE id = \$1 FOR UPDATE',
      parameters: QueryParameters.positional([paymentRecordId]),
      transaction: tx,
    );
  }

  /// Calculates a single-currency PromiseFinancialSummary DTO for a 1-on-1 promise or child milestone.
  Future<PromiseFinancialSummary> _calculatePromiseFinancialSummary(
    Session session,
    Promise promise,
  ) async {
    final terms = await PromiseFinancialTerms.db.findFirstRow(
      session,
      where: (t) => t.promiseId.equals(promise.id!),
    );

    if (terms == null) {
      return PromiseFinancialSummary(
        promiseId: promise.id!,
        hasFinancials: false,
        settlementStatus: 'none',
        refundStatus: 'none',
        hasActiveDispute: false,
      );
    }

    final records = await PromisePaymentRecord.db.find(
      session,
      where: (t) => t.promiseId.equals(promise.id!),
    );

    final schedules = await PromisePaymentSchedule.db.find(
      session,
      where: (t) => t.promiseId.equals(promise.id!),
    );

    int totalScheduledMinorUnits = 0;
    for (var s in schedules) {
      if (s.cancelledAt == null) {
        totalScheduledMinorUnits += s.amountMinorUnits;
      }
    }

    int totalConfirmedPaymentMinorUnits = 0;
    int totalConfirmedRefundMinorUnits = 0;
    bool hasActiveDispute = false;

    for (var r in records) {
      if (r.status == 'disputed') {
        hasActiveDispute = true;
      }

      if (r.status == 'confirmed') {
        if (r.recordKind == 'payment') {
          totalConfirmedPaymentMinorUnits += r.amountMinorUnits;
        } else if (r.recordKind == 'refund') {
          totalConfirmedRefundMinorUnits += r.amountMinorUnits;
        }
      }
    }

    final netConfirmedSettlementMinorUnits =
        totalConfirmedPaymentMinorUnits - totalConfirmedRefundMinorUnits;

    final outstandingBalanceMinorUnits = max(
      0,
      terms.totalAmountMinorUnits - netConfirmedSettlementMinorUnits,
    );

    String settlementStatus;
    if (netConfirmedSettlementMinorUnits == 0) {
      settlementStatus = 'unpaid';
    } else if (netConfirmedSettlementMinorUnits < terms.totalAmountMinorUnits) {
      settlementStatus = 'partially_paid';
    } else if (netConfirmedSettlementMinorUnits ==
        terms.totalAmountMinorUnits) {
      settlementStatus = 'paid';
    } else {
      settlementStatus = 'overpaid';
    }

    String refundStatus;
    if (totalConfirmedRefundMinorUnits == 0) {
      refundStatus = 'none';
    } else if (totalConfirmedRefundMinorUnits <
        totalConfirmedPaymentMinorUnits) {
      refundStatus = 'partially_refunded';
    } else {
      refundStatus = 'fully_refunded';
    }

    return PromiseFinancialSummary(
      promiseId: promise.id!,
      hasFinancials: true,
      currency: terms.currency,
      totalAgreedMinorUnits: terms.totalAmountMinorUnits,
      totalScheduledMinorUnits: totalScheduledMinorUnits,
      totalConfirmedPaymentMinorUnits: totalConfirmedPaymentMinorUnits,
      totalConfirmedRefundMinorUnits: totalConfirmedRefundMinorUnits,
      netConfirmedSettlementMinorUnits: netConfirmedSettlementMinorUnits,
      outstandingBalanceMinorUnits: outstandingBalanceMinorUnits,
      settlementStatus: settlementStatus,
      refundStatus: refundStatus,
      hasActiveDispute: hasActiveDispute,
      payerUserId: terms.payerUserId,
      payeeUserId: terms.payeeUserId,
    );
  }

  /// Returns the financial summary DTO for a 1-on-1 promise or child milestone.
  /// For a group parent promise, returns a multi-currency [GroupFinancialSummary] for the creator.
  Future<PromiseFinancialSummary> getFinancialSummary(
    Session session,
    int promiseId,
  ) async {
    final promise = await _loadAuthorizedPromise(
      session,
      promiseId,
      allowGroupParent: true,
    );

    if (promise.isGroupParent) {
      final children = await Promise.db.find(
        session,
        where: (t) => t.parentPromiseId.equals(promise.id!),
      );

      final childSummaries = <PromiseFinancialSummary>[];
      for (var child in children) {
        final childSummary = await _calculatePromiseFinancialSummary(
          session,
          child,
        );
        if (childSummary.hasFinancials) {
          childSummaries.add(childSummary);
        }
      }

      if (childSummaries.isEmpty) {
        return PromiseFinancialSummary(
          promiseId: promise.id!,
          hasFinancials: false,
          settlementStatus: 'none',
          refundStatus: 'none',
          hasActiveDispute: false,
        );
      }

      final firstSummary = childSummaries.first;
      int aggAgreed = 0;
      int aggNet = 0;
      bool hasDispute = false;

      for (var s in childSummaries) {
        if (s.currency == firstSummary.currency) {
          aggAgreed += s.totalAgreedMinorUnits ?? 0;
          aggNet += s.netConfirmedSettlementMinorUnits ?? 0;
        }
        if (s.hasActiveDispute) {
          hasDispute = true;
        }
      }

      final aggOutstanding = max(0, aggAgreed - aggNet);
      String settlementStatus;
      if (aggNet == 0) {
        settlementStatus = 'unpaid';
      } else if (aggNet < aggAgreed) {
        settlementStatus = 'partially_paid';
      } else if (aggNet == aggAgreed) {
        settlementStatus = 'paid';
      } else {
        settlementStatus = 'overpaid';
      }

      return PromiseFinancialSummary(
        promiseId: promise.id!,
        hasFinancials: true,
        currency: firstSummary.currency,
        totalAgreedMinorUnits: aggAgreed,
        netConfirmedSettlementMinorUnits: aggNet,
        outstandingBalanceMinorUnits: aggOutstanding,
        settlementStatus: settlementStatus,
        refundStatus: 'none',
        hasActiveDispute: hasDispute,
      );
    }

    return await _calculatePromiseFinancialSummary(session, promise);
  }

  /// Returns multi-currency GroupFinancialSummary DTO for a group parent project.
  Future<GroupFinancialSummary> getGroupFinancialSummary(
    Session session,
    int parentPromiseId,
  ) async {
    final parentPromise = await _loadAuthorizedPromise(
      session,
      parentPromiseId,
      allowGroupParent: true,
    );

    if (!parentPromise.isGroupParent) {
      throw ArgumentError('Promise is not a group parent container.');
    }

    final children = await Promise.db.find(
      session,
      where: (t) => t.parentPromiseId.equals(parentPromise.id!),
    );

    final childSummaries = <PromiseFinancialSummary>[];
    bool hasAnyDispute = false;

    for (var child in children) {
      final childSummary = await _calculatePromiseFinancialSummary(
        session,
        child,
      );
      if (childSummary.hasFinancials) {
        childSummaries.add(childSummary);
        if (childSummary.hasActiveDispute) {
          hasAnyDispute = true;
        }
      }
    }

    if (childSummaries.isEmpty) {
      return GroupFinancialSummary(
        parentPromiseId: parentPromise.id!,
        hasFinancials: false,
        currencySummaries: [],
        hasActiveDispute: false,
      );
    }

    final byCurrency = <String, List<PromiseFinancialSummary>>{};
    for (var s in childSummaries) {
      final curr = s.currency!;
      byCurrency.putIfAbsent(curr, () => []).add(s);
    }

    final currencySummariesList = <PromiseFinancialSummary>[];

    byCurrency.forEach((curr, list) {
      int totalAgreed = 0;
      int totalScheduled = 0;
      int totalConfirmedPayment = 0;
      int totalConfirmedRefund = 0;
      bool currDispute = false;

      for (var s in list) {
        totalAgreed += s.totalAgreedMinorUnits ?? 0;
        totalScheduled += s.totalScheduledMinorUnits ?? 0;
        totalConfirmedPayment += s.totalConfirmedPaymentMinorUnits ?? 0;
        totalConfirmedRefund += s.totalConfirmedRefundMinorUnits ?? 0;
        if (s.hasActiveDispute) {
          currDispute = true;
        }
      }

      final netSettlement = totalConfirmedPayment - totalConfirmedRefund;
      final outstanding = max(0, totalAgreed - netSettlement);

      String settlementStatus;
      if (netSettlement == 0) {
        settlementStatus = 'unpaid';
      } else if (netSettlement < totalAgreed) {
        settlementStatus = 'partially_paid';
      } else if (netSettlement == totalAgreed) {
        settlementStatus = 'paid';
      } else {
        settlementStatus = 'overpaid';
      }

      String refundStatus;
      if (totalConfirmedRefund == 0) {
        refundStatus = 'none';
      } else if (totalConfirmedRefund < totalConfirmedPayment) {
        refundStatus = 'partially_refunded';
      } else {
        refundStatus = 'fully_refunded';
      }

      currencySummariesList.add(
        PromiseFinancialSummary(
          promiseId: parentPromise.id!,
          hasFinancials: true,
          currency: curr,
          totalAgreedMinorUnits: totalAgreed,
          totalScheduledMinorUnits: totalScheduled,
          totalConfirmedPaymentMinorUnits: totalConfirmedPayment,
          totalConfirmedRefundMinorUnits: totalConfirmedRefund,
          netConfirmedSettlementMinorUnits: netSettlement,
          outstandingBalanceMinorUnits: outstanding,
          settlementStatus: settlementStatus,
          refundStatus: refundStatus,
          hasActiveDispute: currDispute,
        ),
      );
    });

    return GroupFinancialSummary(
      parentPromiseId: parentPromise.id!,
      hasFinancials: true,
      currencySummaries: currencySummariesList,
      hasActiveDispute: hasAnyDispute,
    );
  }

  /// Returns PromiseFinancialTerms for an authorized promise.
  Future<PromiseFinancialTerms?> getFinancialTerms(
    Session session,
    int promiseId,
  ) async {
    await _loadAuthorizedPromise(session, promiseId);
    return await PromiseFinancialTerms.db.findFirstRow(
      session,
      where: (t) => t.promiseId.equals(promiseId),
    );
  }

  /// Returns payment schedule installments for an authorized promise.
  Future<List<PromisePaymentSchedule>> getPaymentSchedule(
    Session session,
    int promiseId,
  ) async {
    await _loadAuthorizedPromise(session, promiseId);
    final schedules = await PromisePaymentSchedule.db.find(
      session,
      where: (t) => t.promiseId.equals(promiseId),
      orderBy: (t) => t.installmentOrder,
    );
    return schedules;
  }

  /// Returns payment and refund records for an authorized promise.
  Future<List<PromisePaymentRecord>> getPaymentRecords(
    Session session,
    int promiseId,
  ) async {
    await _loadAuthorizedPromise(session, promiseId);
    final records = await PromisePaymentRecord.db.find(
      session,
      where: (t) => t.promiseId.equals(promiseId),
      orderBy: (t) => t.createdAt.desc(),
    );
    return records;
  }

  /// Sets or updates financial terms for a promise.
  /// Throws [ArgumentError] if any payment record already exists (terms are read-only).
  Future<PromiseFinancialTerms> setFinancialTerms(
    Session session,
    int promiseId,
    int totalAmountMinorUnits,
    String currency,
    String payerUserId,
    String payeeUserId,
    String? notes,
  ) async {
    final promise = await _loadAuthorizedPromise(session, promiseId);
    final authUserId = _getAuthUserId(session);
    final creatorName = await _getUserDisplayName(session);

    if (authUserId != promise.creatorUserId) {
      throw ArgumentError(
        'Only the commitment creator can set or update financial terms.',
      );
    }

    if (!promise.recipientAccepted) {
      throw ArgumentError(
        'Cannot set financial terms on an unaccepted promise invitation.',
      );
    }

    final existingRecords = await PromisePaymentRecord.db.find(
      session,
      where: (t) => t.promiseId.equals(promiseId),
    );

    if (existingRecords.isNotEmpty) {
      throw ArgumentError(
        'Financial terms are strictly read-only once payment or refund records exist.',
      );
    }

    final validParticipants = {promise.creatorUserId, promise.recipientUserId};
    if (!validParticipants.contains(payerUserId) ||
        !validParticipants.contains(payeeUserId)) {
      throw ArgumentError(
        'Payer and Payee must be direct participants of this promise.',
      );
    }

    if (payerUserId == payeeUserId) {
      throw ArgumentError('Payer and Payee cannot be the same user.');
    }

    if (totalAmountMinorUnits <= 0) {
      throw ArgumentError('Total amount must be greater than zero.');
    }

    final isoCurrency = CurrencyUtils.validateCurrencyCode(currency);

    final existingTerms = await PromiseFinancialTerms.db.findFirstRow(
      session,
      where: (t) => t.promiseId.equals(promiseId),
    );

    final now = DateTime.now().toUtc();

    return await session.db.transaction((tx) async {
      PromiseFinancialTerms terms;
      if (existingTerms == null) {
        terms = await PromiseFinancialTerms.db.insertRow(
          session,
          PromiseFinancialTerms(
            promiseId: promiseId,
            totalAmountMinorUnits: totalAmountMinorUnits,
            currency: isoCurrency.code,
            payerUserId: payerUserId,
            payeeUserId: payeeUserId,
            notes: notes?.trim(),
            createdAt: now,
          ),
          transaction: tx,
        );
      } else {
        terms = await PromiseFinancialTerms.db.updateRow(
          session,
          existingTerms.copyWith(
            totalAmountMinorUnits: totalAmountMinorUnits,
            currency: isoCurrency.code,
            payerUserId: payerUserId,
            payeeUserId: payeeUserId,
            notes: notes?.trim(),
            updatedAt: now,
          ),
          transaction: tx,
        );
      }

      await PromiseActivity.db.insertRow(
        session,
        PromiseActivity(
          promiseId: promiseId,
          type: 'financial_terms_set',
          message:
              'Financial terms set by $creatorName: ${CurrencyUtils.formatMinorUnits(totalAmountMinorUnits, isoCurrency)} ${isoCurrency.code}',
          status: promise.status,
          createdAt: now,
        ),
        transaction: tx,
      );

      final counterpartyId = authUserId == promise.creatorUserId
          ? promise.recipientUserId!
          : promise.creatorUserId!;

      await NotificationHelper.createNotification(
        session,
        userId: counterpartyId,
        type: 'promise_updated',
        title: 'Financial Terms Configured',
        message:
            '$creatorName configured financial terms on "${promise.title}".',
        promiseId: promiseId,
        transaction: tx,
      );

      return terms;
    });
  }

  /// Sets payment schedule installments for a promise.
  Future<List<PromisePaymentSchedule>> setPaymentSchedule(
    Session session,
    int promiseId,
    List<PromisePaymentSchedule> installments,
  ) async {
    final promise = await _loadAuthorizedPromise(session, promiseId);
    final authUserId = _getAuthUserId(session);
    final creatorName = await _getUserDisplayName(session);

    if (authUserId != promise.creatorUserId) {
      throw ArgumentError(
        'Only the commitment creator can configure payment schedules.',
      );
    }

    final terms = await PromiseFinancialTerms.db.findFirstRow(
      session,
      where: (t) => t.promiseId.equals(promiseId),
    );

    if (terms == null) {
      throw ArgumentError(
        'Set financial terms before creating a payment schedule.',
      );
    }

    if (installments.isEmpty) {
      throw ArgumentError('Schedule must contain at least one installment.');
    }

    final seenOrders = <int>{};
    for (var inst in installments) {
      if (inst.amountMinorUnits <= 0) {
        throw ArgumentError('Installment amounts must be greater than zero.');
      }
      if (inst.currency != terms.currency) {
        throw ArgumentError(
          'Installment currency (${inst.currency}) must match terms currency (${terms.currency}).',
        );
      }
      if (seenOrders.contains(inst.installmentOrder)) {
        throw ArgumentError(
          'Duplicate installment order (${inst.installmentOrder}) is not allowed.',
        );
      }
      seenOrders.add(inst.installmentOrder);
    }

    final now = DateTime.now().toUtc();

    return await session.db.transaction((tx) async {
      await PromisePaymentSchedule.db.deleteWhere(
        session,
        where: (t) => t.promiseId.equals(promiseId),
        transaction: tx,
      );

      final insertedSchedules = <PromisePaymentSchedule>[];
      for (var inst in installments) {
        final inserted = await PromisePaymentSchedule.db.insertRow(
          session,
          inst.copyWith(
            promiseId: promiseId,
            currency: terms.currency,
            createdAt: now,
          ),
          transaction: tx,
        );
        insertedSchedules.add(inserted);
      }

      await PromiseActivity.db.insertRow(
        session,
        PromiseActivity(
          promiseId: promiseId,
          type: 'schedule_configured',
          message:
              'Payment schedule configured with ${insertedSchedules.length} installments by $creatorName.',
          status: promise.status,
          createdAt: now,
        ),
        transaction: tx,
      );

      final counterpartyId = authUserId == promise.creatorUserId
          ? promise.recipientUserId!
          : promise.creatorUserId!;

      await NotificationHelper.createNotification(
        session,
        userId: counterpartyId,
        type: 'promise_updated',
        title: 'Payment Schedule Configured',
        message:
            '$creatorName configured a payment schedule for "${promise.title}".',
        promiseId: promiseId,
        transaction: tx,
      );

      return insertedSchedules;
    });
  }

  /// Cancels an unpaid schedule installment.
  Future<PromisePaymentSchedule> cancelPaymentScheduleInstallment(
    Session session,
    int scheduleId,
    String? cancellationReason,
  ) async {
    final authUserId = _getAuthUserId(session);
    final cancellerName = await _getUserDisplayName(session);

    final schedule = await PromisePaymentSchedule.db.findById(
      session,
      scheduleId,
    );
    if (schedule == null) {
      throw ArgumentError('Payment schedule installment not found.');
    }

    final promise = await _loadAuthorizedPromise(session, schedule.promiseId);
    final now = DateTime.now().toUtc();

    return await session.db.transaction((tx) async {
      final updated = await PromisePaymentSchedule.db.updateRow(
        session,
        schedule.copyWith(
          cancelledAt: now,
          cancelledByUserId: authUserId,
          cancellationReason: cancellationReason?.trim(),
          updatedAt: now,
        ),
        transaction: tx,
      );

      await PromiseActivity.db.insertRow(
        session,
        PromiseActivity(
          promiseId: promise.id!,
          type: 'installment_cancelled',
          message:
              'Payment installment #${schedule.installmentOrder} cancelled by $cancellerName.',
          status: promise.status,
          createdAt: now,
        ),
        transaction: tx,
      );

      return updated;
    });
  }

  /// Records an offline payment entry (`recordKind: 'payment'`).
  Future<PromisePaymentRecord> recordPayment(
    Session session,
    int promiseId,
    int? scheduleId,
    int amountMinorUnits,
    DateTime paymentDate,
    String paymentMethod,
    String? externalReference,
    String? notes,
    int? attachmentId,
  ) async {
    final promise = await _loadAuthorizedPromise(session, promiseId);
    final authUserId = _getAuthUserId(session);
    final recorderName = await _getUserDisplayName(session);

    if (!promise.recipientAccepted) {
      throw ArgumentError(
        'Cannot record payments on an unaccepted promise invitation.',
      );
    }

    final terms = await PromiseFinancialTerms.db.findFirstRow(
      session,
      where: (t) => t.promiseId.equals(promiseId),
    );

    if (terms == null) {
      throw ArgumentError('Set financial terms before recording payments.');
    }

    if (amountMinorUnits <= 0) {
      throw ArgumentError('Payment amount must be greater than zero.');
    }

    if (amountMinorUnits > CurrencyUtils.maxPerRecordMinorUnits) {
      throw ArgumentError(
        'Payment amount exceeds maximum permitted per-record limit.',
      );
    }

    if (scheduleId != null) {
      final schedule = await PromisePaymentSchedule.db.findById(
        session,
        scheduleId,
      );
      if (schedule == null || schedule.promiseId != promiseId) {
        throw ArgumentError(
          'Invalid scheduleId: Installment does not belong to this promise.',
        );
      }
      if (schedule.cancelledAt != null) {
        throw ArgumentError(
          'Cannot record payment against a cancelled schedule installment.',
        );
      }
    }

    if (attachmentId != null) {
      final attachment = await PromiseAttachment.db.findById(
        session,
        attachmentId,
      );
      if (attachment == null || attachment.promiseId != promiseId) {
        throw ArgumentError(
          'Invalid attachmentId: Attachment does not belong to this promise.',
        );
      }
      if (attachment.uploaderUserId != authUserId) {
        throw ArgumentError('You can only attach evidence you uploaded.');
      }
    }

    final isoCurrency = CurrencyUtils.validateCurrencyCode(terms.currency);
    final now = DateTime.now().toUtc();

    return await session.db.transaction((tx) async {
      final record = await PromisePaymentRecord.db.insertRow(
        session,
        PromisePaymentRecord(
          promiseId: promiseId,
          scheduleId: scheduleId,
          recordKind: 'payment',
          recorderUserId: authUserId,
          payerUserId: terms.payerUserId,
          payeeUserId: terms.payeeUserId,
          amountMinorUnits: amountMinorUnits,
          currency: terms.currency,
          paymentDate: paymentDate.toUtc(),
          paymentMethod: paymentMethod.trim().toLowerCase(),
          externalReference: externalReference?.trim(),
          notes: notes?.trim(),
          attachmentId: attachmentId,
          status: 'pending_confirmation',
          createdAt: now,
        ),
        transaction: tx,
      );

      final formattedAmount = CurrencyUtils.formatMinorUnits(
        amountMinorUnits,
        isoCurrency,
      );

      await PromiseActivity.db.insertRow(
        session,
        PromiseActivity(
          promiseId: promiseId,
          type: 'payment_recorded',
          message:
              'Payment of $formattedAmount recorded by $recorderName (Pending counterparty confirmation)',
          status: promise.status,
          createdAt: now,
        ),
        transaction: tx,
      );

      final counterpartyId = authUserId == promise.creatorUserId
          ? promise.recipientUserId!
          : promise.creatorUserId!;

      await NotificationHelper.createNotification(
        session,
        userId: counterpartyId,
        type: 'promise_updated',
        title: 'Payment Recorded',
        message:
            '$recorderName recorded a payment of $formattedAmount on "${promise.title}". Tap to review.',
        promiseId: promiseId,
        transaction: tx,
      );

      return record;
    });
  }

  /// Records an offline refund entry (`recordKind: 'refund'`) reversing an original confirmed payment.
  Future<PromisePaymentRecord> recordRefund(
    Session session,
    int promiseId,
    int originalPaymentRecordId,
    int amountMinorUnits,
    DateTime refundDate,
    String paymentMethod,
    String? externalReference,
    String? notes,
    int? attachmentId,
  ) async {
    final promise = await _loadAuthorizedPromise(session, promiseId);
    final authUserId = _getAuthUserId(session);
    final recorderName = await _getUserDisplayName(session);

    final originalPayment = await PromisePaymentRecord.db.findById(
      session,
      originalPaymentRecordId,
    );

    if (originalPayment == null || originalPayment.promiseId != promiseId) {
      throw ArgumentError(
        'Original payment record not found for this promise.',
      );
    }

    if (originalPayment.recordKind != 'payment' ||
        originalPayment.status != 'confirmed') {
      throw ArgumentError(
        'Refunds can only be recorded against confirmed original payment records.',
      );
    }

    if (amountMinorUnits <= 0) {
      throw ArgumentError('Refund amount must be greater than zero.');
    }

    if (attachmentId != null) {
      final attachment = await PromiseAttachment.db.findById(
        session,
        attachmentId,
      );
      if (attachment == null || attachment.promiseId != promiseId) {
        throw ArgumentError(
          'Invalid attachmentId: Attachment does not belong to this promise.',
        );
      }
      if (attachment.uploaderUserId != authUserId) {
        throw ArgumentError('You can only attach evidence you uploaded.');
      }
    }

    final isoCurrency = CurrencyUtils.validateCurrencyCode(
      originalPayment.currency,
    );
    final now = DateTime.now().toUtc();

    return await session.db.transaction((tx) async {
      await _acquirePaymentRecordLock(session, tx, originalPaymentRecordId);

      final existingRefunds = await PromisePaymentRecord.db.find(
        session,
        where: (t) =>
            t.reversesPaymentRecordId.equals(originalPaymentRecordId) &
            t.recordKind.equals('refund') &
            t.status.equals('confirmed'),
        transaction: tx,
      );

      int totalConfirmedRefunds = 0;
      for (var r in existingRefunds) {
        totalConfirmedRefunds += r.amountMinorUnits;
      }

      if (totalConfirmedRefunds + amountMinorUnits >
          originalPayment.amountMinorUnits) {
        throw ArgumentError(
          'Refund amount exceeds the original payment\'s remaining refundable balance.',
        );
      }

      final record = await PromisePaymentRecord.db.insertRow(
        session,
        PromisePaymentRecord(
          promiseId: promiseId,
          scheduleId: originalPayment.scheduleId,
          recordKind: 'refund',
          reversesPaymentRecordId: originalPaymentRecordId,
          recorderUserId: authUserId,
          payerUserId: originalPayment.payerUserId,
          payeeUserId: originalPayment.payeeUserId,
          amountMinorUnits: amountMinorUnits,
          currency: originalPayment.currency,
          paymentDate: refundDate.toUtc(),
          paymentMethod: paymentMethod.trim().toLowerCase(),
          externalReference: externalReference?.trim(),
          notes: notes?.trim(),
          attachmentId: attachmentId,
          status: 'pending_confirmation',
          createdAt: now,
        ),
        transaction: tx,
      );

      final formattedAmount = CurrencyUtils.formatMinorUnits(
        amountMinorUnits,
        isoCurrency,
      );

      await PromiseActivity.db.insertRow(
        session,
        PromiseActivity(
          promiseId: promiseId,
          type: 'refund_recorded',
          message:
              'Refund of $formattedAmount recorded by $recorderName (Pending counterparty confirmation)',
          status: promise.status,
          createdAt: now,
        ),
        transaction: tx,
      );

      final counterpartyId = authUserId == promise.creatorUserId
          ? promise.recipientUserId!
          : promise.creatorUserId!;

      await NotificationHelper.createNotification(
        session,
        userId: counterpartyId,
        type: 'promise_updated',
        title: 'Refund Recorded',
        message:
            '$recorderName recorded a refund of $formattedAmount on "${promise.title}". Tap to review.',
        promiseId: promiseId,
        transaction: tx,
      );

      return record;
    });
  }

  /// Unified confirmation RPC for pending payment or refund records (`status == 'pending_confirmation'`).
  Future<PromisePaymentRecord> confirmPaymentRecord(
    Session session,
    int paymentRecordId,
  ) async {
    final authUserId = _getAuthUserId(session);
    final confirmerName = await _getUserDisplayName(session);

    final record = await PromisePaymentRecord.db.findById(
      session,
      paymentRecordId,
    );
    if (record == null) {
      throw ArgumentError('Payment/refund record not found.');
    }

    if (record.status == 'confirmed') {
      throw ArgumentError(
        'Confirmed financial records are permanently immutable and cannot be re-confirmed.',
      );
    }

    if (record.status != 'pending_confirmation') {
      throw ArgumentError(
        'Only pending records can be confirmed. Current status: ${record.status}',
      );
    }

    final promise = await _loadAuthorizedPromise(session, record.promiseId);

    if (authUserId == record.recorderUserId) {
      throw ArgumentError(
        'Recorder cannot confirm their own payment or refund.',
      );
    }

    final isoCurrency = CurrencyUtils.validateCurrencyCode(record.currency);
    final now = DateTime.now().toUtc();

    return await session.db.transaction((tx) async {
      if (record.recordKind == 'refund' &&
          record.reversesPaymentRecordId != null) {
        await _acquirePaymentRecordLock(
          session,
          tx,
          record.reversesPaymentRecordId!,
        );

        final originalPayment = await PromisePaymentRecord.db.findById(
          session,
          record.reversesPaymentRecordId!,
          transaction: tx,
        );

        if (originalPayment == null) {
          throw ArgumentError('Original payment record unavailable.');
        }

        final existingConfirmedRefunds = await PromisePaymentRecord.db.find(
          session,
          where: (t) =>
              t.reversesPaymentRecordId.equals(
                record.reversesPaymentRecordId!,
              ) &
              t.recordKind.equals('refund') &
              t.status.equals('confirmed'),
          transaction: tx,
        );

        int totalConfirmed = 0;
        for (var r in existingConfirmedRefunds) {
          totalConfirmed += r.amountMinorUnits;
        }

        if (totalConfirmed + record.amountMinorUnits >
            originalPayment.amountMinorUnits) {
          throw ArgumentError(
            'Refund amount exceeds the remaining refundable balance.',
          );
        }
      }

      final updatedRecord = await PromisePaymentRecord.db.updateRow(
        session,
        record.copyWith(
          status: 'confirmed',
          confirmedAt: now,
          confirmerUserId: authUserId,
          updatedAt: now,
        ),
        transaction: tx,
      );

      final formattedAmount = CurrencyUtils.formatMinorUnits(
        record.amountMinorUnits,
        isoCurrency,
      );

      final activityType = record.recordKind == 'payment'
          ? 'payment_confirmed'
          : 'refund_confirmed';
      final activityMsg = record.recordKind == 'payment'
          ? 'Payment of $formattedAmount confirmed by $confirmerName.'
          : 'Refund of $formattedAmount confirmed by $confirmerName.';

      await PromiseActivity.db.insertRow(
        session,
        PromiseActivity(
          promiseId: promise.id!,
          type: activityType,
          message: activityMsg,
          status: promise.status,
          createdAt: now,
        ),
        transaction: tx,
      );

      await NotificationHelper.createNotification(
        session,
        userId: record.recorderUserId,
        type: 'promise_updated',
        title: record.recordKind == 'payment'
            ? 'Payment Confirmed'
            : 'Refund Confirmed',
        message:
            '$confirmerName confirmed your recorded ${record.recordKind} of $formattedAmount on "${promise.title}".',
        promiseId: promise.id!,
        transaction: tx,
      );

      return updatedRecord;
    });
  }

  /// Unified dispute RPC for pending payment or refund records (`status == 'pending_confirmation'`).
  Future<PromisePaymentRecord> disputePaymentRecord(
    Session session,
    int paymentRecordId,
    String reason,
  ) async {
    final authUserId = _getAuthUserId(session);
    final disputerName = await _getUserDisplayName(session);

    if (reason.trim().isEmpty) {
      throw ArgumentError('Dispute reason cannot be empty.');
    }

    final record = await PromisePaymentRecord.db.findById(
      session,
      paymentRecordId,
    );
    if (record == null) {
      throw ArgumentError('Payment/refund record not found.');
    }

    if (record.status == 'confirmed') {
      throw ArgumentError(
        'Confirmed financial records are permanently immutable and cannot be directly disputed.',
      );
    }

    if (record.status != 'pending_confirmation') {
      throw ArgumentError(
        'Only pending records can be disputed. Current status: ${record.status}',
      );
    }

    final promise = await _loadAuthorizedPromise(session, record.promiseId);

    if (authUserId == record.recorderUserId) {
      throw ArgumentError(
        'Recorder cannot dispute their own payment or refund.',
      );
    }

    final isoCurrency = CurrencyUtils.validateCurrencyCode(record.currency);
    final now = DateTime.now().toUtc();

    return await session.db.transaction((tx) async {
      final updatedRecord = await PromisePaymentRecord.db.updateRow(
        session,
        record.copyWith(
          status: 'disputed',
          disputedAt: now,
          disputerUserId: authUserId,
          disputeReason: reason.trim(),
          updatedAt: now,
        ),
        transaction: tx,
      );

      final formattedAmount = CurrencyUtils.formatMinorUnits(
        record.amountMinorUnits,
        isoCurrency,
      );

      await PromiseActivity.db.insertRow(
        session,
        PromiseActivity(
          promiseId: promise.id!,
          type: 'payment_disputed',
          message:
              'Recorded ${record.recordKind} of $formattedAmount disputed by $disputerName: "${reason.trim()}"',
          status: promise.status,
          createdAt: now,
        ),
        transaction: tx,
      );

      await NotificationHelper.createNotification(
        session,
        userId: record.recorderUserId,
        type: 'promise_updated',
        title: 'Payment Disputed',
        message:
            '$disputerName disputed your recorded ${record.recordKind} of $formattedAmount on "${promise.title}". Reason: "${reason.trim()}".',
        promiseId: promise.id!,
        transaction: tx,
      );

      return updatedRecord;
    });
  }

  /// Unified cancellation RPC for pending payment or refund records (`status == 'pending_confirmation'`).
  Future<PromisePaymentRecord> cancelPaymentRecord(
    Session session,
    int paymentRecordId,
    String? cancellationReason,
  ) async {
    final authUserId = _getAuthUserId(session);
    final cancellerName = await _getUserDisplayName(session);

    final record = await PromisePaymentRecord.db.findById(
      session,
      paymentRecordId,
    );
    if (record == null) {
      throw ArgumentError('Payment/refund record not found.');
    }

    if (record.status == 'confirmed') {
      throw ArgumentError('Confirmed financial records cannot be cancelled.');
    }

    if (record.status != 'pending_confirmation' &&
        record.status != 'disputed') {
      throw ArgumentError('Record is not in a cancellable state.');
    }

    final promise = await _loadAuthorizedPromise(session, record.promiseId);

    if (authUserId != record.recorderUserId) {
      throw ArgumentError(
        'Only the recorder can cancel a pending payment or refund record.',
      );
    }

    final isoCurrency = CurrencyUtils.validateCurrencyCode(record.currency);
    final now = DateTime.now().toUtc();

    return await session.db.transaction((tx) async {
      final updatedRecord = await PromisePaymentRecord.db.updateRow(
        session,
        record.copyWith(
          status: 'cancelled',
          cancelledAt: now,
          cancellerUserId: authUserId,
          cancellationReason: cancellationReason?.trim(),
          updatedAt: now,
        ),
        transaction: tx,
      );

      final formattedAmount = CurrencyUtils.formatMinorUnits(
        record.amountMinorUnits,
        isoCurrency,
      );

      await PromiseActivity.db.insertRow(
        session,
        PromiseActivity(
          promiseId: promise.id!,
          type: 'payment_cancelled',
          message:
              'Recorded ${record.recordKind} of $formattedAmount cancelled by $cancellerName.',
          status: promise.status,
          createdAt: now,
        ),
        transaction: tx,
      );

      return updatedRecord;
    });
  }
}
