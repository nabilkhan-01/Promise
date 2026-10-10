import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../notifications/notification_helper.dart';

class PromiseExpiryFutureCall extends FutureCall<PromiseExpiryObject> {
  Future<void> invoke(Session session, PromiseExpiryObject? object) async {
    if (object == null) return;
    final promiseId = object.promiseId;

    final promise = await Promise.db.findById(session, promiseId);
    if (promise == null) return;

    if (promise.recipientAccepted) return;

    final now = DateTime.now().toUtc();
    final age = now.difference(promise.createdAt);
    if (age.inDays < 7) {
      return;
    }

    final creatorId = promise.creatorUserId;
    final title = promise.title;
    final parentId = promise.parentPromiseId;

    final attachments = await PromiseAttachment.db.find(
      session,
      where: (t) => t.promiseId.equals(promiseId),
    );

    for (final att in attachments) {
      try {
        await session.storage.deleteFile(
          storageId: att.storageId,
          path: att.path,
        );
      } catch (_) {}
    }

    await session.db.transaction((tx) async {
      await AppNotification.db.deleteWhere(
        session,
        where: (t) => t.promiseId.equals(promiseId),
        transaction: tx,
      );

      await PromiseActivity.db.deleteWhere(
        session,
        where: (t) => t.promiseId.equals(promiseId),
        transaction: tx,
      );

      await PromiseAttachment.db.deleteWhere(
        session,
        where: (t) => t.promiseId.equals(promiseId),
        transaction: tx,
      );

      await Promise.db.deleteRow(session, promise, transaction: tx);

      if (creatorId != null) {
        await NotificationHelper.createNotification(
          session,
          userId: creatorId,
          type: 'promise_status_changed',
          title: 'Invitation Expired',
          message:
              'Invitation for "$title" expired after 7 days without acceptance.',
          promiseId: null,
          transaction: tx,
        );
      }

      if (parentId != null) {
        final remainingChildren = await Promise.db.find(
          session,
          where: (t) => t.parentPromiseId.equals(parentId),
          transaction: tx,
        );

        if (remainingChildren.isEmpty) {
          final parent = await Promise.db.findById(
            session,
            parentId,
            transaction: tx,
          );
          if (parent != null) {
            await PromiseActivity.db.deleteWhere(
              session,
              where: (t) => t.promiseId.equals(parentId),
              transaction: tx,
            );
            await Promise.db.deleteRow(session, parent, transaction: tx);
          }
        }
      }
    });
  }
}
