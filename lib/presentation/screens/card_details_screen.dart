import 'package:card_nudge/data/hive/models/credit_card_model.dart';
import 'package:card_nudge/presentation/providers/user_provider.dart';
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
  final CreditCardModel card;

  const CardDetailsScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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
                    value: 'archive',
                    child: ListTile(
                      leading: const Icon(Icons.archive),
                      title: Semantics(
                        label: AppStrings.archiveCard,
                        child: Text(AppStrings.archiveCard),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: Semantics(
                        label: AppStrings.deleteCard,
                        child: Text(AppStrings.deleteCard),
                      ),
                    ),
                  ),
                ],
          ),
        ],
      ),
      floatingActionButton: Semantics(
        label: AppStrings.addPaymentDue,
        child: FloatingActionButton.extended(
          onPressed:
              () => NavigationService.showBottomSheet(
                context: context,
                builder: (context) => AddDueBottomSheet(card: card),
              ),
          icon: const Icon(Icons.add),
          label: Text(AppStrings.addDueButton),
          tooltip: AppStrings.addPaymentDue,
        ),
      ),
      body: paymentsAsync.when(
        data: (payments) {
          final upcoming =
              payments.where((p) => p.cardId == card.id && !p.isPaid).toList();
          final history =
              payments.where((p) => p.cardId == card.id && p.isPaid).toList();

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
                  child: CreditCardTile(card: card),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(
                        (0.1 * 255).toInt(),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Semantics(
                            label: AppStrings.noUpcomingDues,
                            child: Text(
                              AppStrings.noUpcomingDues,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(
                        (0.1 * 255).toInt(),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Semantics(
                            label: AppStrings.noPastPayments,
                            child: Text(
                              AppStrings.noPastPayments,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
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
                    child: Text(AppStrings.retryButtonLabel),
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
    final user = ref.watch(userProvider)!;

    switch (value) {
      case 'edit':
        NavigationService.navigateTo(
          context,
          AddCardScreen(card: card, user: user),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref);
        break;
      case 'archive':
        await ref.read(creditCardListProvider.notifier).markArchive(card.id);
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
                    await ref
                        .read(creditCardListProvider.notifier)
                        .delete(card.id);
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
