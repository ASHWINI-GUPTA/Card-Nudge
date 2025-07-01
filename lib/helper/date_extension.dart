extension CreditCardDateExtension on DateTime {
  /// Returns the next billing/due date for a monthly cycle.
  /// - If the next month has the same day, returns that date.
  /// - If the next month is shorter (e.g., Jan 31 → Feb 28/29), returns the last day of next month.
  DateTime get nextMonthlyCycleDate {
    int year = this.year;
    int month = this.month + 1;
    if (month > 12) {
      month = 1;
      year++;
    }
    // Try same day next month
    DateTime tentative = DateTime(year, month, this.day);
    // If overflowed, fallback to last day of next month
    if (tentative.month != month) {
      tentative = DateTime(year, month + 1, 0);
    }
    return tentative;
  }

  /// Returns the date exactly 30 days after this date.
  /// Use for cards with a fixed 30-day cycle (not calendar month).
  DateTime get next30DayCycleDate => add(const Duration(days: 30));

  /// Returns the next due date for cards that always use the last day of the next month.
  /// E.g., if billing date is 31st, always returns last day of next month.
  DateTime get nextLastDayOfMonth {
    int year = this.year;
    int month = this.month + 1;
    if (month > 12) {
      month = 1;
      year++;
    }
    return DateTime(year, month + 1, 0);
  }

  /// Returns the next due date for cards that always use a fixed day of month (e.g., always 15th).
  /// If the next month doesn't have that day (e.g., Feb 30), returns last day of next month.
  DateTime nextFixedDayOfMonth(int day) {
    int year = this.year;
    int month = this.month + 1;
    if (month > 12) {
      month = 1;
      year++;
    }
    // Try fixed day next month
    DateTime tentative = DateTime(year, month, day);
    // If overflowed, fallback to last day of next month
    if (tentative.month != month) {
      tentative = DateTime(year, month + 1, 0);
    }
    return tentative;
  }

  /// Returns the next due date for cards with a custom interval (e.g., every N days).
  DateTime nextCustomInterval(int days) => add(Duration(days: days));

  /// Returns a positive number if [other] is in the past,
  /// zero if same day, and a negative number if [other] is in the future.
  int differenceInDaysCeil(DateTime other) {
    final difference = this.difference(other);
    return (difference.inHours / 24).ceil();
  }
}
