import 'package:flutter/material.dart';

import '../constants/app_strings.dart';

class NavigationService {
  static Future<void> navigateTo(BuildContext context, Widget screen) async {
    try {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.navigationError}: $e')),
      );
    }
  }

  static void pop(BuildContext context) {
    Navigator.pop(context);
  }
}
