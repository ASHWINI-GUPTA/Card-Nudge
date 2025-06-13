import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hive/models/payment_model.dart';
import '../providers/format_provider.dart';

class MinimalPaymentCard extends ConsumerWidget {
  final PaymentModel payment;

  const MinimalPaymentCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatHelper = ref.watch(formatHelperProvider);

    final isPaid = payment.isPaid;
    final amount = isPaid ? payment.paidAmount : payment.dueAmount;
    final paymentLabel = isPaid ? 'Paid' : 'Due';
    final paymentDate =
        isPaid
            ? formatHelper.formatDate(payment.updatedAt)
            : formatHelper.formatDate(payment.dueDate);

    var paymentSummary = '';
    if (isPaid && payment.dueAmount == 0) {
      paymentSummary = '(No Payment Required)';
    } else if (isPaid && payment.paidAmount != payment.dueAmount) {
      paymentSummary = '(Partial Payment Made)';
    }
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${formatHelper.formatCurrency(amount, decimalDigits: 2)} ${paymentSummary}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${paymentLabel}: ${paymentDate}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),

            // Paid / Unpaid Icon
            Icon(
              isPaid ? Icons.check_circle : Icons.schedule,
              color: isPaid ? Colors.green : Colors.orange,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
