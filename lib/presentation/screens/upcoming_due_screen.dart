import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/hive/models/credit_card_model.dart';
import '../providers/credit_card_provider.dart';

class UpcomingDueScreen extends ConsumerWidget {
  const UpcomingDueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(creditCardListProvider);
    final filteredCards =
        cards.where((card) => card.currentDueAmount > 0).toList();
    final groupedCards = _groupCardsByDueDate(filteredCards);

    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Dues')),
      body:
          cards.isEmpty
              ? const Center(child: Text('No dues found.'))
              : ListView.builder(
                itemCount: groupedCards.length,
                itemBuilder: (context, index) {
                  final entry = groupedCards.entries.elementAt(index);
                  final label = entry.key;
                  final cardList = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      ...cardList.map(
                        (card) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 4,
                          ),
                          child: Card(
                            child: ListTile(
                              title: Text(card.cardName),
                              subtitle: Text(
                                'Due: ₹${card.currentDueAmount.toStringAsFixed(0)}',
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'mark_paid') {
                                    ref
                                        .read(creditCardListProvider.notifier)
                                        .updateByKey(
                                          card.key,
                                          card.copyWith(
                                            currentDueAmount: 0,
                                            lastPaidDate: DateTime.now(),
                                          ),
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Marked as Paid'),
                                      ),
                                    );
                                  }
                                },
                                itemBuilder:
                                    (context) => [
                                      const PopupMenuItem<String>(
                                        value: 'mark_paid',
                                        child: Text('Mark as Paid'),
                                      ),
                                    ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
    );
  }

  Map<String, List<CreditCardModel>> _groupCardsByDueDate(
    List<CreditCardModel> cards,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Map<String, List<CreditCardModel>> grouped = {};

    for (var card in cards) {
      final dueDate = DateTime(
        card.dueDate.year,
        card.dueDate.month,
        card.dueDate.day,
      );
      final diff = dueDate.difference(today).inDays;
      String label;

      if (diff < 0) {
        label = 'Overdue';
      } else if (diff == 0) {
        label = 'Today';
      } else {
        label = DateFormat.yMMMMd().format(dueDate);
      }

      grouped.putIfAbsent(label, () => []).add(card);
    }

    // Sort by date (overdue last)
    grouped = Map.fromEntries(
      grouped.entries.toList()..sort((a, b) {
        if (a.key == 'Overdue') return 1;
        if (b.key == 'Overdue') return -1;
        if (a.key == 'Today') return -1;
        if (b.key == 'Today') return 1;
        final dateA = DateFormat.yMMMMd().parse(a.key);
        final dateB = DateFormat.yMMMMd().parse(b.key);
        return dateA.compareTo(dateB);
      }),
    );

    return grouped;
  }
}
