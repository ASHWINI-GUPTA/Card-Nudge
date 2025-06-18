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
import 'package:flutter_timezone/flutter_timezone.dart';

import '../data/hive/models/credit_card_model.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  // Notification ID constants
  static const _dailyInsightId = 999;
  static const _billingNotificationOffset = 100;
  static const _demoNotificationStartId = 1000;
  static const _maxScheduledNotifications = 50;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<tz.TZDateTime> _convertToLocalTZ(DateTime date, TimeOfDay time) async {
    await ensureInitialized();
    return tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _setLocalTimezone() async {
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('Set local timezone: $timeZoneName');
    } catch (e) {
      debugPrint('Could not set local timezone, defaulting to UTC: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      tzData.initializeTimeZones();
      await _setLocalTimezone();
      await _createNotificationChannels();

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _notifications.initialize(
        InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: (details) {
          if (_isValidPayload(details.payload)) {
            debugPrint('Notification tapped: ${details.payload}');
            _logNotificationEvent('tap', payload: details.payload);
          }
        },
      );

      await _requestPermissions();
      _isInitialized = true;
    } catch (e, stackTrace) {
      debugPrint('NotificationService.init error: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> _createNotificationChannels() async {
    // Android notification channels
    if (Platform.isAndroid) {
      const androidChannels = [
        AndroidNotificationChannel(
          'card_reminders',
          'Card Reminders',
          description: 'Credit card payment reminders',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
        AndroidNotificationChannel(
          'daily_insights',
          'Daily Insights',
          description: 'Daily credit card insights',
          importance: Importance.defaultImportance,
        ),
      ];

      final androidPlugin =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      for (final channel in androidChannels) {
        await androidPlugin?.createNotificationChannel(channel);
      }
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

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      await _logNotificationEvent('cancel_all');
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
      await _logNotificationEvent('cancel_card', cardId: cardId);
    } catch (e, stackTrace) {
      debugPrint('cancelCardNotifications error: $e\n$stackTrace');
    }
  }

  int _generateNotificationId(String cardId) {
    return cardId.hashCode.abs() % 1000000;
  }

  Future<void> _validateNotificationTime(tz.TZDateTime scheduledTime) async {
    final now = tz.TZDateTime.now(tz.local);
    if (scheduledTime.isBefore(now)) {
      throw Exception(
        'Scheduled time $scheduledTime is in the past (Current time: $now)',
      );
    }

    // Check if time is within reasonable bounds (e.g., not 1..100 years in future)
    if (scheduledTime.year > now.year + 1) {
      throw Exception('Scheduled time too far in future');
    }
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
      await ensureInitialized();
      await _checkNotificationLimit();
      await cancelCardNotifications(cardId);

      final baseId = _generateNotificationId(cardId);
      final localBillingDate = await _convertToLocalTZ(
        billingDate,
        reminderTime,
      );

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
        scheduledDate: localBillingDate,
        payload: '/cards/$cardId',
        isTimeSensitive: true,
      );

      // Schedule due date reminders
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
            isTimeSensitive: true,
          );
        }
      }

      await _logNotificationEvent('schedule_card', cardId: cardId);
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
    bool isTimeSensitive = false,
  }) async {
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint('Skipping past-dated notification');
      return;
    }

    if (!_isValidPayload(payload)) {
      throw ArgumentError('Invalid notification payload: $payload');
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
          enableVibration: true,
          groupKey: 'card_reminders_group',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel:
              isTimeSensitive
                  ? InterruptionLevel.timeSensitive
                  : InterruptionLevel.active,
        ),
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
      await ensureInitialized();
      await _checkNotificationLimit();

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
          iOS: const DarwinNotificationDetails(
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: '/dashboard',
      );

      await prefs.setString('last_daily_insight', targetTime.toIso8601String());
      await _logNotificationEvent('daily_insight');
    } catch (e, stackTrace) {
      debugPrint('scheduleDailyInsight error: $e\n$stackTrace');
    }
  }

  Future<void> _checkNotificationLimit() async {
    final pending = await _notifications.pendingNotificationRequests();
    if (pending.length >= _maxScheduledNotifications) {
      throw Exception(
        'Cannot schedule more notifications. Maximum limit ($_maxScheduledNotifications) reached.',
      );
    }
  }

  bool _isValidPayload(String? payload) {
    if (payload == null) return false;
    return payload.startsWith('/') &&
        !payload.contains(' ') &&
        payload.length < 100;
  }

  Future<void> _logNotificationEvent(
    String type, {
    String? cardId,
    String? payload,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('notification_$type') ?? 0;
    await prefs.setInt('notification_$type', count + 1);

    debugPrint('Logged notification event: $type');
  }

  Future<void> rescheduleAllNotifications({
    required List<CreditCardModel> cards,
    required List<PaymentModel> payments,
    required TimeOfDay reminderTime,
  }) async {
    try {
      await ensureInitialized();
      await cancelAllNotifications();

      final activeCards = cards.where((card) => !card.isArchived).toList();

      await Future.wait(
        activeCards.map(
          (card) => scheduleCardNotifications(
            cardId: card.id,
            cardName: card.name,
            last4Digits: card.last4Digits,
            billingDate: card.billingDate,
            dueDate: card.dueDate,
            payments: payments.where((p) => p.cardId == card.id).toList(),
            reminderTime: reminderTime,
          ),
        ),
      );

      final dueCount = _calculateDuePaymentsCount(payments);
      await scheduleDailyInsight(
        dueCount: dueCount,
        reminderTime: reminderTime,
      );

      debugPrint(
        'Rescheduled ${activeCards.length} card notifications and daily insight',
      );
      await _logNotificationEvent('reschedule_all');
    } catch (e, stackTrace) {
      debugPrint('Error rescheduling notifications: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> demoInsight({
    required int dueCount,
    required BuildContext context,
  }) async {
    try {
      await ensureInitialized();
      await _cancelDemoNotifications();

      const notificationCount = 10;
      final notificationIds = List.generate(
        notificationCount,
        (i) => _demoNotificationStartId + i,
      );

      await Future.wait(
        notificationIds.map((id) {
          final minutes = 2 * (id - _demoNotificationStartId + 1);
          return _notifications.zonedSchedule(
            id,
            '💡 Demo Insight ${id - _demoNotificationStartId + 1}/$notificationCount',
            'Sample: $dueCount payment${dueCount == 1 ? '' : 's'} due',
            tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes)),
            NotificationDetails(
              android: AndroidNotificationDetails(
                'daily_insights',
                'Daily Insights',
                importance: Importance.defaultImportance,
              ),
              iOS: const DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: '/dashboard?source=demo_$id',
          );
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demo notifications scheduled')),
      );
      await _logNotificationEvent('demo_insight');
    } catch (e, stackTrace) {
      debugPrint('demoInsight error: $e\n$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule demo: ${e.toString()}')),
      );
    }
  }

  Future<void> _cancelDemoNotifications() async {
    const notificationCount = 10;
    final notificationIds = List.generate(
      notificationCount,
      (i) => _demoNotificationStartId + i,
    );

    await Future.wait(notificationIds.map((id) => _notifications.cancel(id)));
  }

  int _calculateDuePaymentsCount(List<PaymentModel> payments) {
    final now = DateTime.now();
    return payments.where((payment) {
      return !payment.isPaid &&
          payment.dueDate.isAfter(now) &&
          payment.dueDate.isBefore(now.add(const Duration(days: 7)));
    }).length;
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

  Future<void> cancelAllCardNotifications(List<CreditCardModel> cards) async {
    for (final card in cards) {
      await cancelCardNotifications(card.id);
    }
  }
}
