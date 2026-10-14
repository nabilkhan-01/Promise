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
import 'package:promise_server/src/generated/protocol.dart' as _ip5xp6i8;
import 'package:serverpod/serverpod.dart' as _is;
import '../promises/promise_financial_summary.dart' as _is4xf278;

abstract class GroupFinancialSummary
    implements _is.SerializableModel, _is.ProtocolSerialization {
  GroupFinancialSummary._({
    required this.parentPromiseId,
    required this.hasFinancials,
    required this.currencySummaries,
    required this.hasActiveDispute,
  });

  factory GroupFinancialSummary({
    required int parentPromiseId,
    required bool hasFinancials,
    required List<_is4xf278.PromiseFinancialSummary> currencySummaries,
    required bool hasActiveDispute,
  }) = _GroupFinancialSummaryImpl;

  factory GroupFinancialSummary.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return GroupFinancialSummary(
      parentPromiseId: jsonSerialization['parentPromiseId'] as int,
      hasFinancials: _is.BoolJsonExtension.fromJson(
        jsonSerialization['hasFinancials'],
      ),
      currencySummaries: _ip5xp6i8.Protocol()
          .deserialize<List<_is4xf278.PromiseFinancialSummary>>(
            jsonSerialization['currencySummaries'],
          ),
      hasActiveDispute: _is.BoolJsonExtension.fromJson(
        jsonSerialization['hasActiveDispute'],
      ),
    );
  }

  int parentPromiseId;

  bool hasFinancials;

  List<_is4xf278.PromiseFinancialSummary> currencySummaries;

  bool hasActiveDispute;

  /// Returns a shallow copy of this [GroupFinancialSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GroupFinancialSummary copyWith({
    int? parentPromiseId,
    bool? hasFinancials,
    List<_is4xf278.PromiseFinancialSummary>? currencySummaries,
    bool? hasActiveDispute,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GroupFinancialSummary',
      'parentPromiseId': parentPromiseId,
      'hasFinancials': hasFinancials,
      'currencySummaries': currencySummaries.toJson(
        valueToJson: (v) => v.toJson(),
      ),
      'hasActiveDispute': hasActiveDispute,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GroupFinancialSummary',
      'parentPromiseId': parentPromiseId,
      'hasFinancials': hasFinancials,
      'currencySummaries': currencySummaries.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'hasActiveDispute': hasActiveDispute,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _GroupFinancialSummaryImpl extends GroupFinancialSummary {
  _GroupFinancialSummaryImpl({
    required int parentPromiseId,
    required bool hasFinancials,
    required List<_is4xf278.PromiseFinancialSummary> currencySummaries,
    required bool hasActiveDispute,
  }) : super._(
         parentPromiseId: parentPromiseId,
         hasFinancials: hasFinancials,
         currencySummaries: currencySummaries,
         hasActiveDispute: hasActiveDispute,
       );

  /// Returns a shallow copy of this [GroupFinancialSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  GroupFinancialSummary copyWith({
    int? parentPromiseId,
    bool? hasFinancials,
    List<_is4xf278.PromiseFinancialSummary>? currencySummaries,
    bool? hasActiveDispute,
  }) {
    return GroupFinancialSummary(
      parentPromiseId: parentPromiseId ?? this.parentPromiseId,
      hasFinancials: hasFinancials ?? this.hasFinancials,
      currencySummaries:
          currencySummaries ??
          this.currencySummaries.map((e0) => e0.copyWith()).toList(),
      hasActiveDispute: hasActiveDispute ?? this.hasActiveDispute,
    );
  }
}
