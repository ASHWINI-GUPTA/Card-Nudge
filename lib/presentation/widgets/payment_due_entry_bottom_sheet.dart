import 'package:card_nudge/data/hive/models/credit_card_model.dart';
import 'package:card_nudge/helper/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/hive/models/payment_model.dart';
import '../../services/navigation_service.dart';
import '../providers/credit_card_provider.dart';
import '../providers/payment_provider.dart';
import 'credit_card_color_dot_indicator.dart';

class PaymentDueEntryBottomSheet extends ConsumerStatefulWidget {
  final CreditCardModel card;
  final PaymentModel? payment;

  const PaymentDueEntryBottomSheet({
    super.key,
    required this.card,
    this.payment,
  });

  @override
  ConsumerState<PaymentDueEntryBottomSheet> createState() =>
      _PaymentDueEntryBottomSheet();
}

class _PaymentDueEntryBottomSheet
    extends ConsumerState<PaymentDueEntryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _dueAmountController = TextEditingController();
  final _minimumDueController = TextEditingController();
  bool _isNoPaymentDue = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Prefill controllers if editing
    if (widget.payment != null) {
      _dueAmountController.text = widget.payment!.dueAmount.toString();
      if (widget.payment!.minimumDueAmount != null) {
        _minimumDueController.text =
            widget.payment!.minimumDueAmount.toString();
      }
    }
  }

  @override
  void dispose() {
    _dueAmountController.dispose();
    _minimumDueController.dispose();
    super.dispose();
  }

  Future<PaymentModel?> _submit() async {
    if (!_formKey.currentState!.validate()) return null;

    setState(() => _isSubmitting = true);

    try {
      final dueAmount = double.parse(_dueAmountController.text.trim());
      final minimumDueAmount =
          _minimumDueController.text.trim().isEmpty
              ? null
              : double.parse(_minimumDueController.text.trim());

      // UPDATED: Use card's synced dueDate for payment
      final paymentDueDate = widget.card.getNextDueDate;

      var payment = PaymentModel(
        id: widget.payment?.id,
        userId: widget.card.userId,
        cardId: widget.card.id,
        dueAmount: dueAmount,
        minimumDueAmount: minimumDueAmount,
        dueDate: paymentDueDate,
        statementAmount: dueAmount,
        isPaid: false,
        paymentDate: null,
        paidAmount: 0.0,
        syncPending: true,
      );

      await ref.read(paymentProvider.notifier).save(payment);

      // NEW: Sync card dates if this is the first unpaid payment (but don't advance yet; wait for pay)
      final payments = ref.read(paymentBoxProvider);
      final unpaidExists = payments.values.any(
        (p) => p.cardId == widget.card.id && !p.isPaid && p.id != payment.id,
      );
      if (!unpaidExists) {
        // Ensure card.dueDate matches payment dueDate
        final updatedCard = widget.card.copyWith(dueDate: paymentDueDate);
        await ref.read(creditCardProvider.notifier).save(updatedCard);
      }

      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.payment == null
                ? context.l10n.paymentAddedSuccess
                : context.l10n.paymentUpdatedSuccess,
          ),
        ),
      );
      return payment;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.l10n.paymentAddError}: $e')),
      );
      return null;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleNoPaymentDue() async {
    setState(() => _isSubmitting = true);

    try {
      final payments = ref.read(paymentBoxProvider);
      final unpaidExists = payments.values.any(
        (p) => p.cardId == widget.card.id && !p.isPaid,
      );
      if (unpaidExists) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.dueAlreadyExist)));
        }
        NavigationService.pop(context);
        return;
      }

      // UPDATED: Create no-due payment with synced dates
      final payment = PaymentModel(
        userId: widget.card.userId,
        cardId: widget.card.id,
        dueAmount: 0.0,
        minimumDueAmount: 0.0,
        dueDate: widget.card.getNextDueDate, // Synced
        statementAmount: 0.0,
        isPaid: true,
        paymentDate: DateTime.now().toUtc(),
        paidAmount: 0.0,
        syncPending: true,
      );

      await ref.read(paymentProvider.notifier).save(payment);

      // UPDATED: Use centralized advance
      final updatedCard = widget.card.advanceToNextCycle();
      await ref.read(creditCardProvider.notifier).save(updatedCard);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.noDuePaymentAddedSuccess)),
      );

      NavigationService.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating due date: $e')));
      }
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
            Semantics(
              label:
                  widget.payment == null
                      ? context.l10n.addPaymentDue
                      : context.l10n.editPaymentDue,
              child: Text(
                widget.payment == null
                    ? context.l10n.addPaymentDue
                    : context.l10n.editPaymentDue,
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
                    decoration: InputDecoration(
                      labelText: context.l10n.dueAmountLabel,
                    ),
                    enabled: !_isNoPaymentDue,
                    validator: (val) {
                      if (_isNoPaymentDue) return null;
                      final v = double.tryParse(val?.trim() ?? '');
                      if (v == null || v <= 0) {
                        return context.l10n.invalidAmountError;
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
                    decoration: InputDecoration(
                      labelText: context.l10n.minimumDueLabel,
                    ),
                    enabled: !_isNoPaymentDue,
                    validator: (val) {
                      if (_isNoPaymentDue || (val?.trim().isEmpty ?? true)) {
                        return null;
                      }
                      final v = double.tryParse(val!.trim());
                      if (v == null || v <= 0) {
                        return context.l10n.invalidAmountError;
                      }
                      final dueAmount = double.tryParse(
                        _dueAmountController.text.trim(),
                      );
                      if (dueAmount != null && v > dueAmount) {
                        return context.l10n.minimumDueExceedsError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.l10n.editDueDateOnCard)),
                      );
                    },
                    key: const ValueKey('payment_date_picker'),
                    enabled: false,
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.dueDateLabel),
                    subtitle: Text(
                      DateFormat.yMMMd().format(widget.card.getNextDueDate),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: const Icon(Icons.calendar_today),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            context.l10n.editDueDateOnCard,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // No Payment Due Checkbox
                  CheckboxListTile(
                    title: Text(context.l10n.noPaymentDue),
                    contentPadding: EdgeInsets.zero,
                    value: _isNoPaymentDue,
                    onChanged: (value) {
                      setState(() => _isNoPaymentDue = value ?? false);
                    },
                  ),
                  const SizedBox(height: 20),
                  // Add Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          _isSubmitting
                              ? null
                              : () async {
                                if (_isNoPaymentDue) {
                                  await _handleNoPaymentDue();
                                } else {
                                  final payment = await _submit();
                                  if (payment != null) {
                                    NavigationService.pop(context);
                                  }
                                }
                              },
                      icon: _isSubmitting ? null : const Icon(Icons.add),
                      label:
                          _isSubmitting
                              ? const CreditCardColorDotIndicator()
                              : Text(
                                _isNoPaymentDue
                                    ? 'Confirm No Payment Due'
                                    : context.l10n.addDueButton,
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
