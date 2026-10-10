import 'package:promise_client/promise_client.dart';

class DeadlineUtils {
  /// Determines if a stored dueDate is from the legacy implementation.
  ///
  /// The legacy implementation stored date-only deadlines by constructing a local
  /// midnight DateTime and calling `.toUtc()`. For timezones ahead of UTC,
  /// this resulted in non-zero time components (e.g., IST +5:30 became 18:30:00Z
  /// on the previous day).
  /// The new implementation uses `.utc(...)` which results in exactly 00:00:00Z.
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

    // For legacy dates, we must fall back to local timezone conversion,
    // assuming the viewer is in a similar timezone to the creator, which is
    // the safest available heuristic.
    if (isLegacyDate(dueDate)) return dueDate.toLocal();

    // For new date-only formats (UTC midnight), extract Y/M/D directly
    // to a local DateTime to prevent any timezone shifting on render.
    return DateTime(dueDate.year, dueDate.month, dueDate.day);
  }

  /// Calculates the effective local DateTime when a promise is truly due.
  static DateTime getEffectiveEndDateTime(Promise promise) {
    if (promise.dueTime != null) {
      return promise.dueTime!.toLocal();
    }

    // For date-only deadlines, the deadline is the very end of the display day.
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

  /// Returns an indicator string (Overdue, Due Today, Upcoming) based on the deadline.
  static String getIndicatorText(Promise promise) {
    if (promise.status.toLowerCase() == 'completed') return '';

    final now = DateTime.now();
    final effectiveEnd = getEffectiveEndDateTime(promise);

    if (effectiveEnd.isBefore(now)) {
      return 'Overdue';
    }

    if (effectiveEnd.year == now.year &&
        effectiveEnd.month == now.month &&
        effectiveEnd.day == now.day) {
      return 'Due Today';
    }

    return 'Upcoming';
  }
}
