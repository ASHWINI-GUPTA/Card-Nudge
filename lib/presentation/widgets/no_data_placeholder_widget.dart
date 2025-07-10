import 'package:flutter/material.dart';

class NoDataPlaceholderWidget extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const NoDataPlaceholderWidget({
    super.key,
    required this.message,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onButtonPressed, child: Text(buttonText)),
        ],
      ),
    );
  }
}
