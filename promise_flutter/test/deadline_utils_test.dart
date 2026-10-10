import 'package:flutter_test/flutter_test.dart';
import 'package:promise_client/promise_client.dart';
import 'package:promise_flutter/utils/deadline_utils.dart';

void main() {
  group('DeadlineUtils', () {
    test(
      'isLegacyDate correctly identifies legacy dates based on non-zero UTC time',
      () {
        final legacyDate = DateTime.utc(
          2026,
          10,
          13,
          18,
          30,
          0,
        ); // E.g., IST +5:30 creation shifted
        final newDate = DateTime.utc(
          2026,
          10,
          14,
          0,
          0,
          0,
        ); // New exactly midnight UTC creation

        expect(DeadlineUtils.isLegacyDate(legacyDate), isTrue);
        expect(DeadlineUtils.isLegacyDate(newDate), isFalse);
      },
    );

    test('getDisplayDate returns unshifted local date for new format', () {
      // Creator selected Oct 14th date-only -> saved as Oct 14 00:00:00Z
      final utcDate = DateTime.utc(2026, 10, 14, 0, 0, 0);

      final displayDate = DeadlineUtils.getDisplayDate(utcDate, false);

      // Should result in local Date of exactly year 2026, month 10, day 14
      expect(displayDate.year, 2026);
      expect(displayDate.month, 10);
      expect(displayDate.day, 14);
      expect(displayDate.isUtc, isFalse);
    });

    test(
      'getEffectiveEndDateTime creates end-of-day for date-only promises',
      () {
        final utcDate = DateTime.utc(2026, 10, 14, 0, 0, 0);
        final promise = Promise(
          id: 1,
          title: 'Test',
          promisedTo: 'User',
          dueDate: utcDate,
          createdAt: DateTime.now(),
          status: 'pending',
        );

        final effectiveDate = DeadlineUtils.getEffectiveEndDateTime(promise);

        expect(effectiveDate.year, 2026);
        expect(effectiveDate.month, 10);
        expect(effectiveDate.day, 14);
        expect(effectiveDate.hour, 23);
        expect(effectiveDate.minute, 59);
        expect(effectiveDate.second, 59);
      },
    );

    test(
      'compareDeadlines sorts date-only end-of-day properly compared to timed deadlines',
      () {
        final dateOnlyPromise = Promise(
          id: 1,
          title: 'Date Only',
          promisedTo: 'User',
          dueDate: DateTime.utc(
            2026,
            10,
            14,
            0,
            0,
            0,
          ), // Will be effective Oct 14 23:59:59
          createdAt: DateTime.now(),
          status: 'pending',
        );

        final timedPromise = Promise(
          id: 2,
          title: 'Timed',
          promisedTo: 'User',
          dueDate: DateTime.utc(2026, 10, 14, 0, 0, 0),
          dueTime: DateTime(2026, 10, 14, 10, 0, 0), // Same day, 10:00 AM local
          createdAt: DateTime.now(),
          status: 'pending',
        );

        final nextDayPromise = Promise(
          id: 3,
          title: 'Next Day',
          promisedTo: 'User',
          dueDate: DateTime.utc(2026, 10, 15, 0, 0, 0), // Oct 15 23:59:59
          createdAt: DateTime.now(),
          status: 'pending',
        );

        final list = [nextDayPromise, dateOnlyPromise, timedPromise];

        list.sort(DeadlineUtils.compareDeadlines);

        // Sorting order should be: timedPromise -> dateOnlyPromise -> nextDayPromise
        expect(list[0].id, 2); // Timed: Oct 14 10:00:00
        expect(list[1].id, 1); // Date only: Oct 14 23:59:59
        expect(list[2].id, 3); // Next Day: Oct 15 23:59:59
      },
    );

    test('getIndicatorText calculates correct status relative to now', () {
      final now = DateTime.now();

      final overduePromise = Promise(
        id: 1,
        title: 'Overdue',
        promisedTo: 'User',
        dueDate: DateTime.utc(
          now.year,
          now.month,
          now.day - 1,
          0,
          0,
          0,
        ), // Yesterday
        createdAt: DateTime.now(),
        status: 'pending',
      );

      final dueTodayPromise = Promise(
        id: 2,
        title: 'Due Today',
        promisedTo: 'User',
        dueDate: DateTime.utc(now.year, now.month, now.day, 0, 0, 0), // Today
        createdAt: DateTime.now(),
        status: 'pending',
      );

      final upcomingPromise = Promise(
        id: 3,
        title: 'Upcoming',
        promisedTo: 'User',
        dueDate: DateTime.utc(
          now.year,
          now.month,
          now.day + 1,
          0,
          0,
          0,
        ), // Tomorrow
        createdAt: DateTime.now(),
        status: 'pending',
      );

      expect(DeadlineUtils.getIndicatorText(overduePromise), 'Overdue');
      expect(DeadlineUtils.getIndicatorText(dueTodayPromise), 'Due Today');
      expect(DeadlineUtils.getIndicatorText(upcomingPromise), 'Upcoming');

      final completedPromise = overduePromise.copyWith(status: 'completed');
      expect(DeadlineUtils.getIndicatorText(completedPromise), '');
    });
  });
}
