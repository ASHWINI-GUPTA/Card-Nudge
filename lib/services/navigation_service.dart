import 'package:flutter/material.dart';

class NavigationService {
  static Future<void> navigateTo(BuildContext context, Widget screen) async {
    try {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Navigation error: $e')));
    }
  }
}
