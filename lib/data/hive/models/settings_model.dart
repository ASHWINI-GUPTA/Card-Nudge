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

  @HiveField(11)
  int? utilizationAlertThreshold;

  SettingsModel({
    required this.userId,
    this.language = Language.English,
    this.currency = Currency.INR,
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    TimeOfDay? reminderTime,
    this.syncSettings = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncPending = false,
    this.utilizationAlertThreshold = 30,
  }) : reminderTime = reminderTime ?? const TimeOfDay(hour: 10, minute: 0),
       createdAt = (createdAt ?? DateTime.now()).toUtc(),
       updatedAt = (updatedAt ?? DateTime.now()).toUtc();

  SettingsModel copyWith({
    String? userId,
    Language? language,
    Currency? currency,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    TimeOfDay? reminderTime,
    bool? syncSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? syncPending,
    int? utilizationAlertThreshold,
  }) {
    return SettingsModel(
      userId: userId ?? this.userId,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      syncSettings: syncSettings ?? this.syncSettings,
      createdAt: createdAt?.toUtc() ?? this.createdAt,
      updatedAt: updatedAt?.toUtc() ?? DateTime.now().toUtc(),
      syncPending: syncPending ?? this.syncPending,
      utilizationAlertThreshold:
          utilizationAlertThreshold ?? this.utilizationAlertThreshold,
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
      'utilization_alert_threshold': utilizationAlertThreshold,
    };
  }
}
