import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../constants/app_strings.dart';
import '../../data/enums/card_type.dart';
import '../../data/hive/models/credit_card_model.dart';
import '../../data/hive/models/bank_model.dart';
import '../providers/bank_provider.dart';
import '../providers/payment_provider.dart';

class CreditCardTile extends ConsumerWidget {
  final CreditCardModel card;

  const CreditCardTile({super.key, required this.card});

  static const _defaultColor = Color(0xFF1A1A1A);
  static const _cardWidth = 400.0;
  static const _cardHeight = 200.0;
  static const _padding = EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0);
  static const _borderRadius = BorderRadius.all(Radius.circular(20));
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  String get maskedCardNumber => '**** **** **** ${card.last4Digits}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bankAsync = ref.watch(bankProvider);

    return bankAsync.when(
      data: (banks) {
        final bank = banks.firstWhere(
          (b) => b.id == card.bankId,
          orElse:
              () => BankModel(
                id: '',
                name: 'Unknown Bank',
                logoPath: null,
                colorHex: null,
              ),
        );

        return Semantics(
          button: true,
          label: '${AppStrings.cardDetailsTitle} ${card.name}',
          child: _buildCard(context, ref, theme, bank),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${AppStrings.bankDetailsLoadError}: $error',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(bankProvider),
                  child: const Text(AppStrings.retryButtonLabel),
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
  ) {
    final paymentsAsync = ref.watch(paymentProvider);

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
              final hasDue =
                  cardPayments.isNotEmpty && cardPayments.last.dueAmount > 0;
              final dueAmount = cardPayments.fold<double>(
                0.0,
                (sum, payment) => sum + (payment.dueAmount),
              );

              return Semantics(
                label: '${AppStrings.cardDetailsTitle} ${card.name}',
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
                        hasDue,
                        dueAmount,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${AppStrings.paymentLoadError}: $error',
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(paymentProvider),
                        child: const Text(AppStrings.retryButtonLabel),
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
    bool hasDue,
    double dueAmount,
  ) {
    final theme = Theme.of(context);
    final cardNetworkLogo =
        bank.logoPath != null
            ? SvgPicture.asset(card.cardType.logoPath, width: 22, height: 22)
            : const Icon(Icons.credit_card, size: 30);

    final statmentGenerated = DateTime.now().isAfter(card.billingDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              card.name,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            Semantics(label: bank.name, child: cardNetworkLogo),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          maskedCardNumber,
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
            _buildInfoTile(
              label: AppStrings.creditLimitLabel,
              value: _currencyFormat.format(card.creditLimit),
            ),
            _buildInfoTile(
              label: AppStrings.totalDue,
              value: hasDue ? _currencyFormat.format(dueAmount) : '₹0',
              valueColor: hasDue ? Colors.orangeAccent : Colors.greenAccent,
            ),
            if (statmentGenerated)
              _buildInfoTile(
                label: AppStrings.dueDateLabel,
                value: DateFormat.MMMd(
                  Localizations.localeOf(context).toString(),
                ).format(card.dueDate),
                valueColor: hasDue ? Colors.redAccent : Colors.greenAccent,
              )
            else
              _buildInfoTile(
                label: AppStrings.billingDateLabel,
                value: DateFormat.MMMd(
                  Localizations.localeOf(context).toString(),
                ).format(card.billingDate),
                valueColor: hasDue ? Colors.redAccent : Colors.greenAccent,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
