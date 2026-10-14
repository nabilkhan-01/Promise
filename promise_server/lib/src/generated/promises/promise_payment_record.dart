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

abstract class PromisePaymentRecord
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      paymentDate: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['paymentDate'],
      ),
      paymentMethod: jsonSerialization['paymentMethod'] as String,
      externalReference: jsonSerialization['externalReference'] as String?,
      notes: jsonSerialization['notes'] as String?,
      attachmentId: jsonSerialization['attachmentId'] as int?,
      status: jsonSerialization['status'] as String?,
      confirmedAt: jsonSerialization['confirmedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['confirmedAt'],
            ),
      confirmerUserId: jsonSerialization['confirmerUserId'] as String?,
      disputedAt: jsonSerialization['disputedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['disputedAt']),
      disputerUserId: jsonSerialization['disputerUserId'] as String?,
      disputeReason: jsonSerialization['disputeReason'] as String?,
      cancelledAt: jsonSerialization['cancelledAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['cancelledAt'],
            ),
      cancellerUserId: jsonSerialization['cancellerUserId'] as String?,
      cancellationReason: jsonSerialization['cancellationReason'] as String?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = PromisePaymentRecordTable();

  static const db = PromisePaymentRecordRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PromisePaymentRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static PromisePaymentRecordInclude include() {
    return PromisePaymentRecordInclude._();
  }

  static PromisePaymentRecordIncludeList includeList({
    _is.WhereExpressionBuilder<PromisePaymentRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromisePaymentRecordTable>? orderBy,
    _is.OrderByListBuilder<PromisePaymentRecordTable>? orderByList,
    PromisePaymentRecordInclude? include,
  }) {
    return PromisePaymentRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PromisePaymentRecord.t),
      orderByList: orderByList?.call(PromisePaymentRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class PromisePaymentRecordUpdateTable
    extends _is.UpdateTable<PromisePaymentRecordTable> {
  PromisePaymentRecordUpdateTable(super.table);

  _is.ColumnValue<int, int> promiseId(int value) => _is.ColumnValue(
    table.promiseId,
    value,
  );

  _is.ColumnValue<int, int> scheduleId(int? value) => _is.ColumnValue(
    table.scheduleId,
    value,
  );

  _is.ColumnValue<String, String> recordKind(String value) => _is.ColumnValue(
    table.recordKind,
    value,
  );

  _is.ColumnValue<int, int> reversesPaymentRecordId(int? value) =>
      _is.ColumnValue(
        table.reversesPaymentRecordId,
        value,
      );

  _is.ColumnValue<String, String> recorderUserId(String value) =>
      _is.ColumnValue(
        table.recorderUserId,
        value,
      );

  _is.ColumnValue<String, String> payerUserId(String value) => _is.ColumnValue(
    table.payerUserId,
    value,
  );

  _is.ColumnValue<String, String> payeeUserId(String value) => _is.ColumnValue(
    table.payeeUserId,
    value,
  );

  _is.ColumnValue<int, int> amountMinorUnits(int value) => _is.ColumnValue(
    table.amountMinorUnits,
    value,
  );

  _is.ColumnValue<String, String> currency(String value) => _is.ColumnValue(
    table.currency,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> paymentDate(DateTime value) =>
      _is.ColumnValue(
        table.paymentDate,
        value,
      );

  _is.ColumnValue<String, String> paymentMethod(String value) =>
      _is.ColumnValue(
        table.paymentMethod,
        value,
      );

  _is.ColumnValue<String, String> externalReference(String? value) =>
      _is.ColumnValue(
        table.externalReference,
        value,
      );

  _is.ColumnValue<String, String> notes(String? value) => _is.ColumnValue(
    table.notes,
    value,
  );

  _is.ColumnValue<int, int> attachmentId(int? value) => _is.ColumnValue(
    table.attachmentId,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> confirmedAt(DateTime? value) =>
      _is.ColumnValue(
        table.confirmedAt,
        value,
      );

  _is.ColumnValue<String, String> confirmerUserId(String? value) =>
      _is.ColumnValue(
        table.confirmerUserId,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> disputedAt(DateTime? value) =>
      _is.ColumnValue(
        table.disputedAt,
        value,
      );

  _is.ColumnValue<String, String> disputerUserId(String? value) =>
      _is.ColumnValue(
        table.disputerUserId,
        value,
      );

  _is.ColumnValue<String, String> disputeReason(String? value) =>
      _is.ColumnValue(
        table.disputeReason,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> cancelledAt(DateTime? value) =>
      _is.ColumnValue(
        table.cancelledAt,
        value,
      );

  _is.ColumnValue<String, String> cancellerUserId(String? value) =>
      _is.ColumnValue(
        table.cancellerUserId,
        value,
      );

  _is.ColumnValue<String, String> cancellationReason(String? value) =>
      _is.ColumnValue(
        table.cancellationReason,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime? value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class PromisePaymentRecordTable extends _is.Table<int?> {
  PromisePaymentRecordTable({super.tableRelation})
    : super(tableName: 'promise_payment_record') {
    updateTable = PromisePaymentRecordUpdateTable(this);
    promiseId = _is.ColumnInt(
      'promiseId',
      this,
    );
    scheduleId = _is.ColumnInt(
      'scheduleId',
      this,
    );
    recordKind = _is.ColumnString(
      'recordKind',
      this,
    );
    reversesPaymentRecordId = _is.ColumnInt(
      'reversesPaymentRecordId',
      this,
    );
    recorderUserId = _is.ColumnString(
      'recorderUserId',
      this,
    );
    payerUserId = _is.ColumnString(
      'payerUserId',
      this,
    );
    payeeUserId = _is.ColumnString(
      'payeeUserId',
      this,
    );
    amountMinorUnits = _is.ColumnInt(
      'amountMinorUnits',
      this,
    );
    currency = _is.ColumnString(
      'currency',
      this,
    );
    paymentDate = _is.ColumnDateTime(
      'paymentDate',
      this,
    );
    paymentMethod = _is.ColumnString(
      'paymentMethod',
      this,
    );
    externalReference = _is.ColumnString(
      'externalReference',
      this,
    );
    notes = _is.ColumnString(
      'notes',
      this,
    );
    attachmentId = _is.ColumnInt(
      'attachmentId',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    confirmedAt = _is.ColumnDateTime(
      'confirmedAt',
      this,
    );
    confirmerUserId = _is.ColumnString(
      'confirmerUserId',
      this,
    );
    disputedAt = _is.ColumnDateTime(
      'disputedAt',
      this,
    );
    disputerUserId = _is.ColumnString(
      'disputerUserId',
      this,
    );
    disputeReason = _is.ColumnString(
      'disputeReason',
      this,
    );
    cancelledAt = _is.ColumnDateTime(
      'cancelledAt',
      this,
    );
    cancellerUserId = _is.ColumnString(
      'cancellerUserId',
      this,
    );
    cancellationReason = _is.ColumnString(
      'cancellationReason',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final PromisePaymentRecordUpdateTable updateTable;

  late final _is.ColumnInt promiseId;

  late final _is.ColumnInt scheduleId;

  late final _is.ColumnString recordKind;

  late final _is.ColumnInt reversesPaymentRecordId;

  late final _is.ColumnString recorderUserId;

  late final _is.ColumnString payerUserId;

  late final _is.ColumnString payeeUserId;

  late final _is.ColumnInt amountMinorUnits;

  late final _is.ColumnString currency;

  late final _is.ColumnDateTime paymentDate;

  late final _is.ColumnString paymentMethod;

  late final _is.ColumnString externalReference;

  late final _is.ColumnString notes;

  late final _is.ColumnInt attachmentId;

  late final _is.ColumnString status;

  late final _is.ColumnDateTime confirmedAt;

  late final _is.ColumnString confirmerUserId;

  late final _is.ColumnDateTime disputedAt;

  late final _is.ColumnString disputerUserId;

  late final _is.ColumnString disputeReason;

  late final _is.ColumnDateTime cancelledAt;

  late final _is.ColumnString cancellerUserId;

  late final _is.ColumnString cancellationReason;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    promiseId,
    scheduleId,
    recordKind,
    reversesPaymentRecordId,
    recorderUserId,
    payerUserId,
    payeeUserId,
    amountMinorUnits,
    currency,
    paymentDate,
    paymentMethod,
    externalReference,
    notes,
    attachmentId,
    status,
    confirmedAt,
    confirmerUserId,
    disputedAt,
    disputerUserId,
    disputeReason,
    cancelledAt,
    cancellerUserId,
    cancellationReason,
    createdAt,
    updatedAt,
  ];
}

class PromisePaymentRecordInclude extends _is.IncludeObject {
  PromisePaymentRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PromisePaymentRecord.t;
}

class PromisePaymentRecordIncludeList extends _is.IncludeList {
  PromisePaymentRecordIncludeList._({
    _is.WhereExpressionBuilder<PromisePaymentRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PromisePaymentRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PromisePaymentRecord.t;
}

class PromisePaymentRecordRepository {
  const PromisePaymentRecordRepository._();

  /// Returns a list of [PromisePaymentRecord]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<PromisePaymentRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromisePaymentRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromisePaymentRecordTable>? orderBy,
    _is.OrderByListBuilder<PromisePaymentRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PromisePaymentRecord>(
      where: where?.call(PromisePaymentRecord.t),
      orderBy: orderBy?.call(PromisePaymentRecord.t),
      orderByList: orderByList?.call(PromisePaymentRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PromisePaymentRecord] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<PromisePaymentRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromisePaymentRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<PromisePaymentRecordTable>? orderBy,
    _is.OrderByListBuilder<PromisePaymentRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PromisePaymentRecord>(
      where: where?.call(PromisePaymentRecord.t),
      orderBy: orderBy?.call(PromisePaymentRecord.t),
      orderByList: orderByList?.call(PromisePaymentRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PromisePaymentRecord] by its [id] or null if no such row exists.
  Future<PromisePaymentRecord?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PromisePaymentRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PromisePaymentRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [PromisePaymentRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromisePaymentRecord>> insert(
    _is.DatabaseSession session,
    List<PromisePaymentRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PromisePaymentRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PromisePaymentRecord] and returns the inserted row.
  ///
  /// The returned [PromisePaymentRecord] will have its `id` field set.
  Future<PromisePaymentRecord> insertRow(
    _is.DatabaseSession session,
    PromisePaymentRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PromisePaymentRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PromisePaymentRecord]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [PromisePaymentRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromisePaymentRecord>> upsert(
    _is.DatabaseSession session,
    List<PromisePaymentRecord> rows, {
    required _is.ColumnSelections<PromisePaymentRecordTable> conflictColumns,
    _is.ColumnSelections<PromisePaymentRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<PromisePaymentRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PromisePaymentRecord>(
      rows,
      conflictColumns: conflictColumns(PromisePaymentRecord.t),
      updateColumns: updateColumns?.call(PromisePaymentRecord.t),
      updateWhere: updateWhere?.call(PromisePaymentRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PromisePaymentRecord] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [PromisePaymentRecord] will have its `id` field set.
  Future<PromisePaymentRecord?> upsertRow(
    _is.DatabaseSession session,
    PromisePaymentRecord row, {
    required _is.ColumnSelections<PromisePaymentRecordTable> conflictColumns,
    _is.ColumnSelections<PromisePaymentRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<PromisePaymentRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PromisePaymentRecord>(
      row,
      conflictColumns: conflictColumns(PromisePaymentRecord.t),
      updateColumns: updateColumns?.call(PromisePaymentRecord.t),
      updateWhere: updateWhere?.call(PromisePaymentRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [PromisePaymentRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromisePaymentRecord>> update(
    _is.DatabaseSession session,
    List<PromisePaymentRecord> rows, {
    _is.ColumnSelections<PromisePaymentRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PromisePaymentRecord>(
      rows,
      columns: columns?.call(PromisePaymentRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PromisePaymentRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PromisePaymentRecord> updateRow(
    _is.DatabaseSession session,
    PromisePaymentRecord row, {
    _is.ColumnSelections<PromisePaymentRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PromisePaymentRecord>(
      row,
      columns: columns?.call(PromisePaymentRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PromisePaymentRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PromisePaymentRecord?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PromisePaymentRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PromisePaymentRecord>(
      id,
      columnValues: columnValues(PromisePaymentRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PromisePaymentRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromisePaymentRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PromisePaymentRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<PromisePaymentRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromisePaymentRecordTable>? orderBy,
    _is.OrderByListBuilder<PromisePaymentRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PromisePaymentRecord>(
      columnValues: columnValues(PromisePaymentRecord.t.updateTable),
      where: where(PromisePaymentRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PromisePaymentRecord.t),
      orderByList: orderByList?.call(PromisePaymentRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PromisePaymentRecord]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromisePaymentRecord>> delete(
    _is.DatabaseSession session,
    List<PromisePaymentRecord> rows, {
    _is.OrderByBuilder<PromisePaymentRecordTable>? orderBy,
    _is.OrderByListBuilder<PromisePaymentRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PromisePaymentRecord>(
      rows,
      orderBy: orderBy?.call(PromisePaymentRecord.t),
      orderByList: orderByList?.call(PromisePaymentRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PromisePaymentRecord].
  Future<PromisePaymentRecord> deleteRow(
    _is.DatabaseSession session,
    PromisePaymentRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PromisePaymentRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromisePaymentRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PromisePaymentRecordTable> where,
    _is.OrderByBuilder<PromisePaymentRecordTable>? orderBy,
    _is.OrderByListBuilder<PromisePaymentRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PromisePaymentRecord>(
      where: where(PromisePaymentRecord.t),
      orderBy: orderBy?.call(PromisePaymentRecord.t),
      orderByList: orderByList?.call(PromisePaymentRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromisePaymentRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PromisePaymentRecord>(
      where: where?.call(PromisePaymentRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PromisePaymentRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PromisePaymentRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PromisePaymentRecord>(
      where: where(PromisePaymentRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
