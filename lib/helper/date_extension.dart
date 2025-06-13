extension CreditCardDateExtension on DateTime {
  DateTime get nextDueDate {
    int year = this.year;
    int month = this.month + 1;

    // Handle year rollover (December → January)
    if (month > 12) {
      month = 1;
      year++;
    }

    // Tentatively set same day next month
    DateTime tentativeDueDate = DateTime(year, month, this.day);

    // If overflowed (e.g., Feb 30 → Mar 1), adjust to last valid day of next month
    if (tentativeDueDate.month != month) {
      tentativeDueDate = DateTime(
        year,
        month + 1,
        0, // 0 = last day of prev month
      );
    }

    return tentativeDueDate;
  }
}
