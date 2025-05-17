import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzData.initializeTimeZones();

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('iOS Local Notification received ${details.payload}');
      },
    );

    // Request permissions
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
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'due_channel',
          'Due Reminders',
          channelDescription: 'Reminders for credit card due dates',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  static cancelNotifications(key) async {
    // Cancel notifications for 3 days before the due date
    for (int i = 3; i > 0; i--) {
      await _notifications.cancel(key.hashCode ^ i);
    }

    // Cancel notification for the due date
    await _notifications.cancel(key.hashCode ^ 2);

    // Cancel notifications for 30 days after the due date
    for (int i = 1; i <= 30; i++) {
      await _notifications.cancel(key.hashCode ^ (100 + i));
    }
  }

  static cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  static Future<void> showInsightNotification() async {
    final int dueSoonCount = _getDueSoonCount();
    final bigText =
        '💡 You have $dueSoonCount card${dueSoonCount == 1 ? '' : 's'} due this week. Stay ahead and avoid late fees!';

    // Android notification details
    final androidDetails = AndroidNotificationDetails(
      'insight_channel',
      'Insight Notifications',
      channelDescription: 'Shows daily credit card insights',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        bigText,
        contentTitle: '💳 Card Nudge Insight',
        summaryText: 'Manage your dues smarter!',
      ),
    );

    // iOS (Darwin) notification details
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: '📅 Weekly Summary',
      threadIdentifier: 'insight_thread',
    );

    // Combine platform-specific details
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999,
      '💳 Card Nudge Insight',
      bigText,
      notificationDetails,
    );
  }

  static _getDueSoonCount() {
    return 1; // Placeholder for actual logic to count cards due soon
  }
}
