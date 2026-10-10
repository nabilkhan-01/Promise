import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../notifications/notification_helper.dart';

class DeadlineReminderFutureCall extends FutureCall<DeadlineReminderObject> {
  Future<void> invoke(Session session, DeadlineReminderObject? object) async {
    if (object == null) return;
    final promiseId = object.promiseId;

    final promise = await Promise.db.findById(session, promiseId);
    if (promise == null) return;

    if (promise.status == 'completed' || !promise.recipientAccepted) {
      return;
    }

    final title = promise.title;
    final creatorId = promise.creatorUserId;
    final recipientId = promise.recipientUserId;

    await session.db.transaction((tx) async {
      final userIds = [creatorId, recipientId].whereType<String>().toSet();

      for (final userId in userIds) {
        final existing = await AppNotification.db.findFirstRow(
          session,
          where: (t) =>
              t.userId.equals(userId) &
              t.promiseId.equals(promiseId) &
              t.title.equals('Deadline Reminder'),
          transaction: tx,
        );

        if (existing == null) {
          await NotificationHelper.createNotification(
            session,
            userId: userId,
            type: 'promise_updated',
            title: 'Deadline Reminder',
            message:
                'Deadline reminder: "$title" is approaching. Please check its due date.',
            promiseId: promiseId,
            transaction: tx,
          );
        }
      }
    });
  }
}
