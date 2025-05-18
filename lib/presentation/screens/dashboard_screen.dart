import 'package:flutter/material.dart';

import '../widgets/dashboard_alert_card.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/dashboard_month_widget.dart';
import '../widgets/spend_chart_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Nudge'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Hi there 👋, here\'s your credit snapshot',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          // Alerts
          const Text(
            'Alerts',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              DashboardAlertCard(
                text: '2 cards over-utilized by 30%',
                icon: Icons.warning,
                color: Colors.redAccent,
              ),
              DashboardAlertCard(
                text: '3 cards due in next 3 days',
                icon: Icons.calendar_today,
                color: Colors.orangeAccent,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Top Stats
          const Text(
            'Quick Insights',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              DashboardCard(
                title: 'Total Credit Limit',
                value: '₹3,50,000',
                icon: Icons.credit_card,
                color: Colors.indigo,
              ),
              DashboardCard(
                title: 'Total Due',
                value: '₹42,000',
                icon: Icons.account_balance_wallet_outlined,
                color: Colors.redAccent,
              ),
              DashboardCard(
                title: 'Utilization',
                value: '20%',
                icon: Icons.pie_chart_outline,
                color: Colors.orange,
              ),
              DashboardCard(
                title: 'Overutilized Cards',
                value: '2 Cards',
                icon: Icons.warning_amber_rounded,
                color: Colors.deepPurple,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Spend Chart
          const Text(
            'Spend Chart',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const SpendChartWidget(),
          const SizedBox(height: 24),
          // Monthly Overview
          const Text(
            'Monthly Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DashboardMonthWidget(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
