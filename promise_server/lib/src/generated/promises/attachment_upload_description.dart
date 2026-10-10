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

abstract class AttachmentUploadDescription
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AttachmentUploadDescription._({
    required this.uploadDescription,
    required this.path,
  });

  factory AttachmentUploadDescription({
    required String uploadDescription,
    required String path,
  }) = _AttachmentUploadDescriptionImpl;

  factory AttachmentUploadDescription.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AttachmentUploadDescription(
      uploadDescription: jsonSerialization['uploadDescription'] as String,
      path: jsonSerialization['path'] as String,
    );
  }

  String uploadDescription;

  String path;

  /// Returns a shallow copy of this [AttachmentUploadDescription]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AttachmentUploadDescription copyWith({
    String? uploadDescription,
    String? path,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AttachmentUploadDescription',
      'uploadDescription': uploadDescription,
      'path': path,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AttachmentUploadDescription',
      'uploadDescription': uploadDescription,
      'path': path,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AttachmentUploadDescriptionImpl extends AttachmentUploadDescription {
  _AttachmentUploadDescriptionImpl({
    required String uploadDescription,
    required String path,
  }) : super._(
         uploadDescription: uploadDescription,
         path: path,
       );

  /// Returns a shallow copy of this [AttachmentUploadDescription]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AttachmentUploadDescription copyWith({
    String? uploadDescription,
    String? path,
  }) {
    return AttachmentUploadDescription(
      uploadDescription: uploadDescription ?? this.uploadDescription,
      path: path ?? this.path,
    );
  }
}
