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

class PaymentHistoryBottomSheet extends ConsumerWidget {
  final PaymentModel payment;

  const PaymentHistoryBottomSheet({super.key, required this.payment});

  Future<void> _logPayment(WidgetRef ref, BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final customAmountController = TextEditingController();

    final selectedOption = ref.read(selectedOptionProvider);
    if (selectedOption == PaymentOption.custom &&
        !formKey.currentState!.validate()) {
      return null;
    }

    ref.read(isSubmittingProvider.notifier).state = true;

    try {
      double amount;
      switch (selectedOption) {
        case PaymentOption.totalDue:
          amount = payment.dueAmount;
          break;
        case PaymentOption.minDue:
          amount = payment.minimumDueAmount ?? payment.dueAmount;
          break;
        case PaymentOption.custom:
          amount = double.parse(customAmountController.text.trim());
          break;
      }

      await ref.read(paymentProvider.notifier).markAsPaid(payment.id, amount);

      // Update the due date on Card.
      final card = await ref
          .read(creditCardBoxProvider)
          .values
          .firstWhere((c) => c.id == payment.cardId);

      final updatedCard = card.copyWith(
        dueDate: card.getNextDueDate,
        syncPending: true,
      );

      await ref.read(creditCardProvider.notifier).save(updatedCard);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.paymentLoggedSuccess)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.l10n.paymentLogError}: $e')),
      );
      return null;
    } finally {
      ref.read(isSubmittingProvider.notifier).state = false;
      customAmountController.dispose();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatHelper = ref.watch(formatHelperProvider);

    final selectedOption = ref.watch(selectedOptionProvider);
    final isSubmitting = ref.watch(isSubmittingProvider);
    final formKey = GlobalKey<FormState>();
    final customAmountController = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: context.l10n.logPayment,
                child: Text(
                  context.l10n.logPayment,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              RadioListTile<PaymentOption>(
                value: PaymentOption.totalDue,
                groupValue: selectedOption,
                onChanged:
                    isSubmitting
                        ? null
                        : (value) =>
                            ref.read(selectedOptionProvider.notifier).state =
                                value!,
                title: Text(
                  '${context.l10n.totalDue} (${formatHelper.formatCurrency(payment.dueAmount, decimalDigits: 2)})',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (payment.minimumDueAmount != null)
                RadioListTile<PaymentOption>(
                  value: PaymentOption.minDue,
                  groupValue: selectedOption,
                  onChanged:
                      isSubmitting
                          ? null
                          : (value) =>
                              ref.read(selectedOptionProvider.notifier).state =
                                  value!,
                  title: Text(
                    '${context.l10n.minimumDue} (${formatHelper.formatCurrency(payment.minimumDueAmount!, decimalDigits: 2)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              RadioListTile<PaymentOption>(
                value: PaymentOption.custom,
                groupValue: selectedOption,
                onChanged:
                    isSubmitting
                        ? null
                        : (value) =>
                            ref.read(selectedOptionProvider.notifier).state =
                                value!,
                title: Text(
                  context.l10n.customAmount,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (selectedOption == PaymentOption.custom)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    ),
                    validator: (value) {
                      final v = double.tryParse(value?.trim() ?? '');
                      if (v == null || v <= 0) {
                        return context.l10n.invalidCustomAmountError;
                      }
                      if (v > payment.dueAmount) {
                        return context.l10n.amountExceedsDueError;
                      }
                      return null;
                    },
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: isSubmitting ? null : const Icon(Icons.receipt_long),
                  onPressed:
                      isSubmitting
                          ? null
                          : () async {
                            await _logPayment(ref, context);
                            NavigationService.pop(context);
                          },
                  label:
                      isSubmitting
                          ? const CreditCardColorDotIndicator()
                          : Text(context.l10n.logPaymentButton),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
