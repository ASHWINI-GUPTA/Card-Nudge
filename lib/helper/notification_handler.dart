import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../presentation/providers/router_provider.dart';

class NotificationTapHandler {
  static bool _initialized = false;

  static Future<void> init(ProviderContainer container) async {
    if (_initialized) return;
    _initialized = true;

    final plugin = FlutterLocalNotificationsPlugin();

    final details = await plugin.getNotificationAppLaunchDetails();
    final payload = details?.notificationResponse?.payload;
    if (payload != null && _isValidRoute(payload)) {
      container.read(routerProvider).go(payload);
    }

    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload != null && _isValidRoute(payload)) {
          container.read(routerProvider).go(payload);
        }
      },
    );
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
    ];
    return validRoutes.contains(payload) ||
        payload.startsWith(AppRoutes.cardDetails.split(':')[0]);
  }
}
