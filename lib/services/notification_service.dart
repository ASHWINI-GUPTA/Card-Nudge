import 'dart:async';
import 'dart:io';
import 'package:card_nudge/data/hive/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hive/models/credit_card_model.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  static const _dailyInsightId = 999;
  static const _billingNotificationOffset = 100;
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
      );

      await _notifications.initialize(
        InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification tapped: ${details.payload}');
        },
      );

      await _requestPermissions();
    } catch (e, stackTrace) {
      debugPrint('NotificationService.init error: $e\n$stackTrace');
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        debugPrint('Notification permission denied on Android');
      }
    } else if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e, stackTrace) {
      debugPrint('cancelAllNotifications error: $e\n$stackTrace');
    }
  }

  Future<void> cancelCardNotifications(String cardId) async {
    try {
      final baseId = _generateNotificationId(cardId);
      await Future.wait([
        _notifications.cancel(baseId + _billingNotificationOffset),
        ...List.generate(5, (i) => _notifications.cancel(baseId + i)),
      ]);
    } catch (e, stackTrace) {
      debugPrint('cancelCardNotifications error: $e\n$stackTrace');
    }
  }

  int _generateNotificationId(String cardId) {
    return cardId.hashCode.abs() % 1000000;
  }

  Future<void> scheduleCardNotifications({
    required String cardId,
    required String cardName,
    required String last4Digits,
    required DateTime billingDate,
    required DateTime dueDate,
    required List<PaymentModel> payments,
    required TimeOfDay reminderTime,
  }) async {
    try {
      await cancelCardNotifications(cardId);

      final baseId = _generateNotificationId(cardId);
      final unpaidPayments = payments.where((p) => !p.isPaid).toList();
      final dueAmount = unpaidPayments.fold<double>(
        0,
        (sum, payment) => sum + payment.dueAmount,
      );

      // Schedule billing notification
      await _scheduleNotification(
        id: baseId + _billingNotificationOffset,
        title: 'Billing Date Reminder',
        body: 'Billing date for $cardName (**** $last4Digits) is today!',
        scheduledDate: _createTZDateTime(
          billingDate.year,
          billingDate.month,
          billingDate.day,
          reminderTime,
        ),
        payload: '/cards/$cardId',
      );

      // Schedule due date reminders (3 days before, 1 day before, and on due date)
      for (int daysBefore = 3; daysBefore >= 0; daysBefore--) {
        final notificationDate = dueDate.subtract(Duration(days: daysBefore));
        if (notificationDate.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: baseId + daysBefore,
            title:
                daysBefore == 0
                    ? 'Payment Due Today'
                    : 'Payment Due in ${daysBefore} day${daysBefore == 1 ? '' : 's'}',
            body: 'Pay ₹$dueAmount for $cardName (**** $last4Digits)',
            scheduledDate: _createTZDateTime(
              notificationDate.year,
              notificationDate.month,
              notificationDate.day,
              reminderTime,
            ),
            payload: '/cards/$cardId',
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('scheduleCardNotifications error: $e\n$stackTrace');
      rethrow;
    }
  }

  tz.TZDateTime _createTZDateTime(
    int year,
    int month,
    int day,
    TimeOfDay time,
  ) {
    return tz.TZDateTime(tz.local, year, month, day, time.hour, time.minute);
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String payload,
  }) async {
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint(
        'Scheduled date $scheduledDate is in the past. Skipping notification.',
      );
      return;
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'card_reminders',
          'Card Reminders',
          channelDescription: 'Credit card payment reminders',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> scheduleDailyInsight({
    required int dueCount,
    required TimeOfDay reminderTime,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final scheduledTime = _createTZDateTime(
        now.year,
        now.month,
        now.day,
        reminderTime,
      );

      final targetTime =
          scheduledTime.isAfter(now)
              ? scheduledTime
              : scheduledTime.add(const Duration(days: 1));

      await _notifications.zonedSchedule(
        _dailyInsightId,
        '💡 Card Nudge Insight',
        'You have $dueCount payment${dueCount == 1 ? '' : 's'} due this week',
        tz.TZDateTime.from(targetTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_insights',
            'Daily Insights',
            channelDescription: 'Daily credit card insights',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: '/dashboard',
      );

      await prefs.setString('last_daily_insight', targetTime.toIso8601String());
    } catch (e, stackTrace) {
      debugPrint('scheduleDailyInsight error: $e\n$stackTrace');
    }
  }

  Future<void> cancelAllCardNotifications(List<CreditCardModel> cards) async {
    for (final card in cards) {
      await cancelCardNotifications(card.id);
    }
  }

  Future<bool> shouldSendDailyInsight() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSent = prefs.getString('last_daily_insight');
    if (lastSent == null) return true;

    final lastSentDate = DateTime.tryParse(lastSent);
    if (lastSentDate == null) return true;

    final now = DateTime.now();
    return !(lastSentDate.year == now.year &&
        lastSentDate.month == now.month &&
        lastSentDate.day == now.day);
  }

  Future<void> rescheduleAllNotifications({
    required List<CreditCardModel> cards,
    required List<PaymentModel> payments,
    required TimeOfDay reminderTime,
  }) async {
    try {
      // 1. Cancel all existing notifications first
      await cancelAllNotifications();

      // 2. Filter cards that need notifications (active cards)
      final activeCards = cards.where((card) => !card.isArchived).toList();

      // 3. Schedule notifications in parallel for better performance
      await Future.wait(
        activeCards.map(
          (card) => _scheduleCardNotifications(
            card: card,
            payments: payments.where((p) => p.cardId == card.id).toList(),
            reminderTime: reminderTime,
          ),
        ),
      );

      // 4. Schedule daily insight notification
      final dueCount = _calculateDuePaymentsCount(payments);
      await scheduleDailyInsight(
        dueCount: dueCount,
        reminderTime: reminderTime,
      );

      debugPrint(
        'Successfully rescheduled ${activeCards.length} card notifications',
      );
    } catch (e, stackTrace) {
      debugPrint('Error rescheduling notifications: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> _scheduleCardNotifications({
    required CreditCardModel card,
    required List<PaymentModel> payments,
    required TimeOfDay reminderTime,
  }) async {
    await scheduleCardNotifications(
      cardId: card.id,
      cardName: card.name,
      last4Digits: card.last4Digits,
      billingDate: card.billingDate,
      dueDate: card.dueDate,
      payments: payments,
      reminderTime: reminderTime,
    );
  }

  int _calculateDuePaymentsCount(List<PaymentModel> payments) {
    final now = DateTime.now();
    return payments.where((payment) {
      return !payment.isPaid &&
          payment.dueDate.isAfter(now) &&
          payment.dueDate.isBefore(now.add(const Duration(days: 7)));
    }).length;
  }

  Future<void> demoInsight({
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
}
