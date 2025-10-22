import 'package:card_nudge/helper/app_localizations_extension.dart';
import 'package:card_nudge/presentation/screens/spend_analysis_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/navigation_service.dart';
import '../providers/credit_card_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/credit_card_color_dot_indicator.dart';
import '../widgets/credit_card_details_list_tile.dart';
import '../widgets/empty_credit_card_list_widget.dart';
import '../widgets/data_sync_progress_bar.dart';
import 'card_card_form_screen.dart';
import 'card_details_screen.dart';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(creditCardProvider);
    final theme = Theme.of(context);
    final user = ref.read(userProvider);
    if (user == null) {
      throw Exception('User not found');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.cardsScreenTitle,
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Spend Analysis',
            icon: const Icon(Icons.analytics_outlined),
            onPressed:
                () => NavigationService.navigateTo(
                  context,
                  const SpendAnalysisScreen(),
                ),
          ),
        ],
        backgroundColor: theme.primaryColor,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: DataSynchronizationProgressBar(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(creditCardProvider);
        },
        child: cardsAsync.when(
          data: (cards) {
            final activeCards =
                cards.where((card) => !card.isArchived).toList();
            return activeCards.isEmpty
                ? EmptyCreditCardListWidget(context: context, ref: ref)
                : ListView.separated(
                  padding: const EdgeInsets.all(8.0),
                  physics: const BouncingScrollPhysics(),
                  itemCount: activeCards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 0),
                  itemBuilder: (context, index) {
                    final card = activeCards[index];
                    return GestureDetector(
                      onTap:
                          () => NavigationService.navigateTo(
                            context,
                            CardDetailsScreen(card: card),
                          ),
                      child: Semantics(
                        label: '${context.l10n.cardsScreenTitle}: ${card.name}',
                        child: CreditCardDetailsListTile(
                          key: ValueKey(card.id),
                          cardId: card.id,
                        ),
                      ),
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
                    Semantics(
                      label: context.l10n.cardsScreenErrorTitle,
                      child: Text(
                        '${context.l10n.cardsScreenErrorTitle}: $error',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
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
      ),
      floatingActionButton: Semantics(
        label: context.l10n.buttonAddCard,
        child: FloatingActionButton(
          onPressed:
              () => NavigationService.navigateTo(
                context,
                CreditCardFormScreen(user: user),
              ),
          tooltip: context.l10n.buttonAddCard,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
