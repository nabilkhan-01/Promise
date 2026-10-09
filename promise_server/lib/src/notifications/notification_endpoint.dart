import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../generated/protocol.dart';

class NotificationEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  String _getAuthUserId(Session session) {
    final authUserId = session.authenticated?.authUserId.toString();
    if (authUserId == null) {
      throw ArgumentError('Authentication required.');
    }
    return authUserId;
  }

  /// Retrieves notifications for the current authenticated user.
  Future<List<AppNotification>> getNotifications(
    Session session, {
    int? limit,
  }) async {
    final currentUserId = _getAuthUserId(session);

    return await AppNotification.db.find(
      session,
      where: (t) => t.userId.equals(currentUserId),
      orderBy: (t) => t.createdAt.desc(),
      limit: limit ?? 50,
    );
  }

  /// Retrieves the unread notification count for current authenticated user.
  Future<int> getUnreadNotificationCount(Session session) async {
    final currentUserId = _getAuthUserId(session);

    return await AppNotification.db.count(
      session,
      where: (t) => t.userId.equals(currentUserId) & t.readAt.equals(null),
    );
  }

  /// Marks a single notification as read if it belongs to current authenticated user.
  Future<AppNotification?> markNotificationRead(
    Session session,
    int notificationId,
  ) async {
    final currentUserId = _getAuthUserId(session);

    final notification = await AppNotification.db.findById(
      session,
      notificationId,
    );

    if (notification == null) return null;

    if (notification.userId != currentUserId) {
      throw ArgumentError(
        'You are not authorized to update this notification.',
      );
    }

    if (notification.readAt != null) {
      return notification;
    }

    final updated = notification.copyWith(
      readAt: DateTime.now().toUtc(),
    );

    return await AppNotification.db.updateRow(session, updated);
  }

  /// Marks all unread notifications as read for current authenticated user.
  Future<int> markAllNotificationsRead(Session session) async {
    final currentUserId = _getAuthUserId(session);

    final unread = await AppNotification.db.find(
      session,
      where: (t) => t.userId.equals(currentUserId) & t.readAt.equals(null),
    );

    final now = DateTime.now().toUtc();
    for (final notification in unread) {
      await AppNotification.db.updateRow(
        session,
        notification.copyWith(readAt: now),
      );
    }

    return unread.length;
  }
}
