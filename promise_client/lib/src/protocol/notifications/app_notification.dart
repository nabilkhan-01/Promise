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

abstract class AppNotification
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppNotification._({
    this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.promiseId,
    this.friendshipId,
    required this.createdAt,
    this.readAt,
  });

  factory AppNotification({
    int? id,
    required String userId,
    required String type,
    required String title,
    required String message,
    int? promiseId,
    int? friendshipId,
    required DateTime createdAt,
    DateTime? readAt,
  }) = _AppNotificationImpl;

  factory AppNotification.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppNotification(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      type: jsonSerialization['type'] as String,
      title: jsonSerialization['title'] as String,
      message: jsonSerialization['message'] as String,
      promiseId: jsonSerialization['promiseId'] as int?,
      friendshipId: jsonSerialization['friendshipId'] as int?,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      readAt: jsonSerialization['readAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['readAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String userId;

  String type;

  String title;

  String message;

  int? promiseId;

  int? friendshipId;

  DateTime createdAt;

  DateTime? readAt;

  /// Returns a shallow copy of this [AppNotification]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppNotification copyWith({
    int? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    int? promiseId,
    int? friendshipId,
    DateTime? createdAt,
    DateTime? readAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppNotification',
      if (id != null) 'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      if (promiseId != null) 'promiseId': promiseId,
      if (friendshipId != null) 'friendshipId': friendshipId,
      'createdAt': createdAt.toJson(),
      if (readAt != null) 'readAt': readAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppNotification',
      if (id != null) 'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      if (promiseId != null) 'promiseId': promiseId,
      if (friendshipId != null) 'friendshipId': friendshipId,
      'createdAt': createdAt.toJson(),
      if (readAt != null) 'readAt': readAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AppNotificationImpl extends AppNotification {
  _AppNotificationImpl({
    int? id,
    required String userId,
    required String type,
    required String title,
    required String message,
    int? promiseId,
    int? friendshipId,
    required DateTime createdAt,
    DateTime? readAt,
  }) : super._(
         id: id,
         userId: userId,
         type: type,
         title: title,
         message: message,
         promiseId: promiseId,
         friendshipId: friendshipId,
         createdAt: createdAt,
         readAt: readAt,
       );

  /// Returns a shallow copy of this [AppNotification]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppNotification copyWith({
    Object? id = _Undefined,
    String? userId,
    String? type,
    String? title,
    String? message,
    Object? promiseId = _Undefined,
    Object? friendshipId = _Undefined,
    DateTime? createdAt,
    Object? readAt = _Undefined,
  }) {
    return AppNotification(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      promiseId: promiseId is int? ? promiseId : this.promiseId,
      friendshipId: friendshipId is int? ? friendshipId : this.friendshipId,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt is DateTime? ? readAt : this.readAt,
    );
  }
}
