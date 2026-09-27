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

abstract class PromiseActivity
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int promiseId;

  String type;

  String message;

  String? status;

  DateTime createdAt;

  /// Returns a shallow copy of this [PromiseActivity]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
  @_isc.useResult
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
