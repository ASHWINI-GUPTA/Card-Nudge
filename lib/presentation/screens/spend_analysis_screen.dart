import 'dart:math';
import 'package:card_nudge/helper/calender_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:card_nudge/helper/app_localizations_extension.dart';

import '../../l10n/app_localizations.dart';
import '../providers/spend_analysis_provider.dart';
import '../providers/credit_card_provider.dart';
import '../providers/bank_provider.dart';
import '../providers/format_provider.dart';
import '../widgets/data_sync_progress_bar.dart';
import '../widgets/credit_card_color_dot_indicator.dart';

class SpendAnalysisScreen extends ConsumerStatefulWidget {
  const SpendAnalysisScreen({super.key});

  @override
  ConsumerState<SpendAnalysisScreen> createState() =>
      _SpendAnalysisScreenState();
}

class _SpendAnalysisScreenState extends ConsumerState<SpendAnalysisScreen> {
  int? _selectedYear;
  bool _isVerticalChart = true;
  final Set<String> _selectedCardIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primary = Theme.of(context).colorScheme.primary;

    final spendService = ref.watch(spendAnalysisProvider);
    final formatHelper = ref.watch(formatHelperProvider);
    final cardsAsync = ref.watch(creditCardProvider);
    final years = spendService.availableYears();
    _selectedYear ??= years.isNotEmpty ? years.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.spendAnalysisTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        backgroundColor: primary,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Filter Cards',
            icon: const Icon(Icons.filter_list),
            color: Colors.white,
            onPressed: () => _showFilterSheet(context),
          ),
          IconButton(
            tooltip:
                _isVerticalChart
                    ? 'Rotate to Horizontal'
                    : 'Rotate to Vertical',
            icon: Transform.rotate(
              angle: _isVerticalChart ? pi / 2 : 0, // Rotate 90° Clockwise
              child: const Icon(Icons.stacked_bar_chart),
            ),
            color: Colors.white,
            onPressed:
                () => setState(() => _isVerticalChart = !_isVerticalChart),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: DataSynchronizationProgressBar(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildYearSelector(years, l10n),
            const SizedBox(height: 12),
            if (_selectedYear != null)
              _buildTotalSpendCard(context, formatHelper, spendService),
            const SizedBox(height: 12),
            // Card chips
            _buildCardChips(context, spendService),
            const SizedBox(height: 24),
            Expanded(
              child: cardsAsync.when(
                data:
                    (cards) => _buildChart(
                      context,
                      cards,
                      spendService,
                      formatHelper,
                      CalenderHelper.getMonthNames(
                        context.l10n,
                        abbreviated: true,
                      ),
                    ),
                loading:
                    () => const Center(child: CreditCardColorDotIndicator()),
                error: (e, _) => Center(child: Text('Error - $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearSelector(List<int> years, AppLocalizations l10n) {
    if (years.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        Text(
          '${l10n.yearLabel}:',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 12),
        DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _selectedYear,
            items:
                years
                    .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                    .toList(),
            onChanged: (value) => setState(() => _selectedYear = value),
          ),
        ),
      ],
    );
  }

  Widget _buildCardChips(
    BuildContext context,
    SpendAnalysisService spendService,
  ) {
    final theme = Theme.of(context);
    final cards = ref.watch(creditCardProvider).valueOrNull ?? [];
    final filteredCards =
        _selectedCardIds.isEmpty
            ? cards
            : cards.where((c) => _selectedCardIds.contains(c.id)).toList();

    if (filteredCards.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filteredCards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final card = filteredCards[index];
          final color = _getCardColor(index);
          return Chip(
            avatar: CircleAvatar(backgroundColor: color),
            label: Text(card.name, style: theme.textTheme.labelMedium),
            backgroundColor: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.4),
          );
        },
      ),
    );
  }

  Widget _buildTotalSpendCard(
    BuildContext context,
    FormatHelper formatHelper,
    SpendAnalysisService service,
  ) {
    final cards = ref.watch(creditCardProvider).valueOrNull ?? [];
    final filteredCards =
        _selectedCardIds.isEmpty
            ? cards
            : cards.where((c) => _selectedCardIds.contains(c.id)).toList();
    final totals = service.getSpendByYear(_selectedYear!);
    final totalSpend = filteredCards.fold<double>(
      0,
      (sum, c) => sum + (totals[c.id] ?? 0),
    );
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.totalSpend,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatHelper.formatCurrency(totalSpend),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.credit_card, color: primary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${context.l10n.cardsLabel(filteredCards.length)}',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(
    BuildContext context,
    List<dynamic> cards,
    SpendAnalysisService service,
    FormatHelper formatHelper,
    List<String> monthNames,
  ) {
    final selectedYear = _selectedYear!;
    final filteredCards =
        _selectedCardIds.isEmpty
            ? cards
            : cards.where((c) => _selectedCardIds.contains(c.id)).toList();

    if (filteredCards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No cards selected',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Select cards to view spend analysis',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    final monthlyData = service.getMonthlySpend(selectedYear);
    final dataByCard = {
      for (var c in filteredCards)
        c.id: monthlyData[c.id] ?? List.filled(12, 0.0),
    };
    double maxStack = 0;
    for (int m = 0; m < 12; m++) {
      maxStack = max(
        maxStack,
        filteredCards.fold(0.0, (sum, c) => sum + (dataByCard[c.id]![m])),
      );
    }

    final barGroups = List.generate(12, (month) {
      double base = 0;
      final stacks = <BarChartRodStackItem>[];
      for (var entry in filteredCards.asMap().entries) {
        final color = _getCardColor(entry.key);
        final amount = dataByCard[entry.value.id]![month];
        stacks.add(BarChartRodStackItem(base, base + amount, color));
        base += amount;
      }
      return BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(
            toY: base,
            rodStackItems: stacks,
            width: 18,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });

    final chart = BarChart(
      BarChartData(
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        groupsSpace: 12,
        barGroups: barGroups,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                return Text(
                  monthNames[idx],
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 42,
              showTitles: _isVerticalChart,
              getTitlesWidget:
                  (v, _) => Text(
                    formatHelper.formatCurrencyCompact(v),
                    style: const TextStyle(fontSize: 11),
                  ),
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 42,
              showTitles: !_isVerticalChart,
              getTitlesWidget:
                  (v, _) => Text(
                    formatHelper.formatCurrencyCompact(v),
                    style: const TextStyle(fontSize: 11),
                  ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey.withValues(alpha: 0.9),
            getTooltipItem: (group, _, rod, __) {
              final month = group.x;
              final tooltip = StringBuffer('${monthNames[month]}\n');
              for (int i = rod.rodStackItems.length - 1; i >= 0; i--) {
                final card = filteredCards[i];
                final amount =
                    rod.rodStackItems[i].toY - rod.rodStackItems[i].fromY;
                if (amount > 0)
                  tooltip.writeln(
                    '${card.name}: ${formatHelper.formatCurrency(amount)}',
                  );
              }
              return BarTooltipItem(
                tooltip.toString(),
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child:
          _isVerticalChart
              ? chart
              : RotatedBox(
                quarterTurns: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: chart,
                ),
              ),
    );
  }

  Color _getCardColor(int index) {
    const colors = [
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
    final l10n = context.l10n;
    final tempCardIds = Set<String>.from(_selectedCardIds);
    final cards = ref.read(creditCardProvider).valueOrNull ?? [];
    final primary = Theme.of(context).colorScheme.primary;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (modalContext) => StatefulBuilder(
            builder:
                (context, setSheetState) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.filterCardsLabel,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
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
                                    .name,
                              ),
                              value: isSelected,
                              onChanged:
                                  (value) => setSheetState(() {
                                    value == true
                                        ? tempCardIds.add(card.id)
                                        : tempCardIds.remove(card.id);
                                  }),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primary,
                              ),
                              onPressed:
                                  () =>
                                      setSheetState(() => tempCardIds.clear()),
                              child: Text(l10n.clearButton),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedCardIds
                                    ..clear()
                                    ..addAll(tempCardIds);
                                });
                                Navigator.pop(modalContext);
                              },
                              child: Text(l10n.applyButton),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}
