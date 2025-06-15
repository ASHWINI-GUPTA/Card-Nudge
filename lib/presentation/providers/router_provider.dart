import 'package:card_nudge/presentation/screens/dashboard_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/supabase_provider.dart';
import '../screens/auth_progress_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/error_screen.dart';
import '../screens/card_details_screen.dart';
import '../providers/credit_card_provider.dart';
import '../screens/setting_screen.dart';
import '../screens/home_screen.dart';

class AppRoutes {
  static const String root = '/';
  static const String home = '/home';
  static const String auth = '/auth';
  static const String loginCallback = '/login-callback';
  static const String settings = '/settings';
  static const String sync = '/sync';
  static const String error = '/error';
  static const String cardDetails = '/cards/:cardId';
  static const String dashboard = '/dashboard';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.root,
    redirect: (context, state) {
      final supabaseService = ref.read(supabaseServiceProvider);
      final isAuthenticated = supabaseService.isAuthenticated;
      final isLoggingIn =
          state.matchedLocation == AppRoutes.auth ||
          state.matchedLocation == AppRoutes.loginCallback;

      if (!isAuthenticated && !isLoggingIn) {
        return AppRoutes.auth;
      }
      if (isAuthenticated && state.matchedLocation == AppRoutes.auth) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.root,
        name: 'root',
        builder: (context, state) {
          final isAuthenticated =
              ref.watch(supabaseServiceProvider).isAuthenticated;
          return isAuthenticated ? const AuthProgress() : const AuthScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.cardDetails,
        name: 'cardDetails',
        builder: (context, state) {
          final cardId = state.pathParameters['cardId']!;
          final isAuthenticated =
              ref.watch(supabaseServiceProvider).isAuthenticated;

          if (!isAuthenticated) {
            return const AuthScreen();
          }

          final cardProvider = ref.watch(creditCardListProvider);
          final cards = cardProvider.valueOrNull;

          if (cards == null) {
            return const ErrorScreen(message: 'Cards not found.');
          }
          final card = cards.where((c) => c.id == cardId).firstOrNull;

          if (card == null) {
            return ErrorScreen(message: 'Card with ID $cardId not found.');
          }

          return CardDetailsScreen(card: card);
        },
      ),
      GoRoute(
        path: AppRoutes.auth,
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.loginCallback,
        name: 'loginCallback',
        redirect: (context, state) async {
          final supabaseService = ref.read(supabaseServiceProvider);
          try {
            await Supabase.instance.client.auth.getSessionFromUrl(state.uri);
            await supabaseService.syncUserDetails();
            return AppRoutes.home;
          } catch (e) {
            return AppRoutes.error;
          }
        },
      ),
      GoRoute(
        path: AppRoutes.sync,
        name: 'sync',
        builder: (context, state) => const AuthProgress(),
      ),
      GoRoute(
        path: AppRoutes.error,
        name: 'error',
        builder: (context, state) {
          final message =
              state.uri.queryParameters['message'] ?? 'An error occurred';
          return ErrorScreen(message: message);
        },
      ),
    ],
    errorBuilder:
        (context, state) => const ErrorScreen(message: 'Route not found'),
  );
});
