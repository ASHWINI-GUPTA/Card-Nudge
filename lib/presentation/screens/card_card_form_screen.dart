import 'package:card_nudge/helper/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';

import '../../data/enums/card_type.dart';
import '../../data/hive/models/credit_card_model.dart';
import '../../data/hive/models/user_model.dart';
import '../../services/navigation_service.dart';
import '../providers/credit_card_provider.dart';
import '../providers/bank_provider.dart';
import '../widgets/credit_card_color_dot_indicator.dart';
import 'loading_screen.dart';

class CreditCardFormScreen extends ConsumerStatefulWidget {
  final CreditCardModel? card;
  final UserModel user;

  const CreditCardFormScreen({super.key, required this.user, this.card});

  @override
  ConsumerState<CreditCardFormScreen> createState() =>
      _CreditCardFormScreenState();
}

class _CreditCardFormScreenState extends ConsumerState<CreditCardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cardNameController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _cardTypeController;
  late final TextEditingController _last4DigitsController;
  late final TextEditingController _limitController;
  DateTime? _billingDate;
  DateTime? _dueDate;
  bool _isSubmitting = false;
  Map<String, String>? _selectedCardType;
  Map<String, String>? _selectedBank;
  bool _isAutoDebitEnabled = false;

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
    _isAutoDebitEnabled = card?.isAutoDebitEnabled ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.card != null) {
        final banksAsync = ref.read(bankProvider);
        if (banksAsync.hasValue && banksAsync.value!.isNotEmpty) {
          final bank = banksAsync.value!.firstWhere(
            (b) => b.id == widget.card!.bankId,
          );
          setState(() {
            _selectedBank = {
              'id': bank.id,
              'label': bank.name,
              'iconPath': bank.logoPath ?? '',
            };
            _bankNameController.text = bank.name;
          });
        }
        final cardType = CardType.values.firstWhere(
          (type) => type.name == widget.card!.cardType.name,
          orElse: () => CardType.Visa,
        );
        setState(() {
          _selectedCardType = {
            'id': cardType.name,
            'label': cardType.name,
            'iconPath': cardType.logoPath,
          };
          _cardTypeController.text = cardType.name;
        });
      }
    });
  }

  Future<CreditCardModel?> _saveCard(BuildContext context) async {
    print('[DEBUG] AddCardScreen._saveCard called');
    if (_formKey.currentState?.validate() != true ||
        _billingDate == null ||
        _dueDate == null) {
      if (_billingDate == null || _dueDate == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.selectDatesError)));
      }
      return null;
    }

    // Validate due date is after billing date
    if (_dueDate!.isBefore(_billingDate!) ||
        _dueDate!.isAtSameMomentAs(_billingDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.dueDateBeforeBillingError)),
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
        bankId: _selectedBank?['id'],
        last4Digits: _last4DigitsController.text.trim(),
        billingDate: _billingDate!,
        dueDate: _dueDate!,
        creditLimit: double.parse(_limitController.text.trim()),
        currentUtilization: widget.card?.currentUtilization ?? 0.0,
        cardType: cardType,
        isAutoDebitEnabled: _isAutoDebitEnabled,
      );

      print('[DEBUG] Calling creditCardProvider.save');
      await ref.read(creditCardProvider.notifier).save(updatedCard);

      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.card == null
                ? context.l10n.cardAddedSuccess
                : context.l10n.cardUpdatedSuccess,
          ),
        ),
      );
      return updatedCard;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.l10n.cardSaveError}: $e')),
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

  Future<String?> _showSearchBottomSheet({
    required BuildContext context,
    required String title,
    required List<Map<String, String>> items,
    String? selectedId,
  }) async {
    TextEditingController searchController = TextEditingController();
    List<Map<String, String>> filtered = List.from(items);

    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final halfHeight = MediaQuery.of(ctx).size.height * 0.5;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SizedBox(
                height: halfHeight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: Theme.of(ctx).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search...',
                      ),
                      onChanged: (query) {
                        setSheetState(() {
                          filtered =
                              items
                                  .where(
                                    (item) => item['label']!
                                        .toLowerCase()
                                        .contains(query.toLowerCase()),
                                  )
                                  .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child:
                          filtered.isEmpty
                              ? const Padding(
                                padding: EdgeInsets.all(24),
                                child: Text('No results found.'),
                              )
                              : ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (ctx, i) {
                                  final item = filtered[i];
                                  return ListTile(
                                    leading:
                                        selectedId == item['id']
                                            ? const Icon(
                                              Icons.check,
                                              color: Colors.blue,
                                            )
                                            : null,

                                    title: Text(item['label']!),
                                    trailing:
                                        item['iconPath'] != null &&
                                                item['iconPath']!.isNotEmpty
                                            ? SvgPicture.asset(
                                              item['iconPath']!,
                                              width: 24,
                                              height: 24,
                                            )
                                            : const Icon(Icons.credit_card),
                                    onTap: () => Navigator.pop(ctx, item['id']),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
    const spacingBetweenInput = SizedBox(height: 12);

    final banksAsync = ref.watch(bankProvider);
    if (banksAsync.isLoading) {
      LoadingIndicatorScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.card == null
              ? context.l10n.addCardScreenTitle
              : context.l10n.updateCardScreenTitle,
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
                decoration: InputDecoration(
                  labelText: context.l10n.cardNameLabel,
                ),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? context.l10n.validationRequired
                            : null,
              ),
              spacingBetweenInput,
              TextFormField(
                controller: _bankNameController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: context.l10n.bankLabel,
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  prefixIcon:
                      _selectedBank != null &&
                              _selectedBank!['iconPath']!.isNotEmpty
                          ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              _selectedBank!['iconPath']!,
                              width: 24,
                              height: 24,
                              placeholderBuilder:
                                  (_) => const Icon(Icons.account_balance),
                            ),
                          )
                          : null,
                ),
                onTap:
                    _isSubmitting
                        ? null
                        : () async {
                          final banks =
                              ref.read(bankProvider).asData?.value ?? [];
                          if (banks.isEmpty) return;
                          final selectedId = await _showSearchBottomSheet(
                            context: context,
                            title: context.l10n.bankLabel,
                            items:
                                banks
                                    .map(
                                      (b) => {
                                        'id': b.id,
                                        'label': b.name,
                                        'iconPath': b.logoPath ?? '',
                                      },
                                    )
                                    .toList(),
                            selectedId:
                                _selectedBank != null
                                    ? _selectedBank!['id']
                                    : null,
                          );
                          if (selectedId != null) {
                            final selectedBank = banks.firstWhere(
                              (b) => b.id == selectedId,
                            );
                            setState(() {
                              _selectedBank = {
                                'id': selectedBank.id,
                                'label': selectedBank.name,
                                'iconPath': selectedBank.logoPath ?? '',
                              };
                              _bankNameController.text = selectedBank.name;
                            });
                          }
                        },
                validator:
                    (v) =>
                        _selectedBank == null
                            ? context.l10n.validationRequired
                            : null,
              ),
              spacingBetweenInput,
              TextFormField(
                controller: _cardTypeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: context.l10n.networkLabel,
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  prefixIcon:
                      _selectedCardType != null &&
                              _selectedCardType!['iconPath']!.isNotEmpty
                          ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              _selectedCardType!['iconPath']!,
                              width: 24,
                              height: 24,
                              placeholderBuilder:
                                  (_) => const Icon(Icons.credit_card),
                            ),
                          )
                          : null,
                ),
                onTap:
                    _isSubmitting
                        ? null
                        : () async {
                          final cardTypes =
                              CardType.values
                                  .map(
                                    (type) => {
                                      'id': type.name,
                                      'label': type.name,
                                      'iconPath': type.logoPath,
                                    },
                                  )
                                  .toList();
                          final selectedId = await _showSearchBottomSheet(
                            context: context,
                            title: context.l10n.networkLabel,
                            items: cardTypes,
                            selectedId:
                                _selectedCardType != null
                                    ? _selectedCardType!['id']
                                    : null,
                          );
                          if (selectedId != null) {
                            final selectedType = cardTypes.firstWhere(
                              (t) => t['id'] == selectedId,
                            );
                            setState(() {
                              _selectedCardType = selectedType;
                              _cardTypeController.text = selectedType['label']!;
                            });
                          }
                        },
                validator:
                    (v) =>
                        _selectedCardType == null
                            ? context.l10n.validationRequired
                            : null,
              ),
              spacingBetweenInput,
              TextFormField(
                controller: _last4DigitsController,
                decoration: InputDecoration(
                  labelText: context.l10n.last4DigitsLabel,
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator:
                    (v) =>
                        v == null || v.length != 4
                            ? context.l10n.last4DigitsError
                            : null,
              ),
              spacingBetweenInput,
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _billingDate == null
                            ? context.l10n.billingDateLabel
                            : '${context.l10n.billingDateLabel}: ${_billingDate!.day}/${_billingDate!.month}',
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
                            ? context.l10n.dueDateLabel
                            : '${context.l10n.dueDateLabel}: ${_dueDate!.day}/${_dueDate!.month}',
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
              spacingBetweenInput,
              TextFormField(
                controller: _limitController,
                decoration: InputDecoration(
                  labelText: context.l10n.creditLimitLabel,
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
                      ? context.l10n.invalidCreditLimitError
                      : null;
                },
              ),
              spacingBetweenInput,
              Row(
                children: [
                  Text(context.l10n.autoDebitEnabledLabel),
                  const Spacer(),
                  Switch(
                    value: _isAutoDebitEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _isAutoDebitEnabled = value;
                      });
                    },
                  ),
                ],
              ),
              spacingBetweenInput,
              spacingBetweenInput,
              FilledButton(
                onPressed:
                    _isSubmitting
                        ? null
                        : () async {
                          final card = await _saveCard(context);
                          if (card != null) {
                            NavigationService.pop(context);
                          }
                        },
                child:
                    _isSubmitting
                        ? const CreditCardColorDotIndicator()
                        : Text(context.l10n.saveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
