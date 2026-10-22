import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/emi_calculation_model.dart';
import '../providers/format_provider.dart';

class EmiResultSummaryCard extends ConsumerWidget {
  final EmiResult result;

  const EmiResultSummaryCard({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatHelper = ref.watch(formatHelperProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Highlight Box: Monthly Repayment
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: theme.colorScheme.primaryContainer.withAlpha(isDark ? 100 : 180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              children: [
                Text(
                  result.isNoCostEmi ? 'Monthly No-Cost EMI' : 'Monthly EMI',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${formatHelper.formatCurrency(result.standardMonthlyEmi)} × ${result.tenureMonths}m',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                if (result.firstCycleDays != 30 && result.adjustedFirstEmi != result.standardMonthlyEmi) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '1st EMI: ${formatHelper.formatCurrency(result.adjustedFirstEmi)} (${result.firstCycleDays} days to 1st Due Date)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Order Summary Card (Matching Amazon Style)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Order Summary',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _buildRow(
                  context,
                  'Product Total',
                  formatHelper.formatCurrency(result.originalAmount),
                ),
                if (result.instantBankDiscount > 0)
                  _buildRow(
                    context,
                    'Instant Bank Discount',
                    '-${formatHelper.formatCurrency(result.instantBankDiscount)}',
                    color: Colors.green,
                  ),
                if (result.isNoCostEmi && result.noCostDiscount > 0)
                  _buildRow(
                    context,
                    'No Cost EMI Discount',
                    '-${formatHelper.formatCurrency(result.noCostDiscount)}',
                    color: Colors.green,
                  ),
                const Divider(height: 16),
                _buildRow(
                  context,
                  'Order Total (Loan Principal)',
                  formatHelper.formatCurrency(result.netPrincipal),
                  isBold: true,
                ),
                _buildRow(
                  context,
                  'Interest (Charged by Bank)',
                  formatHelper.formatCurrency(result.totalStandardInterest),
                ),
                _buildRow(
                  context,
                  'Total Cost (Payable to Bank)',
                  formatHelper.formatCurrency(result.totalPayableToBank),
                  isBold: true,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // True Cost Breakdown (Hidden Charges explained)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      result.isNoCostEmi ? Icons.visibility_outlined : Icons.account_balance_wallet_outlined,
                      color: Colors.amber.shade800,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.isNoCostEmi ? 'True Cost & Hidden Fees' : 'Taxes & Bank Charges',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(40),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Actual Outflow',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  result.isNoCostEmi
                      ? 'While interest is discounted upfront by the merchant, government regulations and banks charge GST & processing fees:'
                      : 'Applicable GST and bank charges on this transaction:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Divider(height: 20),
                if (result.isCreditCard)
                  _buildRow(
                    context,
                    '18% GST on Interest',
                    formatHelper.formatCurrency(result.totalGstOnInterest),
                    color: Colors.red.shade700,
                  ),
                if (result.processingFee > 0) ...[
                  _buildRow(
                    context,
                    'Bank Processing Fee',
                    formatHelper.formatCurrency(result.processingFee),
                    color: Colors.red.shade700,
                  ),
                  if (result.isCreditCard && result.gstOnProcessingFee > 0)
                    _buildRow(
                      context,
                      '18% GST on Processing Fee',
                      formatHelper.formatCurrency(result.gstOnProcessingFee),
                      color: Colors.red.shade700,
                    ),
                ],
                const Divider(height: 16),
                _buildRow(
                  context,
                  'Total Non-Waived Charges',
                  formatHelper.formatCurrency(result.totalHiddenCharges),
                  isBold: true,
                  color: Colors.red.shade700,
                ),
                const SizedBox(height: 4),
                _buildRow(
                  context,
                  'Total Out-of-Pocket Expense',
                  formatHelper.formatCurrency(result.totalOutOfPocketCost),
                  isBold: true,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Explanation / Bank Rule Note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withAlpha(120),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: theme.colorScheme.onSecondaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    'Bank Calculation Rule',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '• The 1st EMI interest is prorated based on ${result.firstCycleDays} days between booking and first Payment Due Date (PDD).\n'
                '• Subsequent EMIs follow standard 30-day billing.\n'
                '• 18% GST is billed monthly on the interest portion of each EMI.\n'
                '• One-time processing fee is levied in your 1st credit card statement.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final textStyle = isBold
        ? theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.onSurface,
          )
        : theme.textTheme.bodyMedium?.copyWith(
            color: color ?? theme.colorScheme.onSurfaceVariant,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: textStyle)),
          Text(value, style: textStyle),
        ],
      ),
    );
  }
}
