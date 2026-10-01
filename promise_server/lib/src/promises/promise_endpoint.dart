import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../generated/protocol.dart';

class PromiseEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Returns the current authenticated user's AuthUserId string.
  String _getAuthUserId(Session session) {
    final authUserId = session.authenticated?.authUserId.toString();
    if (authUserId == null) {
      throw ArgumentError('Authentication required.');
    }
    return authUserId;
  }

  /// Helper to get user's display name or email for activity logs.
  Future<String> _getUserDisplayName(Session session) async {
    final userProfile = await session.authenticated?.userProfile(session);
    if (userProfile == null) return 'User';
    final name = userProfile.userName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = userProfile.email?.trim();
    if (email != null && email.isNotEmpty) return email;
    return 'User';
  }

  /// Helper to get user's email address.
  Future<String> _getUserEmail(Session session) async {
    final userProfile = await session.authenticated?.userProfile(session);
    return userProfile?.email?.trim().toLowerCase() ?? '';
  }

  /// Creates a new promise for an accepted friend.
  Future<Promise> createPromise(Session session, Promise promise) async {
    final creatorUserId = _getAuthUserId(session);
    final recipientUserId = promise.recipientUserId?.trim();

    if (promise.title.trim().isEmpty) {
      throw ArgumentError('Promise title cannot be empty.');
    }
    if (recipientUserId == null || recipientUserId.isEmpty) {
      throw ArgumentError('Recipient user must be selected.');
    }
    if (creatorUserId == recipientUserId) {
      throw ArgumentError('You cannot create a promise to yourself.');
    }

    // FRIENDSHIP AUTHORIZATION CHECK: Verify creator and recipient are accepted friends
    final isFriend = await Friendship.db.findFirstRow(
      session,
      where: (t) =>
          ((t.senderUserId.equals(creatorUserId) &
                  t.receiverUserId.equals(recipientUserId)) |
              (t.senderUserId.equals(recipientUserId) &
                  t.receiverUserId.equals(creatorUserId))) &
          t.status.equals('accepted'),
    );

    if (isFriend == null) {
      throw ArgumentError(
        'You can only create a Promise for an accepted friend.',
      );
    }

    // Retrieve recipient's user profile for display name / email
    String promisedToDisplay = 'Friend';
    try {
      final profiles = await AuthServices.instance.userProfiles.admin
          .listUserProfiles(session, limit: 500);
      final recipientProfile = profiles
          .where((p) => p.authUserId.toString() == recipientUserId)
          .firstOrNull;
      if (recipientProfile != null) {
        final name = recipientProfile.userName?.trim();
        final email = recipientProfile.email?.trim();
        if (name != null && name.isNotEmpty) {
          promisedToDisplay = name;
        } else if (email != null && email.isNotEmpty) {
          promisedToDisplay = email;
        }
      }
    } catch (_) {}

    final initialStatus = promise.status.trim().isEmpty
        ? 'pending'
        : promise.status.trim();

    final creatorName = await _getUserDisplayName(session);

    final promiseToInsert = promise.copyWith(
      title: promise.title.trim(),
      promisedTo: promisedToDisplay,
      description: promise.description?.trim(),
      createdAt: DateTime.now().toUtc(),
      status: initialStatus,
      creatorConfirmed: false,
      recipientConfirmed: false,
      creatorUserId: creatorUserId,
      recipientUserId: recipientUserId,
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
        message: 'Promise created by $creatorName',
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

  /// Retrieves promises relevant to the current authenticated user.
  Future<List<Promise>> getPromises(Session session) async {
    final authUserId = _getAuthUserId(session);
    final userEmail = await _getUserEmail(session);

    final promises = await Promise.db.find(
      session,
      where: (t) =>
          t.creatorUserId.equals(authUserId) |
          t.recipientUserId.equals(authUserId) |
          (t.recipientUserId.equals(null) & t.promisedTo.ilike(userEmail)),
      orderBy: (t) => t.createdAt.desc(),
    );

    // Auto-bind recipientUserId if matching by email
    for (final p in promises) {
      if (p.recipientUserId == null &&
          userEmail.isNotEmpty &&
          p.promisedTo.trim().toLowerCase() == userEmail) {
        final updated = p.copyWith(recipientUserId: authUserId);
        await Promise.db.updateRow(session, updated);
      }
    }

    return promises;
  }

  /// Retrieves a single promise by ID after authorizing participant access.
  Future<Promise?> getPromise(Session session, int id) async {
    final authUserId = _getAuthUserId(session);
    final userEmail = await _getUserEmail(session);

    final promise = await Promise.db.findById(session, id);
    if (promise == null) return null;

    final isCreator = promise.creatorUserId == authUserId;
    final isRecipient =
        promise.recipientUserId == authUserId ||
        (promise.recipientUserId == null &&
            userEmail.isNotEmpty &&
            promise.promisedTo.trim().toLowerCase() == userEmail);

    if (!isCreator && !isRecipient) {
      throw ArgumentError('You do not have access to this promise.');
    }

    if (promise.recipientUserId == null && isRecipient) {
      final updated = promise.copyWith(recipientUserId: authUserId);
      return await Promise.db.updateRow(session, updated);
    }

    return promise;
  }

  /// Retrieves activities for a promise after authorizing participant access.
  Future<List<PromiseActivity>> getActivities(
    Session session,
    int promiseId,
  ) async {
    final promise = await getPromise(session, promiseId);
    if (promise == null) {
      throw ArgumentError('Promise with ID $promiseId not found.');
    }

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

    final promise = await getPromise(session, promiseId);
    if (promise == null) {
      throw ArgumentError('Promise with ID $promiseId not found.');
    }

    if (promise.status == 'completed') {
      throw ArgumentError('Completed promises cannot receive new updates.');
    }

    final userName = await _getUserDisplayName(session);
    final formattedMessage = '$userName: $cleanMessage';

    final activity = PromiseActivity(
      promiseId: promiseId,
      type: type.trim().isEmpty ? 'update' : type.trim(),
      message: formattedMessage,
      status: activityStatus?.trim().isEmpty == true
          ? null
          : activityStatus?.trim(),
      createdAt: DateTime.now().toUtc(),
    );

    return await PromiseActivity.db.insertRow(session, activity);
  }

  /// Confirms promise completion. Role is derived from authenticated user identity.
  Future<Promise> confirmPromiseCompletion(
    Session session,
    int promiseId,
    String role,
  ) async {
    final authUserId = _getAuthUserId(session);
    final userEmail = await _getUserEmail(session);

    final existing = await Promise.db.findById(session, promiseId);
    if (existing == null) {
      throw ArgumentError('Promise with ID $promiseId not found.');
    }

    bool isCreator = existing.creatorUserId == authUserId;
    bool isRecipient =
        existing.recipientUserId == authUserId ||
        (existing.recipientUserId == null &&
            userEmail.isNotEmpty &&
            existing.promisedTo.trim().toLowerCase() == userEmail);

    if (!isCreator && !isRecipient) {
      throw ArgumentError('You are not a participant of this promise.');
    }

    // Role is derived on server, not trusted from client parameter
    final resolvedRole = isCreator ? 'creator' : 'recipient';

    if (existing.status == 'completed' ||
        (resolvedRole == 'creator' && existing.creatorConfirmed) ||
        (resolvedRole == 'recipient' && existing.recipientConfirmed)) {
      return existing;
    }

    final newCreatorConfirmed = resolvedRole == 'creator'
        ? true
        : existing.creatorConfirmed;
    final newRecipientConfirmed = resolvedRole == 'recipient'
        ? true
        : existing.recipientConfirmed;

    final bothConfirmed = newCreatorConfirmed && newRecipientConfirmed;
    final newStatus = bothConfirmed ? 'completed' : 'awaiting_confirmation';

    final userName = await _getUserDisplayName(session);

    String activityMessage;
    if (bothConfirmed) {
      activityMessage =
          'Promise completed — confirmed by $userName ($resolvedRole)';
    } else {
      activityMessage = '$userName ($resolvedRole) confirmed completion';
    }

    return await session.db.transaction((tx) async {
      final updatedPromise = existing.copyWith(
        creatorConfirmed: newCreatorConfirmed,
        recipientConfirmed: newRecipientConfirmed,
        recipientUserId:
            existing.recipientUserId ?? (isRecipient ? authUserId : null),
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

  /// Requests changes for a promise. Role is derived from authenticated user identity.
  Future<Promise> requestChanges(
    Session session,
    int promiseId,
    String role,
    String reason,
  ) async {
    final authUserId = _getAuthUserId(session);
    final userEmail = await _getUserEmail(session);

    final cleanReason = reason.trim();
    if (cleanReason.isEmpty) {
      throw ArgumentError('Reason for requesting changes cannot be empty.');
    }

    final existing = await Promise.db.findById(session, promiseId);
    if (existing == null) {
      throw ArgumentError('Promise with ID $promiseId not found.');
    }

    if (existing.status == 'completed') {
      throw ArgumentError('Completed promises cannot be changed.');
    }

    bool isCreator = existing.creatorUserId == authUserId;
    bool isRecipient =
        existing.recipientUserId == authUserId ||
        (existing.recipientUserId == null &&
            userEmail.isNotEmpty &&
            existing.promisedTo.trim().toLowerCase() == userEmail);

    if (!isCreator && !isRecipient) {
      throw ArgumentError('You are not a participant of this promise.');
    }

    final resolvedRole = isCreator ? 'creator' : 'recipient';
    final userName = await _getUserDisplayName(session);

    return await session.db.transaction((tx) async {
      final updatedPromise = existing.copyWith(
        creatorConfirmed: false,
        recipientConfirmed: false,
        recipientUserId:
            existing.recipientUserId ?? (isRecipient ? authUserId : null),
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
        message: '$userName ($resolvedRole) requested changes: $cleanReason',
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
  Future<Promise> updatePromiseStatus(
    Session session,
    int promiseId,
    String newStatus,
  ) async {
    final cleanStatus = newStatus.trim().toLowerCase();
    if (cleanStatus.isEmpty) {
      throw ArgumentError('New status cannot be empty.');
    }

    final existing = await getPromise(session, promiseId);
    if (existing == null) {
      throw ArgumentError('Promise with ID $promiseId not found.');
    }

    if (existing.status == cleanStatus) {
      return existing;
    }

    if (existing.status == 'completed') {
      throw ArgumentError('Completed promises cannot be changed.');
    }

    if (cleanStatus == 'completed') {
      if (!existing.creatorConfirmed || !existing.recipientConfirmed) {
        throw ArgumentError(
          'Overall promise status cannot be set to "completed" until both parties have confirmed completion.',
        );
      }
    }

    final userName = await _getUserDisplayName(session);

    return await session.db.transaction((tx) async {
      final updatedPromise = existing.copyWith(
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
        message: '$userName changed status to $readableStatus',
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
