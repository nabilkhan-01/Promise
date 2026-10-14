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

abstract class PromisePaymentSchedule
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PromisePaymentSchedule._({
    this.id,
    required this.promiseId,
    required this.installmentOrder,
    required this.amountMinorUnits,
    required this.currency,
    required this.dueDate,
    this.cancelledAt,
    this.cancelledByUserId,
    this.cancellationReason,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory PromisePaymentSchedule({
    int? id,
    required int promiseId,
    required int installmentOrder,
    required int amountMinorUnits,
    required String currency,
    required DateTime dueDate,
    DateTime? cancelledAt,
    String? cancelledByUserId,
    String? cancellationReason,
    String? notes,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _PromisePaymentScheduleImpl;

  factory PromisePaymentSchedule.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return PromisePaymentSchedule(
      id: jsonSerialization['id'] as int?,
      promiseId: jsonSerialization['promiseId'] as int,
      installmentOrder: jsonSerialization['installmentOrder'] as int,
      amountMinorUnits: jsonSerialization['amountMinorUnits'] as int,
      currency: jsonSerialization['currency'] as String,
      dueDate: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['dueDate'],
      ),
      cancelledAt: jsonSerialization['cancelledAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['cancelledAt'],
            ),
      cancelledByUserId: jsonSerialization['cancelledByUserId'] as String?,
      cancellationReason: jsonSerialization['cancellationReason'] as String?,
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

  int installmentOrder;

  int amountMinorUnits;

  String currency;

  DateTime dueDate;

  DateTime? cancelledAt;

  String? cancelledByUserId;

  String? cancellationReason;

  String? notes;

  DateTime createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [PromisePaymentSchedule]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PromisePaymentSchedule copyWith({
    int? id,
    int? promiseId,
    int? installmentOrder,
    int? amountMinorUnits,
    String? currency,
    DateTime? dueDate,
    DateTime? cancelledAt,
    String? cancelledByUserId,
    String? cancellationReason,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PromisePaymentSchedule',
      if (id != null) 'id': id,
      'promiseId': promiseId,
      'installmentOrder': installmentOrder,
      'amountMinorUnits': amountMinorUnits,
      'currency': currency,
      'dueDate': dueDate.toJson(),
      if (cancelledAt != null) 'cancelledAt': cancelledAt?.toJson(),
      if (cancelledByUserId != null) 'cancelledByUserId': cancelledByUserId,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PromisePaymentSchedule',
      if (id != null) 'id': id,
      'promiseId': promiseId,
      'installmentOrder': installmentOrder,
      'amountMinorUnits': amountMinorUnits,
      'currency': currency,
      'dueDate': dueDate.toJson(),
      if (cancelledAt != null) 'cancelledAt': cancelledAt?.toJson(),
      if (cancelledByUserId != null) 'cancelledByUserId': cancelledByUserId,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
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

class _PromisePaymentScheduleImpl extends PromisePaymentSchedule {
  _PromisePaymentScheduleImpl({
    int? id,
    required int promiseId,
    required int installmentOrder,
    required int amountMinorUnits,
    required String currency,
    required DateTime dueDate,
    DateTime? cancelledAt,
    String? cancelledByUserId,
    String? cancellationReason,
    String? notes,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         promiseId: promiseId,
         installmentOrder: installmentOrder,
         amountMinorUnits: amountMinorUnits,
         currency: currency,
         dueDate: dueDate,
         cancelledAt: cancelledAt,
         cancelledByUserId: cancelledByUserId,
         cancellationReason: cancellationReason,
         notes: notes,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PromisePaymentSchedule]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PromisePaymentSchedule copyWith({
    Object? id = _Undefined,
    int? promiseId,
    int? installmentOrder,
    int? amountMinorUnits,
    String? currency,
    DateTime? dueDate,
    Object? cancelledAt = _Undefined,
    Object? cancelledByUserId = _Undefined,
    Object? cancellationReason = _Undefined,
    Object? notes = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return PromisePaymentSchedule(
      id: id is int? ? id : this.id,
      promiseId: promiseId ?? this.promiseId,
      installmentOrder: installmentOrder ?? this.installmentOrder,
      amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
      currency: currency ?? this.currency,
      dueDate: dueDate ?? this.dueDate,
      cancelledAt: cancelledAt is DateTime? ? cancelledAt : this.cancelledAt,
      cancelledByUserId: cancelledByUserId is String?
          ? cancelledByUserId
          : this.cancelledByUserId,
      cancellationReason: cancellationReason is String?
          ? cancellationReason
          : this.cancellationReason,
      notes: notes is String? ? notes : this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
