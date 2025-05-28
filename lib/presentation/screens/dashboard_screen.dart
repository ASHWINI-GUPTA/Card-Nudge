import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../constants/app_strings.dart';
import '../../data/hive/models/credit_card_model.dart';
import '../../data/hive/models/payment_model.dart';
import '../providers/credit_card_provider.dart';
import '../providers/format_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/dashboard_alert_card.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/dashboard_month_widget.dart';
import '../widgets/spend_chart_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cardsAsync = ref.watch(creditCardListProvider);
    final paymentsAsync = ref.watch(paymentProvider);
    final user = ref.watch(userProvider);
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;
    if (hour >= 5 && hour < 12) {
      greeting = 'Morning';
      emoji = '🌅';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Afternoon';
      emoji = '🌞';
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Evening';
      emoji = '🌇';
    } else {
      greeting = 'Night';
      emoji = '🌙';
    }
    final username = user?.firstName ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Good $greeting $emoji ${username.isNotEmpty ? '$username' : ''}!',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: cardsAsync.when(
        data:
            (cards) => paymentsAsync.when(
              data:
                  (payments) => _buildDashboard(context, ref, cards, payments),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Text(
                      '${AppStrings.paymentLoadError}: $error',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Text(
                '${AppStrings.cardLoadError}: $error',
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
    final nonPaidPayments = payments.where((p) => !p.isPaid).toList();

    // Calculate metrics
    final totalCreditLimit = cards.fold<double>(
      0,
      (sum, card) => sum + (card.creditLimit),
    );
    final totalDue = nonPaidPayments.fold<double>(
      0,
      (sum, payment) => sum + payment.dueAmount,
    );
    final utilization =
        totalCreditLimit > 0 ? totalDue / totalCreditLimit : 0.0;

    // Calculate overutilized cards (utilization > 30% per card)
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
        cardUtilization.values.where((u) => u > 0.3).length;

    // Calculate due-soon payments (within 3 days)
    final dueSoonCount =
        nonPaidPayments
            .where(
              (p) =>
                  p.dueDate.difference(now).inDays >= 0 &&
                  p.dueDate.difference(now).inDays <= 3,
            )
            .length;

    // Generate alerts
    final alerts = <Map<String, dynamic>>[];
    if (overUtilizedCards > 0) {
      alerts.add({
        'text':
            '$overUtilizedCards card${overUtilizedCards > 1 ? 's' : ''} over-utilized (>30%)',
        'icon': Icons.warning,
        'color': theme.colorScheme.error,
      });
    }
    if (dueSoonCount > 0) {
      alerts.add({
        'text':
            '$dueSoonCount card${dueSoonCount > 1 ? 's' : ''} due in next 3 days',
        'icon': Icons.calendar_today,
        'color': theme.colorScheme.tertiary,
      });
    }

    // Monthly spend data for SpendChartWidget
    final monthlySpends = <Map<String, dynamic>>[];
    final months = List.generate(
      3,
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

    // Currency formatter
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Alerts
        if (alerts.isNotEmpty) ..._buildAlert(context, alerts),

        // Quick Insights
        Text(
          'Quick Insights',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            DashboardCard(
              title: 'Total Credit Limit',
              value: formatHelper.formatCurrency(totalCreditLimit),
              icon: Icons.credit_card,
              color: theme.colorScheme.primary,
            ),
            DashboardCard(
              title: 'Total Due',
              value: formatHelper.formatCurrency(totalDue),
              icon: Icons.account_balance_wallet_outlined,
              color: theme.colorScheme.error,
            ),
            DashboardCard(
              title: 'Utilization',
              value: '${(utilization * 100).toStringAsFixed(0)}%',
              icon: Icons.pie_chart_outline,
              color: theme.colorScheme.secondary,
            ),
            DashboardCard(
              title: 'Overutilized Cards',
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
          'Spend Chart',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SpendChartWidget(data: monthlySpends),
        const SizedBox(height: 24),
        // Monthly Overview
        Text(
          'Monthly Overview',
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
                  (alert) => DashboardAlertCard(
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
