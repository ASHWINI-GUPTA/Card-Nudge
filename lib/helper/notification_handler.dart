import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import '../presentation/providers/router_provider.dart';

// Add a global navigatorKey to be used here
final GlobalKey<NavigatorState> notificationNavigatorKey =
    GlobalKey<NavigatorState>();

class NotificationTapHandler {
  static bool _initialized = false;

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
        }
      },
    );
  }

  static void _goToRoute(String route) {
    final context = notificationNavigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).go(route);
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
