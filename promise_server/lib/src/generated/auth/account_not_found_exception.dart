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

abstract class AccountNotFoundException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  AccountNotFoundException._({required this.message});

  factory AccountNotFoundException({required String message}) =
      _AccountNotFoundExceptionImpl;

  factory AccountNotFoundException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AccountNotFoundException(
      message: jsonSerialization['message'] as String,
    );
  }

  String message;

  /// Returns a shallow copy of this [AccountNotFoundException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AccountNotFoundException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccountNotFoundException',
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AccountNotFoundException',
      'message': message,
    };
  }

  @override
  String toString() {
    return 'AccountNotFoundException(message: $message)';
  }
}

class _AccountNotFoundExceptionImpl extends AccountNotFoundException {
  _AccountNotFoundExceptionImpl({required String message})
    : super._(message: message);

  /// Returns a shallow copy of this [AccountNotFoundException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AccountNotFoundException copyWith({String? message}) {
    return AccountNotFoundException(message: message ?? this.message);
  }
}
