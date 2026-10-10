import 'package:promise_server/src/notifications/notification_helper.dart';
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

    final isCreator = promise.creatorUserId == authUserId;
    final isRecipient = promise.recipientUserId == authUserId;

    if (!isCreator && !isRecipient) {
      return null;
    }

    return promise;
  }

  /// Initiates an upload flow by verifying participant access and generating an upload description.
  Future<String?> getUploadDescription(
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

    // Server-side size validation limit to 10 MB
    if (fileSize > 10 * 1024 * 1024) {
      throw ArgumentError('File exceeds 10MB maximum size limit.');
    }

    final ext = fileName.split('.').last.toLowerCase();
    if (!['pdf', 'png', 'jpg', 'jpeg'].contains(ext)) {
      throw ArgumentError('Only PDF, PNG, and JPEG files are supported.');
    }

    final uniqueFileName = '${Uuid().v4()}.$ext';
    final path = 'promises/$promiseId/attachments/$authUserId/$uniqueFileName';

    // We use UploadOptions to request that the storage provider enforce the size limit and prevent overwrite.
    return await session.storage.createUploadDescription(
      storageId: 'private',
      path: path,
      options: UploadOptions(
        maxFileSize: 10 * 1024 * 1024,
        contentLength: fileSize,
        preventOverwrite: true,
      ),
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

    // Path security: verify the path strictly belongs to the current user and promise
    if (!path.startsWith('promises/$promiseId/attachments/$authUserId/')) {
      throw ArgumentError('Invalid or unauthorized storage path.');
    }

    // Duplicate Check: ensure we haven't already verified this path.
    // If a user replays a successful verify call, do not create a duplicate row.
    final existing = await PromiseAttachment.db.findFirstRow(
      session,
      where: (t) => t.path.equals(path),
    );

    if (existing != null) {
      if (existing.promiseId == promiseId &&
          existing.uploaderUserId == authUserId) {
        // Idempotent return if the request is a legitimate retry for the same user/promise
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
        'Upload verification failed. File not found in storage.',
      );
    }

    final ext = originalFileName.split('.').last.toLowerCase();
    if (!['pdf', 'png', 'jpg', 'jpeg'].contains(ext)) {
      throw ArgumentError('Only PDF, PNG, and JPEG files are supported.');
    }
    if (fileSize > 10 * 1024 * 1024) {
      throw ArgumentError('File exceeds 10MB maximum size limit.');
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

    return await session.db.transaction((tx) async {
      final savedAttachment = await PromiseAttachment.db.insertRow(
        session,
        attachment,
        transaction: tx,
      );

      final otherUserId = promise.creatorUserId == authUserId
          ? promise.recipientUserId
          : promise.creatorUserId;

      if (otherUserId != null) {
        await NotificationHelper.createNotification(
          session,
          userId: otherUserId,
          type: 'promise_updated',
          title: 'Evidence Uploaded',
          message: 'A new attachment was uploaded to "${promise.title}".',
          promiseId: promiseId,
          transaction: tx,
        );
      }

      return savedAttachment;
    });
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
    if (attachment == null) return null;

    final promise = await _getAuthorizedPromise(session, attachment.promiseId);
    if (promise == null) {
      throw ArgumentError('Not authorized to access this attachment.');
    }

    final uri = await session.storage.temporaryDownloadUrl(
      storageId: attachment.storageId,
      path: attachment.path,
      options: TemporaryDownloadUrlOptions(
        expirationDuration: const Duration(minutes: 15),
        downloadFileName: attachment.fileName,
      ),
    );

    return uri.toString();
  }

  /// Approves or rejects a pending attachment. Only the other participant can review.
  Future<PromiseAttachment> reviewAttachment(
    Session session,
    int attachmentId,
    String decision,
    String? rejectionReason,
  ) async {
    final authUserId = _getAuthUserId(session);
    final cleanDecision = decision.trim().toLowerCase();

    if (cleanDecision != 'approved' && cleanDecision != 'rejected') {
      throw ArgumentError('Invalid decision. Must be approved or rejected.');
    }

    final attachment = await PromiseAttachment.db.findById(
      session,
      attachmentId,
    );
    if (attachment == null) {
      throw ArgumentError('Attachment not found.');
    }

    final promise = await _getAuthorizedPromise(session, attachment.promiseId);
    if (promise == null) {
      throw ArgumentError('Promise not found or access denied.');
    }

    if (attachment.uploaderUserId == authUserId) {
      throw ArgumentError('You cannot review your own attachment.');
    }

    if (attachment.approvalStatus != 'pending') {
      throw ArgumentError('This attachment has already been reviewed.');
    }

    if (cleanDecision == 'rejected' &&
        (rejectionReason == null || rejectionReason.trim().isEmpty)) {
      throw ArgumentError(
        'A reason must be provided when rejecting an attachment.',
      );
    }

    final updated = attachment.copyWith(
      approvalStatus: cleanDecision,
      reviewedAt: DateTime.now().toUtc(),
      reviewerUserId: authUserId,
      rejectionReason: cleanDecision == 'rejected'
          ? rejectionReason?.trim()
          : null,
    );

    return await session.db.transaction((tx) async {
      final savedAttachment = await PromiseAttachment.db.updateRow(
        session,
        updated,
        transaction: tx,
      );

      await NotificationHelper.createNotification(
        session,
        userId: attachment.uploaderUserId,
        type: cleanDecision == 'approved'
            ? 'promise_updated'
            : 'change_requested',
        title: cleanDecision == 'approved'
            ? 'Attachment Approved'
            : 'Attachment Rejected',
        message: cleanDecision == 'approved'
            ? 'Your attachment for "${promise.title}" was approved.'
            : 'Your attachment for "${promise.title}" was rejected: ${rejectionReason?.trim()}',
        promiseId: promise.id,
        transaction: tx,
      );

      return savedAttachment;
    });
  }
}
