import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/format_provider.dart';

class MonthlySpendingChartWidget extends ConsumerWidget {
  final List<Map<String, dynamic>>
  data; // [{'month': 'Jan', 'amount': 5000}, ...]
  const MonthlySpendingChartWidget({super.key, this.data = const []});

  // Get the last 4 months as DateTime (1st of the month)
  List<DateTime> _getLastFourMonths(DateTime now) {
    final months = <DateTime>[];
    for (int i = 3; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      months.add(monthDate);
    }
    return months;
  }

  // Get spend amounts for the last 4 months, default to 0 if missing
  List<double> _getSpendValues(List<DateTime> months) {
    return months.map((month) {
      final entry = data.firstWhere(
        (d) {
          final entryDate = d['date'] as DateTime?;
          if (entryDate == null) return false;
          return entryDate.year == month.year && entryDate.month == month.month;
        },
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
    final monthsToShow = _getLastFourMonths(now);
    final spendValues = _getSpendValues(monthsToShow);

    return Card(
      margin: const EdgeInsets.all(6),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color:
          isDark
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  barGroups: List.generate(monthsToShow.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: spendValues[i],
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                          width: 20,
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        maxIncluded: false,
                        minIncluded: false,
                        reservedSize: 40,
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
                          if (index >= 0 && index < monthsToShow.length) {
                            return Text(
                              DateFormat.MMM().format(monthsToShow[index]),
                              style: TextStyle(
                                fontSize: 14,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
