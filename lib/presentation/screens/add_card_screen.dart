import 'package:card_nudge/data/hive/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';
import '../../constants/app_strings.dart';
import '../../data/enums/card_type.dart';
import '../../data/hive/models/credit_card_model.dart';
import '../../services/navigation_service.dart';
import '../providers/credit_card_provider.dart';
import '../providers/bank_provider.dart';

class AddCardScreen extends ConsumerStatefulWidget {
  final CreditCardModel? card;
  final UserModel user;

  const AddCardScreen({super.key, required this.user, this.card});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cardNameController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _cardTypeController;
  late final TextEditingController _last4DigitsController;
  late final TextEditingController _limitController;
  DateTime? _billingDate;
  DateTime? _dueDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final card = widget.card;
    _cardNameController = TextEditingController(text: card?.name ?? '');
    _bankNameController = TextEditingController(text: card?.bankId ?? '');
    _cardTypeController = TextEditingController(
      text: card?.cardType.name ?? '',
    );
    _last4DigitsController = TextEditingController(
      text: card?.last4Digits ?? '',
    );
    _limitController = TextEditingController(
      text: card?.creditLimit.toString() ?? '',
    );
    _billingDate = card?.billingDate;
    _dueDate = card?.dueDate;
  }

  Future<CreditCardModel?> _saveCard() async {
    if (_formKey.currentState?.validate() != true ||
        _billingDate == null ||
        _dueDate == null) {
      if (_billingDate == null || _dueDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.selectDatesError)),
        );
      }
      return null;
    }

    // Validate due date is after billing date
    if (_dueDate!.isBefore(_billingDate!) ||
        _dueDate!.isAtSameMomentAs(_billingDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.dueDateBeforeBillingError)),
      );
      return null;
    }

    setState(() => _isSubmitting = true);

    try {
      final cardType = CardType.values.firstWhere(
        (type) => type.name == _cardTypeController.text.trim(),
        orElse: () => CardType.Visa,
      );

      final updatedCard = CreditCardModel(
        id: widget.card?.id,
        userId: widget.user.id,
        name: _cardNameController.text.trim(),
        bankId: _bankNameController.text.trim(),
        last4Digits: _last4DigitsController.text.trim(),
        billingDate: _billingDate!,
        dueDate: _dueDate!,
        creditLimit: double.parse(_limitController.text.trim()),
        currentUtilization: widget.card?.currentUtilization ?? 0.0,
        cardType: cardType,
      );

      await ref.read(creditCardListProvider.notifier).save(updatedCard);

      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.card == null
                ? AppStrings.cardAddedSuccess
                : AppStrings.cardUpdatedSuccess,
          ),
        ),
      );
      return updatedCard;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.cardSaveError}: $e')),
      );
      return null;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickDate(BuildContext context, bool isBilling) async {
    final now = DateTime.now();
    final DateTime firstDate;
    final DateTime? initialDate;

    if (isBilling) {
      firstDate = DateTime(2020);
      initialDate = _billingDate ?? now;
    } else {
      // Due date: firstDate is day after billingDate or now
      firstDate =
          _billingDate != null
              ? _billingDate!.add(const Duration(days: 1))
              : now;
      initialDate = _dueDate ?? firstDate;
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (selected != null && mounted) {
      setState(() {
        if (isBilling) {
          _billingDate = selected;
          // Reset dueDate if it's not after the new billingDate
          if (_dueDate != null &&
              (_dueDate!.isBefore(selected) ||
                  _dueDate!.isAtSameMomentAs(selected))) {
            _dueDate = null;
          }
        } else {
          _dueDate = selected;
        }
      });
    }
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    _bankNameController.dispose();
    _cardTypeController.dispose();
    _last4DigitsController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const spacing = SizedBox(height: 12);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.card == null
              ? AppStrings.addCardScreenTitle
              : AppStrings.updateCardScreenTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _cardNameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.cardNameLabel,
                ),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? AppStrings.validationRequired
                            : null,
              ),
              spacing,
              DropdownButtonFormField<String>(
                value:
                    _bankNameController.text.isNotEmpty
                        ? _bankNameController.text
                        : null,
                decoration: const InputDecoration(
                  labelText: AppStrings.bankLabel,
                ),
                items: ref
                    .watch(bankProvider)
                    .when(
                      data:
                          (banks) =>
                              banks.map((bank) {
                                return DropdownMenuItem<String>(
                                  value: bank.id,
                                  child: Row(
                                    children: [
                                      Semantics(
                                        label:
                                            '${AppStrings.bankLogo} ${bank.name}',
                                        child:
                                            bank.logoPath != null
                                                ? SvgPicture.asset(
                                                  bank.logoPath!,
                                                  width: 20,
                                                  placeholderBuilder:
                                                      (_) => const Icon(
                                                        Icons.account_balance,
                                                        size: 20,
                                                      ),
                                                )
                                                : const Icon(
                                                  Icons.account_balance,
                                                  size: 20,
                                                ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(bank.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                      loading:
                          () => [
                            const DropdownMenuItem<String>(
                              enabled: false,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ],
                      error:
                          (error, stack) => [
                            DropdownMenuItem<String>(
                              enabled: false,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${AppStrings.bankDetailsLoadError}: $error',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                    ),
                onChanged:
                    _isSubmitting
                        ? null
                        : (value) {
                          setState(() {
                            _bankNameController.text = value ?? '';
                          });
                        },
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? AppStrings.validationRequired
                            : null,
              ),
              spacing,
              DropdownButtonFormField<String>(
                value:
                    _cardTypeController.text.isNotEmpty
                        ? _cardTypeController.text
                        : null,
                decoration: const InputDecoration(
                  labelText: AppStrings.networkLabel,
                ),
                items:
                    CardType.values.map((type) {
                      return DropdownMenuItem<String>(
                        value: type.name,
                        child: Text(type.name),
                      );
                    }).toList(),
                onChanged:
                    _isSubmitting
                        ? null
                        : (value) {
                          setState(() {
                            _cardTypeController.text = value ?? '';
                          });
                        },
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? AppStrings.validationRequired
                            : null,
              ),
              spacing,
              TextFormField(
                controller: _last4DigitsController,
                decoration: const InputDecoration(
                  labelText: AppStrings.last4DigitsLabel,
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator:
                    (v) =>
                        v == null || v.length != 4
                            ? AppStrings.last4DigitsError
                            : null,
              ),
              spacing,
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _billingDate == null
                            ? AppStrings.billingDateLabel
                            : '${AppStrings.billingDateLabel}: ${_billingDate!.day}/${_billingDate!.month}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      onPressed:
                          _isSubmitting ? null : () => _pickDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.event),
                      label: Text(
                        _dueDate == null
                            ? AppStrings.dueDateLabel
                            : '${AppStrings.dueDateLabel}: ${_dueDate!.day}/${_dueDate!.month}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      onPressed:
                          _isSubmitting
                              ? null
                              : () => _pickDate(context, false),
                    ),
                  ),
                ],
              ),
              spacing,
              TextFormField(
                controller: _limitController,
                decoration: const InputDecoration(
                  labelText: AppStrings.creditLimitLabel,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (v) {
                  final value = double.tryParse(v?.trim() ?? '');
                  return value == null || value <= 0
                      ? AppStrings.invalidCreditLimitError
                      : null;
                },
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed:
                    _isSubmitting
                        ? null
                        : () async {
                          final card = await _saveCard();
                          if (card != null) {
                            NavigationService.pop(context);
                          }
                        },
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator()
                        : Text(AppStrings.saveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
