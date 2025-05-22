import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'presentation/screens/cards_screen.dart';
import 'presentation/screens/due_screen.dart';
import 'presentation/screens/home_screen.dart';
// import 'presentation/screens/upcoming_due_screen.dart';

class CreditCardApp extends StatelessWidget {
  const CreditCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/cards',
          builder: (context, state) => const CardsScreen(),
        ),
        GoRoute(path: '/dues', builder: (context, state) => const DueScreen()),
      ],
    );

    return MaterialApp.router(
      title: 'Card Nudge',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
