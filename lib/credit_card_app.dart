import 'package:card_nudge/constants/app_strings.dart';
import 'package:card_nudge/data/enums/language.dart';
import 'package:card_nudge/presentation/screens/auth_screen.dart';
import 'package:card_nudge/presentation/screens/home_screen.dart';
import 'package:card_nudge/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'data/enums/app_theme_mode.dart';
import 'presentation/providers/setting_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: true,
  );
  runApp(const ProviderScope(child: CreditCardApp()));
}

class CreditCardApp extends ConsumerWidget {
  const CreditCardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize GoRouter
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) {
            final supabaseService = ref.watch(supabaseServiceProvider);
            return StreamBuilder(
              stream: supabaseService.authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final authState = snapshot.data;
                final isAuthenticated = authState?.session != null;

                return isAuthenticated
                    ? const HomeScreen()
                    : const AuthScreen();
              },
            );
          },
        ),
      ],
    );

    // Watch settings for theme and language
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
      themeMode: switch (settings.themeMode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      },
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
      routerConfig: router,
    );
  }
}
