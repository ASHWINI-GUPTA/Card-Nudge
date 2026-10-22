import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/emi_calculation_model.dart';
import '../providers/format_provider.dart';

class EmiAmortizationTable extends ConsumerWidget {
  final List<AmortizationEntry> schedule;
  final bool isCreditCard;

  const EmiAmortizationTable({
    super.key,
    required this.schedule,
    required this.isCreditCard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatHelper = ref.watch(formatHelperProvider);
    final isDark = theme.brightness == Brightness.dark;

    if (schedule.isEmpty) {
      return const SizedBox.shrink();
    }

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
                Icon(Icons.calendar_month_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Amortization Schedule',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '*MRA (Monthly Repayment Amount) excludes taxes. Taxes reflect 18% GST billed in statement.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                horizontalMargin: 8,
                headingRowColor: WidgetStateProperty.all(
                  theme.colorScheme.primary.withAlpha(isDark ? 40 : 20),
                ),
                columns: [
                  const DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                  const DataColumn(label: Text('Statement Date', style: TextStyle(fontWeight: FontWeight.bold))),
                  const DataColumn(label: Text('MRA (EMI)', style: TextStyle(fontWeight: FontWeight.bold))),
                  const DataColumn(label: Text('Principal', style: TextStyle(fontWeight: FontWeight.bold))),
                  const DataColumn(label: Text('Interest', style: TextStyle(fontWeight: FontWeight.bold))),
                  const DataColumn(label: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold))),
                  if (isCreditCard)
                    const DataColumn(label: Text('Taxes (18%)', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: schedule.map((entry) {
                  final isFirstMonth = entry.monthNumber == 1;
                  return DataRow(
                    color: isFirstMonth && entry.daysInCycle != 30
                        ? WidgetStateProperty.all(
                            theme.colorScheme.tertiary.withAlpha(isDark ? 30 : 15),
                          )
                        : null,
                    cells: [
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${entry.monthNumber}',
                              style: TextStyle(
                                fontWeight: isFirstMonth ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (isFirstMonth && entry.daysInCycle != 30)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Tooltip(
                                  message: 'Adjusted for ${entry.daysInCycle} days',
                                  child: Icon(Icons.info_outline, size: 14, color: theme.colorScheme.tertiary),
                                ),
                              ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          formatHelper.formatDate(entry.billingDate, format: 'dd/MM/yyyy'),
                        ),
                      ),
                      DataCell(
                        Text(
                          formatHelper.formatCurrency(entry.emiAmount),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataCell(Text(formatHelper.formatCurrency(entry.principalAmount))),
                      DataCell(
                        Text(
                          formatHelper.formatCurrency(entry.interestAmount),
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      DataCell(Text(formatHelper.formatCurrency(entry.balancePrincipal))),
                      if (isCreditCard)
                        DataCell(
                          Text(
                            formatHelper.formatCurrency(entry.gstTax),
                            style: TextStyle(color: Colors.amber.shade900),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
