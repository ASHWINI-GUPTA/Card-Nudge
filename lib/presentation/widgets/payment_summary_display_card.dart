import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hive/models/payment_model.dart';
import '../providers/format_provider.dart';

class PaymentSummaryDisplayCard extends ConsumerWidget {
  final PaymentModel payment;

  const PaymentSummaryDisplayCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatHelper = ref.watch(formatHelperProvider);

    final isPaid = payment.isPaid;
    final amount = isPaid ? payment.paidAmount : payment.dueAmount;
    final date = isPaid ? payment.paymentDate : payment.dueDate;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount and Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatHelper.formatCurrency(amount, decimalDigits: 2),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (payment.minimumDueAmount != null && !isPaid)
                        Text(
                          'Min. Due: ${formatHelper.formatCurrency(payment.minimumDueAmount!)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                _buildStatusChip(context, payment),
              ],
            ),
            const SizedBox(height: 8),

            // Payment Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPaid ? 'Paid on' : 'Due on',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      formatHelper.formatDate(date!),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Statement Amount',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      formatHelper.formatCurrency(payment.statementAmount),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (payment.isPaid && payment.isPartiallyPaid)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Partially Paid: ${formatHelper.formatCurrency(payment.paidAmount)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, PaymentModel payment) {
    final theme = Theme.of(context);

    final backgroundColor =
        payment.isPaid
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.errorContainer;
    final foregroundColor =
        payment.isPaid
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onErrorContainer;

    String statusText;
    if (payment.isPaid && payment.isPartiallyPaid) {
      statusText = 'Partially Paid';
    } else if (payment.isPaid && payment.isNoPaymentRequired) {
      statusText = 'No Payment Due';
    } else if (payment.isPaid) {
      statusText = 'Paid';
    } else if (payment.isOverdue) {
      statusText = 'Overdue';
    } else {
      statusText = 'Upcoming Due';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            payment.isPaid ? Icons.check_circle : Icons.schedule,
            size: 16,
            color: foregroundColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
