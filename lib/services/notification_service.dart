import 'dart:async';
import 'dart:io';
import 'package:card_nudge/data/hive/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/hive/models/credit_card_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

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
          // Handle notification tap if needed
          print('Notification received: ${details.payload}');
        },
      );
      if (Platform.isAndroid) {
        final androidInfo = await Permission.notification.status;
        if (!androidInfo.isGranted) {
          await Permission.notification.request();
        }
      } else if (Platform.isIOS) {
        await _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }
    } catch (e) {
      print('NotificationService.init error: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelAllCardNotifications(List<CreditCardModel> cards) async {
    for (final card in cards) {
      await cancelDueNotificationsByCardId(card.id);
      await cancelBillingNotificationByCardId(card.id);
    }
  }

  // Helper to get a stable, positive, bounded int from cardId
  int _cardIdInt(String cardId) {
    // Simple hash: sum of char codes modulo a large safe value
    return cardId.codeUnits.fold(0, (prev, c) => prev + c) % 1000000;
  }

  Future<void> cancelDueNotificationsByCardId(String cardId) async {
    final baseId = _cardIdInt(cardId);
    for (int i = 0; i < 5; i++) {
      await _notifications.cancel(baseId * 10 + i);
    }
  }

  Future<void> cancelBillingNotificationByCardId(String cardId) async {
    final baseId = _cardIdInt(cardId);
    await _notifications.cancel(baseId * 10 + 100);
  }

  Future<void> sendDailyInsight({
    required int dueCount,
    required BuildContext context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastSent = prefs.getString('daily_insight_last_sent');
    if (lastSent != null) {
      final lastSentDate = DateTime.tryParse(lastSent);
      if (lastSentDate != null &&
          lastSentDate.year == today.year &&
          lastSentDate.month == today.month &&
          lastSentDate.day == today.day) {
        // Already sent today, skip
        return;
      }
    }

    final bigText =
        '💡 You have $dueCount card${dueCount == 1 ? '' : 's'} due this week. Tap to view your dashboard.';
    final androidDetails = AndroidNotificationDetails(
      'insight_channel',
      'Insight Notifications',
      channelDescription: 'Shows daily credit card insights',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(bigText),
    );
    final iosDetails = DarwinNotificationDetails();
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999,
      '💡 Card Nudge Insight',
      bigText,
      notificationDetails,
      payload: '/dashboard',
    );

    // Save today's date as last sent
    await prefs.setString('daily_insight_last_sent', today.toIso8601String());
  }

  Future<void> scheduleBillingAndDueNotifications({
    required String cardId,
    required String cardName,
    required String last4Digits,
    required DateTime billingDate,
    required DateTime dueDate,
    required List<PaymentModel> payments,
    required TimeOfDay reminderTime,
  }) async {
    final baseId = _cardIdInt(cardId);

    // Cancel previous notifications for this card
    await cancelDueNotificationsByCardId(cardId);
    await cancelBillingNotificationByCardId(cardId);

    final duePayment = payments.where((p) => !p.isPaid);

    // AG: I don't know why I'm using a .map here, It is Copilot's suggestion -
    // It's assuming there can be many unpaid payment for a Card. Can be True 🤔.
    final dueAmount =
        duePayment.isNotEmpty
            ? duePayment.map((p) => p.dueAmount).reduce((a, b) => a + b)
            : 0.0;

    // Schedule billing notification
    final billingDateTime = tz.TZDateTime(
      tz.local,
      billingDate.year,
      billingDate.month,
      billingDate.day,
      reminderTime.hour,
      reminderTime.minute,
    );
    await _notifications.zonedSchedule(
      baseId * 10 + 100, // Predictable billing notification ID
      'Billing Date Reminder',
      'Billing date for $cardName (**** $last4Digits) is today!',
      billingDateTime,
      _notificationDetails('/cards/$cardId'),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: '/cards/$cardId',
    );

    // Schedule due notifications (3 days before due date)
    for (int i = 3; i >= 0; i--) {
      final dueDateTime = tz.TZDateTime(
        tz.local,
        dueDate.year,
        dueDate.month,
        dueDate.day - i,
        reminderTime.hour,
        reminderTime.minute,
      );
      if (dueDateTime.isAfter(DateTime.now())) {
        await _notifications.zonedSchedule(
          baseId * 10 + i, // Predictable due notification ID
          i == 0 ? 'Payment Due Today' : 'Payment Due Soon',
          'Pay ₹$dueAmount for $cardName (**** $last4Digits). Tap for details.',
          dueDateTime,
          _notificationDetails('/cards/$cardId'),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
          payload: '/cards/$cardId',
        );
      }
    }
  }

  NotificationDetails _notificationDetails(String payload) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          'due_channel',
          'Due Reminders',
          channelDescription: 'Reminders for credit card due dates and billing',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          styleInformation: const DefaultStyleInformation(true, true),
        ),
        iOS: const DarwinNotificationDetails(),
      );

  Future<void> rescheduleAllNotifications({
    required List<CreditCardModel> cards,
    required List<PaymentModel> payments,
    required TimeOfDay reminderTime,
  }) async {
    await cancelAllNotifications();
    for (final card in cards) {
      await scheduleBillingAndDueNotifications(
        cardId: card.id,
        cardName: card.name,
        last4Digits: card.last4Digits,
        billingDate: card.billingDate,
        dueDate: card.dueDate,
        payments: payments.where((p) => p.cardId == card.id).toList(),
        reminderTime: reminderTime,
      );
    }
  }

  /// Schedules the daily insight notification at the user's reminder time.
  Future<void> scheduleDailyInsight({
    required int dueCount,
    required TimeOfDay reminderTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );
    // If the scheduled time is already past for today, schedule for tomorrow
    final targetDateTime =
        scheduledDateTime.isAfter(now)
            ? scheduledDateTime
            : scheduledDateTime.add(const Duration(days: 1));

    // Cancel any previous daily insight notification
    await _notifications.cancel(999);

    final bigText =
        '💡 You have $dueCount card${dueCount == 1 ? '' : 's'} due this week. Tap to view your dashboard.';
    final androidDetails = AndroidNotificationDetails(
      'insight_channel',
      'Insight Notifications',
      channelDescription: 'Shows daily credit card insights',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(bigText),
    );
    final iosDetails = DarwinNotificationDetails();
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      999,
      '💡 Card Nudge Insight',
      bigText,
      tz.TZDateTime.from(targetDateTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '/dashboard',
    );

    await prefs.setString(
      'daily_insight_last_sent',
      targetDateTime.toIso8601String(),
    );
  }
}
