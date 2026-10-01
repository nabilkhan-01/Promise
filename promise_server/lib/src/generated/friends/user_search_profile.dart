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

abstract class UserSearchProfile
    implements _is.SerializableModel, _is.ProtocolSerialization {
  UserSearchProfile._({
    required this.userId,
    this.userName,
    required this.email,
    this.friendshipStatus,
    this.friendshipId,
  });

  factory UserSearchProfile({
    required String userId,
    String? userName,
    required String email,
    String? friendshipStatus,
    int? friendshipId,
  }) = _UserSearchProfileImpl;

  factory UserSearchProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserSearchProfile(
      userId: jsonSerialization['userId'] as String,
      userName: jsonSerialization['userName'] as String?,
      email: jsonSerialization['email'] as String,
      friendshipStatus: jsonSerialization['friendshipStatus'] as String?,
      friendshipId: jsonSerialization['friendshipId'] as int?,
    );
  }

  String userId;

  String? userName;

  String email;

  String? friendshipStatus;

  int? friendshipId;

  /// Returns a shallow copy of this [UserSearchProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  UserSearchProfile copyWith({
    String? userId,
    String? userName,
    String? email,
    String? friendshipStatus,
    int? friendshipId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserSearchProfile',
      'userId': userId,
      if (userName != null) 'userName': userName,
      'email': email,
      if (friendshipStatus != null) 'friendshipStatus': friendshipStatus,
      if (friendshipId != null) 'friendshipId': friendshipId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserSearchProfile',
      'userId': userId,
      if (userName != null) 'userName': userName,
      'email': email,
      if (friendshipStatus != null) 'friendshipStatus': friendshipStatus,
      if (friendshipId != null) 'friendshipId': friendshipId,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserSearchProfileImpl extends UserSearchProfile {
  _UserSearchProfileImpl({
    required String userId,
    String? userName,
    required String email,
    String? friendshipStatus,
    int? friendshipId,
  }) : super._(
         userId: userId,
         userName: userName,
         email: email,
         friendshipStatus: friendshipStatus,
         friendshipId: friendshipId,
       );

  /// Returns a shallow copy of this [UserSearchProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  UserSearchProfile copyWith({
    String? userId,
    Object? userName = _Undefined,
    String? email,
    Object? friendshipStatus = _Undefined,
    Object? friendshipId = _Undefined,
  }) {
    return UserSearchProfile(
      userId: userId ?? this.userId,
      userName: userName is String? ? userName : this.userName,
      email: email ?? this.email,
      friendshipStatus: friendshipStatus is String?
          ? friendshipStatus
          : this.friendshipStatus,
      friendshipId: friendshipId is int? ? friendshipId : this.friendshipId,
    );
  }
}
