import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../data/hive/models/credit_card_model.dart';
import 'package:intl/intl.dart';

import '../../data/hive/models/credit_card_model.dart';
import '../providers/credit_card_provider.dart';
import '../screens/add_card_screen.dart';

class CreditCardTile extends ConsumerWidget {
  final CreditCardModel card;
  const CreditCardTile({super.key, required this.card});

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return format.format(amount);
  }

  String _dueDateLabel(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    if (difference < 0) {
      return 'Overdue by ${-difference} day${-difference == 1 ? '' : 's'}';
    } else if (difference == 0) {
      return 'Due today';
    } else {
      return 'Due in $difference day${difference == 1 ? '' : 's'}';
    }
  }

  Color _dueDateColor(DateTime dueDate, BuildContext context) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    if (difference < 0) {
      return Theme.of(context).colorScheme.error;
    } else if (difference <= 7) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(card.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        final deletedCard = card;
        final deletedKey = card.key as int;
        ref.read(creditCardListProvider.notifier).deleteByKey(deletedKey);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${deletedCard.cardName} deleted'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed:
                  () => ref
                      .read(creditCardListProvider.notifier)
                      .restoreByKey(deletedKey, deletedCard),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      },
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddCardScreen(card: card)),
                ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${card.cardName} • ${card.bankName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('**** ${card.last4Digits}'),
                  const SizedBox(height: 8),
                  Text(
                    'Limit: ${_formatCurrency(card.limit)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Current Due: ${_formatCurrency(card.currentDueAmount)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _dueDateLabel(card.dueDate),
                    style: TextStyle(
                      color: _dueDateColor(card.dueDate, context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
