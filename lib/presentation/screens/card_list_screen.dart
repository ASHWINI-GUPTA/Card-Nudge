import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../notification_service.dart';
import '../providers/credit_card_provider.dart';
import '../widgets/credit_card_tile.dart';
import 'add_card_screen.dart';
import 'upcoming_due_screen.dart';

class CardListScreen extends ConsumerWidget {
  const CardListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(creditCardListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb),
            tooltip: 'Send Insights',
            onPressed: () {
              NotificationService.showInsightNotification();
            },
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Upcoming Payments',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UpcomingDueScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body:
          cards.isEmpty
              ? const Center(child: Text('You have not added any cards yet.'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cards.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return CreditCardTile(card: card);
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCardScreen()),
            ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
