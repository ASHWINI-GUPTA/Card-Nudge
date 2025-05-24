import 'package:card_nudge/data/hive/models/payment_model.dart';
import 'package:flutter/material.dart';

class DashboardMonthWidget extends StatelessWidget {
  final List<PaymentModel> data;
  const DashboardMonthWidget({super.key, this.data = const []});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    // Group payments by month
    final monthPayments = <int, List<PaymentModel>>{};
    for (var payment in data) {
      final month = payment.dueDate.month;
      monthPayments.putIfAbsent(month, () => []).add(payment);
    }

    // Determine status and colors for each month
    Color _getMonthColor(int month) {
      if (month > now.month) {
        return theme.colorScheme.surfaceContainerLowest; // Future
      }
      final payments = monthPayments[month] ?? [];
      if (payments.isEmpty) {
        return theme.colorScheme.surfaceContainer; // No due data
      }
      final hasNotPaid = payments.any((p) => !p.isPaid);
      if (hasNotPaid) {
        return theme.colorScheme.error; // Not paid
      }
      final hasDelayed = payments.any(
        (p) => p.isPaid && p.dueDate.isBefore(now),
      );
      if (hasDelayed) {
        return theme.colorScheme.tertiary; // Delayed
      }
      return theme.colorScheme.primary; // On time
    }

    TextStyle _getTextStyle(int month) {
      final color =
          month > now.month
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onSurface;
      return TextStyle(
        color: color,
        fontWeight: month == now.month ? FontWeight.bold : FontWeight.w600,
        fontSize: 14,
      );
    }

    // Legend items
    final legendItems = [
      {'label': 'On Time', 'color': theme.colorScheme.primary},
      {'label': 'Delayed', 'color': theme.colorScheme.tertiary},
      {'label': 'Not Paid', 'color': theme.colorScheme.error},
      {'label': 'No Data', 'color': theme.colorScheme.surfaceContainer},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          itemCount: 12,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemBuilder: (context, index) {
            final month = index + 1;
            return Material(
              color: _getMonthColor(month),
              borderRadius: BorderRadius.circular(10),
              elevation: month == now.month ? 4 : 0,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border:
                      month == now.month
                          ? Border.all(
                            color: theme.colorScheme.primaryContainer,
                            width: 2,
                          )
                          : null,
                ),
                child: Text(months[index], style: _getTextStyle(month)),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children:
              legendItems.map((item) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['label'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ],
    );
  }
}
