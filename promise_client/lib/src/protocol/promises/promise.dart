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

abstract class Promise
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
  }) : creatorConfirmed = creatorConfirmed ?? false,
       recipientConfirmed = recipientConfirmed ?? false;

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
  }) = _PromiseImpl;

  factory Promise.fromJson(Map<String, dynamic> jsonSerialization) {
    return Promise(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      promisedTo: jsonSerialization['promisedTo'] as String,
      description: jsonSerialization['description'] as String?,
      dueDate: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['dueDate'],
      ),
      dueTime: jsonSerialization['dueTime'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['dueTime']),
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      status: jsonSerialization['status'] as String,
      creatorConfirmed: jsonSerialization['creatorConfirmed'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['creatorConfirmed'],
            ),
      recipientConfirmed: jsonSerialization['recipientConfirmed'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['recipientConfirmed'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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

  /// Returns a shallow copy of this [Promise]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
       );

  /// Returns a shallow copy of this [Promise]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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
    );
  }
}
