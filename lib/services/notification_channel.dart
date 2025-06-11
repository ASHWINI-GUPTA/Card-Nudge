import 'package:flutter/services.dart';

import 'notification_service.dart';

class NotificationChannel {
  static const MethodChannel _channel = MethodChannel(
    'in.fnlsg.card/notifications',
  );

  static void setup() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'runNotificationService') {
        try {
          final notificationService = NotificationService();
          await notificationService.init();
          await notificationService.scheduleBillNotifications();
          print('Notification service executed successfully');
        } catch (e) {
          print('Error running notification service: $e');
        }
      }
      return null;
    });
  }
}
