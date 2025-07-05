import 'package:card_nudge/constants/app_strings.dart';
import 'package:card_nudge/data/hive/models/payment_model.dart';
import 'package:flutter/material.dart';

class DashboardMonthWidget extends StatelessWidget {
  final List<PaymentModel> data;
  const DashboardMonthWidget({super.key, this.data = const []});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    // Legend items
    final legendItems = [
      {
        'label': AppStrings.monthOnTime,
        'color': const Color(0xFF43A047), // Green 600
      },
      {
        'label': AppStrings.monthDelayed,
        'color': const Color(0xFFFFB300), // Amber 600
      },
      {
        'label': AppStrings.monthNotPaid,
        'color': const Color(0xFFE53935), // Red 600
      },
      {
        'label': AppStrings.monthNoData,
        'color': const Color(0xFFB0BEC5), // Blue Grey 200
      },
    ];

    final months = [
      '🎉 Jan', // New Year's Day (Jan 1)
      '❤️ Feb', // Valentine's Day (Feb 14)
      '🌍 Mar', // Earth Hour (March) or Int'l Women's Day (March 8)
      '🌱 Apr', // Earth Day (April 22)
      '👩 May', // Mother's Day (varies, but often May) or Int'l Workers' Day (May 1)
      '🌈 Jun', // Pride Month
      '🇺🇳 Jul', // No major global events - using UN emblem as July has smaller observances
      '👨 Aug', // Father's Day (in many countries)
      '📚 Sep', // International Literacy Day (Sep 8)
      '🎃 Oct', // Halloween (Oct 31)
      '✊ Nov', // Movember (men's health) or World Kindness Day (Nov 13)
      '🎄 Dec', // Christmas (Dec 25)
    ];

    // Group payments by month
    final monthPayments = <int, List<PaymentModel>>{};
    for (var payment in data) {
      final month = payment.dueDate.month;
      monthPayments.putIfAbsent(month, () => []).add(payment);
    }

    // Determine status and colors for each month
    Color _getMonthColor(int month, List<Map<String, Object>> legendItems) {
      if (month > now.month) {
        return legendItems[3]['color'] as Color; // No data (future)
      }
      final payments = monthPayments[month] ?? [];
      if (payments.isEmpty) {
        return legendItems[3]['color'] as Color; // No data
      }
      final hasNotPaid = payments.any((p) => !p.isPaid);
      if (hasNotPaid) {
        return legendItems[2]['color'] as Color; // Not paid
      }
      final hasDelayed = payments.any(
        (p) =>
            p.isPaid &&
            p.paymentDate != null &&
            p.paymentDate!.isAfter(p.dueDate),
      );
      if (hasDelayed) {
        return legendItems[1]['color'] as Color; // Delayed
      }
      return legendItems[0]['color'] as Color; // On time
    }

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
              color: _getMonthColor(month, legendItems),
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
                child: Text(
                  months[index],
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight:
                        month == now.month ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
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
