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

abstract class PromiseFinancialTerms
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = PromiseFinancialTermsTable();

  static const db = PromiseFinancialTermsRepository._();

  @override
  int? id;

  int promiseId;

  int totalAmountMinorUnits;

  String currency;

  String payerUserId;

  String payeeUserId;

  String? notes;

  DateTime createdAt;

  DateTime? updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PromiseFinancialTerms]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static PromiseFinancialTermsInclude include() {
    return PromiseFinancialTermsInclude._();
  }

  static PromiseFinancialTermsIncludeList includeList({
    _is.WhereExpressionBuilder<PromiseFinancialTermsTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromiseFinancialTermsTable>? orderBy,
    _is.OrderByListBuilder<PromiseFinancialTermsTable>? orderByList,
    PromiseFinancialTermsInclude? include,
  }) {
    return PromiseFinancialTermsIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PromiseFinancialTerms.t),
      orderByList: orderByList?.call(PromiseFinancialTerms.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class PromiseFinancialTermsUpdateTable
    extends _is.UpdateTable<PromiseFinancialTermsTable> {
  PromiseFinancialTermsUpdateTable(super.table);

  _is.ColumnValue<int, int> promiseId(int value) => _is.ColumnValue(
    table.promiseId,
    value,
  );

  _is.ColumnValue<int, int> totalAmountMinorUnits(int value) => _is.ColumnValue(
    table.totalAmountMinorUnits,
    value,
  );

  _is.ColumnValue<String, String> currency(String value) => _is.ColumnValue(
    table.currency,
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

class PromiseFinancialTermsTable extends _is.Table<int?> {
  PromiseFinancialTermsTable({super.tableRelation})
    : super(tableName: 'promise_financial_terms') {
    updateTable = PromiseFinancialTermsUpdateTable(this);
    promiseId = _is.ColumnInt(
      'promiseId',
      this,
    );
    totalAmountMinorUnits = _is.ColumnInt(
      'totalAmountMinorUnits',
      this,
    );
    currency = _is.ColumnString(
      'currency',
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

  late final PromiseFinancialTermsUpdateTable updateTable;

  late final _is.ColumnInt promiseId;

  late final _is.ColumnInt totalAmountMinorUnits;

  late final _is.ColumnString currency;

  late final _is.ColumnString payerUserId;

  late final _is.ColumnString payeeUserId;

  late final _is.ColumnString notes;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    promiseId,
    totalAmountMinorUnits,
    currency,
    payerUserId,
    payeeUserId,
    notes,
    createdAt,
    updatedAt,
  ];
}

class PromiseFinancialTermsInclude extends _is.IncludeObject {
  PromiseFinancialTermsInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PromiseFinancialTerms.t;
}

class PromiseFinancialTermsIncludeList extends _is.IncludeList {
  PromiseFinancialTermsIncludeList._({
    _is.WhereExpressionBuilder<PromiseFinancialTermsTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PromiseFinancialTerms.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PromiseFinancialTerms.t;
}

class PromiseFinancialTermsRepository {
  const PromiseFinancialTermsRepository._();

  /// Returns a list of [PromiseFinancialTerms]s matching the given query parameters.
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
  Future<List<PromiseFinancialTerms>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromiseFinancialTermsTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromiseFinancialTermsTable>? orderBy,
    _is.OrderByListBuilder<PromiseFinancialTermsTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PromiseFinancialTerms>(
      where: where?.call(PromiseFinancialTerms.t),
      orderBy: orderBy?.call(PromiseFinancialTerms.t),
      orderByList: orderByList?.call(PromiseFinancialTerms.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PromiseFinancialTerms] matching the given query parameters.
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
  Future<PromiseFinancialTerms?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromiseFinancialTermsTable>? where,
    int? offset,
    _is.OrderByBuilder<PromiseFinancialTermsTable>? orderBy,
    _is.OrderByListBuilder<PromiseFinancialTermsTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PromiseFinancialTerms>(
      where: where?.call(PromiseFinancialTerms.t),
      orderBy: orderBy?.call(PromiseFinancialTerms.t),
      orderByList: orderByList?.call(PromiseFinancialTerms.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PromiseFinancialTerms] by its [id] or null if no such row exists.
  Future<PromiseFinancialTerms?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PromiseFinancialTerms>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PromiseFinancialTerms]s in the list and returns the inserted rows.
  ///
  /// The returned [PromiseFinancialTerms]s will have their `id` fields set.
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
  Future<List<PromiseFinancialTerms>> insert(
    _is.DatabaseSession session,
    List<PromiseFinancialTerms> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PromiseFinancialTerms>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PromiseFinancialTerms] and returns the inserted row.
  ///
  /// The returned [PromiseFinancialTerms] will have its `id` field set.
  Future<PromiseFinancialTerms> insertRow(
    _is.DatabaseSession session,
    PromiseFinancialTerms row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PromiseFinancialTerms>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PromiseFinancialTerms]s in the list and returns the resulting rows.
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
  /// The returned [PromiseFinancialTerms]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromiseFinancialTerms>> upsert(
    _is.DatabaseSession session,
    List<PromiseFinancialTerms> rows, {
    required _is.ColumnSelections<PromiseFinancialTermsTable> conflictColumns,
    _is.ColumnSelections<PromiseFinancialTermsTable>? updateColumns,
    _is.WhereExpressionBuilder<PromiseFinancialTermsTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PromiseFinancialTerms>(
      rows,
      conflictColumns: conflictColumns(PromiseFinancialTerms.t),
      updateColumns: updateColumns?.call(PromiseFinancialTerms.t),
      updateWhere: updateWhere?.call(PromiseFinancialTerms.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PromiseFinancialTerms] and returns the resulting row.
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
  /// The returned [PromiseFinancialTerms] will have its `id` field set.
  Future<PromiseFinancialTerms?> upsertRow(
    _is.DatabaseSession session,
    PromiseFinancialTerms row, {
    required _is.ColumnSelections<PromiseFinancialTermsTable> conflictColumns,
    _is.ColumnSelections<PromiseFinancialTermsTable>? updateColumns,
    _is.WhereExpressionBuilder<PromiseFinancialTermsTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PromiseFinancialTerms>(
      row,
      conflictColumns: conflictColumns(PromiseFinancialTerms.t),
      updateColumns: updateColumns?.call(PromiseFinancialTerms.t),
      updateWhere: updateWhere?.call(PromiseFinancialTerms.t),
      transaction: transaction,
    );
  }

  /// Updates all [PromiseFinancialTerms]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromiseFinancialTerms>> update(
    _is.DatabaseSession session,
    List<PromiseFinancialTerms> rows, {
    _is.ColumnSelections<PromiseFinancialTermsTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PromiseFinancialTerms>(
      rows,
      columns: columns?.call(PromiseFinancialTerms.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PromiseFinancialTerms]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PromiseFinancialTerms> updateRow(
    _is.DatabaseSession session,
    PromiseFinancialTerms row, {
    _is.ColumnSelections<PromiseFinancialTermsTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PromiseFinancialTerms>(
      row,
      columns: columns?.call(PromiseFinancialTerms.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PromiseFinancialTerms] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PromiseFinancialTerms?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PromiseFinancialTermsUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PromiseFinancialTerms>(
      id,
      columnValues: columnValues(PromiseFinancialTerms.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PromiseFinancialTerms]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromiseFinancialTerms>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PromiseFinancialTermsUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<PromiseFinancialTermsTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromiseFinancialTermsTable>? orderBy,
    _is.OrderByListBuilder<PromiseFinancialTermsTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PromiseFinancialTerms>(
      columnValues: columnValues(PromiseFinancialTerms.t.updateTable),
      where: where(PromiseFinancialTerms.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PromiseFinancialTerms.t),
      orderByList: orderByList?.call(PromiseFinancialTerms.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PromiseFinancialTerms]s in the list and returns the deleted rows.
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
  Future<List<PromiseFinancialTerms>> delete(
    _is.DatabaseSession session,
    List<PromiseFinancialTerms> rows, {
    _is.OrderByBuilder<PromiseFinancialTermsTable>? orderBy,
    _is.OrderByListBuilder<PromiseFinancialTermsTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PromiseFinancialTerms>(
      rows,
      orderBy: orderBy?.call(PromiseFinancialTerms.t),
      orderByList: orderByList?.call(PromiseFinancialTerms.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PromiseFinancialTerms].
  Future<PromiseFinancialTerms> deleteRow(
    _is.DatabaseSession session,
    PromiseFinancialTerms row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PromiseFinancialTerms>(
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
  Future<List<PromiseFinancialTerms>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PromiseFinancialTermsTable> where,
    _is.OrderByBuilder<PromiseFinancialTermsTable>? orderBy,
    _is.OrderByListBuilder<PromiseFinancialTermsTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PromiseFinancialTerms>(
      where: where(PromiseFinancialTerms.t),
      orderBy: orderBy?.call(PromiseFinancialTerms.t),
      orderByList: orderByList?.call(PromiseFinancialTerms.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromiseFinancialTermsTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PromiseFinancialTerms>(
      where: where?.call(PromiseFinancialTerms.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PromiseFinancialTerms] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PromiseFinancialTermsTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PromiseFinancialTerms>(
      where: where(PromiseFinancialTerms.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
