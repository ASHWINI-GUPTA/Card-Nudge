import 'package:card_nudge/data/hive/models/payment_model.dart';
import 'package:card_nudge/presentation/providers/bank_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../../data/hive/models/credit_card_model.dart';
import '../providers/credit_card_provider.dart';
import '../providers/payment_provider.dart';
import '../screens/add_card_screen.dart';

class CreditCard extends ConsumerWidget {
  final CreditCardModel card;
  const CreditCard({super.key, required this.card});

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return format.format(amount);
  }

  String _dueDateLabel(List<PaymentModel> payments) {
    final now = DateTime.now();

    if (payments.isEmpty) {
      return 'No payment records';
    }

    final lastPayment = payments.last;
    final dueDate = card.dueDate;
    final difference = dueDate.difference(now).inDays;

    // If the card has no due amount
    if (lastPayment.dueAmount == 0) {
      if (lastPayment.isPaid) {
        return 'All dues cleared on ${DateFormat('dd-MMM').format(lastPayment.paymentDate)}';
      } else {
        return 'No dues';
      }
    }

    // If payment is overdue
    if (difference < 0) {
      return 'Overdue by ${-difference} day${-difference == 1 ? '' : 's'} (was due on ${DateFormat('dd-MMM').format(dueDate)})';
    }

    // If payment is due today
    if (difference == 0) {
      return 'Due today';
    }

    // If payment is upcoming
    if (difference > 0) {
      return 'Due in $difference day${difference == 1 ? '' : 's'} (on ${DateFormat('dd-MMM').format(dueDate)})';
    }

    // Fallback
    return 'Payment status unknown';
  }

  Color _dueDateColor(List<PaymentModel> payments, BuildContext context) {
    if (payments.isEmpty) {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }

    final lastPayment = payments.last;
    final dueDate = card.dueDate;
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (lastPayment.dueAmount == 0) {
      return Theme.of(context).colorScheme.onSurface;
    } else if (difference < 0) {
      return Theme.of(context).colorScheme.error;
    } else if (difference <= 7) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var payments = ref
        .read(paymentProvider.notifier)
        .getPaymentsForCard(card.id);

    var bank = ref.read(bankProvider.notifier).getById(card.bankId);

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
            content: Text('${deletedCard.name} deleted'),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card details column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${card.name} • ${bank.name}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('**** ${card.last4Digits}'),
                        const SizedBox(height: 8),
                        Text(
                          'Limit: ${_formatCurrency(card.creditLimit)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'Current Due: ${_formatCurrency(payments.isEmpty ? 0 : payments.last.dueAmount)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _dueDateLabel(payments),
                          style: TextStyle(
                            color: _dueDateColor(payments, context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bank icon
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                    child: Consumer(
                      builder: (context, ref, child) {
                        return bank.logoPath != null
                            ? SvgPicture.asset(
                              bank.logoPath as String,
                              width: 35,
                              height: 35,
                            )
                            : const Icon(Icons.account_balance, size: 35);
                      },
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
