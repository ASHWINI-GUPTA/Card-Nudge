import 'package:card_nudge/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_strings.dart';
import '../providers/credit_card_provider.dart';
import '../providers/payment_provider.dart';
import '../widgets/add_due_bottom_sheet.dart';
import '../widgets/credit_card_tile.dart';
import '../widgets/minimal_payment_display_card.dart';
import '../widgets/payment_log_sheet.dart';
import 'add_card_screen.dart';

class CardDetailsScreen extends ConsumerWidget {
  final String cardId;

  const CardDetailsScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cardsAsync = ref.watch(creditCardListProvider);
    final paymentsAsync = ref.watch(paymentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: AppStrings.cardDetailsTitle,
          child: Text(
            AppStrings.cardDetailsTitle,
            style: theme.textTheme.titleLarge,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: const Icon(Icons.edit),
                      title: Semantics(
                        label: AppStrings.editCard,
                        child: Text(AppStrings.editCard),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: const Icon(Icons.delete),
                      title: Semantics(
                        label: AppStrings.deleteCard,
                        child: Text(AppStrings.deleteCard),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: ListTile(
                      leading: const Icon(Icons.archive),
                      title: Semantics(
                        label: AppStrings.archiveCard,
                        child: Text(AppStrings.archiveCard),
                      ),
                    ),
                  ),
                ],
          ),
        ],
      ),
      floatingActionButton: Semantics(
        label: AppStrings.createPaymentDue,
        child: FloatingActionButton.extended(
          onPressed:
              () => NavigationService.showBottomSheet(
                context: context,
                builder: (context) => AddDueBottomSheet(cardId: cardId),
              ),
          icon: const Icon(Icons.add),
          label: Text(AppStrings.createDueButton),
          tooltip: AppStrings.createPaymentDue,
        ),
      ),
      body: cardsAsync.when(
        data: (cards) {
          final card = cards.firstWhere(
            (c) => c.id == cardId,
            orElse: () => throw Exception(AppStrings.cardNotFoundError),
          );
          return paymentsAsync.when(
            data: (payments) {
              final upcoming =
                  payments
                      .where((p) => p.cardId == cardId && !p.isPaid)
                      .toList();
              final history =
                  payments
                      .where((p) => p.cardId == cardId && p.isPaid)
                      .toList();

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(paymentProvider);
                  ref.invalidate(creditCardListProvider);
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Semantics(
                      label: '${AppStrings.cardLabel}: ${card.name}',
                      child: CreditCardTile(
                        card: card,
                        showLogPaymentButton: false,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      label: AppStrings.upcomingPayment,
                      child: Text(
                        AppStrings.upcomingPayment,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (upcoming.isEmpty)
                      Semantics(
                        label: AppStrings.noUpcomingDues,
                        child: Text(
                          AppStrings.noUpcomingDues,
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    else
                      Semantics(
                        label: AppStrings.upcomingPaymentCard,
                        child: GestureDetector(
                          onTap:
                              () => NavigationService.showBottomSheet(
                                context: context,
                                builder:
                                    (context) => LogPaymentBottomSheet(
                                      payment: upcoming.first,
                                    ),
                              ),
                          child: MinimalPaymentCard(payment: upcoming.first),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Semantics(
                      label: AppStrings.paymentHistory,
                      child: Text(
                        AppStrings.paymentHistory,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (history.isEmpty)
                      Semantics(
                        label: AppStrings.noPastPayments,
                        child: Text(
                          AppStrings.noPastPayments,
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    else
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: history.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final payment = history[index];
                          return Semantics(
                            label:
                                '${AppStrings.paymentHistoryItem}: ${payment.paidAmount}',
                            child: MinimalPaymentCard(payment: payment),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Semantics(
                        label: AppStrings.paymentLoadError,
                        child: Text(
                          '${AppStrings.paymentLoadError}: $error',
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
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
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    label: AppStrings.cardLoadError,
                    child: Text(
                      '${AppStrings.cardLoadError}: $error',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(creditCardListProvider),
                    child: Text(AppStrings.retryButton),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    switch (value) {
      case 'edit':
        NavigationService.navigateTo(
          context,
          AddCardScreen(
            card: ref
                .read(creditCardListProvider)
                .value!
                .firstWhere(
                  (c) => c.id == cardId,
                  orElse: () => throw Exception(AppStrings.cardNotFoundError),
                ),
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref);
        break;
      case 'archive':
        final card = ref
            .read(creditCardListProvider)
            .value!
            .firstWhere(
              (c) => c.id == cardId,
              orElse: () => throw Exception(AppStrings.cardNotFoundError),
            );
        await ref
            .read(creditCardListProvider.notifier)
            .save(card.copyWith(isArchived: true));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.cardArchivedSuccess)),
        );
        NavigationService.pop(context);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Semantics(
              label: AppStrings.deleteCardConfirmation,
              child: Text(AppStrings.deleteCardConfirmation),
            ),
            content: Text(AppStrings.deleteCardMessage),
            actions: [
              TextButton(
                onPressed: () => NavigationService.pop(context),
                child: Semantics(
                  label: AppStrings.cancelButton,
                  child: Text(AppStrings.cancelButton),
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final card = ref
                        .read(creditCardListProvider)
                        .value!
                        .firstWhere(
                          (c) => c.id == cardId,
                          orElse:
                              () =>
                                  throw Exception(AppStrings.cardNotFoundError),
                        );
                    await ref
                        .read(creditCardListProvider.notifier)
                        .delete(card.key);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.cardDeletedSuccess),
                      ),
                    );
                    NavigationService.pop(context); // Close dialog
                    NavigationService.pop(context); // Return to CardListScreen
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${AppStrings.cardDeleteError}: $e'),
                      ),
                    );
                  }
                },
                child: Semantics(
                  label: AppStrings.deleteButton,
                  child: Text(AppStrings.deleteButton),
                ),
              ),
            ],
          ),
    );
  }
}
