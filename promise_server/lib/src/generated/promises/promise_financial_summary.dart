/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

abstract class PromiseFinancialSummary
    implements _is.SerializableModel, _is.ProtocolSerialization {
  PromiseFinancialSummary._({
    required this.promiseId,
    required this.hasFinancials,
    this.currency,
    this.totalAgreedMinorUnits,
    this.totalScheduledMinorUnits,
    this.totalConfirmedPaymentMinorUnits,
    this.totalConfirmedRefundMinorUnits,
    this.netConfirmedSettlementMinorUnits,
    this.outstandingBalanceMinorUnits,
    required this.settlementStatus,
    required this.refundStatus,
    required this.hasActiveDispute,
    this.payerUserId,
    this.payeeUserId,
  });

  factory PromiseFinancialSummary({
    required int promiseId,
    required bool hasFinancials,
    String? currency,
    int? totalAgreedMinorUnits,
    int? totalScheduledMinorUnits,
    int? totalConfirmedPaymentMinorUnits,
    int? totalConfirmedRefundMinorUnits,
    int? netConfirmedSettlementMinorUnits,
    int? outstandingBalanceMinorUnits,
    required String settlementStatus,
    required String refundStatus,
    required bool hasActiveDispute,
    String? payerUserId,
    String? payeeUserId,
  }) = _PromiseFinancialSummaryImpl;

  factory PromiseFinancialSummary.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return PromiseFinancialSummary(
      promiseId: jsonSerialization['promiseId'] as int,
      hasFinancials: _is.BoolJsonExtension.fromJson(
        jsonSerialization['hasFinancials'],
      ),
      currency: jsonSerialization['currency'] as String?,
      totalAgreedMinorUnits: jsonSerialization['totalAgreedMinorUnits'] as int?,
      totalScheduledMinorUnits:
          jsonSerialization['totalScheduledMinorUnits'] as int?,
      totalConfirmedPaymentMinorUnits:
          jsonSerialization['totalConfirmedPaymentMinorUnits'] as int?,
      totalConfirmedRefundMinorUnits:
          jsonSerialization['totalConfirmedRefundMinorUnits'] as int?,
      netConfirmedSettlementMinorUnits:
          jsonSerialization['netConfirmedSettlementMinorUnits'] as int?,
      outstandingBalanceMinorUnits:
          jsonSerialization['outstandingBalanceMinorUnits'] as int?,
      settlementStatus: jsonSerialization['settlementStatus'] as String,
      refundStatus: jsonSerialization['refundStatus'] as String,
      hasActiveDispute: _is.BoolJsonExtension.fromJson(
        jsonSerialization['hasActiveDispute'],
      ),
      payerUserId: jsonSerialization['payerUserId'] as String?,
      payeeUserId: jsonSerialization['payeeUserId'] as String?,
    );
  }

  int promiseId;

  bool hasFinancials;

  String? currency;

  int? totalAgreedMinorUnits;

  int? totalScheduledMinorUnits;

  int? totalConfirmedPaymentMinorUnits;

  int? totalConfirmedRefundMinorUnits;

  int? netConfirmedSettlementMinorUnits;

  int? outstandingBalanceMinorUnits;

  String settlementStatus;

  String refundStatus;

  bool hasActiveDispute;

  String? payerUserId;

  String? payeeUserId;

  /// Returns a shallow copy of this [PromiseFinancialSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PromiseFinancialSummary copyWith({
    int? promiseId,
    bool? hasFinancials,
    String? currency,
    int? totalAgreedMinorUnits,
    int? totalScheduledMinorUnits,
    int? totalConfirmedPaymentMinorUnits,
    int? totalConfirmedRefundMinorUnits,
    int? netConfirmedSettlementMinorUnits,
    int? outstandingBalanceMinorUnits,
    String? settlementStatus,
    String? refundStatus,
    bool? hasActiveDispute,
    String? payerUserId,
    String? payeeUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PromiseFinancialSummary',
      'promiseId': promiseId,
      'hasFinancials': hasFinancials,
      if (currency != null) 'currency': currency,
      if (totalAgreedMinorUnits != null)
        'totalAgreedMinorUnits': totalAgreedMinorUnits,
      if (totalScheduledMinorUnits != null)
        'totalScheduledMinorUnits': totalScheduledMinorUnits,
      if (totalConfirmedPaymentMinorUnits != null)
        'totalConfirmedPaymentMinorUnits': totalConfirmedPaymentMinorUnits,
      if (totalConfirmedRefundMinorUnits != null)
        'totalConfirmedRefundMinorUnits': totalConfirmedRefundMinorUnits,
      if (netConfirmedSettlementMinorUnits != null)
        'netConfirmedSettlementMinorUnits': netConfirmedSettlementMinorUnits,
      if (outstandingBalanceMinorUnits != null)
        'outstandingBalanceMinorUnits': outstandingBalanceMinorUnits,
      'settlementStatus': settlementStatus,
      'refundStatus': refundStatus,
      'hasActiveDispute': hasActiveDispute,
      if (payerUserId != null) 'payerUserId': payerUserId,
      if (payeeUserId != null) 'payeeUserId': payeeUserId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PromiseFinancialSummary',
      'promiseId': promiseId,
      'hasFinancials': hasFinancials,
      if (currency != null) 'currency': currency,
      if (totalAgreedMinorUnits != null)
        'totalAgreedMinorUnits': totalAgreedMinorUnits,
      if (totalScheduledMinorUnits != null)
        'totalScheduledMinorUnits': totalScheduledMinorUnits,
      if (totalConfirmedPaymentMinorUnits != null)
        'totalConfirmedPaymentMinorUnits': totalConfirmedPaymentMinorUnits,
      if (totalConfirmedRefundMinorUnits != null)
        'totalConfirmedRefundMinorUnits': totalConfirmedRefundMinorUnits,
      if (netConfirmedSettlementMinorUnits != null)
        'netConfirmedSettlementMinorUnits': netConfirmedSettlementMinorUnits,
      if (outstandingBalanceMinorUnits != null)
        'outstandingBalanceMinorUnits': outstandingBalanceMinorUnits,
      'settlementStatus': settlementStatus,
      'refundStatus': refundStatus,
      'hasActiveDispute': hasActiveDispute,
      if (payerUserId != null) 'payerUserId': payerUserId,
      if (payeeUserId != null) 'payeeUserId': payeeUserId,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PromiseFinancialSummaryImpl extends PromiseFinancialSummary {
  _PromiseFinancialSummaryImpl({
    required int promiseId,
    required bool hasFinancials,
    String? currency,
    int? totalAgreedMinorUnits,
    int? totalScheduledMinorUnits,
    int? totalConfirmedPaymentMinorUnits,
    int? totalConfirmedRefundMinorUnits,
    int? netConfirmedSettlementMinorUnits,
    int? outstandingBalanceMinorUnits,
    required String settlementStatus,
    required String refundStatus,
    required bool hasActiveDispute,
    String? payerUserId,
    String? payeeUserId,
  }) : super._(
         promiseId: promiseId,
         hasFinancials: hasFinancials,
         currency: currency,
         totalAgreedMinorUnits: totalAgreedMinorUnits,
         totalScheduledMinorUnits: totalScheduledMinorUnits,
         totalConfirmedPaymentMinorUnits: totalConfirmedPaymentMinorUnits,
         totalConfirmedRefundMinorUnits: totalConfirmedRefundMinorUnits,
         netConfirmedSettlementMinorUnits: netConfirmedSettlementMinorUnits,
         outstandingBalanceMinorUnits: outstandingBalanceMinorUnits,
         settlementStatus: settlementStatus,
         refundStatus: refundStatus,
         hasActiveDispute: hasActiveDispute,
         payerUserId: payerUserId,
         payeeUserId: payeeUserId,
       );

  /// Returns a shallow copy of this [PromiseFinancialSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PromiseFinancialSummary copyWith({
    int? promiseId,
    bool? hasFinancials,
    Object? currency = _Undefined,
    Object? totalAgreedMinorUnits = _Undefined,
    Object? totalScheduledMinorUnits = _Undefined,
    Object? totalConfirmedPaymentMinorUnits = _Undefined,
    Object? totalConfirmedRefundMinorUnits = _Undefined,
    Object? netConfirmedSettlementMinorUnits = _Undefined,
    Object? outstandingBalanceMinorUnits = _Undefined,
    String? settlementStatus,
    String? refundStatus,
    bool? hasActiveDispute,
    Object? payerUserId = _Undefined,
    Object? payeeUserId = _Undefined,
  }) {
    return PromiseFinancialSummary(
      promiseId: promiseId ?? this.promiseId,
      hasFinancials: hasFinancials ?? this.hasFinancials,
      currency: currency is String? ? currency : this.currency,
      totalAgreedMinorUnits: totalAgreedMinorUnits is int?
          ? totalAgreedMinorUnits
          : this.totalAgreedMinorUnits,
      totalScheduledMinorUnits: totalScheduledMinorUnits is int?
          ? totalScheduledMinorUnits
          : this.totalScheduledMinorUnits,
      totalConfirmedPaymentMinorUnits: totalConfirmedPaymentMinorUnits is int?
          ? totalConfirmedPaymentMinorUnits
          : this.totalConfirmedPaymentMinorUnits,
      totalConfirmedRefundMinorUnits: totalConfirmedRefundMinorUnits is int?
          ? totalConfirmedRefundMinorUnits
          : this.totalConfirmedRefundMinorUnits,
      netConfirmedSettlementMinorUnits: netConfirmedSettlementMinorUnits is int?
          ? netConfirmedSettlementMinorUnits
          : this.netConfirmedSettlementMinorUnits,
      outstandingBalanceMinorUnits: outstandingBalanceMinorUnits is int?
          ? outstandingBalanceMinorUnits
          : this.outstandingBalanceMinorUnits,
      settlementStatus: settlementStatus ?? this.settlementStatus,
      refundStatus: refundStatus ?? this.refundStatus,
      hasActiveDispute: hasActiveDispute ?? this.hasActiveDispute,
      payerUserId: payerUserId is String? ? payerUserId : this.payerUserId,
      payeeUserId: payeeUserId is String? ? payeeUserId : this.payeeUserId,
    );
  }
}
