import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/emi_calculation_model.dart';
import '../../helper/emi_calculator.dart';
import '../providers/format_provider.dart';

class EmiForeclosureCard extends ConsumerStatefulWidget {
  final EmiResult emiResult;
  final DateTime bookingDate;

  const EmiForeclosureCard({
    super.key,
    required this.emiResult,
    required this.bookingDate,
  });

  @override
  ConsumerState<EmiForeclosureCard> createState() => _EmiForeclosureCardState();
}

class _EmiForeclosureCardState extends ConsumerState<EmiForeclosureCard> {
  late DateTime _foreclosureDate;

  @override
  void initState() {
    super.initState();
    // Default to middle of 1st cycle or after 1st EMI
    if (widget.emiResult.schedule.isNotEmpty) {
      _foreclosureDate = widget.emiResult.schedule.first.dueDate.add(const Duration(days: 5));
    } else {
      _foreclosureDate = widget.bookingDate.add(const Duration(days: 35));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatHelper = ref.watch(formatHelperProvider);

    final foreclosure = EmiCalculator.calculateForeclosure(
      emiResult: widget.emiResult,
      foreclosureDate: _foreclosureDate,
      bookingDate: widget.bookingDate,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_reset_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Foreclosure Simulator',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Simulate early loan closure charges according to SBI Card / Bank Merchant EMI rules (3% fee + GST + pro-rata daily interest adjustment).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 20),

            // Date picker row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Closure Request Date:'),
                OutlinedButton.icon(
                  icon: const Icon(Icons.event, size: 18),
                  label: Text(formatHelper.formatDate(_foreclosureDate, format: 'dd MMM yyyy')),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _foreclosureDate,
                      firstDate: widget.bookingDate,
                      lastDate: widget.emiResult.schedule.isNotEmpty
                          ? widget.emiResult.schedule.last.dueDate.add(const Duration(days: 30))
                          : widget.bookingDate.add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _foreclosureDate = picked);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Breakdown
            _buildRow('Outstanding Principal', formatHelper.formatCurrency(foreclosure.outstandingPrincipal)),
            _buildRow(
              'Foreclosure Fee (${foreclosure.foreclosureFeeRate}%)',
              formatHelper.formatCurrency(foreclosure.foreclosureFee),
            ),
            _buildRow(
              '18% GST on Foreclosure Fee',
              formatHelper.formatCurrency(foreclosure.gstOnForeclosureFee),
            ),
            _buildRow(
              foreclosure.isInterestDebit ? 'Pro-Rata Interest (Debit)' : 'Pro-Rata Interest (Credit)',
              '${foreclosure.isInterestDebit ? "+" : "-"}${formatHelper.formatCurrency(foreclosure.interestAdjustment)}',
              color: foreclosure.isInterestDebit ? Colors.red.shade700 : Colors.green.shade700,
            ),

            const Divider(height: 16),
            _buildRow(
              'Total Settlement Amount',
              formatHelper.formatCurrency(foreclosure.totalPayableToClose),
              isBold: true,
              color: theme.colorScheme.primary,
            ),

            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                foreclosure.calculationNotes,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? color}) {
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
      padding: const EdgeInsets.symmetric(vertical: 3),
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
