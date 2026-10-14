import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class PromiseLifecycleHelper {
  /// Recalculates and updates parent promise status based on the state of remaining child promises.
  static Future<void> updateParentStatusIfNeeded(
    Session session,
    int? parentPromiseId,
    Transaction tx,
  ) async {
    if (parentPromiseId == null) return;

    final children = await Promise.db.find(
      session,
      where: (t) => t.parentPromiseId.equals(parentPromiseId),
      transaction: tx,
    );

    if (children.isEmpty) return;

    bool allCompleted = true;
    bool allPending = true;

    for (final child in children) {
      if (child.status != 'completed') {
        allCompleted = false;
      }
      if (child.status != 'pending') {
        allPending = false;
      }
    }

    String newStatus = 'in_progress';
    if (allCompleted) {
      newStatus = 'completed';
    } else if (allPending) {
      newStatus = 'pending';
    }

    final parent = await Promise.db.findById(
      session,
      parentPromiseId,
      transaction: tx,
    );
    if (parent != null && parent.status != newStatus) {
      await Promise.db.updateRow(
        session,
        parent.copyWith(status: newStatus),
        transaction: tx,
      );
    }
  }
}
