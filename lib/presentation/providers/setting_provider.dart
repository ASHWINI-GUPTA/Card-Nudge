import 'package:card_nudge/data/enums/currency.dart';
import 'package:card_nudge/data/enums/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hive/models/settings_model.dart';
import 'user_provider.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsModel>(
  (ref) {
    // After Login id MUST NOT be NULL 🤪
    final user = ref.watch(userProvider);
    final userId =
        user == null ? '00000000-0000-0000-0000-000000000000' : user.id;
    return SettingsNotifier(userId);
  },
);

class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier(String userId) : super(SettingsModel(userId: userId));

  void updateLanguage(Language languageCode) {
    state = state.copyWith(language: languageCode);
  }

  void updateCurrency(Currency currencyCode) {
    state = state.copyWith(currency: currencyCode);
  }

  void updateTheme(ThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
  }

  void updateNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }

  void updateReminderTime(TimeOfDay time) {
    state = state.copyWith(reminderTime: time);
  }
}
