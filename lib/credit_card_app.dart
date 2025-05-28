import 'package:card_nudge/constants/app_strings.dart';
import 'package:card_nudge/data/enums/language.dart';
import 'package:card_nudge/presentation/screens/auth_screen.dart';
import 'package:card_nudge/presentation/screens/home_screen.dart';
import 'package:card_nudge/presentation/providers/supabase_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/providers/setting_provider.dart';
import 'presentation/screens/setting_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) {
        return Consumer(
          builder: (context, ref, _) {
            final supabaseService = ref.watch(supabaseServiceProvider);
            return StreamBuilder(
              stream: supabaseService.authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                ref
                    .read(supabaseServiceProvider)
                    .syncUserDetails(
                      snapshot.data ??
                          AuthState(AuthChangeEvent.signedOut, null),
                    );

                final isAuthenticated =
                    ref.watch(supabaseServiceProvider).isAuthenticated;

                return isAuthenticated
                    ? const HomeScreen()
                    : const AuthScreen();
              },
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class CreditCardApp extends ConsumerWidget {
  const CreditCardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final settings = ref.watch(settingsProvider);

        return MaterialApp.router(
          title: AppStrings.appTitle,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.dark,
          ),
          themeMode: settings.themeMode,
          locale: Locale(settings.language.name),
          supportedLocales: [
            Locale(Language.en.name, 'US'),
            Locale(Language.hi.name, 'IN'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
        );
      },
    );
  }
}
