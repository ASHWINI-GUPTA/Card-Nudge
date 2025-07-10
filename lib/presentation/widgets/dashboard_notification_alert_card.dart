import 'package:flutter/material.dart';

class DashboardNotificationAlertCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const DashboardNotificationAlertCard({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: color.withAlpha(25), // Soft background
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: color, width: 5), // Accent line on the left
          ),
        ),
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(text, style: theme.textTheme.labelLarge),
        ),
      ),
    );
  }
}
