import 'package:flutter_test/flutter_test.dart';
import 'package:promise_client/promise_client.dart';
import 'package:promise_flutter/main.dart';

void main() {
  group('Effective Commitment Type Policy Tests', () {
    final now = DateTime.now().toUtc();

    test('standalone 1-on-1 promise with stored personal remains personal', () {
      final p = Promise(
        title: 'Personal Favor',
        promisedTo: 'Friend',
        dueDate: now,
        createdAt: now,
        status: 'pending',
        isGroupParent: false,
        parentPromiseId: null,
        commitmentType: 'personal',
      );
      expect(DashboardScreen.effectiveCommitmentType(p), 'personal');
    });

    test(
      'standalone 1-on-1 promise with explicit freelance remains freelance',
      () {
        final p = Promise(
          title: 'Freelance Task',
          promisedTo: 'Client',
          dueDate: now,
          createdAt: now,
          status: 'pending',
          isGroupParent: false,
          parentPromiseId: null,
          commitmentType: 'freelance',
        );
        expect(DashboardScreen.effectiveCommitmentType(p), 'freelance');
      },
    );

    test('legacy group parent with stored personal resolves to team', () {
      final p = Promise(
        title: 'Legacy Group Parent',
        promisedTo: 'Multiple',
        dueDate: now,
        createdAt: now,
        status: 'pending',
        isGroupParent: true,
        parentPromiseId: null,
        commitmentType: 'personal', // Post-migration SQL column default
      );
      expect(DashboardScreen.effectiveCommitmentType(p), 'team');
    });

    test(
      'legacy child milestone with stored personal resolves to team or parent type',
      () {
        final child = Promise(
          title: 'Legacy Child Milestone',
          promisedTo: 'Friend',
          dueDate: now,
          createdAt: now,
          status: 'pending',
          isGroupParent: false,
          parentPromiseId: 100,
          commitmentType: 'personal', // Post-migration SQL column default
        );

        // Default fallback without parent context
        expect(DashboardScreen.effectiveCommitmentType(child), 'team');

        // With freelance parent project context
        expect(
          DashboardScreen.effectiveCommitmentType(
            child,
            parentType: 'freelance',
          ),
          'freelance',
        );
      },
    );
  });
}
