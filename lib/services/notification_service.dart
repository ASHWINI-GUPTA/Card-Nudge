import 'dart:async';
import 'dart:io';
import 'package:card_nudge/data/hive/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

import '../data/hive/models/credit_card_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      tzData.initializeTimeZones();
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          // Handle notification tap if needed
        },
      );
      if (Platform.isAndroid) {
        await _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestExactAlarmsPermission();
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

  Future<void> cancelDueNotificationsByCardId(String cardId) async {
    // Assume due notification ids are cardId.hashCode * 10 + i
    for (int i = 0; i < 5; i++) {
      await _notifications.cancel(cardId.hashCode * 10 + i);
    }
  }

  Future<void> cancelBillingNotificationByCardId(String cardId) async {
    await _notifications.cancel(cardId.hashCode * 1000);
  }

  Future<void> sendDailyInsight({
    required int dueCount,
    required BuildContext context,
  }) async {
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
      cardId.hashCode * 1000,
      'Billing Date Reminder',
      'Billing date for $cardName (**** $last4Digits) is today!',
      billingDateTime,
      _notificationDetails('/cards/$cardId'),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: '/cards/$cardId',
    );

    // Schedule due notification (3 day before due date)
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
          cardId.hashCode * 10 + i,
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
}
