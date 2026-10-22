import 'package:card_nudge/helper/app_localizations_extension.dart';
import 'package:card_nudge/helper/date_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/enums/payment_option.dart';
import '../../data/hive/models/credit_card_model.dart';
import '../../data/hive/models/payment_model.dart';
import '../../services/navigation_service.dart';
import '../providers/bank_provider.dart';
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
  final CreditCardModel? card;
  final bool? isAutoDebit;

  const PaymentHistoryBottomSheet({
    super.key,
    required this.payment,
    this.card,
    this.isAutoDebit,
  });

  @override
  ConsumerState<PaymentHistoryBottomSheet> createState() =>
      _PaymentHistoryBottomSheetState();
}

class _PaymentHistoryBottomSheetState
    extends ConsumerState<PaymentHistoryBottomSheet> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController customAmountController;
  late FocusNode customAmountFocusNode;
  late PaymentDateOption _selectedDateOption;
  DateTime? _customPaymentDate;

  bool get _isPastDueDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      widget.payment.dueDate.year,
      widget.payment.dueDate.month,
      widget.payment.dueDate.day,
    );
    return today.isAfter(due);
  }

  CreditCardModel? get _card {
    if (widget.card != null) return widget.card;
    try {
      final cardBox = ref.read(creditCardBoxProvider);
      final card =
          cardBox.values
              .where((c) => c.id == widget.payment.cardId)
              .firstOrNull;
      if (card != null) return card;
    } catch (_) {}
    try {
      final cards = ref.read(creditCardProvider).valueOrNull;
      return cards?.where((c) => c.id == widget.payment.cardId).firstOrNull;
    } catch (_) {}
    return null;
  }

  bool get _isAutoDebit {
    if (widget.isAutoDebit != null) return widget.isAutoDebit!;
    return _card?.isAutoDebitEnabled ?? false;
  }

  @override
  void initState() {
    super.initState();
    customAmountController = TextEditingController();
    customAmountFocusNode = FocusNode();
    _customPaymentDate = widget.payment.dueDate;
    _selectedDateOption =
        (widget.isAutoDebit ?? widget.card?.isAutoDebitEnabled ?? false)
            ? PaymentDateOption.dueDate
            : PaymentDateOption.today;

    customAmountController.addListener(() {
      if (mounted) setState(() {});
    });

    if (widget.isAutoDebit == null && widget.card == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isAutoDebit) {
          setState(() {
            _selectedDateOption = PaymentDateOption.dueDate;
          });
        }
      });
    }
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
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(customAmountFocusNode);
        }
      });
    }
  }

  Future<void> _selectCustomDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initialDate =
        _customPaymentDate != null && !_customPaymentDate!.isAfter(today)
            ? _customPaymentDate!
            : (widget.payment.dueDate.isBefore(today)
                ? widget.payment.dueDate
                : today);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: today,
    );

    if (picked != null) {
      setState(() {
        _customPaymentDate = picked;
      });
    }
  }

  void _onDateOptionChanged(PaymentDateOption? value) {
    if (value == null) return;
    setState(() {
      _selectedDateOption = value;
    });
    if (value == PaymentDateOption.custom) {
      _selectCustomDate(context);
    }
  }

  double _getEffectiveAmount(PaymentOption selectedOption) {
    switch (selectedOption) {
      case PaymentOption.totalDue:
        return widget.payment.dueAmount;
      case PaymentOption.minDue:
        return widget.payment.minimumDueAmount ?? widget.payment.dueAmount;
      case PaymentOption.custom:
        final parsed = double.tryParse(customAmountController.text.trim());
        return parsed ?? 0.0;
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
      final amount = _getEffectiveAmount(selectedOption);

      // Determine payment date
      DateTime paymentDate;
      if (!_isPastDueDate) {
        paymentDate = DateTime.now();
      } else {
        switch (_selectedDateOption) {
          case PaymentDateOption.dueDate:
            paymentDate = DateTime.utc(
              widget.payment.dueDate.year,
              widget.payment.dueDate.month,
              widget.payment.dueDate.day,
              12,
              0,
            );
            break;
          case PaymentDateOption.today:
            paymentDate = DateTime.now();
            break;
          case PaymentDateOption.custom:
            final custom = _customPaymentDate ?? widget.payment.dueDate;
            paymentDate = DateTime.utc(
              custom.year,
              custom.month,
              custom.day,
              12,
              0,
            );
            break;
        }
      }

      final wasUnpaid = !widget.payment.isPaid;
      await ref
          .read(paymentProvider.notifier)
          .markAsPaid(widget.payment.id, amount, paymentDate: paymentDate);

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
    final theme = Theme.of(context);
    final formatHelper = ref.watch(formatHelperProvider);
    final selectedOption = ref.watch(selectedOptionProvider);
    final isSubmitting = ref.watch(isSubmittingProvider);

    final card = _card;
    final banksAsync = ref.watch(bankProvider);
    final bank =
        card?.bankId != null
            ? banksAsync.valueOrNull
                ?.where((b) => b.id == card!.bankId)
                .firstOrNull
            : null;

    final effectiveAmount = _getEffectiveAmount(selectedOption);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 10,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Card Context Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        bank?.logoPath != null
                            ? SvgPicture.asset(
                              bank!.logoPath!,
                              placeholderBuilder:
                                  (_) => Icon(
                                    Icons.credit_card_rounded,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                            )
                            : Icon(
                              Icons.credit_card_rounded,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                card?.name ?? context.l10n.logPayment,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (card != null &&
                                card.last4Digits.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                '••${card.last4Digits}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${context.l10n.dueOn} ${formatHelper.formatDate(widget.payment.dueDate, format: 'MMM d, yyyy')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                _isPastDueDate
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onSurfaceVariant,
                            fontWeight:
                                _isPastDueDate
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isAutoDebit)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer.withValues(
                          alpha: 0.4,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 13,
                            color: theme.colorScheme.tertiary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Auto-Debit',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    visualDensity: VisualDensity.compact,
                    tooltip: context.l10n.buttonClose,
                    onPressed: () => NavigationService.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Hero Payment Overview Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.logPayment.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatHelper.formatCurrency(
                            effectiveAmount > 0
                                ? effectiveAmount
                                : widget.payment.dueAmount,
                            decimalDigits: 2,
                          ),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    _buildDueDateStatusBadge(context),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Amount Selection Options
              Text(
                'AMOUNT TO PAY',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),

              // Total Due Tile
              _buildAmountOptionTile(
                context: context,
                option: PaymentOption.totalDue,
                label: context.l10n.totalDue,
                amountFormatted: formatHelper.formatCurrency(
                  widget.payment.dueAmount,
                  decimalDigits: 2,
                ),
                isSelected: selectedOption == PaymentOption.totalDue,
                isSubmitting: isSubmitting,
              ),

              // Minimum Due Tile (if applicable)
              if (widget.payment.minimumDueAmount != null) ...[
                const SizedBox(height: 8),
                _buildAmountOptionTile(
                  context: context,
                  option: PaymentOption.minDue,
                  label: context.l10n.minimumDue,
                  amountFormatted: formatHelper.formatCurrency(
                    widget.payment.minimumDueAmount!,
                    decimalDigits: 2,
                  ),
                  isSelected: selectedOption == PaymentOption.minDue,
                  isSubmitting: isSubmitting,
                ),
              ],

              const SizedBox(height: 8),

              // Custom Amount Tile
              _buildAmountOptionTile(
                context: context,
                option: PaymentOption.custom,
                label: context.l10n.customAmount,
                amountFormatted:
                    selectedOption == PaymentOption.custom &&
                            effectiveAmount > 0
                        ? formatHelper.formatCurrency(
                          effectiveAmount,
                          decimalDigits: 2,
                        )
                        : 'Any amount',
                isSelected: selectedOption == PaymentOption.custom,
                isSubmitting: isSubmitting,
              ),

              // Custom Amount Animated Input Field
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child:
                    selectedOption == PaymentOption.custom
                        ? Padding(
                          key: const ValueKey('customField'),
                          padding: const EdgeInsets.only(top: 10),
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
                              hintText: '0.00',
                              prefixIcon: const Icon(Icons.edit_note_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              helperText:
                                  'Max: ${formatHelper.formatCurrency(widget.payment.dueAmount, decimalDigits: 2)}',
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

              // Payment Date Section (When Past Due Date)
              if (_isPastDueDate) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(
                      alpha: 0.25,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history_toggle_off_rounded,
                        color: theme.colorScheme.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.l10n.paymentPastDueDateWarning,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.whenWasPaymentMade,
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateOptionTile(
                        context: context,
                        option: PaymentDateOption.dueDate,
                        title: 'Due Date',
                        dateFormatted: formatHelper.formatDate(
                          widget.payment.dueDate,
                          format: 'MMM d',
                        ),
                        badgeText: _isAutoDebit ? 'Auto' : null,
                        isSelected:
                            _selectedDateOption == PaymentDateOption.dueDate,
                        isSubmitting: isSubmitting,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDateOptionTile(
                        context: context,
                        option: PaymentDateOption.today,
                        title: 'Today',
                        dateFormatted: formatHelper.formatDate(
                          DateTime.now(),
                          format: 'MMM d',
                        ),
                        isSelected:
                            _selectedDateOption == PaymentDateOption.today,
                        isSubmitting: isSubmitting,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDateOptionTile(
                        context: context,
                        option: PaymentDateOption.custom,
                        title: context.l10n.customDateOption,
                        dateFormatted:
                            _customPaymentDate != null
                                ? formatHelper.formatDate(
                                  _customPaymentDate!,
                                  format: 'MMM d',
                                )
                                : context.l10n.selectDate,
                        icon: Icons.calendar_month_outlined,
                        isSelected:
                            _selectedDateOption == PaymentDateOption.custom,
                        isSubmitting: isSubmitting,
                      ),
                    ),
                  ],
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child:
                      _selectedDateOption == PaymentDateOption.custom
                          ? Padding(
                            key: const ValueKey('customDatePickerContainer'),
                            padding: const EdgeInsets.only(top: 8),
                            child: InkWell(
                              onTap:
                                  isSubmitting
                                      ? null
                                      : () => _selectCustomDate(context),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: theme
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_calendar_rounded,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${context.l10n.paymentDateLabel}: ${formatHelper.formatDate(_customPaymentDate ?? widget.payment.dueDate, format: 'MMMM d, yyyy')}',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
              ],

              const SizedBox(height: 22),

              // Confirm Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon:
                      isSubmitting
                          ? null
                          : const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 20,
                          ),
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
                          : Text(
                            effectiveAmount > 0
                                ? 'Confirm Payment • ${formatHelper.formatCurrency(effectiveAmount, decimalDigits: 2)}'
                                : context.l10n.logPaymentButton,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDueDateStatusBadge(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final diff = widget.payment.dueDate.differenceInDaysCeil(now);

    final isOverdue = diff < 0;
    final isToday = diff == 0;

    final color =
        isOverdue
            ? theme.colorScheme.error
            : (isToday
                ? theme.colorScheme.tertiary
                : theme.colorScheme.primary);

    final text =
        isOverdue
            ? context.l10n.overdueByDays(-diff)
            : (isToday ? context.l10n.dueToday : context.l10n.dueInDays(diff));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning_rounded : Icons.calendar_today_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountOptionTile({
    required BuildContext context,
    required PaymentOption option,
    required String label,
    required String amountFormatted,
    required bool isSelected,
    required bool isSubmitting,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: isSubmitting ? null : () => _onOptionChanged(option),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.08)
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? theme.colorScheme.primary : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child:
                  isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color:
                      isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              amountFormatted,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateOptionTile({
    required BuildContext context,
    required PaymentDateOption option,
    required String title,
    required String dateFormatted,
    required bool isSelected,
    required bool isSubmitting,
    String? badgeText,
    IconData? icon,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: isSubmitting ? null : () => _onDateOptionChanged(option),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.08)
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badgeText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    dateFormatted,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (icon != null)
                  Icon(
                    icon,
                    size: 13,
                    color:
                        isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
