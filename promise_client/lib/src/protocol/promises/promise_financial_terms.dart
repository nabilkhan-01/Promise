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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class PromiseFinancialTerms
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PromiseFinancialTerms._({
    this.id,
    required this.promiseId,
    required this.totalAmountMinorUnits,
    required this.currency,
    required this.payerUserId,
    required this.payeeUserId,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory PromiseFinancialTerms({
    int? id,
    required int promiseId,
    required int totalAmountMinorUnits,
    required String currency,
    required String payerUserId,
    required String payeeUserId,
    String? notes,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _PromiseFinancialTermsImpl;

  factory PromiseFinancialTerms.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return PromiseFinancialTerms(
      id: jsonSerialization['id'] as int?,
      promiseId: jsonSerialization['promiseId'] as int,
      totalAmountMinorUnits: jsonSerialization['totalAmountMinorUnits'] as int,
      currency: jsonSerialization['currency'] as String,
      payerUserId: jsonSerialization['payerUserId'] as String,
      payeeUserId: jsonSerialization['payeeUserId'] as String,
      notes: jsonSerialization['notes'] as String?,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int promiseId;

  int totalAmountMinorUnits;

  String currency;

  String payerUserId;

  String payeeUserId;

  String? notes;

  DateTime createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [PromiseFinancialTerms]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PromiseFinancialTerms copyWith({
    int? id,
    int? promiseId,
    int? totalAmountMinorUnits,
    String? currency,
    String? payerUserId,
    String? payeeUserId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PromiseFinancialTerms',
      if (id != null) 'id': id,
      'promiseId': promiseId,
      'totalAmountMinorUnits': totalAmountMinorUnits,
      'currency': currency,
      'payerUserId': payerUserId,
      'payeeUserId': payeeUserId,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PromiseFinancialTerms',
      if (id != null) 'id': id,
      'promiseId': promiseId,
      'totalAmountMinorUnits': totalAmountMinorUnits,
      'currency': currency,
      'payerUserId': payerUserId,
      'payeeUserId': payeeUserId,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PromiseFinancialTermsImpl extends PromiseFinancialTerms {
  _PromiseFinancialTermsImpl({
    int? id,
    required int promiseId,
    required int totalAmountMinorUnits,
    required String currency,
    required String payerUserId,
    required String payeeUserId,
    String? notes,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         promiseId: promiseId,
         totalAmountMinorUnits: totalAmountMinorUnits,
         currency: currency,
         payerUserId: payerUserId,
         payeeUserId: payeeUserId,
         notes: notes,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PromiseFinancialTerms]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PromiseFinancialTerms copyWith({
    Object? id = _Undefined,
    int? promiseId,
    int? totalAmountMinorUnits,
    String? currency,
    String? payerUserId,
    String? payeeUserId,
    Object? notes = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return PromiseFinancialTerms(
      id: id is int? ? id : this.id,
      promiseId: promiseId ?? this.promiseId,
      totalAmountMinorUnits:
          totalAmountMinorUnits ?? this.totalAmountMinorUnits,
      currency: currency ?? this.currency,
      payerUserId: payerUserId ?? this.payerUserId,
      payeeUserId: payeeUserId ?? this.payeeUserId,
      notes: notes is String? ? notes : this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
