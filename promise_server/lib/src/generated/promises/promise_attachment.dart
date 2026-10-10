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

abstract class PromiseAttachment
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PromiseAttachment._({
    this.id,
    required this.promiseId,
    required this.uploaderUserId,
    required this.storageId,
    required this.path,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    required this.createdAt,
    required this.approvalStatus,
    this.reviewedAt,
    this.reviewerUserId,
    this.rejectionReason,
  });

  factory PromiseAttachment({
    int? id,
    required int promiseId,
    required String uploaderUserId,
    required String storageId,
    required String path,
    required String fileName,
    required String mimeType,
    required int fileSize,
    required DateTime createdAt,
    required String approvalStatus,
    DateTime? reviewedAt,
    String? reviewerUserId,
    String? rejectionReason,
  }) = _PromiseAttachmentImpl;

  factory PromiseAttachment.fromJson(Map<String, dynamic> jsonSerialization) {
    return PromiseAttachment(
      id: jsonSerialization['id'] as int?,
      promiseId: jsonSerialization['promiseId'] as int,
      uploaderUserId: jsonSerialization['uploaderUserId'] as String,
      storageId: jsonSerialization['storageId'] as String,
      path: jsonSerialization['path'] as String,
      fileName: jsonSerialization['fileName'] as String,
      mimeType: jsonSerialization['mimeType'] as String,
      fileSize: jsonSerialization['fileSize'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      approvalStatus: jsonSerialization['approvalStatus'] as String,
      reviewedAt: jsonSerialization['reviewedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['reviewedAt']),
      reviewerUserId: jsonSerialization['reviewerUserId'] as String?,
      rejectionReason: jsonSerialization['rejectionReason'] as String?,
    );
  }

  static final t = PromiseAttachmentTable();

  static const db = PromiseAttachmentRepository._();

  @override
  int? id;

  int promiseId;

  String uploaderUserId;

  String storageId;

  String path;

  String fileName;

  String mimeType;

  int fileSize;

  DateTime createdAt;

  String approvalStatus;

  DateTime? reviewedAt;

  String? reviewerUserId;

  String? rejectionReason;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PromiseAttachment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PromiseAttachment copyWith({
    int? id,
    int? promiseId,
    String? uploaderUserId,
    String? storageId,
    String? path,
    String? fileName,
    String? mimeType,
    int? fileSize,
    DateTime? createdAt,
    String? approvalStatus,
    DateTime? reviewedAt,
    String? reviewerUserId,
    String? rejectionReason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PromiseAttachment',
      if (id != null) 'id': id,
      'promiseId': promiseId,
      'uploaderUserId': uploaderUserId,
      'storageId': storageId,
      'path': path,
      'fileName': fileName,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'createdAt': createdAt.toJson(),
      'approvalStatus': approvalStatus,
      if (reviewedAt != null) 'reviewedAt': reviewedAt?.toJson(),
      if (reviewerUserId != null) 'reviewerUserId': reviewerUserId,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PromiseAttachment',
      if (id != null) 'id': id,
      'promiseId': promiseId,
      'uploaderUserId': uploaderUserId,
      'storageId': storageId,
      'path': path,
      'fileName': fileName,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'createdAt': createdAt.toJson(),
      'approvalStatus': approvalStatus,
      if (reviewedAt != null) 'reviewedAt': reviewedAt?.toJson(),
      if (reviewerUserId != null) 'reviewerUserId': reviewerUserId,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }

  static PromiseAttachmentInclude include() {
    return PromiseAttachmentInclude._();
  }

  static PromiseAttachmentIncludeList includeList({
    _is.WhereExpressionBuilder<PromiseAttachmentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromiseAttachmentTable>? orderBy,
    _is.OrderByListBuilder<PromiseAttachmentTable>? orderByList,
    PromiseAttachmentInclude? include,
  }) {
    return PromiseAttachmentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PromiseAttachment.t),
      orderByList: orderByList?.call(PromiseAttachment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PromiseAttachmentImpl extends PromiseAttachment {
  _PromiseAttachmentImpl({
    int? id,
    required int promiseId,
    required String uploaderUserId,
    required String storageId,
    required String path,
    required String fileName,
    required String mimeType,
    required int fileSize,
    required DateTime createdAt,
    required String approvalStatus,
    DateTime? reviewedAt,
    String? reviewerUserId,
    String? rejectionReason,
  }) : super._(
         id: id,
         promiseId: promiseId,
         uploaderUserId: uploaderUserId,
         storageId: storageId,
         path: path,
         fileName: fileName,
         mimeType: mimeType,
         fileSize: fileSize,
         createdAt: createdAt,
         approvalStatus: approvalStatus,
         reviewedAt: reviewedAt,
         reviewerUserId: reviewerUserId,
         rejectionReason: rejectionReason,
       );

  /// Returns a shallow copy of this [PromiseAttachment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PromiseAttachment copyWith({
    Object? id = _Undefined,
    int? promiseId,
    String? uploaderUserId,
    String? storageId,
    String? path,
    String? fileName,
    String? mimeType,
    int? fileSize,
    DateTime? createdAt,
    String? approvalStatus,
    Object? reviewedAt = _Undefined,
    Object? reviewerUserId = _Undefined,
    Object? rejectionReason = _Undefined,
  }) {
    return PromiseAttachment(
      id: id is int? ? id : this.id,
      promiseId: promiseId ?? this.promiseId,
      uploaderUserId: uploaderUserId ?? this.uploaderUserId,
      storageId: storageId ?? this.storageId,
      path: path ?? this.path,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      reviewedAt: reviewedAt is DateTime? ? reviewedAt : this.reviewedAt,
      reviewerUserId: reviewerUserId is String?
          ? reviewerUserId
          : this.reviewerUserId,
      rejectionReason: rejectionReason is String?
          ? rejectionReason
          : this.rejectionReason,
    );
  }
}

class PromiseAttachmentUpdateTable
    extends _is.UpdateTable<PromiseAttachmentTable> {
  PromiseAttachmentUpdateTable(super.table);

  _is.ColumnValue<int, int> promiseId(int value) => _is.ColumnValue(
    table.promiseId,
    value,
  );

  _is.ColumnValue<String, String> uploaderUserId(String value) =>
      _is.ColumnValue(
        table.uploaderUserId,
        value,
      );

  _is.ColumnValue<String, String> storageId(String value) => _is.ColumnValue(
    table.storageId,
    value,
  );

  _is.ColumnValue<String, String> path(String value) => _is.ColumnValue(
    table.path,
    value,
  );

  _is.ColumnValue<String, String> fileName(String value) => _is.ColumnValue(
    table.fileName,
    value,
  );

  _is.ColumnValue<String, String> mimeType(String value) => _is.ColumnValue(
    table.mimeType,
    value,
  );

  _is.ColumnValue<int, int> fileSize(int value) => _is.ColumnValue(
    table.fileSize,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<String, String> approvalStatus(String value) =>
      _is.ColumnValue(
        table.approvalStatus,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> reviewedAt(DateTime? value) =>
      _is.ColumnValue(
        table.reviewedAt,
        value,
      );

  _is.ColumnValue<String, String> reviewerUserId(String? value) =>
      _is.ColumnValue(
        table.reviewerUserId,
        value,
      );

  _is.ColumnValue<String, String> rejectionReason(String? value) =>
      _is.ColumnValue(
        table.rejectionReason,
        value,
      );
}

class PromiseAttachmentTable extends _is.Table<int?> {
  PromiseAttachmentTable({super.tableRelation})
    : super(tableName: 'promise_attachment') {
    updateTable = PromiseAttachmentUpdateTable(this);
    promiseId = _is.ColumnInt(
      'promiseId',
      this,
    );
    uploaderUserId = _is.ColumnString(
      'uploaderUserId',
      this,
    );
    storageId = _is.ColumnString(
      'storageId',
      this,
    );
    path = _is.ColumnString(
      'path',
      this,
    );
    fileName = _is.ColumnString(
      'fileName',
      this,
    );
    mimeType = _is.ColumnString(
      'mimeType',
      this,
    );
    fileSize = _is.ColumnInt(
      'fileSize',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    approvalStatus = _is.ColumnString(
      'approvalStatus',
      this,
    );
    reviewedAt = _is.ColumnDateTime(
      'reviewedAt',
      this,
    );
    reviewerUserId = _is.ColumnString(
      'reviewerUserId',
      this,
    );
    rejectionReason = _is.ColumnString(
      'rejectionReason',
      this,
    );
  }

  late final PromiseAttachmentUpdateTable updateTable;

  late final _is.ColumnInt promiseId;

  late final _is.ColumnString uploaderUserId;

  late final _is.ColumnString storageId;

  late final _is.ColumnString path;

  late final _is.ColumnString fileName;

  late final _is.ColumnString mimeType;

  late final _is.ColumnInt fileSize;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnString approvalStatus;

  late final _is.ColumnDateTime reviewedAt;

  late final _is.ColumnString reviewerUserId;

  late final _is.ColumnString rejectionReason;

  @override
  List<_is.Column> get columns => [
    id,
    promiseId,
    uploaderUserId,
    storageId,
    path,
    fileName,
    mimeType,
    fileSize,
    createdAt,
    approvalStatus,
    reviewedAt,
    reviewerUserId,
    rejectionReason,
  ];
}

class PromiseAttachmentInclude extends _is.IncludeObject {
  PromiseAttachmentInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PromiseAttachment.t;
}

class PromiseAttachmentIncludeList extends _is.IncludeList {
  PromiseAttachmentIncludeList._({
    _is.WhereExpressionBuilder<PromiseAttachmentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PromiseAttachment.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PromiseAttachment.t;
}

class PromiseAttachmentRepository {
  const PromiseAttachmentRepository._();

  /// Returns a list of [PromiseAttachment]s matching the given query parameters.
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
  Future<List<PromiseAttachment>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromiseAttachmentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromiseAttachmentTable>? orderBy,
    _is.OrderByListBuilder<PromiseAttachmentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PromiseAttachment>(
      where: where?.call(PromiseAttachment.t),
      orderBy: orderBy?.call(PromiseAttachment.t),
      orderByList: orderByList?.call(PromiseAttachment.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PromiseAttachment] matching the given query parameters.
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
  Future<PromiseAttachment?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromiseAttachmentTable>? where,
    int? offset,
    _is.OrderByBuilder<PromiseAttachmentTable>? orderBy,
    _is.OrderByListBuilder<PromiseAttachmentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PromiseAttachment>(
      where: where?.call(PromiseAttachment.t),
      orderBy: orderBy?.call(PromiseAttachment.t),
      orderByList: orderByList?.call(PromiseAttachment.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PromiseAttachment] by its [id] or null if no such row exists.
  Future<PromiseAttachment?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PromiseAttachment>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PromiseAttachment]s in the list and returns the inserted rows.
  ///
  /// The returned [PromiseAttachment]s will have their `id` fields set.
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
  Future<List<PromiseAttachment>> insert(
    _is.DatabaseSession session,
    List<PromiseAttachment> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PromiseAttachment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PromiseAttachment] and returns the inserted row.
  ///
  /// The returned [PromiseAttachment] will have its `id` field set.
  Future<PromiseAttachment> insertRow(
    _is.DatabaseSession session,
    PromiseAttachment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PromiseAttachment>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PromiseAttachment]s in the list and returns the resulting rows.
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
  /// The returned [PromiseAttachment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromiseAttachment>> upsert(
    _is.DatabaseSession session,
    List<PromiseAttachment> rows, {
    required _is.ColumnSelections<PromiseAttachmentTable> conflictColumns,
    _is.ColumnSelections<PromiseAttachmentTable>? updateColumns,
    _is.WhereExpressionBuilder<PromiseAttachmentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PromiseAttachment>(
      rows,
      conflictColumns: conflictColumns(PromiseAttachment.t),
      updateColumns: updateColumns?.call(PromiseAttachment.t),
      updateWhere: updateWhere?.call(PromiseAttachment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PromiseAttachment] and returns the resulting row.
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
  /// The returned [PromiseAttachment] will have its `id` field set.
  Future<PromiseAttachment?> upsertRow(
    _is.DatabaseSession session,
    PromiseAttachment row, {
    required _is.ColumnSelections<PromiseAttachmentTable> conflictColumns,
    _is.ColumnSelections<PromiseAttachmentTable>? updateColumns,
    _is.WhereExpressionBuilder<PromiseAttachmentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PromiseAttachment>(
      row,
      conflictColumns: conflictColumns(PromiseAttachment.t),
      updateColumns: updateColumns?.call(PromiseAttachment.t),
      updateWhere: updateWhere?.call(PromiseAttachment.t),
      transaction: transaction,
    );
  }

  /// Updates all [PromiseAttachment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromiseAttachment>> update(
    _is.DatabaseSession session,
    List<PromiseAttachment> rows, {
    _is.ColumnSelections<PromiseAttachmentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PromiseAttachment>(
      rows,
      columns: columns?.call(PromiseAttachment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PromiseAttachment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PromiseAttachment> updateRow(
    _is.DatabaseSession session,
    PromiseAttachment row, {
    _is.ColumnSelections<PromiseAttachmentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PromiseAttachment>(
      row,
      columns: columns?.call(PromiseAttachment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PromiseAttachment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PromiseAttachment?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PromiseAttachmentUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PromiseAttachment>(
      id,
      columnValues: columnValues(PromiseAttachment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PromiseAttachment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PromiseAttachment>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PromiseAttachmentUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<PromiseAttachmentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PromiseAttachmentTable>? orderBy,
    _is.OrderByListBuilder<PromiseAttachmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PromiseAttachment>(
      columnValues: columnValues(PromiseAttachment.t.updateTable),
      where: where(PromiseAttachment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PromiseAttachment.t),
      orderByList: orderByList?.call(PromiseAttachment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PromiseAttachment]s in the list and returns the deleted rows.
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
  Future<List<PromiseAttachment>> delete(
    _is.DatabaseSession session,
    List<PromiseAttachment> rows, {
    _is.OrderByBuilder<PromiseAttachmentTable>? orderBy,
    _is.OrderByListBuilder<PromiseAttachmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PromiseAttachment>(
      rows,
      orderBy: orderBy?.call(PromiseAttachment.t),
      orderByList: orderByList?.call(PromiseAttachment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PromiseAttachment].
  Future<PromiseAttachment> deleteRow(
    _is.DatabaseSession session,
    PromiseAttachment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PromiseAttachment>(
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
  Future<List<PromiseAttachment>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PromiseAttachmentTable> where,
    _is.OrderByBuilder<PromiseAttachmentTable>? orderBy,
    _is.OrderByListBuilder<PromiseAttachmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PromiseAttachment>(
      where: where(PromiseAttachment.t),
      orderBy: orderBy?.call(PromiseAttachment.t),
      orderByList: orderByList?.call(PromiseAttachment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PromiseAttachmentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PromiseAttachment>(
      where: where?.call(PromiseAttachment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PromiseAttachment] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PromiseAttachmentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PromiseAttachment>(
      where: where(PromiseAttachment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
