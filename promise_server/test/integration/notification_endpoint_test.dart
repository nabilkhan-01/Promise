import 'package:promise_server/src/notifications/notification_helper.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  const user1 = '11111111-1111-4111-a111-111111111111';
  const user2 = '22222222-2222-4222-a222-222222222222';

  withServerpod('Given Notification endpoint', (sessionBuilder, endpoints) {
    test(
      'when user creates and reads notifications then unread count updates correctly',
      () async {
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user1,
            {},
          ),
        );

        final session = sessionBuilder.build();
        await NotificationHelper.createNotification(
          session,
          userId: user1,
          type: 'promise_created',
          title: 'New Promise',
          message: 'Test notification',
          promiseId: 1,
        );

        final unreadBefore = await endpoints.notification
            .getUnreadNotificationCount(
              authenticatedSession,
            );
        expect(unreadBefore, equals(1));

        final notifications = await endpoints.notification.getNotifications(
          authenticatedSession,
        );
        expect(notifications.length, equals(1));
        expect(notifications.first.userId, equals(user1));
        expect(notifications.first.readAt, isNull);

        final updated = await endpoints.notification.markNotificationRead(
          authenticatedSession,
          notifications.first.id!,
        );
        expect(updated?.readAt, isNotNull);

        final unreadAfter = await endpoints.notification
            .getUnreadNotificationCount(
              authenticatedSession,
            );
        expect(unreadAfter, equals(0));
      },
    );

    test('user cannot read notifications belonging to another user', () async {
      final session = sessionBuilder.build();
      final user2Session = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          user2,
          {},
        ),
      );

      final notif = await NotificationHelper.createNotification(
        session,
        userId: user1,
        type: 'promise_created',
        title: 'Secret',
        message: 'Only for user1',
      );

      final user2Notifications = await endpoints.notification.getNotifications(
        user2Session,
      );
      expect(user2Notifications, isEmpty);

      expect(
        () => endpoints.notification.markNotificationRead(
          user2Session,
          notif.id!,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'markAllNotificationsRead marks all unread notifications read for user',
      () async {
        final userSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user1,
            {},
          ),
        );
        final session = sessionBuilder.build();

        await NotificationHelper.createNotification(
          session,
          userId: user1,
          type: 'friend_request',
          title: 'FR 1',
          message: 'Request 1',
        );
        await NotificationHelper.createNotification(
          session,
          userId: user1,
          type: 'friend_request',
          title: 'FR 2',
          message: 'Request 2',
        );

        final countBefore = await endpoints.notification
            .getUnreadNotificationCount(
              userSession,
            );
        expect(countBefore, equals(2));

        final markedCount = await endpoints.notification
            .markAllNotificationsRead(
              userSession,
            );
        expect(markedCount, equals(2));

        final countAfter = await endpoints.notification
            .getUnreadNotificationCount(
              userSession,
            );
        expect(countAfter, equals(0));
      },
    );
  });
}
