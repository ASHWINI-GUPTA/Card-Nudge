import 'dart:async';
import 'dart:io';
import 'package:card_nudge/data/hive/storage/credit_card_storage.dart';
import 'package:card_nudge/data/hive/storage/payment_storage.dart';
import 'package:card_nudge/data/hive/storage/setting_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

import '../data/hive/models/payment_model.dart';
import '../data/hive/models/settings_model.dart';

class NotificationService {
  static const MethodChannel _channel = MethodChannel(
    'in.fnlsg.card/notifications',
  );
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  Timer? _debounceTimer;

  Future<void> init() async {
    try {
      tzData.initializeTimeZones();

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          print('Notification received: ${details.payload}');
        },
      );

      if (Platform.isAndroid) {
        final androidImpl =
            _notifications
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();
        await androidImpl?.requestExactAlarmsPermission();
        await Permission.notification.request();
      } else if (Platform.isIOS) {
        await _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
              critical: true,
            );
      }
    } catch (e) {
      print('NotificationService.init error: $e');
    }
  }

  Future<void> scheduleBillNotifications() async {
    try {
      final settingsBox = SettingStorage.getBox();
      final settings = settingsBox.values.firstOrNull;
      if (settings == null || !settings.notificationsEnabled) {
        await _notifications.cancelAll();
        print('Notifications disabled or settings missing');
        return;
      }

      final reminderTime = settings.reminderTime;
      final paymentsBox = PaymentStorage.getBox();
      final cardsBox = CreditCardStorage.getBox();
      final payments = paymentsBox.values.toList();
      final cards = cardsBox.values.toList();

      await _notifications.cancelAll();
      final now = DateTime.now();

      for (final payment in payments) {
        if (payment.isPaid) continue;

        final dueDate = payment.dueDate;

        for (int i = 7; i >= 0; i--) {
          final reminderDate = dueDate.subtract(Duration(days: i));
          if (reminderDate.isBefore(now)) continue;

          final scheduledTime = tz.TZDateTime(
            tz.local,
            reminderDate.year,
            reminderDate.month,
            reminderDate.day,
            reminderTime.hour,
            reminderTime.minute,
          );

          await _notifications.zonedSchedule(
            int.parse(payment.id) * 10 + i,
            'Payment Reminder',
            'Log payment of ${payment.dueAmount} for card ending ${payment.cardId} due on ${dueDate.toString().split(' ')[0]}',
            scheduledTime,
            _notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dateAndTime,
            payload: payment.id,
          );
        }

        final overdueTime = tz.TZDateTime(
          tz.local,
          dueDate.year,
          dueDate.month,
          dueDate.day,
          reminderTime.hour,
          reminderTime.minute,
        ).add(const Duration(days: 1));

        if (overdueTime.isAfter(now)) {
          await _notifications.zonedSchedule(
            int.parse(payment.id) * 10 + 8,
            'Payment Overdue',
            'Payment of ${payment.dueAmount} for card ending ${payment.cardId} is overdue!',
            overdueTime,
            _notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dateAndTime,
            payload: payment.id,
          );
        }
      }

      for (final card in cards) {
        if (card.isArchived) continue;

        final billingDate = card.billingDate;
        if (billingDate.isBefore(now)) continue;

        final scheduledTime = tz.TZDateTime(
          tz.local,
          billingDate.year,
          billingDate.month,
          billingDate.day,
          reminderTime.hour,
          reminderTime.minute,
        );

        await _notifications.zonedSchedule(
          int.parse(card.id) * 1000,
          'Billing Date Reminder',
          'Billing date for card ${card.name} (ending ${card.last4Digits}) is today!',
          scheduledTime,
          _notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
          payload: card.id,
        );
      }

      await _showInsightNotification(payments);
    } catch (e) {
      print('scheduleBillNotifications error: $e');
    }
  }

  NotificationDetails get _notificationDetails => const NotificationDetails(
    android: AndroidNotificationDetails(
      'due_channel',
      'Due Reminders',
      channelDescription: 'Reminders for credit card due dates and billing',
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      ledColor: Colors.red,
      ledOnMs: 1000,
      ledOffMs: 500,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alert'),
      category: AndroidNotificationCategory.reminder,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alert.aiff',
    ),
  );

  Future<void> cancelNotifications(String key) async {
    try {
      for (int i = 0; i <= 8; i++) {
        await _notifications.cancel(int.parse(key) * 10 + i);
      }
      await _notifications.cancel(int.parse(key) * 1000);
    } catch (e) {
      print('cancelNotifications error: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      print('cancelAllNotifications error: $e');
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      print('getPendingNotifications error: $e');
      return [];
    }
  }

  Future<void> _showInsightNotification(List<PaymentModel> payments) async {
    try {
      final dueSoonCount = _getDueSoonCount(payments);
      final bigText =
          '💡 You have $dueSoonCount card${dueSoonCount == 1 ? '' : 's'} due this week. Stay ahead and avoid late fees!';

      final androidDetails = AndroidNotificationDetails(
        'insight_channel',
        'Insight Notifications',
        channelDescription: 'Shows daily credit card insights',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(
          bigText,
          contentTitle: '💡 Card Nudge Insight',
          summaryText: 'Manage your dues smarter!',
        ),
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: '📅 Weekly Summary',
        threadIdentifier: 'insight_thread',
        sound: 'alert.aiff',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        999,
        '💡 Card Nudge Insight',
        bigText,
        notificationDetails,
      );
    } catch (e) {
      print('_showInsightNotification error: $e');
    }
  }

  int _getDueSoonCount(List<PaymentModel> payments) {
    final now = DateTime.now();
    final oneWeekFromNow = now.add(const Duration(days: 7));
    return payments.where((p) {
      return !p.isPaid &&
          p.dueDate.isAfter(now) &&
          p.dueDate.isBefore(oneWeekFromNow);
    }).length;
  }

  Future<void> scheduleBackgroundCheck({bool immediate = false}) async {
    try {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
        final settingsBox = await Hive.openBox<SettingsModel>('settings');
        final settings = settingsBox.get('settings');
        if (settings == null) {
          print('Settings not found, skipping background check');
          return;
        }

        final reminderTime = settings.reminderTime;
        final now = DateTime.now();
        var targetTime = DateTime(
          now.year,
          now.month,
          now.day,
          reminderTime.hour,
          reminderTime.minute,
        );
        if (targetTime.isBefore(now)) {
          targetTime = targetTime.add(const Duration(days: 1));
        }
        final delaySeconds =
            immediate ? 10 : targetTime.difference(now).inSeconds;

        if (Platform.isAndroid) {
          await _channel.invokeMethod('scheduleBackgroundCheck', {
            'delaySeconds': delaySeconds,
            'isOneTime': immediate,
          });
        } else if (Platform.isIOS) {
          await _channel.invokeMethod('scheduleBackgroundCheck', {
            'identifier':
                immediate
                    ? 'in.fnlsg.card.immediateCheck'
                    : 'in.fnlsg.card.dailyCheck',
            'earliestBeginDate':
                DateTime.now()
                    .add(Duration(seconds: delaySeconds))
                    .millisecondsSinceEpoch /
                1000,
          });
        }
      });
    } catch (e) {
      print('scheduleBackgroundCheck error: $e');
    }
  }
}
