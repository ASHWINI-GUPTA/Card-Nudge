import 'package:card_nudge/constants/app_routes.dart';
import 'package:card_nudge/presentation/screens/dashboard_screen.dart';
import '../screens/spend_analysis_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/supabase_provider.dart';
import '../widgets/auth_progress_widget.dart';
import '../screens/auth_screen.dart';
import '../screens/error_screen.dart';
import '../screens/card_details_screen.dart';
import '../providers/credit_card_provider.dart';
import '../screens/loading_screen.dart';
import '../screens/setting_screen.dart';
import '../screens/home_screen.dart';

final notificationNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.root,
    navigatorKey: notificationNavigatorKey,
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
        name: AppRoutes.rootName,
        // AG TODO: On App reload/resume it should not go to AuthProgress instead use Loading Screen
        builder: (context, state) {
          final isAuthenticated =
              ref.watch(supabaseServiceProvider).isAuthenticated;
          return isAuthenticated ? const AuthProgress() : const AuthScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settingsName,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: AppRoutes.dashboardName,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.spendAnalysis,
        name: AppRoutes.spendAnalysisName,
        builder: (context, state) => const SpendAnalysisScreen(),
      ),
      GoRoute(
        path: AppRoutes.cardDetails,
        name: AppRoutes.cardDetailsName,
        builder: (context, state) {
          final cardId = state.pathParameters['cardId']!;
          final isAuthenticated =
              ref.watch(supabaseServiceProvider).isAuthenticated;

          if (!isAuthenticated) {
            return const AuthScreen();
          }

          final cardAsync = ref.watch(creditCardProvider);
          if (cardAsync.isLoading) {
            return const LoadingIndicatorScreen();
          }

          final cards = cardAsync.valueOrNull;
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
        name: AppRoutes.authName,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.loginCallback,
        name: AppRoutes.loginCallbackName,
        redirect: (context, state) async {
          final supabaseService = ref.read(supabaseServiceProvider);
          try {
            await supabaseService.client.auth.getSessionFromUrl(state.uri);
            return AppRoutes.root;
          } catch (e) {
            return '${AppRoutes.error}?message=${Uri.encodeComponent(e.toString())}';
          }
        },
      ),
      GoRoute(
        path: AppRoutes.sync,
        name: AppRoutes.syncName,
        builder: (context, state) => const AuthProgress(),
      ),
      GoRoute(
        path: AppRoutes.error,
        name: AppRoutes.errorName,
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
