import 'package:promise_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  const user1 = '11111111-1111-4111-a111-111111111111';
  const user2 = '22222222-2222-4222-a222-222222222222';
  const unrelatedUser = '33333333-3333-4333-a333-333333333333';

  withServerpod('Given Attachment endpoint', (sessionBuilder, endpoints) {
    late int testPromiseId;

    setUp(() async {
      final session = sessionBuilder.build();
      final promise = Promise(
        title: 'Test Attachment Promise',
        promisedTo: 'User2',
        creatorUserId: user1,
        recipientUserId: user2,
        recipientAccepted: true,
        dueDate: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        status: 'pending',
      );
      final p = await Promise.db.insertRow(session, promise);
      testPromiseId = p.id!;
    });

    test('participant can request upload description', () async {
      final user1Session = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(user1, {}),
      );

      final desc = await endpoints.attachment.getUploadDescription(
        user1Session,
        testPromiseId,
        'receipt.png',
        1024,
      );

      expect(desc, isNotNull);
      expect(desc, isA<AttachmentUploadDescription>());
      expect(desc?.uploadDescription, isNotEmpty);
      expect(desc?.path, contains('.png'));
    });

    test('non-participant cannot request upload description', () async {
      final unrelatedSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          unrelatedUser,
          {},
        ),
      );

      expect(
        () => endpoints.attachment.getUploadDescription(
          unrelatedSession,
          testPromiseId,
          'receipt.png',
          1024,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('access denied'),
          ),
        ),
      );
    });

    test('upload rejects unsupported file types', () async {
      final user1Session = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(user1, {}),
      );

      expect(
        () => endpoints.attachment.getUploadDescription(
          user1Session,
          testPromiseId,
          'malware.exe',
          1024,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('verify upload fails if file not actually in storage', () async {
      final user1Session = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(user1, {}),
      );

      final uploadData = await endpoints.attachment.getUploadDescription(
        user1Session,
        testPromiseId,
        'receipt.pdf',
        1024,
      );

      expect(
        () => endpoints.attachment.verifyAttachment(
          user1Session,
          testPromiseId,
          uploadData!.path,
          'receipt.pdf',
          1024,
          'application/pdf',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('File was not found in storage'),
          ),
        ),
      );
    });

    test('uploader cannot approve their own attachment', () async {
      final session = sessionBuilder.build();
      final attachment = PromiseAttachment(
        promiseId: testPromiseId,
        uploaderUserId: user1,
        storageId: 'private',
        path: 'dummy/path.pdf',
        fileName: 'receipt.pdf',
        mimeType: 'application/pdf',
        fileSize: 1024,
        createdAt: DateTime.now().toUtc(),
        approvalStatus: 'pending',
      );
      final saved = await PromiseAttachment.db.insertRow(session, attachment);

      final user1Session = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(user1, {}),
      );

      expect(
        () => endpoints.attachment.reviewAttachment(
          user1Session,
          saved.id!,
          'approved',
          rejectionReason: null,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('cannot review their own'),
          ),
        ),
      );
    });

    test('other participant can reject attachment', () async {
      final session = sessionBuilder.build();
      final attachment = PromiseAttachment(
        promiseId: testPromiseId,
        uploaderUserId: user1,
        storageId: 'private',
        path: 'dummy/path.pdf',
        fileName: 'receipt.pdf',
        mimeType: 'application/pdf',
        fileSize: 1024,
        createdAt: DateTime.now().toUtc(),
        approvalStatus: 'pending',
      );
      final saved = await PromiseAttachment.db.insertRow(session, attachment);

      final user2Session = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(user2, {}),
      );

      final reviewed = await endpoints.attachment.reviewAttachment(
        user2Session,
        saved.id!,
        'rejected',
        rejectionReason: 'Blurry photo',
      );

      expect(reviewed.approvalStatus, 'rejected');
      expect(reviewed.reviewerUserId, user2);
      expect(reviewed.rejectionReason, 'Blurry photo');
    });

    test('authorized participant can generate download url', () async {
      final user1Session = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(user1, {}),
      );

      final uploadData = await endpoints.attachment.getUploadDescription(
        user1Session,
        testPromiseId,
        'download.pdf',
        1024,
      );
      final actualPath = uploadData!.path;

      final session = sessionBuilder.build();

      await session.db.unsafeQuery(
        'INSERT INTO serverpod_cloud_storage ("storageId", "path", "addedTime", "expiration", "byteData", "verified") VALUES (\'private\', \'$actualPath\', NOW(), NULL, decode(\'00\', \'hex\'), true)',
      );

      final attachment = PromiseAttachment(
        promiseId: testPromiseId,
        uploaderUserId: user1,
        storageId: 'private',
        path: actualPath,
        fileName: 'download.pdf',
        mimeType: 'application/pdf',
        fileSize: 1024,
        createdAt: DateTime.now().toUtc(),
        approvalStatus: 'pending',
      );
      final saved = await PromiseAttachment.db.insertRow(session, attachment);

      final url = await endpoints.attachment.getDownloadUrl(
        user1Session,
        saved.id!,
      );
      expect(url, isNotNull);
      expect(url, contains('.pdf'));
    });

    test('unauthorized user cannot generate download url', () async {
      final session = sessionBuilder.build();
      final attachment = PromiseAttachment(
        promiseId: testPromiseId,
        uploaderUserId: user1,
        storageId: 'private',
        path: 'dummy/private.pdf',
        fileName: 'private.pdf',
        mimeType: 'application/pdf',
        fileSize: 1024,
        createdAt: DateTime.now().toUtc(),
        approvalStatus: 'pending',
      );
      final saved = await PromiseAttachment.db.insertRow(session, attachment);

      final unrelatedSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          unrelatedUser,
          {},
        ),
      );

      expect(
        () => endpoints.attachment.getDownloadUrl(unrelatedSession, saved.id!),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('denied'),
          ),
        ),
      );
    });

    test('other participant can approve attachment', () async {
      final session = sessionBuilder.build();
      final attachment = PromiseAttachment(
        promiseId: testPromiseId,
        uploaderUserId: user1,
        storageId: 'private',
        path: 'dummy/approve.pdf',
        fileName: 'approve.pdf',
        mimeType: 'application/pdf',
        fileSize: 1024,
        createdAt: DateTime.now().toUtc(),
        approvalStatus: 'pending',
      );
      final saved = await PromiseAttachment.db.insertRow(session, attachment);

      final user2Session = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(user2, {}),
      );

      final reviewed = await endpoints.attachment.reviewAttachment(
        user2Session,
        saved.id!,
        'approved',
        rejectionReason: null,
      );

      expect(reviewed.approvalStatus, 'approved');
      expect(reviewed.reviewerUserId, user2);
    });

    test(
      'duplicate verification is idempotent and returns existing attachment',
      () async {
        final user1Session = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(user1, {}),
        );

        final session = sessionBuilder.build();
        final attachment = PromiseAttachment(
          promiseId: testPromiseId,
          uploaderUserId: user1,
          storageId: 'private',
          path: 'promises/$testPromiseId/attachments/$user1/duplicate.pdf',
          fileName: 'duplicate.pdf',
          mimeType: 'application/pdf',
          fileSize: 1024,
          createdAt: DateTime.now().toUtc(),
          approvalStatus: 'pending',
        );
        final saved = await PromiseAttachment.db.insertRow(session, attachment);

        final verified = await endpoints.attachment.verifyAttachment(
          user1Session,
          testPromiseId,
          'promises/$testPromiseId/attachments/$user1/duplicate.pdf',
          'duplicate.pdf',
          1024,
          'application/pdf',
        );

        expect(verified.id, saved.id);
      },
    );

    test('requesting upload for file > 10MB fails', () async {
      final user1Session = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(user1, {}),
      );

      expect(
        () => endpoints.attachment.getUploadDescription(
          user1Session,
          testPromiseId,
          'large.pdf',
          11 * 1024 * 1024,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('exceeds 10MB'),
          ),
        ),
      );
    });
  });
}
