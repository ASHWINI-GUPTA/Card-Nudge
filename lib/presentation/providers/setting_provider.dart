import 'package:card_nudge/data/enums/currency.dart';
import 'package:card_nudge/data/enums/language.dart';
import 'package:card_nudge/data/hive/models/settings_model.dart';
import 'package:card_nudge/data/hive/storage/setting_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user_provider.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsModel>(
  (ref) {
    // After login, user ID must not be null
    final user = ref.watch(userProvider);
    final userId =
        user == null ? '00000000-0000-0000-0000-000000000000' : user.id;
    return SettingsNotifier(userId);
  },
);

class SettingsNotifier extends StateNotifier<SettingsModel> {
  final String _userId;

  SettingsNotifier(this._userId) : super(SettingsModel(userId: _userId)) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final box = SettingStorage.getBox();
      final settings = box.get(_userId);
      if (settings != null) {
        state = settings;
      } else {
        // Initialize default settings if none exist
        await box.put(_userId, state);
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings(SettingsModel newState) async {
    try {
      state = newState;
      final box = SettingStorage.getBox();
      await box.put(_userId, newState);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  Future<void> updateLanguage(Language languageCode) async {
    await _saveSettings(
      state.copyWith(language: languageCode, syncPending: true),
    );
  }

  Future<void> updateCurrency(Currency currencyCode) async {
    await _saveSettings(
      state.copyWith(currency: currencyCode, syncPending: true),
    );
  }

  Future<void> updateTheme(ThemeMode themeMode) async {
    await _saveSettings(
      state.copyWith(themeMode: themeMode, syncPending: true),
    );
  }

  Future<void> updateNotifications(bool enabled) async {
    await _saveSettings(
      state.copyWith(notificationsEnabled: enabled, syncPending: true),
    );
  }

  Future<void> updateReminderTime(TimeOfDay time) async {
    await _saveSettings(state.copyWith(reminderTime: time, syncPending: true));
  }

  Future<void> updateSyncPreference(bool syncPreference) async {
    await _saveSettings(
      state.copyWith(syncSettings: syncPreference, syncPending: true),
    );
  }
}
