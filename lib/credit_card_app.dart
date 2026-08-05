import 'package:card_nudge/data/enums/language.dart';
import 'package:card_nudge/presentation/widgets/offline_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'constants/app_strings.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/router_provider.dart';
import 'presentation/providers/setting_provider.dart';
import 'presentation/providers/sync_provider.dart';

import 'package:flutter/gestures.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class CreditCardApp extends ConsumerWidget {
  const CreditCardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final connectivityAsync = ref.watch(connectivityStatusProvider);

    bool isOffline = connectivityAsync.when(
      data: (result) => result.contains(ConnectivityResult.none),
      loading: () => false,
      error: (_, __) => false,
    );

    return Consumer(
      builder: (context, ref, child) {
        final settings = ref.watch(settingsProvider);

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              MaterialApp.router(
                scrollBehavior: CustomScrollBehavior(),
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
                locale: Locale(settings.language.code),
                supportedLocales: [
                  Locale(Language.English.code, 'US'),
                  Locale(Language.Hindi.code, 'IN'),
                ],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                debugShowCheckedModeBanner: false,
                routerConfig: router,
                builder: (context, child) {
                  if (child == null) return const SizedBox.shrink();

                  final isWide = MediaQuery.of(context).size.width > 500;
                  if (!isWide) return child;

                  final isDark =
                      settings.themeMode == ThemeMode.dark ||
                      (settings.themeMode == ThemeMode.system &&
                          MediaQuery.platformBrightnessOf(context) ==
                              Brightness.dark);

                  final gradientColors =
                      isDark
                          ? const [Color(0xFF0F172A), Color(0xFF020617)]
                          : const [Color(0xFFE8ECF2), Color(0xFFD2D9E4)];

                  return Scaffold(
                    body: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradientColors,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 420,
                          height: MediaQuery.of(context).size.height * 0.98,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.5 : 0.1,
                                ),
                                blurRadius: 40,
                                spreadRadius: 5,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (isOffline) OfflineButton(),
            ],
          ),
        );
      },
    );
  }
}
