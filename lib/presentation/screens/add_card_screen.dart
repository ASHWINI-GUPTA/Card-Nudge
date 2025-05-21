import 'package:card_nudge/presentation/providers/bank_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../data/hive/models/credit_card_model.dart';
import '../../data/enums/card_type.dart';
import '../providers/credit_card_provider.dart';

class AddCardScreen extends ConsumerStatefulWidget {
  final CreditCardModel? card;

  const AddCardScreen({super.key, this.card});

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

  Future<void> _pickDate(BuildContext context, bool isBilling) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        if (isBilling) {
          _billingDate = selected;
        } else {
          _dueDate = selected;
        }
      });
    }
  }

  Future<void> _saveCard() async {
    if (_formKey.currentState?.validate() != true ||
        _billingDate == null ||
        _dueDate == null) {
      return;
    }

    final updatedCard = CreditCardModel(
      name: _cardNameController.text.trim(),
      bankId: _bankNameController.text.trim(),
      last4Digits: _last4DigitsController.text.trim(),
      billingDate: _billingDate!,
      dueDate: _dueDate!,
      creditLimit: double.parse(_limitController.text.trim()),
      currentUtilization: 0.0,
      cardType: CardType.Visa,
    );

    final notifier = ref.read(creditCardListProvider.notifier);

    if (widget.card != null) {
      // UPDATE
      notifier.updateByKey(widget.card!.key, updatedCard);
    } else {
      // ADD
      notifier.add(updatedCard);
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    _bankNameController.dispose();
    _last4DigitsController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = const SizedBox(height: 12);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card == null ? 'Add Card' : 'Update Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _cardNameController,
                decoration: const InputDecoration(labelText: 'Card'),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              spacing,
              DropdownButtonFormField<String>(
                value:
                    _bankNameController.text.isNotEmpty
                        ? _bankNameController.text
                        : null,
                decoration: const InputDecoration(labelText: 'Bank'),
                items:
                    ref.watch(bankProvider.notifier).getAllBanks().map((bank) {
                      return DropdownMenuItem<String>(
                        value: bank.id,
                        child: Row(
                          children: [
                            if (bank.logoPath != null)
                              SvgPicture.asset(
                                bank.logoPath as String,
                                width: 20,
                              )
                            else
                              const Icon(Icons.account_balance, size: 20),
                            const SizedBox(width: 8),
                            Text(bank.name),
                          ],
                        ),
                      );
                    }).toList(),

                onChanged: (value) {
                  setState(() {
                    _bankNameController.text = value ?? '';
                  });
                },
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              spacing,
              DropdownButtonFormField<String>(
                value:
                    _cardTypeController.text.isNotEmpty
                        ? _cardTypeController.text
                        : null,
                decoration: const InputDecoration(labelText: 'Network'),
                items:
                    CardType.values.map((type) {
                      return DropdownMenuItem<String>(
                        value: type.name,
                        child: Row(children: [Text(type.name)]),
                      );
                    }).toList(),

                onChanged: (value) {
                  setState(() {
                    _cardTypeController.text = value ?? '';
                  });
                },
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              spacing,
              TextFormField(
                controller: _last4DigitsController,
                decoration: const InputDecoration(labelText: 'Last 4 Digits'),
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator:
                    (v) =>
                        v == null || v.length != 4
                            ? 'Enter exactly 4 digits'
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
                            ? 'Billing Date'
                            : 'Billing: ${_billingDate!.day}/${_billingDate!.month}',
                      ),
                      onPressed: () => _pickDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.event),
                      label: Text(
                        _dueDate == null
                            ? 'Due Date'
                            : 'Due: ${_dueDate!.day}/${_dueDate!.month}',
                      ),
                      onPressed: () => _pickDate(context, false),
                    ),
                  ),
                ],
              ),
              spacing,
              TextFormField(
                controller: _limitController,
                decoration: const InputDecoration(
                  labelText: 'Credit Limit (₹)',
                ),
                keyboardType: TextInputType.number,
                validator:
                    (v) =>
                        v == null || double.tryParse(v) == null
                            ? 'Enter valid number'
                            : null,
              ),
              spacing,

              const SizedBox(height: 20),
              FilledButton(onPressed: _saveCard, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
