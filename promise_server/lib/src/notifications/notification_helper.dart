import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class NotificationHelper {
  static Future<AppNotification> createNotification(
    Session session, {
    required String userId,
    required String type,
    required String title,
    required String message,
    int? promiseId,
    int? friendshipId,
    Transaction? transaction,
  }) async {
    final notification = AppNotification(
      userId: userId,
      type: type,
      title: title,
      message: message,
      promiseId: promiseId,
      friendshipId: friendshipId,
      createdAt: DateTime.now().toUtc(),
    );

    return await AppNotification.db.insertRow(
      session,
      notification,
      transaction: transaction,
    );
  }
}
