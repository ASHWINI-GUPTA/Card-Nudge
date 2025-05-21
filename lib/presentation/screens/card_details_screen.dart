import 'package:flutter/material.dart';

import '../../data/hive/models/credit_card_model.dart';
import '../../data/hive/models/payment_model.dart';
import '../widgets/add_due_bottom_sheet.dart';
import '../widgets/credit_card_tile.dart';
import '../widgets/minimal_payment_display_card.dart';

class CardDetailsScreen extends StatelessWidget {
  final CreditCardModel card;
  final List<PaymentModel> payments;

  const CardDetailsScreen({
    super.key,
    required this.card,
    required this.payments,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final upcoming = payments.where((p) => !p.isPaid).toList();
    final history = payments.where((p) => p.isPaid).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // handle edit/delete/archive
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  const PopupMenuItem(value: 'archive', child: Text('Archive')),
                ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => AddDueBottomSheet(cardId: card.id),
            ),
        icon: const Icon(Icons.add),
        label: const Text('Create Due'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CreditCard(card: card),

          const SizedBox(height: 24),
          Text('Upcoming Payment', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (upcoming.isEmpty)
            const Text('No upcoming dues.')
          else
            MinimalPaymentCard(payment: upcoming.first),

          const SizedBox(height: 24),
          Text('Payment History', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (history.isEmpty)
            const Text('No past payments yet.')
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final payment = history[index];
                return MinimalPaymentCard(payment: payment);
              },
            ),
        ],
      ),
    );
  }
}

// Future<void> showCreateDueBottomSheet(BuildContext context, WidgetRef ref, String cardId) {
//   return showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     builder: (context) => Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//         left: 16,
//         right: 16,
//         top: 24,
//       ),
//       child: _CreateDueForm(cardId: cardId),
//     ),
//   );
// }
