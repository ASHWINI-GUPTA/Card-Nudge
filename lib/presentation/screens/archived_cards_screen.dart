import 'package:card_nudge/helper/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/navigation_service.dart';
import '../providers/credit_card_provider.dart';
import '../widgets/credit_card_color_dot_indicator.dart';
import '../widgets/credit_card_details_list_tile.dart';
import 'card_details_screen.dart';

class ArchivedCardsScreen extends ConsumerWidget {
  const ArchivedCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(creditCardProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.archivedCardsTitle,
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(creditCardProvider);
        },
        child: cardsAsync.when(
          data: (cards) {
            final archivedCards =
                cards.where((card) => card.isArchived).toList();
            return archivedCards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.archive_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.archivedCardsEmptyStateTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.archivedCardsEmptyStateSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(8.0),
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: archivedCards.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (context, index) {
                      final card = archivedCards[index];
                      return GestureDetector(
                        onTap: () => NavigationService.navigateTo(
                          context,
                          CardDetailsScreen(card: card),
                        ),
                        child: Semantics(
                          label: '${context.l10n.archivedCardsTitle}: ${card.name}',
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
          error: (error, stack) => Center(
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
    );
  }
}
