import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_strings.dart';

class NavigationService {
  static Future<T?> navigateTo<T>(BuildContext context, Widget screen) async {
    try {
      return await Navigator.push<T>(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.navigationError}: $e')),
      );
      return null;
    }
  }

  static Future<void> goToRoute(BuildContext context, String routeName) async {
    try {
      GoRouter.of(context).go(routeName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.navigationError}: $e')),
      );
    }
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }

  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) async {
    try {
      return await showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: builder,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.navigationError}: $e')),
      );
      return null;
    }
  }
}
