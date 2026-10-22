import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/credit_card_provider.dart';
import '../providers/emi_calculator_provider.dart';
import '../providers/format_provider.dart';
import '../widgets/emi_result_summary_card.dart';
import '../widgets/emi_amortization_table.dart';
import '../widgets/emi_foreclosure_sheet.dart';

class EmiCalculatorScreen extends ConsumerStatefulWidget {
  final String? initialCardId;

  const EmiCalculatorScreen({super.key, this.initialCardId});

  @override
  ConsumerState<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends ConsumerState<EmiCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _amountController;
  late TextEditingController _discountController;
  late TextEditingController _rateController;
  late TextEditingController _processingFeeController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final emiState = ref.read(emiCalculatorProvider);
    _amountController = TextEditingController(
      text: emiState.productAmount > 0 ? emiState.productAmount.toStringAsFixed(2) : '',
    );
    _discountController = TextEditingController(
      text: emiState.instantBankDiscount > 0 ? emiState.instantBankDiscount.toStringAsFixed(2) : '0',
    );
    _rateController = TextEditingController(
      text: emiState.annualInterestRate.toStringAsFixed(2),
    );
    _processingFeeController = TextEditingController(
      text: emiState.processingFee > 0 ? emiState.processingFee.toStringAsFixed(2) : '0',
    );

    if (widget.initialCardId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(emiCalculatorProvider.notifier).selectCard(widget.initialCardId);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _discountController.dispose();
    _rateController.dispose();
    _processingFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emiState = ref.watch(emiCalculatorProvider);
    final emiNotifier = ref.read(emiCalculatorProvider.notifier);
    final cardsAsync = ref.watch(creditCardProvider);
    final formatHelper = ref.watch(formatHelperProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EMI & No-Cost EMI Calculator'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card Selection Card
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
                      Icon(Icons.credit_card, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Select Card for Statement & Due Dates',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  cardsAsync.when(
                    data: (cards) {
                      final activeCards = cards.where((c) => !c.isArchived).toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String?>(
                            value: emiState.selectedCardId,
                            decoration: InputDecoration(
                              labelText: 'Credit Card',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            items: [
                              ...activeCards.map(
                                (card) => DropdownMenuItem<String?>(
                                  value: card.id,
                                  child: Text(
                                    '${card.name} (••${card.last4Digits})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Custom / Other Card'),
                              ),
                            ],
                            onChanged: (cardId) {
                              emiNotifier.selectCard(cardId);
                            },
                          ),
                          const SizedBox(height: 8),
                          if (emiState.selectedCardId != null) ...[
                            Builder(
                              builder: (context) {
                                final card = activeCards
                                    .where((c) => c.id == emiState.selectedCardId)
                                    .firstOrNull;
                                if (card == null) return const SizedBox.shrink();
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.event, size: 16, color: theme.colorScheme.primary),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Statement Date: ${card.billingDate.day}th of month • Grace Period: ${card.dueGracePeriodDays} days',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: emiState.customBillingStatementDay.toString(),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Billing Day (1-28)',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    ),
                                    onChanged: (val) {
                                      final day = int.tryParse(val);
                                      if (day != null && day >= 1 && day <= 28) {
                                        emiNotifier.updateBillingStatementDay(day);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: emiState.customGracePeriodDays.toString(),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Grace Days',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    ),
                                    onChanged: (val) {
                                      final days = int.tryParse(val);
                                      if (days != null && days > 0) {
                                        emiNotifier.updateGracePeriod(days);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Loan & Purchase Parameters Card
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
                      Icon(Icons.shopping_bag_outlined, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Purchase Details',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Product Price Input
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Product / Purchase Amount',
                      prefixText: '${formatHelper.formatCurrency(0, decimalDigits: 0).replaceAll('0', '')} ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    onChanged: (val) {
                      final amount = double.tryParse(val) ?? 0.0;
                      emiNotifier.updateProductAmount(amount);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Instant Bank Discount Input
                  TextFormField(
                    controller: _discountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Instant Bank Discount (Optional)',
                      hintText: 'e.g. 3000',
                      prefixText: '${formatHelper.formatCurrency(0, decimalDigits: 0).replaceAll('0', '')} ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    onChanged: (val) {
                      final discount = double.tryParse(val) ?? 0.0;
                      emiNotifier.updateInstantDiscount(discount);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Interest Rate & Booking Date row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _rateController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Bank Interest (% p.a.)',
                            suffixText: '%',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                          onChanged: (val) {
                            final rate = double.tryParse(val) ?? 0.0;
                            emiNotifier.updateInterestRate(rate);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: emiState.bookingDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              emiNotifier.updateBookingDate(picked);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Booking Date',
                              suffixIcon: const Icon(Icons.calendar_today, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                            child: Text(
                              formatHelper.formatDate(emiState.bookingDate, format: 'dd MMM yyyy'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tenure Selector
                  Text('Tenure (Months)', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [3, 6, 9, 12, 18, 24].map((tenure) {
                      final isSelected = emiState.tenureMonths == tenure;
                      return ChoiceChip(
                        label: Text('$tenure Months'),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) emiNotifier.updateTenure(tenure);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Processing fee input
                  TextFormField(
                    controller: _processingFeeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Bank Processing Fee',
                      hintText: 'e.g. 169 or 199',
                      prefixText: '${formatHelper.formatCurrency(0, decimalDigits: 0).replaceAll('0', '')} ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    onChanged: (val) {
                      final fee = double.tryParse(val) ?? 0.0;
                      emiNotifier.updateProcessingFee(fee);
                    },
                  ),

                  const Divider(height: 24),

                  // Switch options
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('No-Cost EMI', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Merchant gives upfront discount equal to the bank interest'),
                    value: emiState.isNoCostEmi,
                    onChanged: (val) => emiNotifier.toggleNoCostEmi(val),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Credit Card Transaction', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Levies 18% GST on interest & processing fee per Indian tax laws'),
                    value: emiState.isCreditCard,
                    onChanged: (val) => emiNotifier.toggleCreditCard(val),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Output Tabs
          if (emiState.result != null) ...[
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                tabs: const [
                  Tab(icon: Icon(Icons.summarize_outlined), text: 'Summary'),
                  Tab(icon: Icon(Icons.table_chart_outlined), text: 'Schedule'),
                  Tab(icon: Icon(Icons.lock_clock_outlined), text: 'Foreclose'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                switch (_tabController.index) {
                  case 0:
                    return EmiResultSummaryCard(result: emiState.result!);
                  case 1:
                    return EmiAmortizationTable(
                      schedule: emiState.result!.schedule,
                      isCreditCard: emiState.result!.isCreditCard,
                    );
                  case 2:
                    return EmiForeclosureCard(
                      emiResult: emiState.result!,
                      bookingDate: emiState.bookingDate,
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
