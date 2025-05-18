import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpendChartWidget extends StatelessWidget {
  const SpendChartWidget({super.key});

  List<String> getLastThreeMonths(DateTime now) {
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
    List<String> result = [];
    for (int i = 2; i >= 0; i--) {
      int monthIndex = (now.month - i - 1) % 12;
      if (monthIndex < 0) monthIndex += 12;
      result.add(months[monthIndex]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final quarterMonths = getLastThreeMonths(now);
    final spendValues = [
      40000.0,
      35000.0,
      28000.0,
    ]; // Replace with actual values

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey[900] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Spend Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
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
                        reservedSize: 40,
                        getTitlesWidget:
                            (value, _) => Text(
                              '₹${(value / 1000).round()}k',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          return Text(
                            quarterMonths[value.toInt()],
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          );
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
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: spendValues[i],
                          color: isDark ? Colors.tealAccent : Colors.teal,
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
