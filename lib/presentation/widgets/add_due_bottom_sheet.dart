import 'package:card_nudge/data/hive/models/credit_card_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/app_strings.dart';
import '../../data/hive/models/payment_model.dart';
import '../../services/navigation_service.dart';
import '../providers/payment_provider.dart';

class AddDueBottomSheet extends ConsumerStatefulWidget {
  final CreditCardModel card;

  const AddDueBottomSheet({super.key, required this.card});

  @override
  ConsumerState<AddDueBottomSheet> createState() => _AddDueBottomSheetState();
}

class _AddDueBottomSheetState extends ConsumerState<AddDueBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _dueAmountController = TextEditingController();
  final _minimumDueController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _dueAmountController.dispose();
    _minimumDueController.dispose();
    super.dispose();
  }

  Future<PaymentModel?> _submit() async {
    setState(() => _isSubmitting = true);

    try {
      final dueAmount = double.parse(_dueAmountController.text.trim());
      final minimumDue =
          _minimumDueController.text.trim().isNotEmpty
              ? double.tryParse(_minimumDueController.text.trim())
              : null;

      final payment = PaymentModel(
        cardId: widget.card.id,
        dueAmount: dueAmount,
        minimumDueAmount: minimumDue,
        dueDate: widget.card.dueDate,
      );

      await ref.read(paymentProvider.notifier).save(payment);

      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.paymentAddedSuccess)),
      );
      return payment;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.paymentAddError}: $e')),
      );
      return null;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: AppStrings.createPaymentDue,
              child: Text(
                AppStrings.createPaymentDue,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Total Due
                  TextFormField(
                    controller: _dueAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: AppStrings.dueAmountLabel,
                    ),
                    validator: (val) {
                      final v = double.tryParse(val?.trim() ?? '');
                      if (v == null || v <= 0) {
                        return AppStrings.invalidAmountError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // Minimum Due
                  TextFormField(
                    controller: _minimumDueController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: AppStrings.minimumDueLabel,
                    ),
                    validator: (val) {
                      if (val?.trim().isEmpty ?? true) return null;
                      final v = double.tryParse(val!.trim());
                      if (v == null || v <= 0) {
                        return AppStrings.invalidAmountError;
                      }
                      final dueAmount = double.tryParse(
                        _dueAmountController.text.trim(),
                      );
                      if (dueAmount != null && v > dueAmount) {
                        return AppStrings.minimumDueExceedsError;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  ListTile(
                    onTap: () {
                      const SnackBar(
                        content: Text(AppStrings.editDueDateOnCard),
                      );
                    },
                    key: const ValueKey('payment_date_picker'),
                    enabled: false,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(AppStrings.dueDateLabel),
                    subtitle: Text(
                      DateFormat.yMMMd().format(widget.card.dueDate!),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: const Icon(Icons.calendar_today),
                  ),

                  const SizedBox(height: 20),

                  // Add Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isSubmitting
                              ? null
                              : () async {
                                final payment = await _submit();
                                if (payment != null) {
                                  NavigationService.pop(context);
                                }
                              },
                      icon: const Icon(Icons.add),
                      label:
                          _isSubmitting
                              ? const CircularProgressIndicator()
                              : Text(
                                AppStrings.createDueButton,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
