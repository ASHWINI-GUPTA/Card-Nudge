import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/enums/currency.dart';
import '../../data/enums/language.dart';
import '../../data/hive/models/settings_model.dart';
import '../../data/hive/storage/credit_card_storage.dart';
import '../../data/hive/storage/payment_storage.dart';
import '../../data/hive/storage/setting_storage.dart';
import '../../services/notification_service.dart';
import 'user_provider.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsModel>(
  (ref) {
    final user = ref.watch(userProvider);
    final userId = user?.id ?? '00000000-0000-0000-0000-000000000000';
    return SettingsNotifier(ref, userId);
  },
);

class SettingsNotifier extends StateNotifier<SettingsModel> {
  final Ref _ref;
  String _userId;

  final defaultSettingId = '00000000-0000-0000-0000-000000000000';

  SettingsNotifier(this._ref, this._userId)
    : super(SettingsModel(userId: _userId)) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final box = SettingStorage.getBox();
      final setting = box.values.first;
      // Update userId in box if needed
      if (setting.userId != _userId) {
        setting.userId = _userId;
        await box.put(defaultSettingId, setting);
      }
      state = setting;
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> updateUserId(String newUserId) async {
    _userId = newUserId;
    final box = SettingStorage.getBox();
    final setting = box.values.first;
    if (setting.userId != newUserId) {
      setting.userId = newUserId;
      await box.put(defaultSettingId, setting);
      state = setting;
    }
  }

  Future<void> _saveSettings(SettingsModel newState) async {
    try {
      final box = SettingStorage.getBox();
      newState.userId = _userId;
      await box.put(defaultSettingId, newState);
      state = newState;
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
    // Cancel or reschedule notifications based on toggle
    final notificationProvider = _ref.read(notificationServiceProvider);
    if (!enabled) {
      await notificationProvider.cancelAllNotifications();
    } else {
      final cards = CreditCardStorage.getBox().values.toList();
      final payments = PaymentStorage.getBox().values.toList();
      await notificationProvider.rescheduleAllNotifications(
        cards: cards,
        payments: payments.where((p) => !p.isPaid).toList(),
        reminderTime: state.reminderTime,
      );
    }
  }

  Future<void> updateReminderTime(TimeOfDay time) async {
    await _saveSettings(state.copyWith(reminderTime: time, syncPending: true));
    // Reschedule notifications with new time
    final cards = CreditCardStorage.getBox().values.toList();
    final payments = PaymentStorage.getBox().values.toList();

    final notificationProvider = _ref.read(notificationServiceProvider);
    await notificationProvider.rescheduleAllNotifications(
      cards: cards,
      payments: payments.where((p) => !p.isPaid).toList(),
      reminderTime: time,
    );
  }

  Future<void> updateSyncPreference(bool syncPreference) async {
    await _saveSettings(
      state.copyWith(syncSettings: syncPreference, syncPending: true),
    );
  }

  void refresh() {
    _loadSettings();
  }
}
