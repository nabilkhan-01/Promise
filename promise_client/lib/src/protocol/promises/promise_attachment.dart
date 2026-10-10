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

abstract class PromiseAttachment
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      approvalStatus: jsonSerialization['approvalStatus'] as String,
      reviewedAt: jsonSerialization['reviewedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['reviewedAt'],
            ),
      reviewerUserId: jsonSerialization['reviewerUserId'] as String?,
      rejectionReason: jsonSerialization['rejectionReason'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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

  /// Returns a shallow copy of this [PromiseAttachment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
  @_isc.useResult
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
