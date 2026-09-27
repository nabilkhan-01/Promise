import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class PromiseEndpoint extends Endpoint {
  /// Creates a new promise and records its initial "created" activity.
  Future<Promise> createPromise(Session session, Promise promise) async {
    if (promise.title.trim().isEmpty) {
      throw ArgumentError('Promise title cannot be empty.');
    }
    if (promise.promisedTo.trim().isEmpty) {
      throw ArgumentError('Promised to cannot be empty.');
    }

    final initialStatus = promise.status.trim().isEmpty
        ? 'pending'
        : promise.status.trim();

    final promiseToInsert = promise.copyWith(
      title: promise.title.trim(),
      promisedTo: promise.promisedTo.trim(),
      description: promise.description?.trim(),
      createdAt: DateTime.now().toUtc(),
      status: initialStatus,
      creatorConfirmed: false,
      recipientConfirmed: false,
    );

    return await session.db.transaction((tx) async {
      final insertedPromise = await Promise.db.insertRow(
        session,
        promiseToInsert,
        transaction: tx,
      );

      final activity = PromiseActivity(
        promiseId: insertedPromise.id!,
        type: 'created',
        message: 'Promise created',
        status: initialStatus,
        createdAt: DateTime.now().toUtc(),
      );

      await PromiseActivity.db.insertRow(
        session,
        activity,
        transaction: tx,
      );

      return insertedPromise;
    });
  }

  /// Retrieves all promises ordered newest-created first.
  Future<List<Promise>> getPromises(Session session) async {
    return await Promise.db.find(
      session,
      orderBy: (t) => t.createdAt.desc(),
    );
  }

  /// Retrieves a single promise by ID.
  Future<Promise?> getPromise(Session session, int id) async {
    return await Promise.db.findById(session, id);
  }

  /// Retrieves activities for a promise ordered oldest to newest.
  Future<List<PromiseActivity>> getActivities(
    Session session,
    int promiseId,
  ) async {
    return await PromiseActivity.db.find(
      session,
      where: (t) => t.promiseId.equals(promiseId),
      orderBy: (t) => t.createdAt.asc(),
    );
  }

  /// Adds a new activity update for a promise. Does NOT alter overall promise status.
  Future<PromiseActivity> addActivity(
    Session session,
    int promiseId,
    String type,
    String message, {
    String? activityStatus,
  }) async {
    final cleanMessage = message.trim();
    if (cleanMessage.isEmpty) {
      throw ArgumentError('Activity message cannot be empty.');
    }

    final promise = await Promise.db.findById(session, promiseId);
    if (promise == null) {
      throw ArgumentError('Promise with ID $promiseId not found.');
    }

    final activity = PromiseActivity(
      promiseId: promiseId,
      type: type.trim().isEmpty ? 'update' : type.trim(),
      message: cleanMessage,
      status: activityStatus?.trim().isEmpty == true
          ? null
          : activityStatus?.trim(),
      createdAt: DateTime.now().toUtc(),
    );

    return await PromiseActivity.db.insertRow(session, activity);
  }

  /// Confirms promise completion for a specific role ('creator' or 'recipient').
  /// Both parties must confirm before the promise status becomes 'completed'.
  Future<Promise> confirmPromiseCompletion(
    Session session,
    int promiseId,
    String role,
  ) async {
    final cleanRole = role.trim().toLowerCase();
    if (cleanRole != 'creator' && cleanRole != 'recipient') {
      throw ArgumentError('Role must be either "creator" or "recipient".');
    }

    final existing = await Promise.db.findById(session, promiseId);
    if (existing == null) {
      throw ArgumentError('Promise with ID $promiseId not found.');
    }

    // Safe/idempotent check: if role is already confirmed, return without duplicate activities
    if (cleanRole == 'creator' && existing.creatorConfirmed) {
      return existing;
    }
    if (cleanRole == 'recipient' && existing.recipientConfirmed) {
      return existing;
    }

    final newCreatorConfirmed = cleanRole == 'creator'
        ? true
        : existing.creatorConfirmed;
    final newRecipientConfirmed = cleanRole == 'recipient'
        ? true
        : existing.recipientConfirmed;

    final bothConfirmed = newCreatorConfirmed && newRecipientConfirmed;
    final newStatus = bothConfirmed ? 'completed' : 'awaiting_confirmation';

    String activityMessage;
    if (bothConfirmed) {
      activityMessage = 'Promise completed — both parties confirmed';
    } else {
      activityMessage = cleanRole == 'creator'
          ? 'Creator confirmed completion'
          : 'Recipient confirmed completion';
    }

    return await session.db.transaction((tx) async {
      final updatedPromise = existing.copyWith(
        creatorConfirmed: newCreatorConfirmed,
        recipientConfirmed: newRecipientConfirmed,
        status: newStatus,
      );

      final savedPromise = await Promise.db.updateRow(
        session,
        updatedPromise,
        transaction: tx,
      );

      final activity = PromiseActivity(
        promiseId: promiseId,
        type: 'confirmation',
        message: activityMessage,
        status: newStatus,
        createdAt: DateTime.now().toUtc(),
      );

      await PromiseActivity.db.insertRow(
        session,
        activity,
        transaction: tx,
      );

      return savedPromise;
    });
  }

  /// Requests changes for a promise, resetting confirmations and setting status to 'in_progress'.
  Future<Promise> requestChanges(
    Session session,
    int promiseId,
    String role,
    String reason,
  ) async {
    final cleanRole = role.trim().toLowerCase();
    final cleanReason = reason.trim();
    if (cleanReason.isEmpty) {
      throw ArgumentError('Reason for requesting changes cannot be empty.');
    }

    final existing = await Promise.db.findById(session, promiseId);
    if (existing == null) {
      throw ArgumentError('Promise with ID $promiseId not found.');
    }

    final roleLabel = cleanRole == 'creator' ? 'Creator' : 'Recipient';

    return await session.db.transaction((tx) async {
      final updatedPromise = existing.copyWith(
        creatorConfirmed: false,
        recipientConfirmed: false,
        status: 'in_progress',
      );

      final savedPromise = await Promise.db.updateRow(
        session,
        updatedPromise,
        transaction: tx,
      );

      final activity = PromiseActivity(
        promiseId: promiseId,
        type: 'request_changes',
        message: '$roleLabel requested changes: $cleanReason',
        status: 'in_progress',
        createdAt: DateTime.now().toUtc(),
      );

      await PromiseActivity.db.insertRow(
        session,
        activity,
        transaction: tx,
      );

      return savedPromise;
    });
  }

  /// Explicitly updates the overall status of a promise.
  /// Enforces that 'completed' CANNOT be set manually unless both parties have confirmed.
  Future<Promise> updatePromiseStatus(
    Session session,
    int promiseId,
    String newStatus,
  ) async {
    final cleanStatus = newStatus.trim().toLowerCase();
    if (cleanStatus.isEmpty) {
      throw ArgumentError('New status cannot be empty.');
    }

    return await session.db.transaction((tx) async {
      final promise = await Promise.db.findById(
        session,
        promiseId,
        transaction: tx,
      );
      if (promise == null) {
        throw ArgumentError('Promise with ID $promiseId not found.');
      }

      if (promise.status == cleanStatus) {
        return promise;
      }

      if (cleanStatus == 'completed') {
        if (!promise.creatorConfirmed || !promise.recipientConfirmed) {
          throw ArgumentError(
            'Overall promise status cannot be set to "completed" until both parties have confirmed completion.',
          );
        }
      }

      final updatedPromise = promise.copyWith(
        status: cleanStatus,
      );

      final savedPromise = await Promise.db.updateRow(
        session,
        updatedPromise,
        transaction: tx,
      );

      String readableStatus = cleanStatus;
      if (cleanStatus == 'in_progress') readableStatus = 'In Progress';
      if (cleanStatus == 'awaiting_confirmation') {
        readableStatus = 'Awaiting Confirmation';
      }
      if (cleanStatus == 'completed') readableStatus = 'Completed';
      if (cleanStatus == 'pending') readableStatus = 'Pending';

      final activity = PromiseActivity(
        promiseId: promiseId,
        type: 'status_change',
        message: 'Overall status changed to $readableStatus',
        status: cleanStatus,
        createdAt: DateTime.now().toUtc(),
      );

      await PromiseActivity.db.insertRow(
        session,
        activity,
        transaction: tx,
      );

      return savedPromise;
    });
  }
}
