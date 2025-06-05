import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

  // Get current settings from settingsProvider, reactive to changes
  SettingsModel get _settings => ref.watch(settingsProvider);

  // Get current locale
  Language get _language => _settings.language;

  // Get current currency code
  Currency get _currencyCode => _settings.currency;

  // Get currency symbol based on currency code
  String get _currencySymbol {
    switch (_currencyCode) {
      case Currency.INR:
        return '₹';
      case Currency.USD:
        return '\$';
    }
  }

  // Format currency amount with locale-specific formatting
  String formatCurrency(
    double amount, {
    bool showSymbol = true,
    int decimalDigits = 0,
  }) {
    final formatter = NumberFormat.currency(
      name: _currencyCode.code,
      locale: _currencyCode.locale,
      symbol: showSymbol ? _currencySymbol : '',
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  // Format currency amount in compact form (e.g., ₹1.2K, $5M)
  String formatCurrencyCompact(
    double amount, {
    bool showSymbol = true,
    int decimalDigits = 0,
  }) {
    final formatter = NumberFormat.compactCurrency(
      name: _currencyCode.code,
      locale: _currencyCode.locale,
      symbol: showSymbol ? _currencySymbol : '',
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  // Format date (e.g., June 1)
  String formatShortDate(DateTime date) {
    final formatter = DateFormat.MMMd(_language.locale);
    return formatter.format(date);
  }

  // Format date (e.g., 25/05/2025 or 25-05-2025 based on locale)
  String formatDate(DateTime date) {
    final formatter = DateFormat.yMd(_language.locale);
    return formatter.format(date);
  }

  // Format time (e.g., 3:30 PM or 15:30 based on locale)
  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    final formatter = DateFormat.jm(_language.locale);
    return formatter.format(dateTime);
  }

  // Format datetime (e.g., 25/05/2025, 3:30 PM)
  String formatDateTime(DateTime dateTime) {
    final dateFormatter = DateFormat.yMd(_language.locale);
    final timeFormatter = DateFormat.jm(_language.locale);
    return '${dateFormatter.format(dateTime)}, ${timeFormatter.format(dateTime)}';
  }

  // Parse date string to DateTime (expects format based on locale)
  DateTime? parseDate(String dateString) {
    try {
      final formatter = DateFormat.yMd(_language.locale);
      return formatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Parse time string to TimeOfDay
  TimeOfDay? parseTime(String timeString) {
    try {
      final formatter = DateFormat.jm(_language.locale);
      final dateTime = formatter.parse(timeString);
      return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    } catch (e) {
      return null;
    }
  }

  // Get current date
  DateTime getCurrentDate() => DateTime.now();

  // Get current time
  TimeOfDay getCurrentTime() {
    final now = DateTime.now();
    return TimeOfDay(hour: now.hour, minute: now.minute);
  }

  // Get current datetime
  DateTime getCurrentDateTime() => DateTime.now();
}
