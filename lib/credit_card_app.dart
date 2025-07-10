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
              ),
              if (isOffline) OfflineButton(),
            ],
          ),
        );
      },
    );
  }
}
