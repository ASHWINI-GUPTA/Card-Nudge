import 'package:card_nudge/constants/app_strings.dart';
import 'package:card_nudge/data/enums/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/providers/router_provider.dart';
import 'presentation/providers/setting_provider.dart';

class CreditCardApp extends ConsumerWidget {
  const CreditCardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
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
            Locale(Language.English.code, 'US'),
            Locale(Language.Hindi.code, 'IN'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        );
      },
    );
  }
}
