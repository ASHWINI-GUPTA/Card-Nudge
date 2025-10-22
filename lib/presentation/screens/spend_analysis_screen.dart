import 'dart:math';
import 'package:card_nudge/helper/app_localizations_extension.dart';
import 'package:card_nudge/presentation/widgets/credit_card_color_dot_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/spend_analysis_provider.dart';
import '../providers/credit_card_provider.dart';
import '../providers/bank_provider.dart';
import '../providers/format_provider.dart';

class SpendAnalysisScreen extends ConsumerStatefulWidget {
  const SpendAnalysisScreen({super.key});

  @override
  ConsumerState<SpendAnalysisScreen> createState() =>
      _SpendAnalysisScreenState();
}

class _SpendAnalysisScreenState extends ConsumerState<SpendAnalysisScreen> {
  int? _selectedYear;
  final Set<String> _selectedCardIds = <String>{};
  bool _isBarChart = false;
  bool _isHorizontalBar = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final service = ref.watch(spendAnalysisProvider);
    final formatHelper = ref.watch(formatHelperProvider);
    final cardsAsync = ref.watch(creditCardProvider);

    final years = service.availableYears();
    if (_selectedYear == null && years.isNotEmpty) {
      _selectedYear = years.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.spendAnalysisTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
          IconButton(
            icon: Icon(_isBarChart ? Icons.show_chart : Icons.bar_chart),
            onPressed: () => setState(() => _isBarChart = !_isBarChart),
          ),
          if (_isBarChart)
            IconButton(
              icon: Icon(_isHorizontalBar ? Icons.swap_vert : Icons.swap_horiz),
              onPressed:
                  () => setState(() => _isHorizontalBar = !_isHorizontalBar),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Year selector
            Row(
              children: [
                Text('${l10n.yearLabel}: '),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedYear,
                    items:
                        years
                            .map(
                              (y) =>
                                  DropdownMenuItem(value: y, child: Text('$y')),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedYear = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Total Summary
            if (_selectedYear != null)
              Consumer(
                builder: (context, ref, child) {
                  final cards = ref.watch(creditCardProvider).valueOrNull ?? [];
                  final filteredCards =
                      _selectedCardIds.isEmpty
                          ? cards
                          : cards
                              .where((c) => _selectedCardIds.contains(c.id))
                              .toList();
                  final totals = service.getSpendByYear(_selectedYear!);
                  final totalSpend = filteredCards.fold<double>(
                    0.0,
                    (sum, card) => sum + (totals[card.id] ?? 0.0),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.totalSpend,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                formatHelper.formatCurrency(totalSpend),
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (filteredCards.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              filteredCards.take(5).map((card) {
                                final color = _getCardColor(
                                  filteredCards.indexOf(card),
                                );
                                return Chip(
                                  avatar: CircleAvatar(backgroundColor: color),
                                  label: Text(
                                    card.name,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ],
                  );
                },
              ),
            const SizedBox(height: 16),

            // Chart
            Expanded(
              child: cardsAsync.when(
                data: (cards) {
                  final selectedYear = _selectedYear ?? years.first;
                  final filteredCards =
                      _selectedCardIds.isEmpty
                          ? cards
                          : cards
                              .where((c) => _selectedCardIds.contains(c.id))
                              .toList();

                  if (filteredCards.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No cards selected',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select cards to view monthly spend analysis',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // Fetch real monthly data
                  final allMonthlyData = service.getMonthlySpend(selectedYear);
                  final monthlyData = <String, List<double>>{};
                  for (var card in filteredCards) {
                    monthlyData[card.id] =
                        allMonthlyData[card.id] ?? List.filled(12, 0.0);
                  }

                  final monthNames = [
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

                  if (_isBarChart) {
                    // Stacked Bar Chart
                    final barGroups = List.generate(12, (month) {
                      final stackItems =
                          filteredCards.asMap().entries.map((entry) {
                            final index = entry.key;
                            final card = entry.value;
                            final amount = monthlyData[card.id]![month];
                            final color = _getCardColor(index);
                            return BarChartRodStackItem(0, amount, color);
                          }).toList();

                      return BarChartGroupData(
                        x: month,
                        barRods: [
                          BarChartRodData(
                            toY: stackItems.fold(
                              0.0,
                              (sum, item) => sum + item.toY,
                            ),
                            rodStackItems: stackItems,
                            width: 22,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    });

                    Widget chartWidget = BarChart(
                      BarChartData(
                        barGroups: barGroups,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 64,
                              getTitlesWidget: (v, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    formatHelper.formatCurrencyCompact(v),
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= 12)
                                  return const SizedBox.shrink();
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    monthNames[idx],
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor:
                                (_) => Colors.blueGrey.withValues(alpha: 0.8),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final month = group.x;
                              String tooltip = '${monthNames[month]}\n';
                              double cumulative = 0;
                              for (
                                int i = rod.rodStackItems.length - 1;
                                i >= 0;
                                i--
                              ) {
                                final stackItem = rod.rodStackItems[i];
                                final card = filteredCards[i];
                                final amount = stackItem.toY - stackItem.fromY;
                                tooltip +=
                                    '${card.name}: ${formatHelper.formatCurrency(amount)}\n';
                              }
                              return BarTooltipItem(
                                tooltip,
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                      ),
                    );

                    if (_isHorizontalBar) {
                      chartWidget = RotatedBox(
                        quarterTurns: -1,
                        child: chartWidget,
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection:
                          _isHorizontalBar ? Axis.vertical : Axis.horizontal,
                      child: SizedBox(
                        width:
                            _isHorizontalBar
                                ? null
                                : max(
                                  MediaQuery.of(context).size.width,
                                  12 * 50.0,
                                ),
                        height:
                            _isHorizontalBar
                                ? max(
                                  MediaQuery.of(context).size.height / 2,
                                  400.0,
                                )
                                : null,
                        child: chartWidget,
                      ),
                    );
                  } else {
                    // Line Chart
                    return LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 1000, // Adjust based on data
                          verticalInterval: 1,
                        ),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < 12) {
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Text(monthNames[index]),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 64,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    formatHelper.formatCurrencyCompact(
                                      value.toDouble(),
                                    ),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData:
                            filteredCards.asMap().entries.map((entry) {
                              final index = entry.key;
                              final card = entry.value;
                              final cardData =
                                  monthlyData[card.id] ??
                                  List.generate(12, (i) => 0.0);
                              final color = _getCardColor(index);
                              final spots =
                                  cardData.asMap().entries.map((e) {
                                    return FlSpot(e.key.toDouble(), e.value);
                                  }).toList();

                              return LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: color,
                                barWidth: 3,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: color.withValues(alpha: 0.3),
                                ),
                                dotData: const FlDotData(show: false),
                              );
                            }).toList(),
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor:
                                (_) => Colors.blueGrey.withValues(alpha: 0.8),
                            getTooltipItems: (touchedSpots) {
                              if (touchedSpots.isEmpty) return [];
                              final month = touchedSpots.first.x.toInt();
                              return touchedSpots.map((spot) {
                                final cardIndex = spot.barIndex;
                                final card = filteredCards[cardIndex];
                                return LineTooltipItem(
                                  '${monthNames[month]} - ${card.name}: ${formatHelper.formatCurrency(spot.y)}',
                                  const TextStyle(color: Colors.white),
                                );
                              }).toList();
                            },
                          ),
                          handleBuiltInTouches: true,
                        ),
                      ),
                    );
                  }
                },
                loading:
                    () => const Center(child: CreditCardColorDotIndicator()),
                error: (e, s) => Center(child: Text('Error - $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCardColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }

  void _showFilterSheet(BuildContext context) {
    final tempCardIds = Set<String>.from(_selectedCardIds);
    final cards = ref.read(creditCardProvider).valueOrNull ?? [];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      'Select Cards',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Cards'),
                      trailing: TextButton(
                        child: const Text('Clear'),
                        onPressed: () {
                          setSheetState(() => tempCardIds.clear());
                        },
                      ),
                    ),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          final isSelected = tempCardIds.contains(card.id);
                          final color = _getCardColor(index);
                          return CheckboxListTile(
                            secondary: CircleAvatar(
                              backgroundColor: color,
                              radius: 16,
                            ),
                            title: Text(card.name),
                            subtitle: Text(
                              ref
                                      .read(bankProvider.notifier)
                                      .get(card.bankId ?? '')
                                      ?.name ??
                                  '',
                            ),
                            value: isSelected,
                            onChanged: (value) {
                              setSheetState(() {
                                if (value == true) {
                                  tempCardIds.add(card.id);
                                } else {
                                  tempCardIds.remove(card.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedCardIds.clear();
                                _selectedCardIds.addAll(tempCardIds);
                              });
                              Navigator.pop(modalContext);
                            },
                            child: const Text('Apply'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(modalContext),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
