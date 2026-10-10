import 'package:promise_server/src/generated/protocol.dart';
import 'package:promise_server/src/promises/deadline_reminder_future_call.dart';
import 'package:promise_server/src/promises/promise_expiry_future_call.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  const creatorId = '11111111-1111-4111-a111-111111111111';
  const recipientId = '22222222-2222-4222-a222-222222222222';
  const unrelatedId = '33333333-3333-4333-a333-333333333333';

  withServerpod('Given Promise Acceptance & FutureCalls', (
    sessionBuilder,
    endpoints,
  ) {
    late int unacceptedPromiseId;
    late int acceptedPromiseId;

    setUp(() async {
      final session = sessionBuilder.build();

      final pUnaccepted = await Promise.db.insertRow(
        session,
        Promise(
          title: 'Unaccepted Promise',
          promisedTo: 'Recipient',
          creatorUserId: creatorId,
          recipientUserId: recipientId,
          recipientAccepted: false,
          dueDate: DateTime.now().toUtc().add(const Duration(days: 2)),
          createdAt: DateTime.now().toUtc().subtract(
            const Duration(days: 8),
          ), // 8 days old
          status: 'pending',
        ),
      );
      unacceptedPromiseId = pUnaccepted.id!;

      final pAccepted = await Promise.db.insertRow(
        session,
        Promise(
          title: 'Accepted Promise',
          promisedTo: 'Recipient',
          creatorUserId: creatorId,
          recipientUserId: recipientId,
          recipientAccepted: true,
          recipientAcceptedAt: DateTime.now().toUtc(),
          dueDate: DateTime.now().toUtc().add(const Duration(days: 1)),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
        ),
      );
      acceptedPromiseId = pAccepted.id!;
    });

    test(
      'unaccepted promise blocks work operations until recipient accepts',
      () async {
        final creatorSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            creatorId,
            {},
          ),
        );
        final recipientSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            recipientId,
            {},
          ),
        );
        final unrelatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            unrelatedId,
            {},
          ),
        );

        await expectLater(
          endpoints.promise.addActivity(
            creatorSession,
            unacceptedPromiseId,
            'update',
            'Work started',
          ),
          throwsA(isA<ArgumentError>()),
        );

        await expectLater(
          endpoints.promise.acceptPromise(
            unrelatedSession,
            unacceptedPromiseId,
          ),
          throwsA(isA<ArgumentError>()),
        );

        final accepted = await endpoints.promise.acceptPromise(
          recipientSession,
          unacceptedPromiseId,
        );
        expect(accepted.recipientAccepted, isTrue);
        expect(accepted.recipientAcceptedAt, isNotNull);

        final activity = await endpoints.promise.addActivity(
          recipientSession,
          unacceptedPromiseId,
          'update',
          'Work started',
        );
        expect(activity, isNotNull);
      },
    );

    test(
      'PromiseExpiryFutureCall expires 8-day old unaccepted promise and cleans up notifications',
      () async {
        final session = sessionBuilder.build();
        final recipientSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            recipientId,
            {},
          ),
        );

        await AppNotification.db.insertRow(
          session,
          AppNotification(
            userId: recipientId,
            type: 'promise_created',
            title: 'New Promise',
            message: 'Test message',
            createdAt: DateTime.now().toUtc(),
            readAt: null,
            promiseId: unacceptedPromiseId,
          ),
        );

        await PromiseExpiryFutureCall().invoke(
          session,
          PromiseExpiryObject(promiseId: unacceptedPromiseId),
        );

        final dbUnaccepted = await Promise.db.findById(
          session,
          unacceptedPromiseId,
        );
        expect(dbUnaccepted, isNull);

        final notifs = await endpoints.notification.getNotifications(
          recipientSession,
        );
        final dangling = notifs.where(
          (n) => n.promiseId == unacceptedPromiseId,
        );
        expect(dangling, isEmpty);

        await PromiseExpiryFutureCall().invoke(
          session,
          PromiseExpiryObject(promiseId: acceptedPromiseId),
        );
        final dbAccepted = await Promise.db.findById(
          session,
          acceptedPromiseId,
        );
        expect(dbAccepted, isNotNull);
      },
    );

    test(
      'DeadlineReminderFutureCall is idempotent and prevents duplicate notifications',
      () async {
        final session = sessionBuilder.build();
        final recipientSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            recipientId,
            {},
          ),
        );

        final initialNotifs = await endpoints.notification.getNotifications(
          recipientSession,
        );

        await DeadlineReminderFutureCall().invoke(
          session,
          DeadlineReminderObject(promiseId: acceptedPromiseId),
        );

        final countAfterFirst = (await endpoints.notification.getNotifications(
          recipientSession,
        )).length;
        expect(countAfterFirst, equals(initialNotifs.length + 1));

        await DeadlineReminderFutureCall().invoke(
          session,
          DeadlineReminderObject(promiseId: acceptedPromiseId),
        );

        final countAfterSecond = (await endpoints.notification.getNotifications(
          recipientSession,
        )).length;

        expect(countAfterSecond, equals(countAfterFirst));
      },
    );

    test(
      'accepting a promise 12h before deadline triggers late-acceptance reminder',
      () async {
        final session = sessionBuilder.build();
        final recipientSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            recipientId,
            {},
          ),
        );

        final latePromise = await Promise.db.insertRow(
          session,
          Promise(
            title: 'Late Acceptance Promise',
            promisedTo: 'Recipient',
            creatorUserId: creatorId,
            recipientUserId: recipientId,
            recipientAccepted: false,
            dueDate: DateTime.now().toUtc().add(const Duration(hours: 12)),
            dueTime: DateTime.now().toUtc().add(const Duration(hours: 12)),
            createdAt: DateTime.now().toUtc(),
            status: 'pending',
          ),
        );

        await endpoints.promise.acceptPromise(
          recipientSession,
          latePromise.id!,
        );

        final recipientNotifs = await endpoints.notification.getNotifications(
          recipientSession,
        );
        final reminderNotif = recipientNotifs.firstWhere(
          (n) =>
              n.promiseId == latePromise.id && n.title == 'Deadline Reminder',
        );
        expect(reminderNotif, isNotNull);
        expect(reminderNotif.message, contains('approaching'));
      },
    );
  });
}
