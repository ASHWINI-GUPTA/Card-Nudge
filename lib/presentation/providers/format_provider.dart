import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../data/enums/currency.dart';
import '../../data/enums/language.dart';
import '../../data/hive/models/settings_model.dart';
import 'setting_provider.dart';

final formatHelperProvider = Provider<FormatHelper>((ref) {
  return FormatHelper(ref);
});

class FormatHelper {
  final Ref ref;

  FormatHelper(this.ref);

  SettingsModel get _settings {
    return ref.watch(settingsProvider);
  }

  Language get _language => _settings.language;

  Currency get _currency => _settings.currency;

  String get _currencySymbol {
    return _currency.symbol;
  }

  String formatCurrency(
    double amount, {
    bool showSymbol = true,
    int decimalDigits = 2,
    String? customPattern,
  }) {
    final formatter = NumberFormat.currency(
      locale: _currency.locale,
      symbol: showSymbol ? _currencySymbol : '',
      decimalDigits: decimalDigits,
      customPattern: customPattern,
    );
    return formatter.format(amount);
  }

  String formatCurrencyCompact(
    double amount, {
    bool showSymbol = true,
    int decimalDigits = 1,
  }) {
    final formatter = NumberFormat.compactSimpleCurrency(
      locale: _currency.locale,
      name: showSymbol ? _currency.code : '',
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  String formatShortDate(DateTime date) {
    final localDate = _toLocal(date);
    return DateFormat.MMMd(_language.locale).format(localDate);
  }

  String formatDate(DateTime date, {String format = 'MMMM d, yyyy'}) {
    final localDate = _toLocal(date);
    return DateFormat(format, _language.locale).format(localDate);
  }

  String formatTime(TimeOfDay time) {
    final formatter = DateFormat.jm(_language.locale);
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    final localDateTime = _toLocal(dateTime);
    return formatter.format(localDateTime);
  }

  String formatDateTime(
    DateTime dateTime, {
    String dateFormat = 'yMd',
    String timeFormat = 'jm',
  }) {
    final localDateTime = _toLocal(dateTime);
    final dateStr = DateFormat(
      dateFormat,
      _language.locale,
    ).format(localDateTime);
    final timeStr = DateFormat(
      timeFormat,
      _language.locale,
    ).format(localDateTime);
    return '$dateStr, $timeStr';
  }

  DateTime? parseDate(String dateString) {
    final formats = [
      DateFormat.yMd(_language.locale),
      DateFormat('yyyy-MM-dd'),
      DateFormat('dd/MM/yyyy'),
      DateFormat('MM/dd/yyyy'),
    ];

    for (final format in formats) {
      try {
        return format.parse(dateString);
      } catch (_) {}
    }
    return null;
  }

  TimeOfDay? parseTime(String timeString) {
    final formats = [
      DateFormat.jm(_language.locale),
      DateFormat.Hm(_language.locale),
      DateFormat('HH:mm'),
      DateFormat('h:mm a'),
    ];

    for (final format in formats) {
      try {
        final dateTime = format.parse(timeString);
        return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
      } catch (_) {}
    }
    return null;
  }

  /// Convert UTC DateTime to local using timezone package if available, else fallback to .toLocal()
  DateTime _toLocal(DateTime dateTime) {
    try {
      // If already local, return as is
      if (!dateTime.isUtc) return dateTime;
      // Use timezone package if tz.local is set
      final tzDateTime = tz.TZDateTime.from(dateTime, tz.local);
      return DateTime(
        tzDateTime.year,
        tzDateTime.month,
        tzDateTime.day,
        tzDateTime.hour,
        tzDateTime.minute,
        tzDateTime.second,
        tzDateTime.millisecond,
        tzDateTime.microsecond,
      );
    } catch (_) {
      // Fallback to Dart's built-in conversion
      return dateTime.toLocal();
    }
  }

  // Extension methods for DateTime and TimeOfDay
  String formatDateTimeExtension(DateTime dateTime) => formatDateTime(dateTime);
  String formatTimeExtension(TimeOfDay time) => formatTime(time);
}
