import 'package:card_nudge/data/enums/app_theme_mode.dart';
import 'package:card_nudge/data/enums/currency.dart';
import 'package:card_nudge/data/enums/language.dart';
import 'package:flutter/material.dart';

class SettingsModel {
  final Language language;
  final Currency currency;
  final AppThemeMode themeMode;
  final bool notificationsEnabled;
  final TimeOfDay reminderTime;

  SettingsModel({
    this.language = Language.en,
    this.currency = Currency.INR,
    this.themeMode = AppThemeMode.system,
    this.notificationsEnabled = true,
    this.reminderTime = const TimeOfDay(hour: 9, minute: 0),
  });

  SettingsModel copyWith({
    Language? language,
    Currency? currency,
    AppThemeMode? themeMode,
    bool? notificationsEnabled,
    TimeOfDay? reminderTime,
  }) {
    return SettingsModel(
      language: language ?? this.language,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
