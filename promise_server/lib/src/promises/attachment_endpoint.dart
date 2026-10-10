import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../generated/protocol.dart';

class AttachmentEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  String _getAuthUserId(Session session) {
    final authUserId = session.authenticated?.authUserId.toString();
    if (authUserId == null) {
      throw ArgumentError('Authentication required.');
    }
    return authUserId;
  }

  Future<Promise?> _getAuthorizedPromise(Session session, int promiseId) async {
    final authUserId = _getAuthUserId(session);
    final promise = await Promise.db.findById(session, promiseId);

    if (promise == null) return null;

    if (promise.creatorUserId == authUserId ||
        promise.recipientUserId == authUserId) {
      return promise;
    }

    return null;
  }

  /// Initiates an upload flow by verifying participant access and generating an upload description.
  Future<AttachmentUploadDescription?> getUploadDescription(
    Session session,
    int promiseId,
    String fileName,
    int fileSize,
  ) async {
    final authUserId = _getAuthUserId(session);
    final promise = await _getAuthorizedPromise(session, promiseId);

    if (promise == null) {
      throw ArgumentError('Promise not found or access denied.');
    }

    if (promise.recipientUserId != null && !promise.recipientAccepted) {
      throw ArgumentError(
        'Cannot upload attachments before the promise is accepted by the recipient.',
      );
    }

    if (fileSize > 10 * 1024 * 1024) {
      throw ArgumentError('File exceeds 10MB maximum size limit.');
    }

    final ext = fileName.split('.').last.toLowerCase();
    if (!['pdf', 'png', 'jpg', 'jpeg'].contains(ext)) {
      throw ArgumentError('Only PDF, PNG, and JPEG files are supported.');
    }

    final uniqueFileName = '${Uuid().v4()}.$ext';
    final path = 'promises/$promiseId/attachments/$authUserId/$uniqueFileName';

    final uploadDescription = await session.storage.createUploadDescription(
      storageId: 'private',
      path: path,
      options: UploadOptions(
        maxFileSize: 10 * 1024 * 1024,
        contentLength: fileSize,
        preventOverwrite: true,
      ),
    );

    return AttachmentUploadDescription(
      uploadDescription: uploadDescription,
      path: path,
    );
  }

  /// Verifies that an upload succeeded and creates the `PromiseAttachment` database record.
  Future<PromiseAttachment> verifyAttachment(
    Session session,
    int promiseId,
    String path,
    String originalFileName,
    int fileSize,
    String mimeType,
  ) async {
    final authUserId = _getAuthUserId(session);
    final promise = await _getAuthorizedPromise(session, promiseId);

    if (promise == null) {
      throw ArgumentError('Promise not found or access denied.');
    }

    if (promise.recipientUserId != null && !promise.recipientAccepted) {
      throw ArgumentError(
        'Cannot verify attachments before the promise is accepted by the recipient.',
      );
    }

    if (!path.startsWith('promises/$promiseId/attachments/$authUserId/')) {
      throw ArgumentError('Invalid or unauthorized storage path.');
    }

    final existing = await PromiseAttachment.db.findFirstRow(
      session,
      where: (t) => t.path.equals(path),
    );

    if (existing != null) {
      if (existing.promiseId == promiseId &&
          existing.uploaderUserId == authUserId) {
        return existing;
      }
      throw ArgumentError(
        'Path is already associated with another attachment.',
      );
    }

    final isUploaded = await session.storage.verifyUpload(
      storageId: 'private',
      path: path,
    );

    if (!isUploaded) {
      throw ArgumentError(
        'Upload verification failed. File was not found in storage.',
      );
    }

    final attachment = PromiseAttachment(
      promiseId: promiseId,
      uploaderUserId: authUserId,
      storageId: 'private',
      path: path,
      fileName: originalFileName,
      mimeType: mimeType,
      fileSize: fileSize,
      createdAt: DateTime.now().toUtc(),
      approvalStatus: 'pending',
    );

    return await PromiseAttachment.db.insertRow(session, attachment);
  }

  /// Retrieves the list of attachments for a promise.
  Future<List<PromiseAttachment>> getAttachments(
    Session session,
    int promiseId,
  ) async {
    final promise = await _getAuthorizedPromise(session, promiseId);
    if (promise == null) {
      throw ArgumentError('Promise not found or access denied.');
    }

    return await PromiseAttachment.db.find(
      session,
      where: (t) => t.promiseId.equals(promiseId),
      orderBy: (t) => t.createdAt.desc(),
    );
  }

  /// Generates a time-limited download URL for an attachment if authorized.
  Future<String?> getDownloadUrl(Session session, int attachmentId) async {
    final attachment = await PromiseAttachment.db.findById(
      session,
      attachmentId,
    );
    if (attachment == null) {
      throw ArgumentError('Attachment not found.');
    }

    final promise = await _getAuthorizedPromise(session, attachment.promiseId);
    if (promise == null) {
      throw ArgumentError('Access denied.');
    }

    final uri = await session.storage.temporaryDownloadUrl(
      storageId: attachment.storageId,
      path: attachment.path,
    );
    return uri.toString();
  }

  /// Approves or rejects a pending attachment. Only the other participant can review.
  Future<PromiseAttachment> reviewAttachment(
    Session session,
    int attachmentId,
    String decision, {
    String? rejectionReason,
  }) async {
    final authUserId = _getAuthUserId(session);
    final attachment = await PromiseAttachment.db.findById(
      session,
      attachmentId,
    );

    if (attachment == null) {
      throw ArgumentError('Attachment not found.');
    }

    final promise = await _getAuthorizedPromise(session, attachment.promiseId);
    if (promise == null) {
      throw ArgumentError('Access denied.');
    }

    if (promise.recipientUserId != null && !promise.recipientAccepted) {
      throw ArgumentError(
        'Cannot review attachments before the promise is accepted by the recipient.',
      );
    }

    if (attachment.uploaderUserId == authUserId) {
      throw ArgumentError('The uploader cannot review their own attachment.');
    }

    if (!['approved', 'rejected'].contains(decision)) {
      throw ArgumentError('Decision must be "approved" or "rejected".');
    }

    final updated = attachment.copyWith(
      approvalStatus: decision,
      reviewedAt: DateTime.now().toUtc(),
      reviewerUserId: authUserId,
      rejectionReason: decision == 'rejected' ? rejectionReason : null,
    );

    return await PromiseAttachment.db.updateRow(session, updated);
  }
}
