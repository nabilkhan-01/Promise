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

abstract class PromisePaymentRecord
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PromisePaymentRecord._({
    this.id,
    required this.promiseId,
    this.scheduleId,
    required this.recordKind,
    this.reversesPaymentRecordId,
    required this.recorderUserId,
    required this.payerUserId,
    required this.payeeUserId,
    required this.amountMinorUnits,
    required this.currency,
    required this.paymentDate,
    required this.paymentMethod,
    this.externalReference,
    this.notes,
    this.attachmentId,
    String? status,
    this.confirmedAt,
    this.confirmerUserId,
    this.disputedAt,
    this.disputerUserId,
    this.disputeReason,
    this.cancelledAt,
    this.cancellerUserId,
    this.cancellationReason,
    required this.createdAt,
    this.updatedAt,
  }) : status = status ?? 'pending_confirmation';

  factory PromisePaymentRecord({
    int? id,
    required int promiseId,
    int? scheduleId,
    required String recordKind,
    int? reversesPaymentRecordId,
    required String recorderUserId,
    required String payerUserId,
    required String payeeUserId,
    required int amountMinorUnits,
    required String currency,
    required DateTime paymentDate,
    required String paymentMethod,
    String? externalReference,
    String? notes,
    int? attachmentId,
    String? status,
    DateTime? confirmedAt,
    String? confirmerUserId,
    DateTime? disputedAt,
    String? disputerUserId,
    String? disputeReason,
    DateTime? cancelledAt,
    String? cancellerUserId,
    String? cancellationReason,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _PromisePaymentRecordImpl;

  factory PromisePaymentRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return PromisePaymentRecord(
      id: jsonSerialization['id'] as int?,
      promiseId: jsonSerialization['promiseId'] as int,
      scheduleId: jsonSerialization['scheduleId'] as int?,
      recordKind: jsonSerialization['recordKind'] as String,
      reversesPaymentRecordId:
          jsonSerialization['reversesPaymentRecordId'] as int?,
      recorderUserId: jsonSerialization['recorderUserId'] as String,
      payerUserId: jsonSerialization['payerUserId'] as String,
      payeeUserId: jsonSerialization['payeeUserId'] as String,
      amountMinorUnits: jsonSerialization['amountMinorUnits'] as int,
      currency: jsonSerialization['currency'] as String,
      paymentDate: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['paymentDate'],
      ),
      paymentMethod: jsonSerialization['paymentMethod'] as String,
      externalReference: jsonSerialization['externalReference'] as String?,
      notes: jsonSerialization['notes'] as String?,
      attachmentId: jsonSerialization['attachmentId'] as int?,
      status: jsonSerialization['status'] as String?,
      confirmedAt: jsonSerialization['confirmedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['confirmedAt'],
            ),
      confirmerUserId: jsonSerialization['confirmerUserId'] as String?,
      disputedAt: jsonSerialization['disputedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['disputedAt'],
            ),
      disputerUserId: jsonSerialization['disputerUserId'] as String?,
      disputeReason: jsonSerialization['disputeReason'] as String?,
      cancelledAt: jsonSerialization['cancelledAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['cancelledAt'],
            ),
      cancellerUserId: jsonSerialization['cancellerUserId'] as String?,
      cancellationReason: jsonSerialization['cancellationReason'] as String?,
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

  int? scheduleId;

  String recordKind;

  int? reversesPaymentRecordId;

  String recorderUserId;

  String payerUserId;

  String payeeUserId;

  int amountMinorUnits;

  String currency;

  DateTime paymentDate;

  String paymentMethod;

  String? externalReference;

  String? notes;

  int? attachmentId;

  String status;

  DateTime? confirmedAt;

  String? confirmerUserId;

  DateTime? disputedAt;

  String? disputerUserId;

  String? disputeReason;

  DateTime? cancelledAt;

  String? cancellerUserId;

  String? cancellationReason;

  DateTime createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [PromisePaymentRecord]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PromisePaymentRecord copyWith({
    int? id,
    int? promiseId,
    int? scheduleId,
    String? recordKind,
    int? reversesPaymentRecordId,
    String? recorderUserId,
    String? payerUserId,
    String? payeeUserId,
    int? amountMinorUnits,
    String? currency,
    DateTime? paymentDate,
    String? paymentMethod,
    String? externalReference,
    String? notes,
    int? attachmentId,
    String? status,
    DateTime? confirmedAt,
    String? confirmerUserId,
    DateTime? disputedAt,
    String? disputerUserId,
    String? disputeReason,
    DateTime? cancelledAt,
    String? cancellerUserId,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PromisePaymentRecord',
      if (id != null) 'id': id,
      'promiseId': promiseId,
      if (scheduleId != null) 'scheduleId': scheduleId,
      'recordKind': recordKind,
      if (reversesPaymentRecordId != null)
        'reversesPaymentRecordId': reversesPaymentRecordId,
      'recorderUserId': recorderUserId,
      'payerUserId': payerUserId,
      'payeeUserId': payeeUserId,
      'amountMinorUnits': amountMinorUnits,
      'currency': currency,
      'paymentDate': paymentDate.toJson(),
      'paymentMethod': paymentMethod,
      if (externalReference != null) 'externalReference': externalReference,
      if (notes != null) 'notes': notes,
      if (attachmentId != null) 'attachmentId': attachmentId,
      'status': status,
      if (confirmedAt != null) 'confirmedAt': confirmedAt?.toJson(),
      if (confirmerUserId != null) 'confirmerUserId': confirmerUserId,
      if (disputedAt != null) 'disputedAt': disputedAt?.toJson(),
      if (disputerUserId != null) 'disputerUserId': disputerUserId,
      if (disputeReason != null) 'disputeReason': disputeReason,
      if (cancelledAt != null) 'cancelledAt': cancelledAt?.toJson(),
      if (cancellerUserId != null) 'cancellerUserId': cancellerUserId,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PromisePaymentRecord',
      if (id != null) 'id': id,
      'promiseId': promiseId,
      if (scheduleId != null) 'scheduleId': scheduleId,
      'recordKind': recordKind,
      if (reversesPaymentRecordId != null)
        'reversesPaymentRecordId': reversesPaymentRecordId,
      'recorderUserId': recorderUserId,
      'payerUserId': payerUserId,
      'payeeUserId': payeeUserId,
      'amountMinorUnits': amountMinorUnits,
      'currency': currency,
      'paymentDate': paymentDate.toJson(),
      'paymentMethod': paymentMethod,
      if (externalReference != null) 'externalReference': externalReference,
      if (notes != null) 'notes': notes,
      if (attachmentId != null) 'attachmentId': attachmentId,
      'status': status,
      if (confirmedAt != null) 'confirmedAt': confirmedAt?.toJson(),
      if (confirmerUserId != null) 'confirmerUserId': confirmerUserId,
      if (disputedAt != null) 'disputedAt': disputedAt?.toJson(),
      if (disputerUserId != null) 'disputerUserId': disputerUserId,
      if (disputeReason != null) 'disputeReason': disputeReason,
      if (cancelledAt != null) 'cancelledAt': cancelledAt?.toJson(),
      if (cancellerUserId != null) 'cancellerUserId': cancellerUserId,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
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

class _PromisePaymentRecordImpl extends PromisePaymentRecord {
  _PromisePaymentRecordImpl({
    int? id,
    required int promiseId,
    int? scheduleId,
    required String recordKind,
    int? reversesPaymentRecordId,
    required String recorderUserId,
    required String payerUserId,
    required String payeeUserId,
    required int amountMinorUnits,
    required String currency,
    required DateTime paymentDate,
    required String paymentMethod,
    String? externalReference,
    String? notes,
    int? attachmentId,
    String? status,
    DateTime? confirmedAt,
    String? confirmerUserId,
    DateTime? disputedAt,
    String? disputerUserId,
    String? disputeReason,
    DateTime? cancelledAt,
    String? cancellerUserId,
    String? cancellationReason,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         promiseId: promiseId,
         scheduleId: scheduleId,
         recordKind: recordKind,
         reversesPaymentRecordId: reversesPaymentRecordId,
         recorderUserId: recorderUserId,
         payerUserId: payerUserId,
         payeeUserId: payeeUserId,
         amountMinorUnits: amountMinorUnits,
         currency: currency,
         paymentDate: paymentDate,
         paymentMethod: paymentMethod,
         externalReference: externalReference,
         notes: notes,
         attachmentId: attachmentId,
         status: status,
         confirmedAt: confirmedAt,
         confirmerUserId: confirmerUserId,
         disputedAt: disputedAt,
         disputerUserId: disputerUserId,
         disputeReason: disputeReason,
         cancelledAt: cancelledAt,
         cancellerUserId: cancellerUserId,
         cancellationReason: cancellationReason,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PromisePaymentRecord]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PromisePaymentRecord copyWith({
    Object? id = _Undefined,
    int? promiseId,
    Object? scheduleId = _Undefined,
    String? recordKind,
    Object? reversesPaymentRecordId = _Undefined,
    String? recorderUserId,
    String? payerUserId,
    String? payeeUserId,
    int? amountMinorUnits,
    String? currency,
    DateTime? paymentDate,
    String? paymentMethod,
    Object? externalReference = _Undefined,
    Object? notes = _Undefined,
    Object? attachmentId = _Undefined,
    String? status,
    Object? confirmedAt = _Undefined,
    Object? confirmerUserId = _Undefined,
    Object? disputedAt = _Undefined,
    Object? disputerUserId = _Undefined,
    Object? disputeReason = _Undefined,
    Object? cancelledAt = _Undefined,
    Object? cancellerUserId = _Undefined,
    Object? cancellationReason = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return PromisePaymentRecord(
      id: id is int? ? id : this.id,
      promiseId: promiseId ?? this.promiseId,
      scheduleId: scheduleId is int? ? scheduleId : this.scheduleId,
      recordKind: recordKind ?? this.recordKind,
      reversesPaymentRecordId: reversesPaymentRecordId is int?
          ? reversesPaymentRecordId
          : this.reversesPaymentRecordId,
      recorderUserId: recorderUserId ?? this.recorderUserId,
      payerUserId: payerUserId ?? this.payerUserId,
      payeeUserId: payeeUserId ?? this.payeeUserId,
      amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
      currency: currency ?? this.currency,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      externalReference: externalReference is String?
          ? externalReference
          : this.externalReference,
      notes: notes is String? ? notes : this.notes,
      attachmentId: attachmentId is int? ? attachmentId : this.attachmentId,
      status: status ?? this.status,
      confirmedAt: confirmedAt is DateTime? ? confirmedAt : this.confirmedAt,
      confirmerUserId: confirmerUserId is String?
          ? confirmerUserId
          : this.confirmerUserId,
      disputedAt: disputedAt is DateTime? ? disputedAt : this.disputedAt,
      disputerUserId: disputerUserId is String?
          ? disputerUserId
          : this.disputerUserId,
      disputeReason: disputeReason is String?
          ? disputeReason
          : this.disputeReason,
      cancelledAt: cancelledAt is DateTime? ? cancelledAt : this.cancelledAt,
      cancellerUserId: cancellerUserId is String?
          ? cancellerUserId
          : this.cancellerUserId,
      cancellationReason: cancellationReason is String?
          ? cancellationReason
          : this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
