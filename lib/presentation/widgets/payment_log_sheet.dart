import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../constants/app_strings.dart';
import '../../data/enums/payment_option.dart';
import '../../data/hive/models/payment_model.dart';
import '../../services/navigation_service.dart';
import '../providers/credit_card_provider.dart';
import '../providers/payment_provider.dart';

class LogPaymentBottomSheet extends ConsumerStatefulWidget {
  final PaymentModel payment;

  const LogPaymentBottomSheet({super.key, required this.payment});

  @override
  ConsumerState<LogPaymentBottomSheet> createState() =>
      _LogPaymentBottomSheetState();
}

class _LogPaymentBottomSheetState extends ConsumerState<LogPaymentBottomSheet> {
  PaymentOption _selectedOption = PaymentOption.totalDue;
  final TextEditingController _customAmountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  Future<PaymentModel?> _logPayment() async {
    if (_selectedOption == PaymentOption.custom &&
        !_formKey.currentState!.validate()) {
      return null;
    }

    setState(() => _isSubmitting = true);

    try {
      double amount;
      switch (_selectedOption) {
        case PaymentOption.totalDue:
          amount = widget.payment.dueAmount;
          break;
        case PaymentOption.minDue:
          amount = widget.payment.minimumDueAmount ?? widget.payment.dueAmount;
          break;
        case PaymentOption.custom:
          amount = double.parse(_customAmountController.text.trim());
          break;
      }

      await ref
          .read(paymentProvider.notifier)
          .markAsPaid(widget.payment.id, amount);

      final updatedPayment = widget.payment.copyWith(
        isPaid: true,
        paidAmount: amount,
        paymentDate: DateTime.now().toUtc(),
      );

      // Update the due date on Card.
      final card = await ref
          .read(creditCardBoxProvider)
          .values
          .firstWhere((c) => c.id == updatedPayment.cardId);

      final updatedCard = card.copyWith(
        dueDate: card.dueDate.add(const Duration(days: 30)),
        billingDate: card.billingDate.add(const Duration(days: 30)),
      );

      await ref.read(creditCardListProvider.notifier).save(updatedCard);

      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.paymentLoggedSuccess)),
      );
      return updatedPayment;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.paymentLogError}: $e')),
      );
      return null;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: AppStrings.logPayment,
                child: Text(
                  AppStrings.logPayment,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              RadioListTile<PaymentOption>(
                value: PaymentOption.totalDue,
                groupValue: _selectedOption,
                onChanged:
                    _isSubmitting
                        ? null
                        : (value) => setState(() => _selectedOption = value!),
                title: Text(
                  '${AppStrings.totalDue} (${currencyFormat.format(widget.payment.dueAmount)})',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (widget.payment.minimumDueAmount != null)
                RadioListTile<PaymentOption>(
                  value: PaymentOption.minDue,
                  groupValue: _selectedOption,
                  onChanged:
                      _isSubmitting
                          ? null
                          : (value) => setState(() => _selectedOption = value!),
                  title: Text(
                    '${AppStrings.minimumDue} (${currencyFormat.format(widget.payment.minimumDueAmount)})',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              RadioListTile<PaymentOption>(
                value: PaymentOption.custom,
                groupValue: _selectedOption,
                onChanged:
                    _isSubmitting
                        ? null
                        : (value) => setState(() => _selectedOption = value!),
                title: Text(
                  AppStrings.customAmount,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (_selectedOption == PaymentOption.custom)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextFormField(
                    controller: _customAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: AppStrings.customAmountLabel,
                    ),
                    validator: (value) {
                      final v = double.tryParse(value?.trim() ?? '');
                      if (v == null || v <= 0) {
                        return AppStrings.invalidCustomAmountError;
                      }
                      if (v > widget.payment.dueAmount) {
                        return AppStrings.amountExceedsDueError;
                      }
                      return null;
                    },
                  ),
                ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.receipt_long),
                  onPressed:
                      _isSubmitting
                          ? null
                          : () async {
                            final payment = await _logPayment();
                            if (payment != null) {
                              NavigationService.pop(context);
                            }
                          },
                  label:
                      _isSubmitting
                          ? const CircularProgressIndicator()
                          : Text(AppStrings.logPaymentButton),
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
