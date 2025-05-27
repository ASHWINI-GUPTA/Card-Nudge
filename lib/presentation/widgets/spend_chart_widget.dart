import 'package:card_nudge/constants/app_strings.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/format_provider.dart';

class SpendChartWidget extends ConsumerWidget {
  final List<Map<String, dynamic>>
  data; // [{'month': 'Jan', 'amount': 5000}, ...]
  const SpendChartWidget({super.key, this.data = const []});

  // Get the last 3 months (e.g., May, Apr, Mar for May 2025)
  List<String> _getLastThreeMonths(DateTime now) {
    final months = <String>[];
    for (int i = 2; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      months.add(DateFormat.MMM().format(monthDate));
    }
    return months;
  }

  // Get spend amounts for the last 3 months, default to 0 if missing
  List<double> _getSpendValues(List<String> months) {
    return months.map((month) {
      final entry = data.firstWhere(
        (d) => d['month'] == month,
        orElse: () => {'amount': 0.0},
      );
      return (entry['amount'] as num?)?.toDouble() ?? 0.0;
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatHelper = ref.watch(formatHelperProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final quarterMonths = _getLastThreeMonths(now);
    final spendValues = _getSpendValues(quarterMonths);

    // AG TODO: Get this from Settings
    const overspendThreshold = 50000.0; // ₹50,000

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color:
          isDark
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.spendOverview,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        maxIncluded: true,
                        minIncluded: false,
                        reservedSize: 50,
                        getTitlesWidget:
                            (value, _) => Text(
                              formatHelper.formatCurrencyCompact(value),
                              style: TextStyle(
                                color:
                                    isDark
                                        ? theme.colorScheme.onSurfaceVariant
                                        : theme.colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index >= 0 && index < quarterMonths.length) {
                            return Text(
                              quarterMonths[index],
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isDark
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.onSurface,
                              ),
                            );
                          }
                          return const Text('');
                        },
                        interval: 1,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups: List.generate(quarterMonths.length, (i) {
                    final isOverspent = spendValues[i] > overspendThreshold;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: spendValues[i],
                          color:
                              isOverspent
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                          width: 18,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
