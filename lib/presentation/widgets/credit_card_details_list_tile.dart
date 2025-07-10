import 'package:card_nudge/helper/date_extension.dart';
import 'package:card_nudge/presentation/providers/credit_card_provider.dart';
import 'package:card_nudge/presentation/providers/format_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../helper/app_localizations_extension.dart';
import '../../data/enums/card_type.dart';
import '../../data/hive/models/credit_card_model.dart';
import '../../data/hive/models/bank_model.dart';
import '../../helper/string_helper.dart';
import '../providers/bank_provider.dart';
import '../providers/payment_provider.dart';
import 'credit_card_color_dot_indicator.dart';

class CreditCardDetailsListTile extends ConsumerWidget {
  final String cardId;

  const CreditCardDetailsListTile({super.key, required this.cardId});

  static const _defaultColor = Color(0xFF1A1A1A);
  static const _cardWidth = 400.0;
  static const _cardHeight = 200.0;
  static const _padding = EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0);
  static const _borderRadius = BorderRadius.all(Radius.circular(20));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bankAsync = ref.watch(bankProvider);
    final cardAsync = ref.watch(creditCardProvider);

    return cardAsync.when(
      data: (cards) {
        final card = cards.firstWhere((c) => c.id == cardId);
        return bankAsync.when(
          data: (banks) {
            final bank = banks.firstWhere((b) => b.id == card.bankId);

            return Semantics(
              button: true,
              label: '${context.l10n.cardDetailsTitle} ${card.name}',
              child: _buildCard(context, ref, theme, bank, card),
            );
          },
          loading: () => const Center(child: CreditCardColorDotIndicator()),
          error:
              (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${context.l10n.bankDetailsLoadError}: $error',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(bankProvider),
                      child: Text(context.l10n.retryButtonLabel),
                    ),
                  ],
                ),
              ),
        );
      },
      loading: () => const Center(child: CreditCardColorDotIndicator()),
      error:
          (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Card Load Error: $error',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(creditCardProvider),
                  child: Text(context.l10n.buttonRetry),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    BankModel bank,
    CreditCardModel card,
  ) {
    final paymentsAsync = ref.watch(paymentProvider);
    final formatHelper = ref.watch(formatHelperProvider);

    return Padding(
      padding: _padding,
      child: Card(
        elevation: 4,
        shape: const RoundedRectangleBorder(borderRadius: _borderRadius),
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: _cardHeight,
          width:
              MediaQuery.of(context).size.width * 0.9 > _cardWidth
                  ? _cardWidth
                  : MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_parseColor(bank.colorHex), const Color(0xFF2A2A2A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: _borderRadius,
          ),
          child: paymentsAsync.when(
            data: (payments) {
              final cardPayments =
                  payments.where((p) => p.cardId == card.id).toList();
              final hasDue = cardPayments.any(
                (p) => !p.isPaid || p.isPartiallyPaid,
              );
              final dueAmount = cardPayments.fold<double>(
                0.0,
                (sum, payment) => sum + (payment.dueAmount),
              );

              return Semantics(
                label: '${context.l10n.cardDetailsTitle} ${card.name}',
                child: Stack(
                  children: [
                    Positioned(
                      top: 16,
                      left: 16,
                      child: _buildCardLogo(theme, bank),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: _buildCardDetails(
                        context,
                        bank,
                        card,
                        hasDue,
                        dueAmount,
                        formatHelper,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CreditCardColorDotIndicator()),
            error:
                (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${context.l10n.paymentLoadError}: $error',
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(paymentProvider),
                        child: Text(context.l10n.buttonRetry),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String? colorHex) {
    try {
      final hex = colorHex?.replaceFirst('#', '') ?? 'FF1A1A1A';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return _defaultColor;
    }
  }

  Widget _buildCardLogo(ThemeData theme, BankModel bank) {
    final bankLogo =
        bank.logoPath != null
            ? SvgPicture.asset(bank.logoPath!, width: 35, height: 35)
            : const Icon(Icons.account_balance, size: 35);

    return Row(
      children: [
        Semantics(label: bank.name, child: bankLogo),
        const SizedBox(width: 12),
        Text(
          bank.name,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCardDetails(
    BuildContext context,
    BankModel bank,
    CreditCardModel card,
    bool hasDue,
    double dueAmount,
    FormatHelper formatHelper,
  ) {
    final theme = Theme.of(context);
    final cardNetworkLogo = SvgPicture.asset(
      card.cardType.logoPath,
      width: 22,
      height: 22,
      semanticsLabel: card.cardType.name,
    );

    final statmentGenerated = DateTime.now().isAfter(card.billingDate);
    final daysLeft = card.dueDate.differenceInDaysCeil(DateTime.now());

    Color dueDateColor;
    if (daysLeft <= 5) {
      dueDateColor = Colors.redAccent;
    } else if (daysLeft <= 10) {
      dueDateColor = Colors.deepOrangeAccent;
    } else {
      dueDateColor = Colors.orangeAccent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                card.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Semantics(label: bank.name, child: cardNetworkLogo),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          obfuscateCardNumber(card.last4Digits, card.cardType),
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            letterSpacing: 2.0,
            shadows: const [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Credit Limit
            _buildInfoTile(
              label: context.l10n.creditLimitLabel,
              value: formatHelper.formatCurrency(
                card.creditLimit,
                decimalDigits: 0,
              ),
            ),
            _buildInfoTile(
              label: context.l10n.totalDue,
              value: hasDue ? formatHelper.formatCurrency(dueAmount) : '0.00',
              valueColor: hasDue ? Colors.orangeAccent : Colors.greenAccent,
            ),
            if (hasDue)
              _buildInfoTile(
                label: context.l10n.dueDateLabel,
                value: formatHelper.formatDate(card.dueDate, format: 'MMMM d'),
                valueColor: dueDateColor,
              )
            else
              _buildInfoTile(
                label: context.l10n.billingDateLabel,
                value: formatHelper.formatDate(
                  card.billingDate,
                  format: 'MMMM d',
                ),
                valueColor:
                    hasDue || statmentGenerated
                        ? Colors.redAccent
                        : Colors.greenAccent,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
