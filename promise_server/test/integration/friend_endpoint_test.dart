import 'package:promise_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  const user1Id = '11111111-1111-4111-a111-111111111111';
  const user2Id = '22222222-2222-4222-a222-222222222222';
  const user3Id = '33333333-3333-4333-a333-333333333333';

  final user1Uuid = UuidValue.fromString(user1Id);
  final user2Uuid = UuidValue.fromString(user2Id);
  final user3Uuid = UuidValue.fromString(user3Id);

  setUpAll(() {
    try {
      AuthServices.instance;
    } catch (_) {
      AuthServices.set(
        tokenManagerBuilders: [JwtConfigFromPasswords()],
        identityProviderBuilders: [
          EmailIdpConfigFromPasswords(
            sendRegistrationVerificationCode:
                (
                  session, {
                  required email,
                  required accountRequestId,
                  required verificationCode,
                  transaction,
                }) async {},
            sendPasswordResetVerificationCode:
                (
                  session, {
                  required email,
                  required passwordResetRequestId,
                  required verificationCode,
                  transaction,
                }) async {},
          ),
        ],
      );
    }
  });

  withServerpod(
    'Given Friend Endpoint Concurrency and Reliability',
    rollbackDatabase: RollbackDatabase.disabled,
    (
      sessionBuilder,
      endpoints,
    ) {
      setUp(() async {
        final session = sessionBuilder.build();

        // Clean up notifications and friendships before each test
        await AppNotification.db.deleteWhere(
          session,
          where: (t) => t.id.notEquals(null),
        );
        await Friendship.db.deleteWhere(
          session,
          where: (t) => t.id.notEquals(null),
        );
        await UserProfile.db.deleteWhere(
          session,
          where: (t) => t.id.notEquals(null),
        );
        await AuthUser.db.deleteWhere(
          session,
          where: (t) => t.id.notEquals(null),
        );

        // Seed test users in AuthUser and UserProfile if not already present
        for (final (uuid, name, email) in [
          (user1Uuid, 'User One', 'user1@example.com'),
          (user2Uuid, 'User Two', 'user2@example.com'),
          (user3Uuid, 'User Three', 'user3@example.com'),
        ]) {
          final existingUser = await AuthUser.db.findById(session, uuid);
          if (existingUser == null) {
            await AuthUser.db.insertRow(
              session,
              AuthUser(
                id: uuid,
                createdAt: DateTime.now().toUtc(),
                scopeNames: {},
              ),
            );
          }

          final existingProfile = await UserProfile.db.findFirstRow(
            session,
            where: (t) => t.authUserId.equals(uuid),
          );
          if (existingProfile == null) {
            await UserProfile.db.insertRow(
              session,
              UserProfile(
                authUserId: uuid,
                userName: name,
                email: email,
              ),
            );
          }
        }
      });

      test(
        '1. sending a friend request successfully creates pending friendship and notification',
        () async {
          final user1Session = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              user1Id,
              {},
            ),
          );

          final friendship = await endpoints.friend.sendFriendRequest(
            user1Session,
            user2Id,
          );

          expect(friendship.id, isNotNull);
          expect(friendship.senderUserId, equals(user1Id));
          expect(friendship.receiverUserId, equals(user2Id));
          expect(friendship.status, equals('pending'));

          final session = sessionBuilder.build();
          final notifs = await AppNotification.db.find(
            session,
            where: (t) => t.userId.equals(user2Id),
          );
          expect(notifs.length, equals(1));
          expect(notifs.first.type, equals('friend_request'));
          expect(notifs.first.friendshipId, equals(friendship.id));
        },
      );

      test('2. rejecting duplicate and conflicting requests', () async {
        final user1Session = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user1Id,
            {},
          ),
        );
        final user2Session = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user2Id,
            {},
          ),
        );

        await endpoints.friend.sendFriendRequest(user1Session, user2Id);

        // Duplicate from same sender
        expect(
          () => endpoints.friend.sendFriendRequest(user1Session, user2Id),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('A pending friend request already exists'),
            ),
          ),
        );

        // Conflicting reverse request from recipient
        expect(
          () => endpoints.friend.sendFriendRequest(user2Session, user1Id),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains(
                'A pending friend request from this user already exists',
              ),
            ),
          ),
        );

        // Verify still only 1 friendship row and 1 notification
        final session = sessionBuilder.build();
        final rows = await Friendship.db.find(session);
        expect(rows.length, equals(1));
        final notifs = await AppNotification.db.find(session);
        expect(notifs.length, equals(1));
      });

      test(
        '3. re-sending a rejected request updates existing record and sends notification',
        () async {
          final user1Session = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              user1Id,
              {},
            ),
          );
          final user2Session = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              user2Id,
              {},
            ),
          );

          final initial = await endpoints.friend.sendFriendRequest(
            user1Session,
            user2Id,
          );
          final rejected = await endpoints.friend.rejectFriendRequest(
            user2Session,
            initial.id!,
          );
          expect(rejected.status, equals('rejected'));

          // Re-send from user1 to user2
          final resent = await endpoints.friend.sendFriendRequest(
            user1Session,
            user2Id,
          );
          expect(resent.id, equals(initial.id));
          expect(resent.status, equals('pending'));
          expect(resent.senderUserId, equals(user1Id));
          expect(resent.receiverUserId, equals(user2Id));

          final session = sessionBuilder.build();
          final rows = await Friendship.db.find(session);
          expect(rows.length, equals(1));

          // Notifications should have the new friend request notification
          final notifs = await AppNotification.db.find(
            session,
            where: (t) =>
                t.userId.equals(user2Id) & t.type.equals('friend_request'),
          );
          expect(notifs.length, equals(2));
        },
      );

      test('4. accepting a request only as the intended recipient', () async {
        final user1Session = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user1Id,
            {},
          ),
        );
        final user2Session = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user2Id,
            {},
          ),
        );
        final user3Session = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user3Id,
            {},
          ),
        );

        final req = await endpoints.friend.sendFriendRequest(
          user1Session,
          user2Id,
        );

        // Unauthorized user (user1 or user3) cannot accept
        expect(
          () => endpoints.friend.acceptFriendRequest(user1Session, req.id!),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('You are not authorized to accept this friend request'),
            ),
          ),
        );
        expect(
          () => endpoints.friend.acceptFriendRequest(user3Session, req.id!),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('You are not authorized to accept this friend request'),
            ),
          ),
        );

        // Intended recipient accepts successfully
        final accepted = await endpoints.friend.acceptFriendRequest(
          user2Session,
          req.id!,
        );
        expect(accepted.status, equals('accepted'));

        final session = sessionBuilder.build();
        final senderNotifs = await AppNotification.db.find(
          session,
          where: (t) =>
              t.userId.equals(user1Id) &
              t.type.equals('friend_request_accepted'),
        );
        expect(senderNotifs.length, equals(1));
      });

      test('5. rejecting a request only as the intended recipient', () async {
        final user1Session = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user1Id,
            {},
          ),
        );
        final user2Session = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user2Id,
            {},
          ),
        );
        final user3Session = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user3Id,
            {},
          ),
        );

        final req = await endpoints.friend.sendFriendRequest(
          user1Session,
          user2Id,
        );

        // Unauthorized user cannot reject
        expect(
          () => endpoints.friend.rejectFriendRequest(user3Session, req.id!),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('You are not authorized to reject this friend request'),
            ),
          ),
        );

        // Intended recipient rejects successfully
        final rejected = await endpoints.friend.rejectFriendRequest(
          user2Session,
          req.id!,
        );
        expect(rejected.status, equals('rejected'));

        // Cannot accept an already rejected request
        expect(
          () => endpoints.friend.acceptFriendRequest(user2Session, req.id!),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('no longer pending'),
            ),
          ),
        );
      });

      test(
        '6. concurrent attempts to create conflicting relationships are serialized safely',
        () async {
          final user1Session = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              user1Id,
              {},
            ),
          );
          final user2Session = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              user2Id,
              {},
            ),
          );

          // Run concurrent opposite-direction friend requests simultaneously
          final results = await Future.wait([
            endpoints.friend
                .sendFriendRequest(user1Session, user2Id)
                .then((r) => 'u1_success')
                .catchError((e) => 'u1_err: $e'),
            endpoints.friend
                .sendFriendRequest(user2Session, user1Id)
                .then((r) => 'u2_success')
                .catchError((e) => 'u2_err: $e'),
          ]);

          // Exactly one must succeed, and the other must fail with conflict
          final successCount = results
              .where((r) => r.endsWith('_success'))
              .length;
          final errorCount = results.where((r) => r.contains('_err')).length;
          expect(successCount, equals(1));
          expect(errorCount, equals(1));

          // Verify database state: exactly 1 friendship row in total
          final session = sessionBuilder.build();
          final allFriendships = await Friendship.db.find(session);
          expect(allFriendships.length, equals(1));
          expect(allFriendships.first.status, equals('pending'));
        },
      );

      test(
        '7. concurrent acceptance of the same request is idempotent without duplicate notifications',
        () async {
          final user1Session = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              user1Id,
              {},
            ),
          );
          final user2Session = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              user2Id,
              {},
            ),
          );

          final req = await endpoints.friend.sendFriendRequest(
            user1Session,
            user2Id,
          );

          // Concurrent acceptances by the recipient
          final acceptedList = await Future.wait([
            endpoints.friend.acceptFriendRequest(user2Session, req.id!),
            endpoints.friend.acceptFriendRequest(user2Session, req.id!),
          ]);

          expect(acceptedList[0].status, equals('accepted'));
          expect(acceptedList[1].status, equals('accepted'));

          final session = sessionBuilder.build();
          final acceptedNotifs = await AppNotification.db.find(
            session,
            where: (t) => t.type.equals('friend_request_accepted'),
          );
          // Exactly 1 acceptance notification created, no duplicates
          expect(acceptedNotifs.length, equals(1));
        },
      );

      test(
        '8. correct notification behavior: failed operations leave zero notifications',
        () async {
          final user1Session = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              user1Id,
              {},
            ),
          );

          // Self request fails validation
          expect(
            () => endpoints.friend.sendFriendRequest(user1Session, user1Id),
            throwsA(isA<ArgumentError>()),
          );

          // Invalid user ID fails validation
          expect(
            () => endpoints.friend.sendFriendRequest(
              user1Session,
              '99999999-9999-4999-a999-999999999999',
            ),
            throwsA(isA<ArgumentError>()),
          );

          final session = sessionBuilder.build();
          final notifs = await AppNotification.db.find(session);
          expect(notifs, isEmpty);
        },
      );

      test(
        '9. preservation of existing friendship lifecycle and query behavior',
        () async {
          final user1Session = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              user1Id,
              {},
            ),
          );
          final user2Session = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              user2Id,
              {},
            ),
          );

          // Before request: no pending, no friends
          var pending = await endpoints.friend.getPendingFriendRequests(
            user2Session,
          );
          expect(pending, isEmpty);
          var friends1 = await endpoints.friend.getFriends(user1Session);
          expect(friends1, isEmpty);

          // Send request
          final req = await endpoints.friend.sendFriendRequest(
            user1Session,
            user2Id,
          );

          // Pending for recipient
          pending = await endpoints.friend.getPendingFriendRequests(
            user2Session,
          );
          expect(pending.length, equals(1));
          expect(pending.first.userId, equals(user1Id));

          // Accept request
          await endpoints.friend.acceptFriendRequest(user2Session, req.id!);

          // Both see each other as friends
          friends1 = await endpoints.friend.getFriends(user1Session);
          expect(friends1.length, equals(1));
          expect(friends1.first.userId, equals(user2Id));

          final friends2 = await endpoints.friend.getFriends(user2Session);
          expect(friends2.length, equals(1));
          expect(friends2.first.userId, equals(user1Id));

          // Remove friend
          await endpoints.friend.removeFriend(user1Session, user2Id);

          // Both have 0 friends now
          friends1 = await endpoints.friend.getFriends(user1Session);
          expect(friends1, isEmpty);
          final friends2After = await endpoints.friend.getFriends(user2Session);
          expect(friends2After, isEmpty);
        },
      );
    },
  );
}
