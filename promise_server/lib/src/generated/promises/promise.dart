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

abstract class Promise
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Promise._({
    this.id,
    required this.title,
    required this.promisedTo,
    this.description,
    required this.dueDate,
    this.dueTime,
    required this.createdAt,
    required this.status,
    bool? creatorConfirmed,
    bool? recipientConfirmed,
    this.creatorUserId,
    this.recipientUserId,
    bool? isGroupParent,
    this.parentPromiseId,
    bool? recipientAccepted,
    this.recipientAcceptedAt,
  }) : creatorConfirmed = creatorConfirmed ?? false,
       recipientConfirmed = recipientConfirmed ?? false,
       isGroupParent = isGroupParent ?? false,
       recipientAccepted = recipientAccepted ?? true;

  factory Promise({
    int? id,
    required String title,
    required String promisedTo,
    String? description,
    required DateTime dueDate,
    DateTime? dueTime,
    required DateTime createdAt,
    required String status,
    bool? creatorConfirmed,
    bool? recipientConfirmed,
    String? creatorUserId,
    String? recipientUserId,
    bool? isGroupParent,
    int? parentPromiseId,
    bool? recipientAccepted,
    DateTime? recipientAcceptedAt,
  }) = _PromiseImpl;

  factory Promise.fromJson(Map<String, dynamic> jsonSerialization) {
    return Promise(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      promisedTo: jsonSerialization['promisedTo'] as String,
      description: jsonSerialization['description'] as String?,
      dueDate: _is.DateTimeJsonExtension.fromJson(jsonSerialization['dueDate']),
      dueTime: jsonSerialization['dueTime'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['dueTime']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      status: jsonSerialization['status'] as String,
      creatorConfirmed: jsonSerialization['creatorConfirmed'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['creatorConfirmed'],
            ),
      recipientConfirmed: jsonSerialization['recipientConfirmed'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['recipientConfirmed'],
            ),
      creatorUserId: jsonSerialization['creatorUserId'] as String?,
      recipientUserId: jsonSerialization['recipientUserId'] as String?,
      isGroupParent: jsonSerialization['isGroupParent'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isGroupParent']),
      parentPromiseId: jsonSerialization['parentPromiseId'] as int?,
      recipientAccepted: jsonSerialization['recipientAccepted'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['recipientAccepted'],
            ),
      recipientAcceptedAt: jsonSerialization['recipientAcceptedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['recipientAcceptedAt'],
            ),
    );
  }

  static final t = PromiseTable();

  static const db = PromiseRepository._();

  @override
  int? id;

  String title;

  String promisedTo;

  String? description;

  DateTime dueDate;

  DateTime? dueTime;

  DateTime createdAt;

  String status;

  bool creatorConfirmed;

  bool recipientConfirmed;

  String? creatorUserId;

  String? recipientUserId;

  bool isGroupParent;

  int? parentPromiseId;

  bool recipientAccepted;

  DateTime? recipientAcceptedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Promise]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Promise copyWith({
    int? id,
    String? title,
    String? promisedTo,
    String? description,
    DateTime? dueDate,
    DateTime? dueTime,
    DateTime? createdAt,
    String? status,
    bool? creatorConfirmed,
    bool? recipientConfirmed,
    String? creatorUserId,
    String? recipientUserId,
    bool? isGroupParent,
    int? parentPromiseId,
    bool? recipientAccepted,
    DateTime? recipientAcceptedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Promise',
      if (id != null) 'id': id,
      'title': title,
      'promisedTo': promisedTo,
      if (description != null) 'description': description,
      'dueDate': dueDate.toJson(),
      if (dueTime != null) 'dueTime': dueTime?.toJson(),
      'createdAt': createdAt.toJson(),
      'status': status,
      'creatorConfirmed': creatorConfirmed,
      'recipientConfirmed': recipientConfirmed,
      if (creatorUserId != null) 'creatorUserId': creatorUserId,
      if (recipientUserId != null) 'recipientUserId': recipientUserId,
      'isGroupParent': isGroupParent,
      if (parentPromiseId != null) 'parentPromiseId': parentPromiseId,
      'recipientAccepted': recipientAccepted,
      if (recipientAcceptedAt != null)
        'recipientAcceptedAt': recipientAcceptedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Promise',
      if (id != null) 'id': id,
      'title': title,
      'promisedTo': promisedTo,
      if (description != null) 'description': description,
      'dueDate': dueDate.toJson(),
      if (dueTime != null) 'dueTime': dueTime?.toJson(),
      'createdAt': createdAt.toJson(),
      'status': status,
      'creatorConfirmed': creatorConfirmed,
      'recipientConfirmed': recipientConfirmed,
      if (creatorUserId != null) 'creatorUserId': creatorUserId,
      if (recipientUserId != null) 'recipientUserId': recipientUserId,
      'isGroupParent': isGroupParent,
      if (parentPromiseId != null) 'parentPromiseId': parentPromiseId,
      'recipientAccepted': recipientAccepted,
      if (recipientAcceptedAt != null)
        'recipientAcceptedAt': recipientAcceptedAt?.toJson(),
    };
  }

  static PromiseInclude include() {
    return PromiseInclude._();
  }

  static PromiseIncludeList includeList({
    _is.WhereExpressionBuilder<PromiseTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromiseTable>? orderBy,
    _is.OrderByListBuilder<PromiseTable>? orderByList,
    PromiseInclude? include,
  }) {
    return PromiseIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Promise.t),
      orderByList: orderByList?.call(Promise.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PromiseImpl extends Promise {
  _PromiseImpl({
    int? id,
    required String title,
    required String promisedTo,
    String? description,
    required DateTime dueDate,
    DateTime? dueTime,
    required DateTime createdAt,
    required String status,
    bool? creatorConfirmed,
    bool? recipientConfirmed,
    String? creatorUserId,
    String? recipientUserId,
    bool? isGroupParent,
    int? parentPromiseId,
    bool? recipientAccepted,
    DateTime? recipientAcceptedAt,
  }) : super._(
         id: id,
         title: title,
         promisedTo: promisedTo,
         description: description,
         dueDate: dueDate,
         dueTime: dueTime,
         createdAt: createdAt,
         status: status,
         creatorConfirmed: creatorConfirmed,
         recipientConfirmed: recipientConfirmed,
         creatorUserId: creatorUserId,
         recipientUserId: recipientUserId,
         isGroupParent: isGroupParent,
         parentPromiseId: parentPromiseId,
         recipientAccepted: recipientAccepted,
         recipientAcceptedAt: recipientAcceptedAt,
       );

  /// Returns a shallow copy of this [Promise]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Promise copyWith({
    Object? id = _Undefined,
    String? title,
    String? promisedTo,
    Object? description = _Undefined,
    DateTime? dueDate,
    Object? dueTime = _Undefined,
    DateTime? createdAt,
    String? status,
    bool? creatorConfirmed,
    bool? recipientConfirmed,
    Object? creatorUserId = _Undefined,
    Object? recipientUserId = _Undefined,
    bool? isGroupParent,
    Object? parentPromiseId = _Undefined,
    bool? recipientAccepted,
    Object? recipientAcceptedAt = _Undefined,
  }) {
    return Promise(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      promisedTo: promisedTo ?? this.promisedTo,
      description: description is String? ? description : this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime is DateTime? ? dueTime : this.dueTime,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      creatorConfirmed: creatorConfirmed ?? this.creatorConfirmed,
      recipientConfirmed: recipientConfirmed ?? this.recipientConfirmed,
      creatorUserId: creatorUserId is String?
          ? creatorUserId
          : this.creatorUserId,
      recipientUserId: recipientUserId is String?
          ? recipientUserId
          : this.recipientUserId,
      isGroupParent: isGroupParent ?? this.isGroupParent,
      parentPromiseId: parentPromiseId is int?
          ? parentPromiseId
          : this.parentPromiseId,
      recipientAccepted: recipientAccepted ?? this.recipientAccepted,
      recipientAcceptedAt: recipientAcceptedAt is DateTime?
          ? recipientAcceptedAt
          : this.recipientAcceptedAt,
    );
  }
}

class PromiseUpdateTable extends _is.UpdateTable<PromiseTable> {
  PromiseUpdateTable(super.table);

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<String, String> promisedTo(String value) => _is.ColumnValue(
    table.promisedTo,
    value,
  );

  _is.ColumnValue<String, String> description(String? value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> dueDate(DateTime value) =>
      _is.ColumnValue(
        table.dueDate,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> dueTime(DateTime? value) =>
      _is.ColumnValue(
        table.dueTime,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<bool, bool> creatorConfirmed(bool value) => _is.ColumnValue(
    table.creatorConfirmed,
    value,
  );

  _is.ColumnValue<bool, bool> recipientConfirmed(bool value) => _is.ColumnValue(
    table.recipientConfirmed,
    value,
  );

  _is.ColumnValue<String, String> creatorUserId(String? value) =>
      _is.ColumnValue(
        table.creatorUserId,
        value,
      );

  _is.ColumnValue<String, String> recipientUserId(String? value) =>
      _is.ColumnValue(
        table.recipientUserId,
        value,
      );

  _is.ColumnValue<bool, bool> isGroupParent(bool value) => _is.ColumnValue(
    table.isGroupParent,
    value,
  );

  _is.ColumnValue<int, int> parentPromiseId(int? value) => _is.ColumnValue(
    table.parentPromiseId,
    value,
  );

  _is.ColumnValue<bool, bool> recipientAccepted(bool value) => _is.ColumnValue(
    table.recipientAccepted,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> recipientAcceptedAt(DateTime? value) =>
      _is.ColumnValue(
        table.recipientAcceptedAt,
        value,
      );
}

class PromiseTable extends _is.Table<int?> {
  PromiseTable({super.tableRelation}) : super(tableName: 'promise') {
    updateTable = PromiseUpdateTable(this);
    title = _is.ColumnString(
      'title',
      this,
    );
    promisedTo = _is.ColumnString(
      'promisedTo',
      this,
    );
    description = _is.ColumnString(
      'description',
      this,
    );
    dueDate = _is.ColumnDateTime(
      'dueDate',
      this,
    );
    dueTime = _is.ColumnDateTime(
      'dueTime',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    creatorConfirmed = _is.ColumnBool(
      'creatorConfirmed',
      this,
      hasDefault: true,
    );
    recipientConfirmed = _is.ColumnBool(
      'recipientConfirmed',
      this,
      hasDefault: true,
    );
    creatorUserId = _is.ColumnString(
      'creatorUserId',
      this,
    );
    recipientUserId = _is.ColumnString(
      'recipientUserId',
      this,
    );
    isGroupParent = _is.ColumnBool(
      'isGroupParent',
      this,
      hasDefault: true,
    );
    parentPromiseId = _is.ColumnInt(
      'parentPromiseId',
      this,
    );
    recipientAccepted = _is.ColumnBool(
      'recipientAccepted',
      this,
      hasDefault: true,
    );
    recipientAcceptedAt = _is.ColumnDateTime(
      'recipientAcceptedAt',
      this,
    );
  }

  late final PromiseUpdateTable updateTable;

  late final _is.ColumnString title;

  late final _is.ColumnString promisedTo;

  late final _is.ColumnString description;

  late final _is.ColumnDateTime dueDate;

  late final _is.ColumnDateTime dueTime;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnString status;

  late final _is.ColumnBool creatorConfirmed;

  late final _is.ColumnBool recipientConfirmed;

  late final _is.ColumnString creatorUserId;

  late final _is.ColumnString recipientUserId;

  late final _is.ColumnBool isGroupParent;

  late final _is.ColumnInt parentPromiseId;

  late final _is.ColumnBool recipientAccepted;

  late final _is.ColumnDateTime recipientAcceptedAt;

  @override
  List<_is.Column> get columns => [
    id,
    title,
    promisedTo,
    description,
    dueDate,
    dueTime,
    createdAt,
    status,
    creatorConfirmed,
    recipientConfirmed,
    creatorUserId,
    recipientUserId,
    isGroupParent,
    parentPromiseId,
    recipientAccepted,
    recipientAcceptedAt,
  ];
}

class PromiseInclude extends _is.IncludeObject {
  PromiseInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Promise.t;
}

class PromiseIncludeList extends _is.IncludeList {
  PromiseIncludeList._({
    _is.WhereExpressionBuilder<PromiseTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Promise.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Promise.t;
}

class PromiseRepository {
  const PromiseRepository._();

  /// Returns a list of [Promise]s matching the given query parameters.
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
  Future<List<Promise>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromiseTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromiseTable>? orderBy,
    _is.OrderByListBuilder<PromiseTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Promise>(
      where: where?.call(Promise.t),
      orderBy: orderBy?.call(Promise.t),
      orderByList: orderByList?.call(Promise.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Promise] matching the given query parameters.
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
  Future<Promise?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromiseTable>? where,
    int? offset,
    _is.OrderByBuilder<PromiseTable>? orderBy,
    _is.OrderByListBuilder<PromiseTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Promise>(
      where: where?.call(Promise.t),
      orderBy: orderBy?.call(Promise.t),
      orderByList: orderByList?.call(Promise.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Promise] by its [id] or null if no such row exists.
  Future<Promise?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Promise>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Promise]s in the list and returns the inserted rows.
  ///
  /// The returned [Promise]s will have their `id` fields set.
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
  Future<List<Promise>> insert(
    _is.DatabaseSession session,
    List<Promise> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Promise>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Promise] and returns the inserted row.
  ///
  /// The returned [Promise] will have its `id` field set.
  Future<Promise> insertRow(
    _is.DatabaseSession session,
    Promise row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Promise>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Promise]s in the list and returns the resulting rows.
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
  /// The returned [Promise]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Promise>> upsert(
    _is.DatabaseSession session,
    List<Promise> rows, {
    required _is.ColumnSelections<PromiseTable> conflictColumns,
    _is.ColumnSelections<PromiseTable>? updateColumns,
    _is.WhereExpressionBuilder<PromiseTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Promise>(
      rows,
      conflictColumns: conflictColumns(Promise.t),
      updateColumns: updateColumns?.call(Promise.t),
      updateWhere: updateWhere?.call(Promise.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Promise] and returns the resulting row.
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
  /// The returned [Promise] will have its `id` field set.
  Future<Promise?> upsertRow(
    _is.DatabaseSession session,
    Promise row, {
    required _is.ColumnSelections<PromiseTable> conflictColumns,
    _is.ColumnSelections<PromiseTable>? updateColumns,
    _is.WhereExpressionBuilder<PromiseTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Promise>(
      row,
      conflictColumns: conflictColumns(Promise.t),
      updateColumns: updateColumns?.call(Promise.t),
      updateWhere: updateWhere?.call(Promise.t),
      transaction: transaction,
    );
  }

  /// Updates all [Promise]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Promise>> update(
    _is.DatabaseSession session,
    List<Promise> rows, {
    _is.ColumnSelections<PromiseTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Promise>(
      rows,
      columns: columns?.call(Promise.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Promise]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Promise> updateRow(
    _is.DatabaseSession session,
    Promise row, {
    _is.ColumnSelections<PromiseTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Promise>(
      row,
      columns: columns?.call(Promise.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Promise] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Promise?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PromiseUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Promise>(
      id,
      columnValues: columnValues(Promise.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Promise]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Promise>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PromiseUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PromiseTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromiseTable>? orderBy,
    _is.OrderByListBuilder<PromiseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Promise>(
      columnValues: columnValues(Promise.t.updateTable),
      where: where(Promise.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Promise.t),
      orderByList: orderByList?.call(Promise.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Promise]s in the list and returns the deleted rows.
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
  Future<List<Promise>> delete(
    _is.DatabaseSession session,
    List<Promise> rows, {
    _is.OrderByBuilder<PromiseTable>? orderBy,
    _is.OrderByListBuilder<PromiseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Promise>(
      rows,
      orderBy: orderBy?.call(Promise.t),
      orderByList: orderByList?.call(Promise.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Promise].
  Future<Promise> deleteRow(
    _is.DatabaseSession session,
    Promise row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Promise>(
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
  Future<List<Promise>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PromiseTable> where,
    _is.OrderByBuilder<PromiseTable>? orderBy,
    _is.OrderByListBuilder<PromiseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Promise>(
      where: where(Promise.t),
      orderBy: orderBy?.call(Promise.t),
      orderByList: orderByList?.call(Promise.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromiseTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Promise>(
      where: where?.call(Promise.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Promise] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PromiseTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Promise>(
      where: where(Promise.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
