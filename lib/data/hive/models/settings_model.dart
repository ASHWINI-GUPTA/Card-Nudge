import 'package:card_nudge/data/enums/currency.dart';
import 'package:card_nudge/data/enums/language.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 4)
class SettingsModel {
  @HiveField(1)
  String userId;

  @HiveField(2)
  Language language;

  @HiveField(3)
  Currency currency;

  @HiveField(4)
  ThemeMode themeMode;

  @HiveField(5)
  bool notificationsEnabled;

  @HiveField(6)
  TimeOfDay reminderTime;

  @HiveField(7)
  bool syncSettings;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  @HiveField(10)
  bool syncPending;

  SettingsModel({
    String? userId,
    this.language = Language.en,
    this.currency = Currency.INR,
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.reminderTime = const TimeOfDay(hour: 9, minute: 0),
    this.syncSettings = true,
    this.syncPending = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : userId = (userId ?? '00000000-0000-0000-0000-000000000000'),
       createdAt = (createdAt ?? DateTime.now()).toUtc(),
       updatedAt = (updatedAt ?? DateTime.now()).toUtc();

  SettingsModel copyWith({
    Language? language,
    Currency? currency,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    TimeOfDay? reminderTime,
    bool? syncSettings,
    bool? syncPending,
  }) {
    return SettingsModel(
      userId: this.userId,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      syncSettings: syncSettings ?? this.syncSettings,
      syncPending: syncPending ?? this.syncPending,
    );
  }

  // Getter to check if userId is '00000000-0000-0000-0000-000000000000'
  bool get isDefaultSetting => userId == '00000000-0000-0000-0000-000000000000';

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'language': language.name,
      'currency': currency.name,
      'theme_mode': themeMode.name,
      'notifications_enabled': notificationsEnabled,
      'reminder_time': '${reminderTime.hour}:${reminderTime.minute}',
      'sync_settings': syncSettings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
