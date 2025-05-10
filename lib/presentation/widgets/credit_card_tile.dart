import 'package:credit_card_manager/data/hive/models/credit_card_model.dart';
import 'package:flutter/material.dart';
// import '../../data/hive/models/credit_card_model.dart';
import 'package:intl/intl.dart';

class CreditCardTile extends StatelessWidget {
  final CreditCardModel card;
  const CreditCardTile({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final dueDateStr = DateFormat('dd MMM').format(card.dueDate);
    final currency = NumberFormat.simpleCurrency(name: '₹');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.cardName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              card.bankName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('•••• ${card.last4Digits}'),
                Text('Due: $dueDateStr'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Limit: ${currency.format(card.limit)}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  'Due: ${currency.format(card.currentDue)}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
