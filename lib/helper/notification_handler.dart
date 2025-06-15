import 'package:card_nudge/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../presentation/providers/router_provider.dart';

class NotificationTapHandler {
  static bool _initialized = false;
  static final GlobalKey<NavigatorState> navigatorKey =
      notificationNavigatorKey;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final plugin = FlutterLocalNotificationsPlugin();

    final details = await plugin.getNotificationAppLaunchDetails();
    final payload = details?.notificationResponse?.payload;
    if (payload != null && _isValidRoute(payload)) {
      _goToRoute(payload);
    }

    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload != null && _isValidRoute(payload)) {
          _goToRoute(payload);
        } else {
          _goToRoute(AppRoutes.error);
        }
      },
    );
  }

  static void _goToRoute(String route) {
    final context = notificationNavigatorKey.currentContext;
    if (context != null) {
      NavigationService.goToRoute(context, route);
    }
  }

  static bool _isValidRoute(String payload) {
    const validRoutes = [
      AppRoutes.root,
      AppRoutes.home,
      AppRoutes.auth,
      AppRoutes.settings,
      AppRoutes.sync,
      AppRoutes.error,
      AppRoutes.cardDetails,
      AppRoutes.dashboard,
    ];
    return validRoutes.contains(payload) ||
        payload.startsWith(AppRoutes.cardDetails.split(':')[0]);
  }
}
