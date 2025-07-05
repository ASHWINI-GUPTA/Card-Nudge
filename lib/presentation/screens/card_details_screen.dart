import 'package:card_nudge/data/hive/models/credit_card_model.dart';
import 'package:card_nudge/data/hive/models/payment_model.dart';
import 'package:card_nudge/helper/date_extension.dart';
import 'package:card_nudge/presentation/providers/user_provider.dart';
import 'package:card_nudge/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_strings.dart';
import '../providers/credit_card_provider.dart';
import '../providers/payment_provider.dart';
import '../widgets/add_due_bottom_sheet.dart';
import '../widgets/credit_card_color_dot_indicator.dart';
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
          child: Text(card.name, style: theme.textTheme.titleLarge),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: theme.colorScheme.surface,
            elevation: 8,
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(AppStrings.editCard),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(Icons.archive, color: theme.colorScheme.secondary),
                        const SizedBox(width: 12),
                        Text(AppStrings.archiveCard),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 12),
                        Text(
                          AppStrings.deleteCard,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
            onSelected: (value) => _handleMenuAction(context, ref, value),
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
          // AG TODO: Update to supporting one upcoming payment per card.
          final upcoming =
              payments.where((p) => p.cardId == card.id && !p.isPaid).toList();
          final history =
              payments.where((p) => p.cardId == card.id && p.isPaid).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(paymentProvider);
              ref.invalidate(creditCardProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Semantics(
                  label: '${AppStrings.cardLabel}: ${card.name}',
                  child: CreditCardTile(cardId: card.id),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label: AppStrings.upcomingPayment,
                        child: Text(
                          AppStrings.upcomingPayment,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ),
                    if (upcoming.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: AppStrings.editCard,
                        onPressed: () {
                          NavigationService.showBottomSheet(
                            context: context,
                            builder:
                                (context) => AddDueBottomSheet(
                                  card: card,
                                  payment: upcoming.first,
                                ),
                          );
                        },
                      ),
                    if (upcoming.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: theme.colorScheme.error.withAlpha(220),
                        ),
                        tooltip: AppStrings.deleteCard,
                        onPressed: () {
                          _showDeletePaymentConfirmation(
                            context,
                            ref,
                            upcoming.first,
                          );
                        },
                      ),
                  ],
                ),
                if (upcoming.isEmpty) const SizedBox(height: 8),
                if (upcoming.isEmpty)
                  Builder(
                    builder: (context) {
                      String message;
                      final now = DateTime.now();
                      if (card.billingDate.isAfter(now)) {
                        final daysUntilBilling = card.billingDate
                            .differenceInDaysCeil(now);
                        message = AppStrings.nextBillingDateMessage(
                          daysUntilBilling,
                        );
                      } else {
                        message = AppStrings.noUpcomingDueMessage;
                      }

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Semantics(
                                label: message,
                                child: Text(
                                  message,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
                      color: theme.colorScheme.primary.withAlpha(26),
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
                  _listPayment(history),
              ],
            ),
          );
        },
        loading: () => const Center(child: CreditCardColorDotIndicator()),
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
                    child: Text(AppStrings.buttonRetry),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  ListView _listPayment(List<PaymentModel> paymentHistory) {
    final sortedHistory = [...paymentHistory]
      ..sort((a, b) => (b.paymentDate!).compareTo(a.paymentDate!));
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: sortedHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (context, index) {
        final payment = sortedHistory[index];
        return Semantics(
          label: '${AppStrings.paymentHistoryItem}: ${payment.paidAmount}',
          child: MinimalPaymentCard(payment: payment),
        );
      },
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
        await ref.read(creditCardProvider.notifier).markArchive(card.id);
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
                    await ref.read(creditCardProvider.notifier).delete(card.id);
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

  void _showDeletePaymentConfirmation(
    BuildContext context,
    WidgetRef ref,
    PaymentModel payment,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Semantics(
              label: AppStrings.deletePaymentConfirmation,
              child: Text(AppStrings.deletePaymentConfirmation),
            ),
            content: Text(AppStrings.deletePaymentMessage),
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
                    await ref.read(paymentProvider.notifier).delete(payment.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Upcoming payment deleted successfully'),
                      ),
                    );
                    NavigationService.pop(context); // Close dialog
                    ref.invalidate(paymentProvider); // Refresh payment list
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting payment: $e')),
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
