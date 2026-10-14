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

abstract class ParentProjectMetadata
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ParentProjectMetadata._({
    required this.id,
    required this.title,
    this.description,
    this.commitmentType,
    required this.status,
    required this.dueDate,
    this.dueTime,
    required this.createdAt,
  });

  factory ParentProjectMetadata({
    required int id,
    required String title,
    String? description,
    String? commitmentType,
    required String status,
    required DateTime dueDate,
    DateTime? dueTime,
    required DateTime createdAt,
  }) = _ParentProjectMetadataImpl;

  factory ParentProjectMetadata.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ParentProjectMetadata(
      id: jsonSerialization['id'] as int,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String?,
      commitmentType: jsonSerialization['commitmentType'] as String?,
      status: jsonSerialization['status'] as String,
      dueDate: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['dueDate'],
      ),
      dueTime: jsonSerialization['dueTime'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['dueTime']),
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  int id;

  String title;

  String? description;

  String? commitmentType;

  String status;

  DateTime dueDate;

  DateTime? dueTime;

  DateTime createdAt;

  /// Returns a shallow copy of this [ParentProjectMetadata]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ParentProjectMetadata copyWith({
    int? id,
    String? title,
    String? description,
    String? commitmentType,
    String? status,
    DateTime? dueDate,
    DateTime? dueTime,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ParentProjectMetadata',
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      if (commitmentType != null) 'commitmentType': commitmentType,
      'status': status,
      'dueDate': dueDate.toJson(),
      if (dueTime != null) 'dueTime': dueTime?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ParentProjectMetadata',
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      if (commitmentType != null) 'commitmentType': commitmentType,
      'status': status,
      'dueDate': dueDate.toJson(),
      if (dueTime != null) 'dueTime': dueTime?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ParentProjectMetadataImpl extends ParentProjectMetadata {
  _ParentProjectMetadataImpl({
    required int id,
    required String title,
    String? description,
    String? commitmentType,
    required String status,
    required DateTime dueDate,
    DateTime? dueTime,
    required DateTime createdAt,
  }) : super._(
         id: id,
         title: title,
         description: description,
         commitmentType: commitmentType,
         status: status,
         dueDate: dueDate,
         dueTime: dueTime,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ParentProjectMetadata]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ParentProjectMetadata copyWith({
    int? id,
    String? title,
    Object? description = _Undefined,
    Object? commitmentType = _Undefined,
    String? status,
    DateTime? dueDate,
    Object? dueTime = _Undefined,
    DateTime? createdAt,
  }) {
    return ParentProjectMetadata(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description is String? ? description : this.description,
      commitmentType: commitmentType is String?
          ? commitmentType
          : this.commitmentType,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime is DateTime? ? dueTime : this.dueTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
