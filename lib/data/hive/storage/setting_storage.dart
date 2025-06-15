import 'package:card_nudge/data/hive/adapters/card_type_adapter.dart';
import 'package:card_nudge/data/hive/models/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../enums/currency.dart';
import '../../enums/language.dart';

class SettingStorage {
  static Box<SettingsModel>? _box;

  static Box<SettingsModel> getBox() {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Hive box not initialized. Call initHive() first.');
    }
    return _box!;
  }

  static Future<void> initHive() async {
    Hive.registerAdapter(SettingsModelAdapter());
    Hive.registerAdapter(CurrencyAdapter());
    Hive.registerAdapter(LanguageAdapter());
    Hive.registerAdapter(ThemeModeAdapter());
    Hive.registerAdapter(TimeOfDayAdapter());
    _box = await Hive.openBox<SettingsModel>('settings');

    if (_box!.isEmpty) {
      _box!.put(
        '00000000-0000-0000-0000-000000000000',
        SettingsModel(
          language: Language.en,
          currency: Currency.INR,
          themeMode: ThemeMode.system,
          notificationsEnabled: true,
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
          syncSettings: false,
          updatedAt: DateTime(2012, 12, 12),
          createdAt: DateTime(2012, 12, 12),
        ),
      );
    }
  }
}
