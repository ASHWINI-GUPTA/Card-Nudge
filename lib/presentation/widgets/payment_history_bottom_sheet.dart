import 'package:card_nudge/helper/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../data/enums/payment_option.dart';
import '../../data/hive/models/payment_model.dart';
import '../../services/navigation_service.dart';
import '../providers/credit_card_provider.dart';
import '../providers/format_provider.dart';
import '../providers/payment_provider.dart';
import 'credit_card_color_dot_indicator.dart';

final selectedOptionProvider = StateProvider<PaymentOption>(
  (ref) => PaymentOption.totalDue,
);

final isSubmittingProvider = StateProvider<bool>((ref) => false);

class PaymentHistoryBottomSheet extends ConsumerStatefulWidget {
  final PaymentModel payment;

  const PaymentHistoryBottomSheet({super.key, required this.payment});

  @override
  ConsumerState<PaymentHistoryBottomSheet> createState() =>
      _PaymentHistoryBottomSheetState();
}

class _PaymentHistoryBottomSheetState
    extends ConsumerState<PaymentHistoryBottomSheet> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController customAmountController;
  late FocusNode customAmountFocusNode;

  @override
  void initState() {
    super.initState();
    customAmountController = TextEditingController();
    customAmountFocusNode = FocusNode();
  }

  @override
  void dispose() {
    customAmountController.dispose();
    customAmountFocusNode.dispose();
    super.dispose();
  }

  void _onOptionChanged(PaymentOption? value) {
    if (value == null) return;

    ref.read(selectedOptionProvider.notifier).state = value;

    if (value == PaymentOption.custom) {
      // Delay to ensure the field is built before focusing
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(customAmountFocusNode);
        }
      });
    }
  }

  Future<void> _logPayment(BuildContext context) async {
    final selectedOption = ref.read(selectedOptionProvider);

    if (selectedOption == PaymentOption.custom &&
        !formKey.currentState!.validate()) {
      return;
    }

    ref.read(isSubmittingProvider.notifier).state = true;

    try {
      double amount;
      switch (selectedOption) {
        case PaymentOption.totalDue:
          amount = widget.payment.dueAmount;
          break;
        case PaymentOption.minDue:
          amount = widget.payment.minimumDueAmount ?? widget.payment.dueAmount;
          break;
        case PaymentOption.custom:
          amount = double.parse(customAmountController.text.trim());
          break;
      }

      final wasUnpaid = !widget.payment.isPaid;
      await ref
          .read(paymentProvider.notifier)
          .markAsPaid(widget.payment.id, amount);

      if (wasUnpaid && amount >= widget.payment.statementAmount) {
        final cardBox = ref.read(creditCardBoxProvider);
        final card = cardBox.values.firstWhere(
          (c) => c.id == widget.payment.cardId,
        );

        final updatedCard = card.advanceToNextCycle();
        await ref.read(creditCardProvider.notifier).save(updatedCard);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.paymentLoggedSuccess)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.l10n.paymentLogError}: $e')),
        );
      }
    } finally {
      ref.read(isSubmittingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatHelper = ref.watch(formatHelperProvider);
    final selectedOption = ref.watch(selectedOptionProvider);
    final isSubmitting = ref.watch(isSubmittingProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 12,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
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

              // Title
              Text(
                context.l10n.logPayment,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Radio options in a Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    RadioListTile<PaymentOption>(
                      value: PaymentOption.totalDue,
                      groupValue: selectedOption,
                      onChanged: isSubmitting ? null : _onOptionChanged,
                      title: Text(
                        '${context.l10n.totalDue}: ${formatHelper.formatCurrency(widget.payment.dueAmount, decimalDigits: 2)}',
                      ),
                    ),
                    if (widget.payment.minimumDueAmount != null)
                      RadioListTile<PaymentOption>(
                        value: PaymentOption.minDue,
                        groupValue: selectedOption,
                        onChanged: isSubmitting ? null : _onOptionChanged,
                        title: Text(
                          '${context.l10n.minimumDue}: ${formatHelper.formatCurrency(widget.payment.minimumDueAmount!, decimalDigits: 2)}',
                        ),
                      ),
                    RadioListTile<PaymentOption>(
                      value: PaymentOption.custom,
                      groupValue: selectedOption,
                      onChanged: isSubmitting ? null : _onOptionChanged,
                      title: Text(context.l10n.customAmount),
                    ),
                  ],
                ),
              ),

              // Custom Amount Field (animated in/out)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    selectedOption == PaymentOption.custom
                        ? Padding(
                          key: const ValueKey('customField'),
                          padding: const EdgeInsets.only(top: 12),
                          child: TextFormField(
                            controller: customAmountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: context.l10n.customAmountLabel,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return context.l10n.customAmountRequiredError;
                              }

                              final v = double.tryParse(value.trim());
                              if (v == null || v <= 0) {
                                return context.l10n.invalidCustomAmountError;
                              }
                              if (v > widget.payment.dueAmount) {
                                return context.l10n.amountExceedsDueError;
                              }
                              return null;
                            },
                          ),
                        )
                        : const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.receipt_long),
                  onPressed:
                      isSubmitting
                          ? null
                          : () async {
                            await _logPayment(context);
                            NavigationService.pop(context);
                          },
                  label:
                      isSubmitting
                          ? const CreditCardColorDotIndicator()
                          : Text(context.l10n.logPaymentButton),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel button
              TextButton(
                onPressed: () => NavigationService.pop(context),
                child: Text(
                  context.l10n.cancel,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
