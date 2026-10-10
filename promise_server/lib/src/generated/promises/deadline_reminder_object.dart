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

abstract class DeadlineReminderObject
    implements _is.SerializableModel, _is.ProtocolSerialization {
  DeadlineReminderObject._({required this.promiseId});

  factory DeadlineReminderObject({required int promiseId}) =
      _DeadlineReminderObjectImpl;

  factory DeadlineReminderObject.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DeadlineReminderObject(
      promiseId: jsonSerialization['promiseId'] as int,
    );
  }

  int promiseId;

  /// Returns a shallow copy of this [DeadlineReminderObject]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DeadlineReminderObject copyWith({int? promiseId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeadlineReminderObject',
      'promiseId': promiseId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DeadlineReminderObject',
      'promiseId': promiseId,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _DeadlineReminderObjectImpl extends DeadlineReminderObject {
  _DeadlineReminderObjectImpl({required int promiseId})
    : super._(promiseId: promiseId);

  /// Returns a shallow copy of this [DeadlineReminderObject]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DeadlineReminderObject copyWith({int? promiseId}) {
    return DeadlineReminderObject(promiseId: promiseId ?? this.promiseId);
  }
}
