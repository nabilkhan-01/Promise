import 'package:promise_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  const creatorId = '11111111-1111-4111-a111-111111111111';
  const child1Id = '22222222-2222-4222-a222-222222222222';
  const child2Id = '33333333-3333-4333-a333-333333333333';

  withServerpod('Given Group Promise endpoints', (sessionBuilder, endpoints) {
    setUp(() async {
      final session = sessionBuilder.build();

      // Create accepted friendships between creator and children
      await Friendship.db.insertRow(
        session,
        Friendship(
          senderUserId: creatorId,
          receiverUserId: child1Id,
          status: 'accepted',
          createdAt: DateTime.now().toUtc(),
        ),
      );

      await Friendship.db.insertRow(
        session,
        Friendship(
          senderUserId: creatorId,
          receiverUserId: child2Id,
          status: 'accepted',
          createdAt: DateTime.now().toUtc(),
        ),
      );
    });

    test('can create a grouped promise atomically', () async {
      final creatorSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          creatorId,
          {},
        ),
      );

      final parent = Promise(
        title: 'Group Parent',
        promisedTo: '',
        dueDate: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        status: 'pending',
      );

      final child1 = Promise(
        title: 'Child 1',
        promisedTo: '',
        recipientUserId: child1Id,
        dueDate: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        status: 'pending',
      );

      final child2 = Promise(
        title: 'Child 2',
        promisedTo: '',
        recipientUserId: child2Id,
        dueDate: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        status: 'pending',
      );

      final createdParent = await endpoints.promise.createGroupedPromise(
        creatorSession,
        parent,
        [child1, child2],
      );

      expect(createdParent.isGroupParent, isTrue);
      expect(createdParent.parentPromiseId, isNull);
      expect(createdParent.recipientUserId, isNull);

      final children = await endpoints.promise.getChildPromises(
        creatorSession,
        createdParent.id!,
      );
      expect(children.length, 2);
      expect(children[0].parentPromiseId, createdParent.id);
      expect(children[1].parentPromiseId, createdParent.id);
      expect(children[0].isGroupParent, isFalse);
    });

    test(
      'can create grouped promise with multiple child commitments assigned to the same recipient friend',
      () async {
        final creatorSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            creatorId,
            {},
          ),
        );

        final parent = Promise(
          title: 'Freelance Website Contract',
          promisedTo: '',
          dueDate: DateTime.now().toUtc(),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
          commitmentType: 'freelance',
        );

        final m1 = Promise(
          title: 'Milestone 1 - Design',
          promisedTo: '',
          recipientUserId: child1Id,
          dueDate: DateTime.now().toUtc().add(const Duration(days: 2)),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
          milestoneOrder: 1,
        );

        final m2 = Promise(
          title: 'Milestone 2 - Backend API',
          promisedTo: '',
          recipientUserId: child1Id,
          dueDate: DateTime.now().toUtc().add(const Duration(days: 5)),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
          milestoneOrder: 2,
        );

        final createdParent = await endpoints.promise.createGroupedPromise(
          creatorSession,
          parent,
          [m1, m2],
        );

        expect(createdParent.commitmentType, 'freelance');

        final children = await endpoints.promise.getChildPromises(
          creatorSession,
          createdParent.id!,
        );

        expect(children.length, 2);
        expect(children[0].recipientUserId, child1Id);
        expect(children[1].recipientUserId, child1Id);
        expect(children[0].milestoneOrder, 1);
        expect(children[1].milestoneOrder, 2);
      },
    );

    test('child updates bubble up to parent status', () async {
      final creatorSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          creatorId,
          {},
        ),
      );
      final child1Session = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(child1Id, {}),
      );
      final child2Session = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(child2Id, {}),
      );

      // Create group
      final parent = Promise(
        title: 'P',
        promisedTo: '',
        dueDate: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        status: 'pending',
      );
      final c1 = Promise(
        title: 'C1',
        promisedTo: '',
        recipientUserId: child1Id,
        dueDate: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        status: 'pending',
      );
      final c2 = Promise(
        title: 'C2',
        promisedTo: '',
        recipientUserId: child2Id,
        dueDate: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        status: 'pending',
      );
      final createdParent = await endpoints.promise.createGroupedPromise(
        creatorSession,
        parent,
        [c1, c2],
      );

      final children = await endpoints.promise.getChildPromises(
        creatorSession,
        createdParent.id!,
      );

      // Children accept invitations
      await endpoints.promise.acceptPromise(child1Session, children[0].id!);
      await endpoints.promise.acceptPromise(child2Session, children[1].id!);

      // Confirm child 1 by both creator and recipient to complete it
      await endpoints.promise.confirmPromiseCompletion(
        creatorSession,
        children[0].id!,
        'creator',
      );
      await endpoints.promise.confirmPromiseCompletion(
        child1Session,
        children[0].id!,
        'recipient',
      );

      // Parent should now be in_progress
      var updatedParent = await endpoints.promise.getPromise(
        creatorSession,
        createdParent.id!,
      );
      expect(updatedParent!.status, 'in_progress');

      // Confirm child 2 to complete it
      await endpoints.promise.confirmPromiseCompletion(
        creatorSession,
        children[1].id!,
        'creator',
      );
      await endpoints.promise.confirmPromiseCompletion(
        child2Session,
        children[1].id!,
        'recipient',
      );

      // Parent should now be completed
      updatedParent = await endpoints.promise.getPromise(
        creatorSession,
        createdParent.id!,
      );
      expect(updatedParent!.status, 'completed');
    });

    test('manual status change on parent is blocked', () async {
      final creatorSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          creatorId,
          {},
        ),
      );

      final parent = Promise(
        title: 'P',
        promisedTo: '',
        dueDate: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        status: 'pending',
      );
      final c1 = Promise(
        title: 'C1',
        promisedTo: '',
        recipientUserId: child1Id,
        dueDate: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        status: 'pending',
      );
      final createdParent = await endpoints.promise.createGroupedPromise(
        creatorSession,
        parent,
        [c1],
      );

      await expectLater(
        endpoints.promise.confirmPromiseCompletion(
          creatorSession,
          createdParent.id!,
          'creator',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Group promises cannot be manually confirmed'),
          ),
        ),
      );

      await expectLater(
        endpoints.promise.updatePromiseStatus(
          creatorSession,
          createdParent.id!,
          'in_progress',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('cannot be manually changed via updatePromiseStatus'),
          ),
        ),
      );
    });

    test(
      'parent metadata read-only access and strict authorization boundaries',
      () async {
        final creatorSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            creatorId,
            {},
          ),
        );
        final child1Session = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            child1Id,
            {},
          ),
        );
        final unrelatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            '44444444-4444-4444-a444-444444444444',
            {},
          ),
        );

        final parent = Promise(
          title: 'Parent Project',
          promisedTo: '',
          description: 'Project Scope Document',
          dueDate: DateTime.now().toUtc(),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
          commitmentType: 'freelance',
        );
        final c1 = Promise(
          title: 'C1 for Child1',
          promisedTo: '',
          recipientUserId: child1Id,
          dueDate: DateTime.now().toUtc(),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
        );
        final c2 = Promise(
          title: 'C2 for Child2',
          promisedTo: '',
          recipientUserId: child2Id,
          dueDate: DateTime.now().toUtc(),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
        );
        final createdParent = await endpoints.promise.createGroupedPromise(
          creatorSession,
          parent,
          [c1, c2],
        );

        // 1. Assigned child recipient CAN retrieve approved ParentProjectMetadata
        final parentMeta = await endpoints.promise.getParentProjectMetadata(
          child1Session,
          createdParent.id!,
        );
        expect(parentMeta.id, createdParent.id);
        expect(parentMeta.title, 'Parent Project');
        expect(parentMeta.description, 'Project Scope Document');
        expect(parentMeta.commitmentType, 'freelance');

        // 2. Unrelated user CANNOT retrieve parent project metadata
        await expectLater(
          endpoints.promise.getParentProjectMetadata(
            unrelatedSession,
            createdParent.id!,
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('do not have access'),
            ),
          ),
        );

        // 3. Child recipient CANNOT retrieve full parent Promise DB entity via getPromise
        await expectLater(
          endpoints.promise.getPromise(child1Session, createdParent.id!),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('do not have access'),
            ),
          ),
        );

        // 4. Coordinator (creator) retains full access via getPromise and getParentProjectMetadata
        final creatorFullPromise = await endpoints.promise.getPromise(
          creatorSession,
          createdParent.id!,
        );
        expect(creatorFullPromise, isNotNull);
        expect(creatorFullPromise!.id, createdParent.id);

        final creatorMeta = await endpoints.promise.getParentProjectMetadata(
          creatorSession,
          createdParent.id!,
        );
        expect(creatorMeta.title, 'Parent Project');

        // 5. Child recipient CANNOT read parent activities or add activities
        await expectLater(
          endpoints.promise.getActivities(child1Session, createdParent.id!),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('direct participant access'),
            ),
          ),
        );

        await expectLater(
          endpoints.promise.addActivity(
            child1Session,
            createdParent.id!,
            'update',
            'Attempted parent update',
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('direct participant access'),
            ),
          ),
        );

        // 6. Sibling task isolation: Child 1 calling getChildPromises gets ONLY Child 1 task
        final child1Tasks = await endpoints.promise.getChildPromises(
          child1Session,
          createdParent.id!,
        );
        expect(child1Tasks.length, 1);
        expect(child1Tasks[0].title, 'C1 for Child1');
      },
    );

    test(
      'legacy group parents with null or SQL default personal commitmentType resolve to team while standalone remains personal',
      () async {
        final creatorSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            creatorId,
            {},
          ),
        );

        final legacyParent = Promise(
          title: 'Legacy Group Parent',
          promisedTo: '',
          dueDate: DateTime.now().toUtc(),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
          commitmentType: 'personal', // SQL migration column default
        );
        final c1 = Promise(
          title: 'Child 1',
          promisedTo: '',
          recipientUserId: child1Id,
          dueDate: DateTime.now().toUtc(),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
          commitmentType: 'personal', // SQL migration column default
        );

        final createdParent = await endpoints.promise.createGroupedPromise(
          creatorSession,
          legacyParent,
          [c1],
        );

        final metadata = await endpoints.promise.getParentProjectMetadata(
          creatorSession,
          createdParent.id!,
        );

        expect(metadata.commitmentType, 'team');

        final standalone = await endpoints.promise.createPromise(
          creatorSession,
          Promise(
            title: 'Standalone Personal',
            promisedTo: 'Friend',
            recipientUserId: child1Id,
            dueDate: DateTime.now().toUtc(),
            createdAt: DateTime.now().toUtc(),
            status: 'pending',
            commitmentType: 'personal',
          ),
        );

        expect(standalone.commitmentType, 'personal');
      },
    );

    test(
      'creating a group promise with invalid commitmentType is rejected',
      () async {
        final creatorSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            creatorId,
            {},
          ),
        );

        final parent = Promise(
          title: 'Invalid Group Parent',
          promisedTo: '',
          dueDate: DateTime.now().toUtc(),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
          commitmentType: 'invalid_type',
        );

        final c1 = Promise(
          title: 'Child 1',
          promisedTo: '',
          recipientUserId: child1Id,
          dueDate: DateTime.now().toUtc(),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
        );

        await expectLater(
          endpoints.promise.createGroupedPromise(
            creatorSession,
            parent,
            [c1],
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Invalid commitment type'),
            ),
          ),
        );
      },
    );

    test(
      'getChildPromises sorts explicitly ordered milestones first, followed by fallback due date sorting',
      () async {
        final creatorSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            creatorId,
            {},
          ),
        );

        final now = DateTime.now().toUtc();

        final parent = Promise(
          title: 'Ordering Parent',
          promisedTo: '',
          dueDate: now,
          createdAt: now,
          status: 'pending',
        );

        // Unordered child with earliest due date
        final cUnordered = Promise(
          title: 'Unordered Child',
          promisedTo: '',
          recipientUserId: child1Id,
          dueDate: now.add(const Duration(days: 1)),
          createdAt: now,
          status: 'pending',
          milestoneOrder: null,
        );

        // Milestone 2 with later due date
        final c2 = Promise(
          title: 'Milestone 2',
          promisedTo: '',
          recipientUserId: child1Id,
          dueDate: now.add(const Duration(days: 10)),
          createdAt: now,
          status: 'pending',
          milestoneOrder: 2,
        );

        // Milestone 1 with earlier due date
        final c1 = Promise(
          title: 'Milestone 1',
          promisedTo: '',
          recipientUserId: child1Id,
          dueDate: now.add(const Duration(days: 5)),
          createdAt: now,
          status: 'pending',
          milestoneOrder: 1,
        );

        final createdParent = await endpoints.promise.createGroupedPromise(
          creatorSession,
          parent,
          [cUnordered, c2, c1],
        );

        final children = await endpoints.promise.getChildPromises(
          creatorSession,
          createdParent.id!,
        );

        expect(children.length, 3);
        expect(children[0].title, 'Milestone 1');
        expect(children[1].title, 'Milestone 2');
        expect(children[2].title, 'Unordered Child');
      },
    );

    test(
      'transaction rolls back completely if any child has invalid or unaccepted recipient',
      () async {
        final creatorSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            creatorId,
            {},
          ),
        );

        final parent = Promise(
          title: 'Rollback Parent',
          promisedTo: '',
          dueDate: DateTime.now().toUtc(),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
        );

        final validChild = Promise(
          title: 'Valid Child',
          promisedTo: '',
          recipientUserId: child1Id,
          dueDate: DateTime.now().toUtc(),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
        );

        final invalidChild = Promise(
          title: 'Invalid Child',
          promisedTo: '',
          recipientUserId: '99999999-9999-9999-9999-999999999999',
          dueDate: DateTime.now().toUtc(),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
        );

        await expectLater(
          endpoints.promise.createGroupedPromise(
            creatorSession,
            parent,
            [validChild, invalidChild],
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('not accepted friends'),
            ),
          ),
        );

        final session = sessionBuilder.build();

        final parentsInDb = await Promise.db.find(
          session,
          where: (t) => t.title.equals('Rollback Parent'),
        );
        expect(parentsInDb, isEmpty);

        final childrenInDb = await Promise.db.find(
          session,
          where: (t) => t.title.equals('Valid Child'),
        );
        expect(childrenInDb, isEmpty);

        final activitiesInDb = await PromiseActivity.db.find(
          session,
          where: (t) => t.message.ilike('%Rollback Parent%'),
        );
        expect(activitiesInDb, isEmpty);
      },
    );

    test(
      'requesting changes on a child resets child and keeps parent in_progress',
      () async {
        final creatorSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            creatorId,
            {},
          ),
        );
        final child1Session = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            child1Id,
            {},
          ),
        );

        final parent = Promise(
          title: 'Parent RC',
          promisedTo: '',
          dueDate: DateTime.now().toUtc(),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
        );
        final c1 = Promise(
          title: 'C1 RC',
          promisedTo: '',
          recipientUserId: child1Id,
          dueDate: DateTime.now().toUtc(),
          createdAt: DateTime.now().toUtc(),
          status: 'pending',
        );
        final createdParent = await endpoints.promise.createGroupedPromise(
          creatorSession,
          parent,
          [c1],
        );

        final children = await endpoints.promise.getChildPromises(
          creatorSession,
          createdParent.id!,
        );
        final child1Db = children[0];

        await endpoints.promise.acceptPromise(child1Session, child1Db.id!);

        await endpoints.promise.confirmPromiseCompletion(
          creatorSession,
          child1Db.id!,
          'creator',
        );

        var updatedChild = await endpoints.promise.getPromise(
          creatorSession,
          child1Db.id!,
        );
        expect(updatedChild!.status, 'awaiting_confirmation');
        expect(updatedChild.creatorConfirmed, isTrue);

        var updatedParent = await endpoints.promise.getPromise(
          creatorSession,
          createdParent.id!,
        );
        expect(updatedParent!.status, 'in_progress');

        await endpoints.promise.requestChanges(
          child1Session,
          child1Db.id!,
          'recipient',
          'Need more details',
        );

        updatedChild = await endpoints.promise.getPromise(
          creatorSession,
          child1Db.id!,
        );
        expect(updatedChild!.status, 'in_progress');
        expect(updatedChild.creatorConfirmed, isFalse);
        expect(updatedChild.recipientConfirmed, isFalse);

        updatedParent = await endpoints.promise.getPromise(
          creatorSession,
          createdParent.id!,
        );
        expect(updatedParent!.status, 'in_progress');
        expect(updatedParent.status, isNot(equals('completed')));
      },
    );
  });
}
