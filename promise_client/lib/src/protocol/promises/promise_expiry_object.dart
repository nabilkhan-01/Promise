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

abstract class PromiseExpiryObject
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PromiseExpiryObject._({required this.promiseId});

  factory PromiseExpiryObject({required int promiseId}) =
      _PromiseExpiryObjectImpl;

  factory PromiseExpiryObject.fromJson(Map<String, dynamic> jsonSerialization) {
    return PromiseExpiryObject(
      promiseId: jsonSerialization['promiseId'] as int,
    );
  }

  int promiseId;

  /// Returns a shallow copy of this [PromiseExpiryObject]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PromiseExpiryObject copyWith({int? promiseId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PromiseExpiryObject',
      'promiseId': promiseId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PromiseExpiryObject',
      'promiseId': promiseId,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _PromiseExpiryObjectImpl extends PromiseExpiryObject {
  _PromiseExpiryObjectImpl({required int promiseId})
    : super._(promiseId: promiseId);

  /// Returns a shallow copy of this [PromiseExpiryObject]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PromiseExpiryObject copyWith({int? promiseId}) {
    return PromiseExpiryObject(promiseId: promiseId ?? this.promiseId);
  }
}
