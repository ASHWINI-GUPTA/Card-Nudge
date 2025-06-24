import 'package:card_nudge/services/navigation_service.dart';
import 'package:flutter/material.dart';
import '../presentation/providers/router_provider.dart';

class NotificationTapHandler {
  static bool _initialized = false;
  static final GlobalKey<NavigatorState> navigatorKey =
      notificationNavigatorKey;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
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
