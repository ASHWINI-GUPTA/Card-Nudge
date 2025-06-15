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
      // Adding Default Settings if box is empty
      final setting = box.values.first;
      state = setting;
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings(SettingsModel newState) async {
    try {
      final box = SettingStorage.getBox();
      // Update UserId
      newState.userId = _userId;
      // As there is only one setting in Store, newState.id will have the id of default setting.
      await box.put(newState.id, newState);
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
    if (!enabled) {
      await NotificationService().cancelAllNotifications();
    } else {
      final cards = CreditCardStorage.getBox().values.toList();
      final payments = PaymentStorage.getBox().values.toList();
      await NotificationService().rescheduleAllNotifications(
        cards: cards,
        payments: payments,
        reminderTime: state.reminderTime,
      );
      // Schedule daily insight
      final dueCount =
          payments
              .where(
                (p) =>
                    !p.isPaid &&
                    p.dueDate.difference(DateTime.now()).inDays >= 0 &&
                    p.dueDate.difference(DateTime.now()).inDays <= 7,
              )
              .length;
      await NotificationService().scheduleDailyInsight(
        dueCount: dueCount,
        reminderTime: state.reminderTime,
      );
    }
  }

  Future<void> updateReminderTime(TimeOfDay time) async {
    await _saveSettings(state.copyWith(reminderTime: time, syncPending: true));
    // Reschedule notifications with new time
    final cards = CreditCardStorage.getBox().values.toList();
    final payments = PaymentStorage.getBox().values.toList();
    await NotificationService().rescheduleAllNotifications(
      cards: cards,
      payments: payments,
      reminderTime: time,
    );
    // Schedule daily insight
    final dueCount =
        payments
            .where(
              (p) =>
                  !p.isPaid &&
                  p.dueDate.difference(DateTime.now()).inDays >= 0 &&
                  p.dueDate.difference(DateTime.now()).inDays <= 7,
            )
            .length;
    await NotificationService().scheduleDailyInsight(
      dueCount: dueCount,
      reminderTime: time,
    );
  }

  Future<void> updateSyncPreference(bool syncPreference) async {
    await _saveSettings(
      state.copyWith(syncSettings: syncPreference, syncPending: true),
    );
  }
}
