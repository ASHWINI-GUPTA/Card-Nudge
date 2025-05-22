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
  final bool showLogPaymentButton;

  const CreditCardTile({
    super.key,
    required this.card,
    this.showLogPaymentButton = true,
  });

  String get maskedCardNumber {
    return '**** **** **** ${card.last4Digits}';
  }

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bankAsync = ref.watch(bankProvider);
    return bankAsync.when(
      data: (banks) {
        final bank = banks.firstWhere(
          (b) => b.id == card.bankId,
          orElse: () => throw Exception(AppStrings.invalidBankError),
        );
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: CardContainer(
            bank: bank,
            child: CardContent(
              card: card,
              bank: bank,
              showLogPaymentButton: showLogPaymentButton,
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${AppStrings.bankLoadError}: $error',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(bankProvider),
                  child: Text(AppStrings.retryButton),
                ),
              ],
            ),
          ),
    );
  }
}

class CardContainer extends StatelessWidget {
  final BankModel bank;
  final Widget child;

  const CardContainer({super.key, required this.bank, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorHex = bank.colorHex?.replaceFirst('#', '') ?? 'FF1A1A1A';
    final colorValue = int.parse(colorHex, radix: 16);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 200,
        width:
            MediaQuery.of(context).size.width * 0.9 > 400
                ? 400
                : MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(colorValue), const Color(0xFF2A2A2A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: child,
      ),
    );
  }
}

class CardContent extends ConsumerWidget {
  final CreditCardModel card;
  final BankModel bank;
  final bool showLogPaymentButton;

  const CardContent({
    super.key,
    required this.card,
    required this.bank,
    required this.showLogPaymentButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final paymentsAsync = ref.watch(paymentProvider);

    return paymentsAsync.when(
      data: (payments) {
        final cardPayments =
            payments.where((p) => p.cardId == card.id).toList();
        final hasDue =
            cardPayments.isNotEmpty && cardPayments.last.dueAmount > 0;

        return Stack(
          children: [
            Positioned(
              top: 16,
              left: 16,
              child: CardLogo(
                bank: bank,
                cardType: card.cardType,
                theme: theme,
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: CardDetails(
                card: card,
                bank: bank,
                theme: theme,
                hasDue: hasDue,
                dueAmount: hasDue ? cardPayments.last.dueAmount : 0,
                showLogPaymentButton: showLogPaymentButton,
                cardType: card.cardType,
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
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
                  child: Text(AppStrings.retryButton),
                ),
              ],
            ),
          ),
    );
  }
}

class CardLogo extends StatelessWidget {
  final BankModel bank;
  final CardType cardType;
  final ThemeData theme;

  const CardLogo({
    super.key,
    required this.bank,
    required this.cardType,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final bankLogo =
        bank.logoPath != null
            ? SvgPicture.asset(bank.logoPath as String, width: 35, height: 35)
            : const Icon(Icons.account_balance, size: 35);

    return Row(
      children: [
        Semantics(label: '${bank.name}', child: bankLogo),
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
}

class CardDetails extends ConsumerWidget {
  final CreditCardModel card;
  final BankModel bank;
  final ThemeData theme;
  final bool hasDue;
  final double dueAmount;
  final bool showLogPaymentButton;
  final CardType cardType;

  const CardDetails({
    super.key,
    required this.card,
    required this.bank,
    required this.theme,
    required this.hasDue,
    required this.dueAmount,
    required this.showLogPaymentButton,
    required this.cardType,
  });

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardNetworkLogo =
        bank.logoPath != null
            ? SvgPicture.asset(cardType.logoPath, width: 20, height: 20)
            : const Icon(Icons.credit_card, size: 20);
    return Semantics(
      label: '${AppStrings.cardDetailsTitle} ${card.name}',
      child: Column(
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
              Semantics(label: '${bank.name}', child: cardNetworkLogo),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '**** **** **** ${card.last4Digits}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              letterSpacing: 2.0,
              shadows: [
                const Shadow(
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
              _cardInfoTile(
                label: AppStrings.creditLimitLabel,
                value: _currencyFormat.format(card.creditLimit),
              ),
              _cardInfoTile(
                label: AppStrings.totalDue,
                value: hasDue ? _currencyFormat.format(dueAmount) : '₹0',
                valueColor: hasDue ? Colors.orangeAccent : Colors.greenAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardInfoTile({
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
