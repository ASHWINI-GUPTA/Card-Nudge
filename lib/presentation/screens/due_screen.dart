import 'package:card_nudge/helper/app_localizations_extension.dart';
import 'package:card_nudge/helper/date_extension.dart';
import 'package:card_nudge/presentation/providers/filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../constants/app_strings.dart';
import '../../data/hive/models/bank_model.dart';
import '../../data/hive/models/credit_card_model.dart';
import '../../data/hive/models/payment_model.dart';
import '../../helper/string_helper.dart';
import '../../services/navigation_service.dart';
import '../providers/bank_provider.dart';
import '../providers/credit_card_provider.dart';
import '../providers/format_provider.dart';
import '../providers/payment_provider.dart';
import '../widgets/payment_due_entry_bottom_sheet.dart';
import '../widgets/credit_card_color_dot_indicator.dart';
import '../widgets/no_data_placeholder_widget.dart';
import '../widgets/empty_credit_card_list_widget.dart';
import '../widgets/payment_history_bottom_sheet.dart';
import '../widgets/data_sync_progress_bar.dart';

class DueScreen extends ConsumerWidget {
  const DueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cardsAsync = ref.watch(creditCardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.upcomingPaymentsTitle,
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: DataSynchronizationProgressBar(),
        ),
      ),
      body: cardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return EmptyCreditCardListWidget(context: context, ref: ref);
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(creditCardProvider);
              ref.invalidate(bankProvider);
              ref.invalidate(paymentProvider);
            },
            child: _buildPaymentList(context, ref, cards),
          );
        },
        loading: () => const Center(child: CreditCardColorDotIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${context.l10n.cardsScreenErrorTitle}: $error',
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
      ),
    );
  }

  Widget _buildPaymentList(
    BuildContext context,
    WidgetRef ref,
    List<CreditCardModel> cards,
  ) {
    final paymentsAsync = ref.watch(paymentProvider);
    final banksAsync = ref.watch(bankProvider);

    return paymentsAsync.when(
      data: (payments) {
        final nonPaidPayments = payments.where((p) => !p.isPaid).toList();
        if (nonPaidPayments.isEmpty) {
          return _buildEmptyStateNoPayments(context, ref, cards);
        }

        final groupedCards = _groupPaymentsByDueDate(context, nonPaidPayments);

        if (groupedCards.isEmpty) return _buildNoFilteredPayments(context, ref);

        return banksAsync.when(
          data: (banks) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: groupedCards.length,
              itemBuilder: (context, index) {
                final entry = groupedCards.entries.elementAt(index);
                final label = entry.key;
                final payments = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DateHeader(label: label),
                    ...payments.map((payment) {
                      final card = cards.firstWhere(
                        (c) => c.id == payment.cardId,
                        orElse:
                            () =>
                                throw Exception(context.l10n.invalidCardError),
                      );
                      final bank = banks.firstWhere((b) => b.id == card.bankId);
                      return DueCard(card: card, bank: bank, payment: payment);
                    }),
                  ],
                );
              },
            );
          },
          loading: () => const Center(child: CreditCardColorDotIndicator()),
          error:
              (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${context.l10n.bankDetailsLoadError}: $error',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(bankProvider),
                      child: Text(context.l10n.buttonRetry),
                    ),
                  ],
                ),
              ),
        );
      },
      loading: () => const Center(child: CreditCardColorDotIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${context.l10n.paymentLoadError}: $error',
                  style: Theme.of(context).textTheme.bodyLarge,
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
    );
  }

  Widget _buildEmptyStateNoPayments(
    BuildContext context,
    WidgetRef ref,
    List<CreditCardModel> cards,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noPaymentsMessage,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                () => NavigationService.showBottomSheet(
                  context: context,
                  builder:
                      (context) =>
                          PaymentDueEntryBottomSheet(card: cards.first),
                ),
            child: Text(context.l10n.addPaymentButton),
          ),
        ],
      ),
    );
  }

  Map<String, List<PaymentModel>> _groupPaymentsByDueDate(
    BuildContext context,
    List<PaymentModel> payments,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Map<String, List<PaymentModel>> grouped = {};

    for (var payment in payments) {
      final dueDate = DateTime(
        payment.dueDate.year,
        payment.dueDate.month,
        payment.dueDate.day,
      );
      final diff = dueDate.differenceInDaysCeil(today);
      String label;

      if (diff < 0) {
        label = AppStrings.overdue;
      } else if (diff == 0) {
        label = AppStrings.today;
      } else {
        label = DateFormat.yMMMMd().format(dueDate);
      }

      grouped.putIfAbsent(label, () => []).add(payment);
    }

    // Sort by date (overdue first)
    grouped = Map.fromEntries(
      grouped.entries.toList()..sort((a, b) {
        if (a.key == 'Overdue') return -1;
        if (b.key == 'Overdue') return 1;
        if (a.key == 'Today') return -1;
        if (b.key == 'Today') return 1;
        final dateA =
            a.key == 'Overdue' || a.key == 'Today'
                ? today
                : DateFormat.yMMMMd().parse(a.key);
        final dateB =
            b.key == 'Overdue' || b.key == 'Today'
                ? today
                : DateFormat.yMMMMd().parse(b.key);
        return dateA.compareTo(dateB);
      }),
    );

    return grouped;
  }

  Widget _buildNoFilteredPayments(BuildContext context, WidgetRef ref) {
    return NoDataPlaceholderWidget(
      message: context.l10n.dueScreenNoFilterMessage,
      buttonText: context.l10n.clearButton,
      onButtonPressed: () => ref.read(dueFilterProvider.notifier).resetFilter(),
    );
  }
}

class DateHeader extends StatelessWidget {
  final String label;

  const DateHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = label == 'Overdue';
    final isToday = label == 'Today';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color:
                  isOverdue
                      ? Colors.red[400]
                      : isToday
                      ? Colors.teal[400]
                      : theme.colorScheme.onSurface,
            ),
          ),
          Container(
            height: 2,
            width: 50,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isOverdue
                        ? [Colors.red[400]!, Colors.red[200]!]
                        : isToday
                        ? [Colors.teal[400]!, Colors.teal[200]!]
                        : [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.5),
                        ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DueCard extends ConsumerWidget {
  final CreditCardModel card;
  final BankModel bank;
  final PaymentModel payment;

  const DueCard({
    super.key,
    required this.card,
    required this.bank,
    required this.payment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CardContainer(
          bank: bank,
          child: DueCardContent(
            card: card,
            bank: bank,
            payment: payment,
            maxWidth: constraints.maxWidth,
          ),
        );
      },
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
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

class DueCardContent extends ConsumerWidget {
  final CreditCardModel card;
  final BankModel bank;
  final PaymentModel payment;
  final double maxWidth;

  const DueCardContent({
    super.key,
    required this.card,
    required this.bank,
    required this.payment,
    required this.maxWidth,
  });

  String _getStatusMessage(BuildContext context, DateTime dueDate) {
    final now = DateTime.now();
    int days = dueDate.differenceInDaysCeil(now);

    if (days < 0) {
      return context.l10n.overdueByDays(-days);
    } else if (days == 0) {
      return context.l10n.dueToday;
    } else if (days == 1) {
      return context.l10n.dueTomorrow;
    } else {
      return context.l10n.dueInDays(days);
    }
  }

  Color _dueDateColor(DateTime dueDate, BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final difference = dueDate.differenceInDaysCeil(now);

    if (difference < 0) {
      return theme.colorScheme.error; // Critical: Overdue
    } else if (difference <= 3) {
      return theme.colorScheme.tertiary; // Urgent: Due today or within 3 days
    } else if (difference <= 7) {
      return theme.colorScheme.secondary; // Warning: Due within 4-7 days
    } else {
      return theme.colorScheme.onSurfaceVariant; // Neutral: Due beyond 7 days
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final status = _getStatusMessage(context, payment.dueDate);
    final formatHelper = ref.watch(formatHelperProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  obfuscateCardNumber(card.last4Digits, card.cardType),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${context.l10n.totalDue}: ${formatHelper.formatCurrency(payment.dueAmount, decimalDigits: 2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  status,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: '${context.l10n.bankLogo} ${bank.name}',
                child:
                    bank.logoPath != null
                        ? SvgPicture.asset(
                          bank.logoPath!,
                          width: 30,
                          height: 30,
                          placeholderBuilder:
                              (_) =>
                                  const Icon(Icons.account_balance, size: 30),
                        )
                        : const Icon(Icons.account_balance, size: 30),
              ),
              const SizedBox(height: 20),
              Semantics(
                label: context.l10n.logPaymentButton,
                child: IconButton(
                  tooltip: context.l10n.logPaymentButton,
                  icon: Icon(
                    Icons.payments_outlined,
                    color: _dueDateColor(payment.dueDate, context),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                  ),
                  onPressed:
                      () => NavigationService.showBottomSheet(
                        context: context,
                        builder:
                            (context) =>
                                PaymentHistoryBottomSheet(payment: payment),
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
