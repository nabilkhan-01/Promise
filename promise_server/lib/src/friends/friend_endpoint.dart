import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../generated/protocol.dart';

class FriendEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  String _getAuthUserId(Session session) {
    final authUserId = session.authenticated?.authUserId.toString();
    if (authUserId == null) {
      throw ArgumentError('Authentication required.');
    }
    return authUserId;
  }

  Future<UserProfileModel?> _getProfileByAuthUserId(
    Session session,
    String userId,
  ) async {
    try {
      final profiles = await AuthServices.instance.userProfiles.admin
          .listUserProfiles(session, limit: 500);
      return profiles
          .where((p) => p.authUserId.toString() == userId)
          .firstOrNull;
    } catch (_) {
      return null;
    }
  }

  /// Searches for registered users by email or username, including friendship status with current user.
  Future<List<UserSearchProfile>> searchUsers(
    Session session,
    String query,
  ) async {
    final currentUserId = _getAuthUserId(session);
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    final profiles = await AuthServices.instance.userProfiles.admin
        .listUserProfiles(session, limit: 500);

    final matchingProfiles = profiles
        .where((p) {
          final emailMatch =
              p.email != null && p.email!.toLowerCase().contains(cleanQuery);
          final nameMatch =
              p.userName != null &&
              p.userName!.toLowerCase().contains(cleanQuery);
          return emailMatch || nameMatch;
        })
        .take(20);

    final results = <UserSearchProfile>[];

    for (final profile in matchingProfiles) {
      final targetUserId = profile.authUserId.toString();
      if (targetUserId == currentUserId) continue;

      final existingFriendship = await Friendship.db.findFirstRow(
        session,
        where: (t) =>
            (t.senderUserId.equals(currentUserId) &
                t.receiverUserId.equals(targetUserId)) |
            (t.senderUserId.equals(targetUserId) &
                t.receiverUserId.equals(currentUserId)),
      );

      String friendshipStatus = 'none';
      int? friendshipId;

      if (existingFriendship != null) {
        friendshipId = existingFriendship.id;
        if (existingFriendship.status == 'accepted') {
          friendshipStatus = 'accepted';
        } else if (existingFriendship.status == 'pending') {
          if (existingFriendship.senderUserId == currentUserId) {
            friendshipStatus = 'pending_sent';
          } else {
            friendshipStatus = 'pending_received';
          }
        }
      }

      results.add(
        UserSearchProfile(
          userId: targetUserId,
          userName: profile.userName,
          email: profile.email ?? '',
          friendshipStatus: friendshipStatus,
          friendshipId: friendshipId,
        ),
      );
    }

    return results;
  }

  /// Sends a friend request to a target user ID.
  Future<Friendship> sendFriendRequest(
    Session session,
    String receiverUserId,
  ) async {
    final senderUserId = _getAuthUserId(session);
    final cleanReceiverId = receiverUserId.trim();

    if (senderUserId == cleanReceiverId) {
      throw ArgumentError('You cannot send a friend request to yourself.');
    }

    final receiverProfile = await _getProfileByAuthUserId(
      session,
      cleanReceiverId,
    );
    if (receiverProfile == null) {
      throw ArgumentError('Target user not found.');
    }

    final existing = await Friendship.db.findFirstRow(
      session,
      where: (t) =>
          (t.senderUserId.equals(senderUserId) &
              t.receiverUserId.equals(cleanReceiverId)) |
          (t.senderUserId.equals(cleanReceiverId) &
              t.receiverUserId.equals(senderUserId)),
    );

    if (existing != null) {
      if (existing.status == 'accepted') {
        throw ArgumentError('You are already friends with this user.');
      }
      if (existing.status == 'pending') {
        throw ArgumentError('A pending friend request already exists.');
      }
      // Re-send rejected request
      final updated = existing.copyWith(
        senderUserId: senderUserId,
        receiverUserId: cleanReceiverId,
        status: 'pending',
        updatedAt: DateTime.now().toUtc(),
      );
      return await Friendship.db.updateRow(session, updated);
    }

    final newFriendship = Friendship(
      senderUserId: senderUserId,
      receiverUserId: cleanReceiverId,
      status: 'pending',
      createdAt: DateTime.now().toUtc(),
    );

    return await Friendship.db.insertRow(session, newFriendship);
  }

  /// Retrieves pending friend requests sent TO the current authenticated user.
  Future<List<UserSearchProfile>> getPendingFriendRequests(
    Session session,
  ) async {
    final currentUserId = _getAuthUserId(session);

    final pendingRows = await Friendship.db.find(
      session,
      where: (t) =>
          t.receiverUserId.equals(currentUserId) & t.status.equals('pending'),
      orderBy: (t) => t.createdAt.desc(),
    );

    final results = <UserSearchProfile>[];

    for (final row in pendingRows) {
      final senderProfile = await _getProfileByAuthUserId(
        session,
        row.senderUserId,
      );

      if (senderProfile != null) {
        results.add(
          UserSearchProfile(
            userId: row.senderUserId,
            userName: senderProfile.userName,
            email: senderProfile.email ?? '',
            friendshipStatus: 'pending_received',
            friendshipId: row.id,
          ),
        );
      }
    }

    return results;
  }

  /// Accepts an incoming friend request.
  Future<Friendship> acceptFriendRequest(
    Session session,
    int friendshipId,
  ) async {
    final currentUserId = _getAuthUserId(session);

    final friendship = await Friendship.db.findById(session, friendshipId);
    if (friendship == null) {
      throw ArgumentError('Friend request not found.');
    }

    if (friendship.receiverUserId != currentUserId) {
      throw ArgumentError(
        'You are not authorized to accept this friend request.',
      );
    }

    final updated = friendship.copyWith(
      status: 'accepted',
      updatedAt: DateTime.now().toUtc(),
    );

    return await Friendship.db.updateRow(session, updated);
  }

  /// Rejects an incoming friend request.
  Future<Friendship> rejectFriendRequest(
    Session session,
    int friendshipId,
  ) async {
    final currentUserId = _getAuthUserId(session);

    final friendship = await Friendship.db.findById(session, friendshipId);
    if (friendship == null) {
      throw ArgumentError('Friend request not found.');
    }

    if (friendship.receiverUserId != currentUserId) {
      throw ArgumentError(
        'You are not authorized to reject this friend request.',
      );
    }

    final updated = friendship.copyWith(
      status: 'rejected',
      updatedAt: DateTime.now().toUtc(),
    );

    return await Friendship.db.updateRow(session, updated);
  }

  /// Retrieves list of accepted friends for current authenticated user.
  Future<List<UserSearchProfile>> getFriends(Session session) async {
    final currentUserId = _getAuthUserId(session);

    final friendshipRows = await Friendship.db.find(
      session,
      where: (t) =>
          (t.senderUserId.equals(currentUserId) |
              t.receiverUserId.equals(currentUserId)) &
          t.status.equals('accepted'),
    );

    final results = <UserSearchProfile>[];

    for (final row in friendshipRows) {
      final friendUserId = row.senderUserId == currentUserId
          ? row.receiverUserId
          : row.senderUserId;

      final friendProfile = await _getProfileByAuthUserId(
        session,
        friendUserId,
      );

      if (friendProfile != null) {
        results.add(
          UserSearchProfile(
            userId: friendUserId,
            userName: friendProfile.userName,
            email: friendProfile.email ?? '',
            friendshipStatus: 'accepted',
            friendshipId: row.id,
          ),
        );
      }
    }

    return results;
  }

  /// Removes an accepted friend relationship.
  Future<void> removeFriend(
    Session session,
    String friendUserId,
  ) async {
    final currentUserId = _getAuthUserId(session);
    final cleanFriendId = friendUserId.trim();

    final friendship = await Friendship.db.findFirstRow(
      session,
      where: (t) =>
          ((t.senderUserId.equals(currentUserId) &
                  t.receiverUserId.equals(cleanFriendId)) |
              (t.senderUserId.equals(cleanFriendId) &
                  t.receiverUserId.equals(currentUserId))) &
          t.status.equals('accepted'),
    );

    if (friendship != null) {
      await Friendship.db.deleteRow(session, friendship);
    }
  }
}
