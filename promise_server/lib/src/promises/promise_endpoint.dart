import 'package:serverpod_auth_idp_server/core.dart';
import '../generated/protocol.dart';
import '../generated/serverpod.dart';
import '../notifications/notification_helper.dart';

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
    UserProfileModel? userProfile;
    try {
      userProfile = await session.authenticated?.userProfile(session);
    } catch (_) {}
    if (userProfile == null) return 'User';
    final name = userProfile.userName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = userProfile.email?.trim();
    if (email != null && email.isNotEmpty) return email;
    return 'User';
  }

  /// Helper to get user's email address.
  Future<String> _getUserEmail(Session session) async {
    UserProfileModel? userProfile;
    try {
      userProfile = await session.authenticated?.userProfile(session);
    } catch (_) {}
    return userProfile?.email?.trim().toLowerCase() ?? '';
  }

  void _scheduleFutureCalls(Session session, Promise promise) {
    if (promise.id == null ||
        promise.recipientUserId == null ||
        promise.isGroupParent) {
      return;
    }

    try {
      session.serverpod.futureCalls
          .callWithDelay(const Duration(days: 7))
          .promiseExpiry
          .invoke(PromiseExpiryObject(promiseId: promise.id!));

      final now = DateTime.now().toUtc();
      DateTime effectiveEnd;
      if (promise.dueTime != null) {
        effectiveEnd = promise.dueTime!.toUtc();
      } else {
        effectiveEnd = DateTime.utc(
          promise.dueDate.year,
          promise.dueDate.month,
          promise.dueDate.day,
          23,
          59,
          59,
        );
      }

      final reminderTime = effectiveEnd.subtract(const Duration(hours: 24));
      final delay = reminderTime.difference(now);

      if (delay.inSeconds > 0) {
        session.serverpod.futureCalls
            .callWithDelay(delay)
            .deadlineReminder
            .invoke(DeadlineReminderObject(promiseId: promise.id!));
      }
    } catch (_) {}
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
      isGroupParent: false,
      parentPromiseId: null,
      recipientAccepted: false,
      recipientAcceptedAt: null,
    );

    return await session.db.transaction((tx) async {
      final insertedPromise = await Promise.db.insertRow(
        session,
        promiseToInsert,
        transaction: tx,
      );

      _scheduleFutureCalls(session, insertedPromise);

      final activity = PromiseActivity(
        promiseId: insertedPromise.id!,
        type: 'created',
        message:
            'Promise created by $creatorName (Awaiting recipient acceptance)',
        status: initialStatus,
        createdAt: DateTime.now().toUtc(),
      );

      await PromiseActivity.db.insertRow(
        session,
        activity,
        transaction: tx,
      );

      if (insertedPromise.recipientUserId != null) {
        await NotificationHelper.createNotification(
          session,
          userId: insertedPromise.recipientUserId!,
          type: 'promise_created',
          title: 'New Promise',
          message: '$creatorName created a promise: "${insertedPromise.title}"',
          promiseId: insertedPromise.id,
          transaction: tx,
        );
      }

      return insertedPromise;
    });
  }

  /// Creates a group of promises atomically.
  Future<Promise> createGroupedPromise(
    Session session,
    Promise parent,
    List<Promise> children,
  ) async {
    final creatorUserId = _getAuthUserId(session);

    if (parent.title.trim().isEmpty) {
      throw ArgumentError('Parent promise title cannot be empty.');
    }
    if (children.isEmpty) {
      throw ArgumentError('A grouped promise must have at least one child.');
    }
    if (children.length > 10) {
      throw ArgumentError('Maximum 10 children allowed per group.');
    }

    final creatorName = await _getUserDisplayName(session);

    final recipientUserIds = children
        .map((c) => c.recipientUserId?.trim())
        .whereType<String>()
        .toSet();
    if (recipientUserIds.isEmpty ||
        recipientUserIds.length != children.length) {
      throw ArgumentError(
        'All children must have a valid recipient user selected.',
      );
    }
    if (recipientUserIds.contains(creatorUserId)) {
      throw ArgumentError('You cannot create a promise to yourself.');
    }

    final friendships = await Friendship.db.find(
      session,
      where: (t) =>
          ((t.senderUserId.equals(creatorUserId) &
                  t.receiverUserId.inSet(recipientUserIds)) |
              (t.senderUserId.inSet(recipientUserIds) &
                  t.receiverUserId.equals(creatorUserId))) &
          t.status.equals('accepted'),
    );

    final validFriendIds = <String>{};
    for (var f in friendships) {
      if (f.senderUserId == creatorUserId) {
        validFriendIds.add(f.receiverUserId);
      } else {
        validFriendIds.add(f.senderUserId);
      }
    }

    for (var id in recipientUserIds) {
      if (!validFriendIds.contains(id)) {
        throw ArgumentError('One or more recipients are not accepted friends.');
      }
    }

    List<UserProfileModel> profiles = [];
    try {
      profiles = await AuthServices.instance.userProfiles.admin
          .listUserProfiles(session, limit: 500);
    } catch (_) {}
    final profileMap = {for (var p in profiles) p.authUserId.toString(): p};

    final parentToInsert = parent.copyWith(
      title: parent.title.trim(),
      promisedTo: 'Multiple Recipients',
      description: parent.description?.trim(),
      createdAt: DateTime.now().toUtc(),
      status: 'pending',
      creatorConfirmed: false,
      recipientConfirmed: false,
      creatorUserId: creatorUserId,
      recipientUserId: null,
      isGroupParent: true,
      parentPromiseId: null,
    );

    return await session.db.transaction((tx) async {
      final insertedParent = await Promise.db.insertRow(
        session,
        parentToInsert,
        transaction: tx,
      );

      final parentActivity = PromiseActivity(
        promiseId: insertedParent.id!,
        type: 'created',
        message: 'Group Promise created by $creatorName',
        status: 'pending',
        createdAt: DateTime.now().toUtc(),
      );
      await PromiseActivity.db.insertRow(
        session,
        parentActivity,
        transaction: tx,
      );

      for (var child in children) {
        if (child.title.trim().isEmpty) {
          throw ArgumentError('Child promise title cannot be empty.');
        }

        final recId = child.recipientUserId!.trim();
        final recProfile = profileMap[recId];
        String childPromisedTo = 'Friend';
        if (recProfile != null) {
          final name = recProfile.userName?.trim();
          final email = recProfile.email?.trim();
          if (name != null && name.isNotEmpty) {
            childPromisedTo = name;
          } else if (email != null && email.isNotEmpty) {
            childPromisedTo = email;
          }
        }

        final childToInsert = child.copyWith(
          title: child.title.trim(),
          promisedTo: childPromisedTo,
          description: child.description?.trim(),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
          creatorConfirmed: false,
          recipientConfirmed: false,
          creatorUserId: creatorUserId,
          recipientUserId: recId,
          isGroupParent: false,
          parentPromiseId: insertedParent.id,
          recipientAccepted: false,
          recipientAcceptedAt: null,
        );

        final insertedChild = await Promise.db.insertRow(
          session,
          childToInsert,
          transaction: tx,
        );

        _scheduleFutureCalls(session, insertedChild);

        final childActivity = PromiseActivity(
          promiseId: insertedChild.id!,
          type: 'created',
          message: 'Promise created by $creatorName (Part of a group)',
          status: 'pending',
          createdAt: DateTime.now().toUtc(),
        );
        await PromiseActivity.db.insertRow(
          session,
          childActivity,
          transaction: tx,
        );

        await NotificationHelper.createNotification(
          session,
          userId: recId,
          type: 'promise_created',
          title: 'New Promise',
          message:
              '$creatorName assigned you a promise: "${insertedChild.title}"',
          promiseId: insertedChild.id,
          transaction: tx,
        );
      }

      return insertedParent;
    });
  }

  /// Retrieves promises relevant to the current authenticated user.
  Future<List<Promise>> getPromises(Session session) async {
    final authUserId = _getAuthUserId(session);
    final userEmail = await _getUserEmail(session);

    final promises = await Promise.db.find(
      session,
      where: (t) =>
          (t.creatorUserId.equals(authUserId) &
              t.parentPromiseId.equals(null)) |
          t.recipientUserId.equals(authUserId) |
          (t.recipientUserId.equals(null) &
              t.isGroupParent.equals(false) &
              t.promisedTo.ilike(userEmail)),
      orderBy: (t) => t.createdAt.desc(),
    );

    for (final p in promises) {
      if (p.recipientUserId == null &&
          !p.isGroupParent &&
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
        (!promise.isGroupParent &&
            promise.recipientUserId == null &&
            userEmail.isNotEmpty &&
            promise.promisedTo.trim().toLowerCase() == userEmail);

    if (!isCreator && !isRecipient) {
      throw ArgumentError('You do not have access to this promise.');
    }

    if (!promise.isGroupParent &&
        promise.recipientUserId == null &&
        isRecipient) {
      final updated = promise.copyWith(recipientUserId: authUserId);
      return await Promise.db.updateRow(session, updated);
    }

    return promise;
  }

  /// Retrieves children of a grouped promise.
  Future<List<Promise>> getChildPromises(
    Session session,
    int parentPromiseId,
  ) async {
    final authUserId = _getAuthUserId(session);
    final parent = await Promise.db.findById(session, parentPromiseId);
    if (parent == null || parent.creatorUserId != authUserId) {
      throw ArgumentError('Access denied or parent not found.');
    }
    return await Promise.db.find(
      session,
      where: (t) => t.parentPromiseId.equals(parentPromiseId),
      orderBy: (t) => t.dueDate.asc(),
    );
  }

  Future<void> _updateParentStatusIfNeeded(
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

  /// Accepts an unaccepted promise invitation.
  Future<Promise> acceptPromise(Session session, int promiseId) async {
    final authUserId = _getAuthUserId(session);
    final existing = await getPromise(session, promiseId);
    if (existing == null) {
      throw ArgumentError('Promise with ID $promiseId not found.');
    }

    if (existing.recipientUserId != authUserId) {
      throw ArgumentError(
        'Only the assigned recipient can accept this promise.',
      );
    }

    if (existing.recipientAccepted) {
      return existing;
    }

    final userName = await _getUserDisplayName(session);
    final now = DateTime.now().toUtc();

    return await session.db.transaction((tx) async {
      final updatedPromise = existing.copyWith(
        recipientAccepted: true,
        recipientAcceptedAt: now,
      );

      final savedPromise = await Promise.db.updateRow(
        session,
        updatedPromise,
        transaction: tx,
      );

      final activity = PromiseActivity(
        promiseId: promiseId,
        type: 'accepted',
        message: 'Promise invitation accepted by $userName',
        status: existing.status,
        createdAt: now,
      );

      await PromiseActivity.db.insertRow(
        session,
        activity,
        transaction: tx,
      );

      if (savedPromise.creatorUserId != null) {
        await NotificationHelper.createNotification(
          session,
          userId: savedPromise.creatorUserId!,
          type: 'promise_updated',
          title: 'Promise Accepted',
          message: '$userName accepted your promise: "${savedPromise.title}"',
          promiseId: promiseId,
          transaction: tx,
        );
      }

      final effectiveEnd = savedPromise.dueTime != null
          ? savedPromise.dueTime!.toUtc()
          : DateTime.utc(
              savedPromise.dueDate.year,
              savedPromise.dueDate.month,
              savedPromise.dueDate.day,
              23,
              59,
              59,
            );

      final reminderTime = effectiveEnd.subtract(const Duration(hours: 24));
      if (now.isAfter(reminderTime) &&
          now.isBefore(effectiveEnd) &&
          savedPromise.status != 'completed') {
        final userIds = [
          savedPromise.creatorUserId,
          savedPromise.recipientUserId,
        ].whereType<String>().toSet();

        for (final userId in userIds) {
          final existingNotif = await AppNotification.db.findFirstRow(
            session,
            where: (t) =>
                t.userId.equals(userId) &
                t.promiseId.equals(promiseId) &
                t.title.equals('Deadline Reminder'),
            transaction: tx,
          );

          if (existingNotif == null) {
            await NotificationHelper.createNotification(
              session,
              userId: userId,
              type: 'promise_updated',
              title: 'Deadline Reminder',
              message:
                  'Deadline reminder: "${savedPromise.title}" is approaching. Please check its due date.',
              promiseId: promiseId,
              transaction: tx,
            );
          }
        }
      }

      return savedPromise;
    });
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

    if (promise.recipientUserId != null && !promise.recipientAccepted) {
      throw ArgumentError(
        'Cannot add updates to a promise that has not been accepted by the recipient.',
      );
    }

    final currentUserId = _getAuthUserId(session);
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

    return await session.db.transaction((tx) async {
      final insertedActivity = await PromiseActivity.db.insertRow(
        session,
        activity,
        transaction: tx,
      );

      final otherUserId = promise.creatorUserId == currentUserId
          ? promise.recipientUserId
          : promise.creatorUserId;

      if (otherUserId != null) {
        await NotificationHelper.createNotification(
          session,
          userId: otherUserId,
          type: 'promise_updated',
          title: 'Promise Updated',
          message:
              '$userName added an update on "${promise.title}": $cleanMessage',
          promiseId: promiseId,
          transaction: tx,
        );
      }

      return insertedActivity;
    });
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

    if (existing.isGroupParent) {
      throw ArgumentError('Group promises cannot be manually confirmed.');
    }

    if (existing.recipientUserId != null && !existing.recipientAccepted) {
      throw ArgumentError(
        'Cannot confirm completion on a promise that has not been accepted by the recipient.',
      );
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

      await _updateParentStatusIfNeeded(
        session,
        savedPromise.parentPromiseId,
        tx,
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

      final otherUserId = resolvedRole == 'creator'
          ? savedPromise.recipientUserId
          : savedPromise.creatorUserId;

      if (otherUserId != null) {
        if (bothConfirmed) {
          await NotificationHelper.createNotification(
            session,
            userId: otherUserId,
            type: 'promise_completed',
            title: 'Promise Completed',
            message: 'Promise "${savedPromise.title}" has been completed!',
            promiseId: promiseId,
            transaction: tx,
          );
        } else {
          await NotificationHelper.createNotification(
            session,
            userId: otherUserId,
            type: 'confirmation_requested',
            title: 'Confirmation Requested',
            message:
                '$userName confirmed completion for "${savedPromise.title}". Awaiting your confirmation.',
            promiseId: promiseId,
            transaction: tx,
          );
        }
      }

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

    if (existing.isGroupParent) {
      throw ArgumentError(
        'Group promises cannot be manually changed via requestChanges.',
      );
    }

    if (existing.recipientUserId != null && !existing.recipientAccepted) {
      throw ArgumentError(
        'Cannot request changes on a promise that has not been accepted by the recipient.',
      );
    }

    bool isCreator = existing.creatorUserId == authUserId;
    bool isRecipient =
        existing.recipientUserId == authUserId ||
        (!existing.isGroupParent &&
            existing.recipientUserId == null &&
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

      await _updateParentStatusIfNeeded(
        session,
        savedPromise.parentPromiseId,
        tx,
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

      final otherUserId = resolvedRole == 'creator'
          ? savedPromise.recipientUserId
          : savedPromise.creatorUserId;

      if (otherUserId != null) {
        await NotificationHelper.createNotification(
          session,
          userId: otherUserId,
          type: 'change_requested',
          title: 'Changes Requested',
          message:
              '$userName requested changes on "${savedPromise.title}": $cleanReason',
          promiseId: promiseId,
          transaction: tx,
        );
      }

      return savedPromise;
    });
  }

  /// Explicitly updates the overall status of a promise.
  Future<Promise> updatePromiseStatus(
    Session session,
    int promiseId,
    String newStatus,
  ) async {
    final authUserId = _getAuthUserId(session);
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

    if (existing.isGroupParent) {
      throw ArgumentError(
        'Group promises cannot be manually changed via updatePromiseStatus.',
      );
    }

    if (existing.recipientUserId != null && !existing.recipientAccepted) {
      throw ArgumentError(
        'Cannot update status on a promise that has not been accepted by the recipient.',
      );
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

      await _updateParentStatusIfNeeded(
        session,
        savedPromise.parentPromiseId,
        tx,
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

      final otherUserId = savedPromise.creatorUserId == authUserId
          ? savedPromise.recipientUserId
          : savedPromise.creatorUserId;

      if (otherUserId != null) {
        await NotificationHelper.createNotification(
          session,
          userId: otherUserId,
          type: 'promise_status_changed',
          title: 'Promise Status Updated',
          message:
              '$userName updated status of "${savedPromise.title}" to $readableStatus',
          promiseId: promiseId,
          transaction: tx,
        );
      }

      return savedPromise;
    });
  }
}
