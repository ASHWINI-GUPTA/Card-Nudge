import 'package:credit_card_manager/presentation/providers/credit_card_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/credit_card_tile.dart';
import 'add_card_screen.dart';

class CardListScreen extends ConsumerWidget {
  const CardListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(creditCardListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Credit Cards'), centerTitle: true),
      body:
          cards.isEmpty
              ? const Center(
                child: Text(
                  'No cards added yet.',
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: cards.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final card = cards[index];

                  return Dismissible(
                    key: ValueKey(card.key),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: const Text('Delete Card'),
                              content: const Text(
                                'Are you sure you want to delete this card?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                      );
                    },
                    onDismissed: (direction) {
                      final deletedCard = card;
                      final deletedKey = card.key as int;

                      ref
                          .read(creditCardListProvider.notifier)
                          .deleteByKey(deletedKey);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${deletedCard.cardName} deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () async {
                              ref
                                  .read(creditCardListProvider.notifier)
                                  .restoreByKey(deletedKey, deletedCard);
                            },
                          ),
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    },
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddCardScreen(card: card),
                          ),
                        );
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(card.cardName),
                          subtitle: Text(
                            'Due: ${card.dueDate.toLocal().toString().split(' ')[0]}',
                          ),
                          trailing: Text(
                            '₹${card.currentDue.toStringAsFixed(2)}',
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCardScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
