import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  // Advances to the next monthly cycle, preserving day or adjusting to end of month
  DateTime nextMonthlyCycleDate() {
    int targetYear = year;
    int targetMonth = month + 1;
    if (targetMonth > 12) {
      targetMonth = 1;
      targetYear += 1;
    }
    // Handle end-of-month (e.g., Jan 31 → Feb 28/29)
    int targetDay = day;
    final daysInTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    if (targetDay > daysInTargetMonth) {
      targetDay = daysInTargetMonth;
    }
    return DateTime(targetYear, targetMonth, targetDay);
  }

  // NEW: Reverts to the previous monthly cycle
  DateTime previousMonthlyCycleDate() {
    int targetYear = year;
    int targetMonth = month - 1;
    if (targetMonth < 1) {
      targetMonth = 12;
      targetYear -= 1;
    }
    // Handle end-of-month (e.g., Mar 31 → Feb 28/29)
    int targetDay = day;
    final daysInTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    if (targetDay > daysInTargetMonth) {
      targetDay = daysInTargetMonth;
    }
    return DateTime(targetYear, targetMonth, targetDay);
  }

  // Calculates due date by adding grace days
  DateTime dueDateFromBillingGrace(int graceDays) {
    return add(Duration(days: graceDays));
  }

  // Ceiling difference in days between two dates
  int differenceInDaysCeil(DateTime other) {
    final difference = this.difference(other).inDays;
    return difference >= 0 ? difference : difference - 1;
  }

  // Format date using intl package
  String formatDate({String format = 'MMM d, yyyy'}) {
    return DateFormat(format).format(this);
  }
}
