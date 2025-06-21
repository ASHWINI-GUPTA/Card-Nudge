import 'package:card_nudge/presentation/widgets/credit_card_color_dot_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../services/notification_service.dart';

class ActiveNotificationsScreen extends ConsumerWidget {
  const ActiveNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationService = ref.read(notificationServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchNotifications(notificationService),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CreditCardColorDotIndicator());
          }
          final active = snapshot.data?['active'] as List<dynamic>? ?? [];
          final pending =
              snapshot.data?['pending'] as List<PendingNotificationRequest>? ??
              [];

          if (active.isEmpty && pending.isEmpty) {
            return const Center(
              child: Text('No active or pending notifications.'),
            );
          }

          return ListView(
            children: [
              if (active.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: Text(
                    'Active Notifications',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...active.map(
                  (n) => NotificationInfoTile(
                    id: n.id,
                    title: n.title,
                    body: n.body,
                    payload: n.payload,
                    onCancel: () async {
                      await notificationService.cancelNotificationById(n.id);
                      (context as Element).reassemble();
                    },
                  ),
                ),
                const Divider(),
              ],
              if (pending.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: Text(
                    'Pending Notifications',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...pending.map(
                  (n) => NotificationInfoTile(
                    id: n.id,
                    title: n.title,
                    body: n.body,
                    payload: n.payload,
                    onCancel: () async {
                      await notificationService.cancelNotificationById(n.id);
                      (context as Element).reassemble();
                    },
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchNotifications(
    NotificationService service,
  ) async {
    final active = await service.getActiveNotifications();
    final pending = await service.getPendingNotifications();
    return {'active': active, 'pending': pending};
  }
}

class NotificationInfoTile extends StatelessWidget {
  final int id;
  final String? title;
  final String? body;
  final String? payload;
  final VoidCallback onCancel;

  const NotificationInfoTile({
    super.key,
    required this.id,
    this.title,
    this.body,
    this.payload,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.notifications,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: $id',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (title != null && title!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Title: $title'),
                    ),
                  if (body != null && body!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Body: $body'),
                    ),
                  if (payload != null && payload!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Payload: $payload'),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              tooltip: 'Cancel Notification',
              onPressed: onCancel,
            ),
          ],
        ),
      ),
    );
  }
}
