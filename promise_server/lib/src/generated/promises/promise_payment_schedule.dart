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

abstract class PromisePaymentSchedule
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      dueDate: _is.DateTimeJsonExtension.fromJson(jsonSerialization['dueDate']),
      cancelledAt: jsonSerialization['cancelledAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['cancelledAt'],
            ),
      cancelledByUserId: jsonSerialization['cancelledByUserId'] as String?,
      cancellationReason: jsonSerialization['cancellationReason'] as String?,
      notes: jsonSerialization['notes'] as String?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = PromisePaymentScheduleTable();

  static const db = PromisePaymentScheduleRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PromisePaymentSchedule]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static PromisePaymentScheduleInclude include() {
    return PromisePaymentScheduleInclude._();
  }

  static PromisePaymentScheduleIncludeList includeList({
    _is.WhereExpressionBuilder<PromisePaymentScheduleTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromisePaymentScheduleTable>? orderBy,
    _is.OrderByListBuilder<PromisePaymentScheduleTable>? orderByList,
    PromisePaymentScheduleInclude? include,
  }) {
    return PromisePaymentScheduleIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PromisePaymentSchedule.t),
      orderByList: orderByList?.call(PromisePaymentSchedule.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class PromisePaymentScheduleUpdateTable
    extends _is.UpdateTable<PromisePaymentScheduleTable> {
  PromisePaymentScheduleUpdateTable(super.table);

  _is.ColumnValue<int, int> promiseId(int value) => _is.ColumnValue(
    table.promiseId,
    value,
  );

  _is.ColumnValue<int, int> installmentOrder(int value) => _is.ColumnValue(
    table.installmentOrder,
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

  _is.ColumnValue<DateTime, DateTime> dueDate(DateTime value) =>
      _is.ColumnValue(
        table.dueDate,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> cancelledAt(DateTime? value) =>
      _is.ColumnValue(
        table.cancelledAt,
        value,
      );

  _is.ColumnValue<String, String> cancelledByUserId(String? value) =>
      _is.ColumnValue(
        table.cancelledByUserId,
        value,
      );

  _is.ColumnValue<String, String> cancellationReason(String? value) =>
      _is.ColumnValue(
        table.cancellationReason,
        value,
      );

  _is.ColumnValue<String, String> notes(String? value) => _is.ColumnValue(
    table.notes,
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

class PromisePaymentScheduleTable extends _is.Table<int?> {
  PromisePaymentScheduleTable({super.tableRelation})
    : super(tableName: 'promise_payment_schedule') {
    updateTable = PromisePaymentScheduleUpdateTable(this);
    promiseId = _is.ColumnInt(
      'promiseId',
      this,
    );
    installmentOrder = _is.ColumnInt(
      'installmentOrder',
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
    dueDate = _is.ColumnDateTime(
      'dueDate',
      this,
    );
    cancelledAt = _is.ColumnDateTime(
      'cancelledAt',
      this,
    );
    cancelledByUserId = _is.ColumnString(
      'cancelledByUserId',
      this,
    );
    cancellationReason = _is.ColumnString(
      'cancellationReason',
      this,
    );
    notes = _is.ColumnString(
      'notes',
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

  late final PromisePaymentScheduleUpdateTable updateTable;

  late final _is.ColumnInt promiseId;

  late final _is.ColumnInt installmentOrder;

  late final _is.ColumnInt amountMinorUnits;

  late final _is.ColumnString currency;

  late final _is.ColumnDateTime dueDate;

  late final _is.ColumnDateTime cancelledAt;

  late final _is.ColumnString cancelledByUserId;

  late final _is.ColumnString cancellationReason;

  late final _is.ColumnString notes;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    promiseId,
    installmentOrder,
    amountMinorUnits,
    currency,
    dueDate,
    cancelledAt,
    cancelledByUserId,
    cancellationReason,
    notes,
    createdAt,
    updatedAt,
  ];
}

class PromisePaymentScheduleInclude extends _is.IncludeObject {
  PromisePaymentScheduleInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PromisePaymentSchedule.t;
}

class PromisePaymentScheduleIncludeList extends _is.IncludeList {
  PromisePaymentScheduleIncludeList._({
    _is.WhereExpressionBuilder<PromisePaymentScheduleTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PromisePaymentSchedule.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PromisePaymentSchedule.t;
}

class PromisePaymentScheduleRepository {
  const PromisePaymentScheduleRepository._();

  /// Returns a list of [PromisePaymentSchedule]s matching the given query parameters.
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
  Future<List<PromisePaymentSchedule>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromisePaymentScheduleTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromisePaymentScheduleTable>? orderBy,
    _is.OrderByListBuilder<PromisePaymentScheduleTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PromisePaymentSchedule>(
      where: where?.call(PromisePaymentSchedule.t),
      orderBy: orderBy?.call(PromisePaymentSchedule.t),
      orderByList: orderByList?.call(PromisePaymentSchedule.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PromisePaymentSchedule] matching the given query parameters.
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
  Future<PromisePaymentSchedule?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromisePaymentScheduleTable>? where,
    int? offset,
    _is.OrderByBuilder<PromisePaymentScheduleTable>? orderBy,
    _is.OrderByListBuilder<PromisePaymentScheduleTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PromisePaymentSchedule>(
      where: where?.call(PromisePaymentSchedule.t),
      orderBy: orderBy?.call(PromisePaymentSchedule.t),
      orderByList: orderByList?.call(PromisePaymentSchedule.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PromisePaymentSchedule] by its [id] or null if no such row exists.
  Future<PromisePaymentSchedule?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PromisePaymentSchedule>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PromisePaymentSchedule]s in the list and returns the inserted rows.
  ///
  /// The returned [PromisePaymentSchedule]s will have their `id` fields set.
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
  Future<List<PromisePaymentSchedule>> insert(
    _is.DatabaseSession session,
    List<PromisePaymentSchedule> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PromisePaymentSchedule>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PromisePaymentSchedule] and returns the inserted row.
  ///
  /// The returned [PromisePaymentSchedule] will have its `id` field set.
  Future<PromisePaymentSchedule> insertRow(
    _is.DatabaseSession session,
    PromisePaymentSchedule row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PromisePaymentSchedule>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PromisePaymentSchedule]s in the list and returns the resulting rows.
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
  /// The returned [PromisePaymentSchedule]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromisePaymentSchedule>> upsert(
    _is.DatabaseSession session,
    List<PromisePaymentSchedule> rows, {
    required _is.ColumnSelections<PromisePaymentScheduleTable> conflictColumns,
    _is.ColumnSelections<PromisePaymentScheduleTable>? updateColumns,
    _is.WhereExpressionBuilder<PromisePaymentScheduleTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PromisePaymentSchedule>(
      rows,
      conflictColumns: conflictColumns(PromisePaymentSchedule.t),
      updateColumns: updateColumns?.call(PromisePaymentSchedule.t),
      updateWhere: updateWhere?.call(PromisePaymentSchedule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PromisePaymentSchedule] and returns the resulting row.
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
  /// The returned [PromisePaymentSchedule] will have its `id` field set.
  Future<PromisePaymentSchedule?> upsertRow(
    _is.DatabaseSession session,
    PromisePaymentSchedule row, {
    required _is.ColumnSelections<PromisePaymentScheduleTable> conflictColumns,
    _is.ColumnSelections<PromisePaymentScheduleTable>? updateColumns,
    _is.WhereExpressionBuilder<PromisePaymentScheduleTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PromisePaymentSchedule>(
      row,
      conflictColumns: conflictColumns(PromisePaymentSchedule.t),
      updateColumns: updateColumns?.call(PromisePaymentSchedule.t),
      updateWhere: updateWhere?.call(PromisePaymentSchedule.t),
      transaction: transaction,
    );
  }

  /// Updates all [PromisePaymentSchedule]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromisePaymentSchedule>> update(
    _is.DatabaseSession session,
    List<PromisePaymentSchedule> rows, {
    _is.ColumnSelections<PromisePaymentScheduleTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PromisePaymentSchedule>(
      rows,
      columns: columns?.call(PromisePaymentSchedule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PromisePaymentSchedule]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PromisePaymentSchedule> updateRow(
    _is.DatabaseSession session,
    PromisePaymentSchedule row, {
    _is.ColumnSelections<PromisePaymentScheduleTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PromisePaymentSchedule>(
      row,
      columns: columns?.call(PromisePaymentSchedule.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PromisePaymentSchedule] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PromisePaymentSchedule?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PromisePaymentScheduleUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PromisePaymentSchedule>(
      id,
      columnValues: columnValues(PromisePaymentSchedule.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PromisePaymentSchedule]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromisePaymentSchedule>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PromisePaymentScheduleUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<PromisePaymentScheduleTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromisePaymentScheduleTable>? orderBy,
    _is.OrderByListBuilder<PromisePaymentScheduleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PromisePaymentSchedule>(
      columnValues: columnValues(PromisePaymentSchedule.t.updateTable),
      where: where(PromisePaymentSchedule.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PromisePaymentSchedule.t),
      orderByList: orderByList?.call(PromisePaymentSchedule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PromisePaymentSchedule]s in the list and returns the deleted rows.
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
  Future<List<PromisePaymentSchedule>> delete(
    _is.DatabaseSession session,
    List<PromisePaymentSchedule> rows, {
    _is.OrderByBuilder<PromisePaymentScheduleTable>? orderBy,
    _is.OrderByListBuilder<PromisePaymentScheduleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PromisePaymentSchedule>(
      rows,
      orderBy: orderBy?.call(PromisePaymentSchedule.t),
      orderByList: orderByList?.call(PromisePaymentSchedule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PromisePaymentSchedule].
  Future<PromisePaymentSchedule> deleteRow(
    _is.DatabaseSession session,
    PromisePaymentSchedule row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PromisePaymentSchedule>(
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
  Future<List<PromisePaymentSchedule>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PromisePaymentScheduleTable> where,
    _is.OrderByBuilder<PromisePaymentScheduleTable>? orderBy,
    _is.OrderByListBuilder<PromisePaymentScheduleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PromisePaymentSchedule>(
      where: where(PromisePaymentSchedule.t),
      orderBy: orderBy?.call(PromisePaymentSchedule.t),
      orderByList: orderByList?.call(PromisePaymentSchedule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromisePaymentScheduleTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PromisePaymentSchedule>(
      where: where?.call(PromisePaymentSchedule.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PromisePaymentSchedule] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PromisePaymentScheduleTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PromisePaymentSchedule>(
      where: where(PromisePaymentSchedule.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
