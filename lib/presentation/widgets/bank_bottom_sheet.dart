import 'package:card_nudge/data/hive/models/user_model.dart';
import 'package:card_nudge/helper/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hive/models/bank_model.dart';
import '../../services/navigation_service.dart';
import '../providers/bank_provider.dart';

class BankBottomSheet extends ConsumerStatefulWidget {
  final BankModel? bank; // Null for add, non-null for edit
  final UserModel user;

  const BankBottomSheet({super.key, this.bank, required this.user});

  @override
  _BankBottomSheetState createState() => _BankBottomSheetState();
}

class _BankBottomSheetState extends ConsumerState<BankBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _supportNumberController;
  late TextEditingController _websiteController;
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bank?.name ?? '');
    _codeController = TextEditingController(text: widget.bank?.code ?? '');
    _supportNumberController = TextEditingController(
      text: widget.bank?.supportNumber ?? '',
    );
    _websiteController = TextEditingController(
      text: widget.bank?.website ?? '',
    );
    if (widget.bank != null) {
      try {
        _selectedColor = Color(int.parse(widget.bank!.colorHex!));
      } catch (_) {
        _selectedColor = Colors.blue;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _supportNumberController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _saveBank() {
    if (_nameController.text.isEmpty || _codeController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.validationRequired)));
      return;
    }
    final colorHex =
        '#${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

    final bank;

    if (widget.bank == null) {
      bank = BankModel(
        userId: widget.user.id,
        name: _nameController.text,
        code: _codeController.text,
        supportNumber: _supportNumberController.text,
        website: _websiteController.text,
        colorHex: colorHex,
      );
    } else {
      bank = BankModel(
        userId: widget.user.id,
        id: widget.bank!.id,
        name: _nameController.text,
        code: _codeController.text,
        supportNumber: _supportNumberController.text,
        website: _websiteController.text,
        colorHex: colorHex,
      );
    }

    ref.read(bankProvider.notifier).save(bank);
    NavigationService.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.bank == null
                  ? context.l10n.addBank
                  : context.l10n.editBank,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.l10n.bankName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: context.l10n.bankCode,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _supportNumberController,
              decoration: InputDecoration(
                labelText: context.l10n.supportNumber,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _websiteController,
              decoration: InputDecoration(
                labelText: context.l10n.website,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(context.l10n.bankColor),
              trailing: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.onSurface),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text(context.l10n.selectColorLabel),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: _selectedColor,
                            onColorChanged: (color) {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => NavigationService.pop(context),
                            child: Text(context.l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () => NavigationService.pop(context),
                            child: Text(context.l10n.saveButton),
                          ),
                        ],
                      ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => NavigationService.pop(context),
                  child: Text(
                    context.l10n.cancel,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _saveBank,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.bank == null ? context.l10n.add : context.l10n.save,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
