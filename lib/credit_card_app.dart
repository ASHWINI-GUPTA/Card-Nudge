import 'package:flutter/material.dart';
import 'presentation/screens/card_list_screen.dart';

class CreditCardApp extends StatelessWidget {
  const CreditCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Credit Card Manager',
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
      themeMode: ThemeMode.system,
      home: const CardListScreen(),
    );
  }
}
