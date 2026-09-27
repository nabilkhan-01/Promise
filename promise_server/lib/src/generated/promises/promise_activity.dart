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

abstract class PromiseActivity
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PromiseActivity._({
    this.id,
    required this.promiseId,
    required this.type,
    required this.message,
    this.status,
    required this.createdAt,
  });

  factory PromiseActivity({
    int? id,
    required int promiseId,
    required String type,
    required String message,
    String? status,
    required DateTime createdAt,
  }) = _PromiseActivityImpl;

  factory PromiseActivity.fromJson(Map<String, dynamic> jsonSerialization) {
    return PromiseActivity(
      id: jsonSerialization['id'] as int?,
      promiseId: jsonSerialization['promiseId'] as int,
      type: jsonSerialization['type'] as String,
      message: jsonSerialization['message'] as String,
      status: jsonSerialization['status'] as String?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = PromiseActivityTable();

  static const db = PromiseActivityRepository._();

  @override
  int? id;

  int promiseId;

  String type;

  String message;

  String? status;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PromiseActivity]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PromiseActivity copyWith({
    int? id,
    int? promiseId,
    String? type,
    String? message,
    String? status,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PromiseActivity',
      if (id != null) 'id': id,
      'promiseId': promiseId,
      'type': type,
      'message': message,
      if (status != null) 'status': status,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PromiseActivity',
      if (id != null) 'id': id,
      'promiseId': promiseId,
      'type': type,
      'message': message,
      if (status != null) 'status': status,
      'createdAt': createdAt.toJson(),
    };
  }

  static PromiseActivityInclude include() {
    return PromiseActivityInclude._();
  }

  static PromiseActivityIncludeList includeList({
    _is.WhereExpressionBuilder<PromiseActivityTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromiseActivityTable>? orderBy,
    _is.OrderByListBuilder<PromiseActivityTable>? orderByList,
    PromiseActivityInclude? include,
  }) {
    return PromiseActivityIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PromiseActivity.t),
      orderByList: orderByList?.call(PromiseActivity.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PromiseActivityImpl extends PromiseActivity {
  _PromiseActivityImpl({
    int? id,
    required int promiseId,
    required String type,
    required String message,
    String? status,
    required DateTime createdAt,
  }) : super._(
         id: id,
         promiseId: promiseId,
         type: type,
         message: message,
         status: status,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PromiseActivity]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PromiseActivity copyWith({
    Object? id = _Undefined,
    int? promiseId,
    String? type,
    String? message,
    Object? status = _Undefined,
    DateTime? createdAt,
  }) {
    return PromiseActivity(
      id: id is int? ? id : this.id,
      promiseId: promiseId ?? this.promiseId,
      type: type ?? this.type,
      message: message ?? this.message,
      status: status is String? ? status : this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PromiseActivityUpdateTable extends _is.UpdateTable<PromiseActivityTable> {
  PromiseActivityUpdateTable(super.table);

  _is.ColumnValue<int, int> promiseId(int value) => _is.ColumnValue(
    table.promiseId,
    value,
  );

  _is.ColumnValue<String, String> type(String value) => _is.ColumnValue(
    table.type,
    value,
  );

  _is.ColumnValue<String, String> message(String value) => _is.ColumnValue(
    table.message,
    value,
  );

  _is.ColumnValue<String, String> status(String? value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class PromiseActivityTable extends _is.Table<int?> {
  PromiseActivityTable({super.tableRelation})
    : super(tableName: 'promise_activity') {
    updateTable = PromiseActivityUpdateTable(this);
    promiseId = _is.ColumnInt(
      'promiseId',
      this,
    );
    type = _is.ColumnString(
      'type',
      this,
    );
    message = _is.ColumnString(
      'message',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final PromiseActivityUpdateTable updateTable;

  late final _is.ColumnInt promiseId;

  late final _is.ColumnString type;

  late final _is.ColumnString message;

  late final _is.ColumnString status;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    promiseId,
    type,
    message,
    status,
    createdAt,
  ];
}

class PromiseActivityInclude extends _is.IncludeObject {
  PromiseActivityInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PromiseActivity.t;
}

class PromiseActivityIncludeList extends _is.IncludeList {
  PromiseActivityIncludeList._({
    _is.WhereExpressionBuilder<PromiseActivityTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PromiseActivity.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PromiseActivity.t;
}

class PromiseActivityRepository {
  const PromiseActivityRepository._();

  /// Returns a list of [PromiseActivity]s matching the given query parameters.
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
  Future<List<PromiseActivity>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromiseActivityTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromiseActivityTable>? orderBy,
    _is.OrderByListBuilder<PromiseActivityTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PromiseActivity>(
      where: where?.call(PromiseActivity.t),
      orderBy: orderBy?.call(PromiseActivity.t),
      orderByList: orderByList?.call(PromiseActivity.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PromiseActivity] matching the given query parameters.
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
  Future<PromiseActivity?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromiseActivityTable>? where,
    int? offset,
    _is.OrderByBuilder<PromiseActivityTable>? orderBy,
    _is.OrderByListBuilder<PromiseActivityTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PromiseActivity>(
      where: where?.call(PromiseActivity.t),
      orderBy: orderBy?.call(PromiseActivity.t),
      orderByList: orderByList?.call(PromiseActivity.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PromiseActivity] by its [id] or null if no such row exists.
  Future<PromiseActivity?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PromiseActivity>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PromiseActivity]s in the list and returns the inserted rows.
  ///
  /// The returned [PromiseActivity]s will have their `id` fields set.
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
  Future<List<PromiseActivity>> insert(
    _is.DatabaseSession session,
    List<PromiseActivity> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PromiseActivity>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PromiseActivity] and returns the inserted row.
  ///
  /// The returned [PromiseActivity] will have its `id` field set.
  Future<PromiseActivity> insertRow(
    _is.DatabaseSession session,
    PromiseActivity row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PromiseActivity>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PromiseActivity]s in the list and returns the resulting rows.
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
  /// The returned [PromiseActivity]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromiseActivity>> upsert(
    _is.DatabaseSession session,
    List<PromiseActivity> rows, {
    required _is.ColumnSelections<PromiseActivityTable> conflictColumns,
    _is.ColumnSelections<PromiseActivityTable>? updateColumns,
    _is.WhereExpressionBuilder<PromiseActivityTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PromiseActivity>(
      rows,
      conflictColumns: conflictColumns(PromiseActivity.t),
      updateColumns: updateColumns?.call(PromiseActivity.t),
      updateWhere: updateWhere?.call(PromiseActivity.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PromiseActivity] and returns the resulting row.
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
  /// The returned [PromiseActivity] will have its `id` field set.
  Future<PromiseActivity?> upsertRow(
    _is.DatabaseSession session,
    PromiseActivity row, {
    required _is.ColumnSelections<PromiseActivityTable> conflictColumns,
    _is.ColumnSelections<PromiseActivityTable>? updateColumns,
    _is.WhereExpressionBuilder<PromiseActivityTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PromiseActivity>(
      row,
      conflictColumns: conflictColumns(PromiseActivity.t),
      updateColumns: updateColumns?.call(PromiseActivity.t),
      updateWhere: updateWhere?.call(PromiseActivity.t),
      transaction: transaction,
    );
  }

  /// Updates all [PromiseActivity]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromiseActivity>> update(
    _is.DatabaseSession session,
    List<PromiseActivity> rows, {
    _is.ColumnSelections<PromiseActivityTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PromiseActivity>(
      rows,
      columns: columns?.call(PromiseActivity.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PromiseActivity]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PromiseActivity> updateRow(
    _is.DatabaseSession session,
    PromiseActivity row, {
    _is.ColumnSelections<PromiseActivityTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PromiseActivity>(
      row,
      columns: columns?.call(PromiseActivity.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PromiseActivity] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PromiseActivity?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PromiseActivityUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PromiseActivity>(
      id,
      columnValues: columnValues(PromiseActivity.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PromiseActivity]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromiseActivity>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PromiseActivityUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<PromiseActivityTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromiseActivityTable>? orderBy,
    _is.OrderByListBuilder<PromiseActivityTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PromiseActivity>(
      columnValues: columnValues(PromiseActivity.t.updateTable),
      where: where(PromiseActivity.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PromiseActivity.t),
      orderByList: orderByList?.call(PromiseActivity.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PromiseActivity]s in the list and returns the deleted rows.
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
  Future<List<PromiseActivity>> delete(
    _is.DatabaseSession session,
    List<PromiseActivity> rows, {
    _is.OrderByBuilder<PromiseActivityTable>? orderBy,
    _is.OrderByListBuilder<PromiseActivityTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PromiseActivity>(
      rows,
      orderBy: orderBy?.call(PromiseActivity.t),
      orderByList: orderByList?.call(PromiseActivity.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PromiseActivity].
  Future<PromiseActivity> deleteRow(
    _is.DatabaseSession session,
    PromiseActivity row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PromiseActivity>(
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
  Future<List<PromiseActivity>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PromiseActivityTable> where,
    _is.OrderByBuilder<PromiseActivityTable>? orderBy,
    _is.OrderByListBuilder<PromiseActivityTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PromiseActivity>(
      where: where(PromiseActivity.t),
      orderBy: orderBy?.call(PromiseActivity.t),
      orderByList: orderByList?.call(PromiseActivity.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromiseActivityTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PromiseActivity>(
      where: where?.call(PromiseActivity.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PromiseActivity] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PromiseActivityTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PromiseActivity>(
      where: where(PromiseActivity.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
