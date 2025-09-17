import 'package:card_nudge/helper/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/hive/models/credit_card_model.dart';
import '../../data/hive/models/payment_model.dart';
import '../providers/credit_card_provider.dart';
import '../providers/format_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/setting_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/credit_card_color_dot_indicator.dart';
import '../widgets/dashboard_notification_alert_card.dart';
import '../widgets/dashboard_metrics_display_card.dart';
import '../widgets/dashboard_month_widget.dart';
import '../widgets/monthly_spend_chart_widget.dart';
import '../widgets/data_sync_progress_bar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cardsAsync = ref.watch(creditCardProvider);
    final paymentsAsync = ref.watch(paymentProvider);
    final user = ref.watch(userProvider);
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;
    if (hour >= 5 && hour < 12) {
      greeting = context.l10n.morningGreeting;
      emoji = '🌅';
    } else if (hour >= 12 && hour < 17) {
      greeting = context.l10n.afternoonGreeting;
      emoji = '🌞';
    } else if (hour >= 17 && hour < 21) {
      greeting = context.l10n.eveningGreeting;
      emoji = '🌇';
    } else {
      greeting = context.l10n.nightGreeting;
      emoji = '🌙';
    }
    final username = user?.firstName ?? '';

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
            children: [
              TextSpan(text: '$greeting $emoji '),
              if (username.isNotEmpty)
                TextSpan(
                  text: '$username',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              TextSpan(text: '!'),
            ],
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: DataSynchronizationProgressBar(),
        ),
      ),
      body: cardsAsync.when(
        data: (cards) {
          final activeCards = cards.where((card) => !card.isArchived).toList();

          return paymentsAsync.when(
            data:
                (payments) =>
                    _buildDashboard(context, ref, activeCards, payments),
            loading: () => const Center(child: CreditCardColorDotIndicator()),
            error:
                (error, stack) => Center(
                  child: Text(
                    '${context.l10n.paymentLoadError}: $error',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
          );
        },
        loading: () => const Center(child: CreditCardColorDotIndicator()),
        error:
            (error, stack) => Center(
              child: Text(
                '${context.l10n.cardsScreenErrorTitle}: $error',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    WidgetRef ref,
    List<CreditCardModel> cards,
    List<PaymentModel> payments,
  ) {
    final theme = Theme.of(context);
    final formatHelper = ref.watch(formatHelperProvider);
    final now = DateTime.now();
    // Filter out archived cards
    final activeCardIds = cards.map((c) => c.id).toSet();

    final nonPaidPayments =
        payments
            .where((p) => !p.isPaid && activeCardIds.contains(p.cardId))
            .toList();

    final setting = ref.watch(settingsProvider);
    final utilizationThreshold =
        (setting.utilizationAlertThreshold ?? 30) / 100;

    // Calculate metrics
    final totalCreditLimit = cards.fold<double>(
      0,
      (sum, card) => sum + (card.creditLimit),
    );
    final totalDue = nonPaidPayments.fold<double>(
      0,
      (sum, payment) => sum + payment.dueAmount,
    );
    final utilization = totalCreditLimit == 0 ? 0 : totalDue / totalCreditLimit;

    // Calculate overutilized cards (utilization > X% per card)
    final cardUtilization = <String, double>{};
    for (var card in cards) {
      final cardPayments =
          nonPaidPayments.where((p) => p.cardId == card.id).toList();
      final cardDue = cardPayments.fold<double>(
        0,
        (sum, p) => sum + p.dueAmount,
      );
      final cardLimit = card.creditLimit;
      cardUtilization[card.id] = cardLimit > 0 ? cardDue / cardLimit : 0.0;
    }
    final overUtilizedCards =
        cardUtilization.values.where((u) => u > utilizationThreshold).length;

    // Calculate due-soon payments (within 7 days)
    final dueSoonCount =
        nonPaidPayments.where((p) => p.isdueDateInNext7Days).length;

    // Generate alerts
    final alerts = <Map<String, dynamic>>[];
    if (overUtilizedCards > 0) {
      alerts.add({
        'text': context.l10n.overUtilizedCards(
          overUtilizedCards,
          (setting.utilizationAlertThreshold ?? 30).toStringAsFixed(0),
        ),
        'icon': Icons.warning,
        'color': theme.colorScheme.error,
      });
    }

    if (dueSoonCount > 0) {
      alerts.add({
        'text': context.l10n.dueSoonCards(dueSoonCount),
        'icon': Icons.calendar_today,
        'color': theme.colorScheme.tertiary,
      });
    }

    // Monthly spend data for SpendChartWidget
    final monthlySpends = <Map<String, dynamic>>[];
    final months = List.generate(
      4,
      (i) => DateTime(now.year, now.month - i, 1),
    );
    for (var month in months) {
      final monthPayments =
          payments
              .where(
                (p) =>
                    p.dueDate.year == month.year &&
                    p.dueDate.month == month.month,
              )
              .toList();
      final amount = monthPayments.fold<double>(
        0,
        (sum, p) => sum + p.statementAmount,
      );
      monthlySpends.add({
        'month': DateFormat.MMM().format(month),
        'amount': amount,
      });
    }
    monthlySpends.sort(
      (a, b) => months
          .indexWhere((m) => DateFormat.MMM().format(m) == a['month'])
          .compareTo(
            months.indexWhere((m) => DateFormat.MMM().format(m) == b['month']),
          ),
    );

    // Monthly overview data for DashboardMonthWidget
    final monthlyOverview = <Map<String, dynamic>>[];
    for (var month in months) {
      final monthPayments =
          nonPaidPayments
              .where(
                (p) =>
                    p.dueDate.year == month.year &&
                    p.dueDate.month == month.month,
              )
              .toList();
      final amount = monthPayments.fold<double>(
        0,
        (sum, p) => sum + p.dueAmount,
      );
      monthlyOverview.add({
        'month': DateFormat.MMM().format(month),
        'due': amount,
        'count': monthPayments.length,
      });
    }
    monthlyOverview.sort(
      (a, b) => months
          .indexWhere((m) => DateFormat.MMM().format(m) == a['month'])
          .compareTo(
            months.indexWhere((m) => DateFormat.MMM().format(m) == b['month']),
          ),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Alerts
        if (alerts.isNotEmpty) ..._buildAlert(context, alerts),

        // Quick Insights
        Text(
          context.l10n.quickInsights,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            DashboardMetricsDisplayCard(
              title: context.l10n.totalCreditLimit,
              value: formatHelper.formatCurrency(totalCreditLimit),
              icon: Icons.credit_card,
              color: theme.colorScheme.primary,
            ),
            if (totalDue > 0)
              DashboardMetricsDisplayCard(
                title: context.l10n.totalDue,
                value: formatHelper.formatCurrency(totalDue),
                icon: Icons.account_balance_wallet_outlined,
                color: theme.colorScheme.error,
              ),
            if (utilization > 0)
              DashboardMetricsDisplayCard(
                title: context.l10n.utilization,
                value:
                    utilization < 0.01 && utilization > 0
                        ? '< 1%'
                        : '${(utilization * 100).toStringAsFixed(0)}%',
                icon: Icons.pie_chart_outline,
                color: theme.colorScheme.secondary,
              ),
            if (overUtilizedCards > 0)
              DashboardMetricsDisplayCard(
                title: context.l10n.overUtilization,
                value:
                    '$overUtilizedCards Card${overUtilizedCards == 1 ? '' : 's'}',
                icon: Icons.warning_amber_rounded,
                color: theme.colorScheme.tertiary,
              ),
          ],
        ),
        const SizedBox(height: 24),

        // Spend Chart
        Text(
          context.l10n.spendOverview,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        MonthlySpendingChartWidget(data: monthlySpends),
        const SizedBox(height: 24),

        // Monthly Overview
        Text(
          context.l10n.monthlyOverview,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        DashboardMonthWidget(data: payments),
        const SizedBox(height: 24),
      ],
    );
  }

  List<Widget> _buildAlert(
    BuildContext context,
    List<Map<String, dynamic>> alerts,
  ) {
    final theme = Theme.of(context);
    return [
      Text(
        'Alerts',
        style: theme.textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 8),
      Column(
        children:
            alerts
                .map(
                  (alert) => DashboardNotificationAlertCard(
                    text: alert['text'] as String,
                    icon: alert['icon'] as IconData,
                    color: alert['color'] as Color,
                  ),
                )
                .toList(),
      ),

      const SizedBox(height: 24),
    ];
  }
}
