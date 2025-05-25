import 'package:card_nudge/data/enums/currency.dart';
import 'package:card_nudge/data/enums/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/enums/app_theme_mode.dart';
import '../../data/hive/models/settings_model.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsModel>(
  (ref) {
    return SettingsNotifier();
  },
);

class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier() : super(SettingsModel());

  void updateLanguage(Language languageCode) {
    state = state.copyWith(language: languageCode);
  }

  void updateCurrency(Currency currencyCode) {
    state = state.copyWith(currency: currencyCode);
  }

  void updateTheme(AppThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
  }

  void updateNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }

  void updateReminderTime(TimeOfDay time) {
    state = state.copyWith(reminderTime: time);
  }
}
