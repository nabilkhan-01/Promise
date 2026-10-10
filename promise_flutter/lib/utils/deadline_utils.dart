import 'package:promise_client/promise_client.dart';

class DeadlineUtils {
  /// Determines if a stored dueDate is from the legacy implementation.
  static bool isLegacyDate(DateTime date) {
    if (!date.isUtc) return false;
    return date.hour != 0 ||
        date.minute != 0 ||
        date.second != 0 ||
        date.millisecond != 0;
  }

  /// Extracts the intended calendar date for display, avoiding timezone shifts
  /// for new date-only deadlines.
  static DateTime getDisplayDate(DateTime dueDate, bool hasTime) {
    if (hasTime) return dueDate.toLocal();

    if (isLegacyDate(dueDate)) return dueDate.toLocal();

    return DateTime(dueDate.year, dueDate.month, dueDate.day);
  }

  /// Calculates the effective local DateTime when a promise is truly due.
  static DateTime getEffectiveEndDateTime(Promise promise) {
    if (promise.dueTime != null) {
      return promise.dueTime!.toLocal();
    }

    final displayDate = getDisplayDate(promise.dueDate, false);
    return DateTime(
      displayDate.year,
      displayDate.month,
      displayDate.day,
      23,
      59,
      59,
    );
  }

  /// Compares two promises to sort by their effective deadlines.
  static int compareDeadlines(Promise a, Promise b) {
    final aEnd = getEffectiveEndDateTime(a);
    final bEnd = getEffectiveEndDateTime(b);
    return aEnd.compareTo(bEnd);
  }

  /// Returns an indicator string (e.g. Awaiting acceptance, Overdue by 2 days, Due today, Due tomorrow, Due Oct 14) based on the deadline.
  static String getIndicatorText(Promise promise) {
    if (promise.status.toLowerCase() == 'completed') return '';

    if (promise.recipientUserId != null && !promise.recipientAccepted) {
      return 'Awaiting acceptance';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final effectiveEnd = getEffectiveEndDateTime(promise);
    final dueDateOnly = DateTime(
      effectiveEnd.year,
      effectiveEnd.month,
      effectiveEnd.day,
    );

    if (effectiveEnd.isBefore(now)) {
      final daysOverdue = today.difference(dueDateOnly).inDays;
      if (daysOverdue > 1) {
        return 'Overdue by $daysOverdue days';
      }
      return 'Overdue';
    }

    final daysDiff = dueDateOnly.difference(today).inDays;
    if (daysDiff == 0) {
      return 'Due today';
    } else if (daysDiff == 1) {
      return 'Due tomorrow';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return 'Due ${months[dueDateOnly.month - 1]} ${dueDateOnly.day}';
    }
  }
}
