import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_strings.dart';
import '../../services/navigation_service.dart';
import '../providers/credit_card_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/credit_card_tile.dart';
import '../widgets/empty_state_widget.dart';
import 'add_card_screen.dart';
import 'card_details_screen.dart';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(creditCardListProvider);
    final theme = Theme.of(context);
    final user = ref.watch(userProvider);
    if (user == null) {
      throw Exception('User not found');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.cardsTitle,
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {}, // Placeholder for future filter
          ),
        ],
        backgroundColor: theme.primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(creditCardListProvider);
        },
        child: cardsAsync.when(
          data:
              (cards) =>
                  cards.isEmpty
                      ? _buildEmptyStateNoCards(context, ref)
                      : ListView.separated(
                        padding: const EdgeInsets.all(8.0),
                        physics: const BouncingScrollPhysics(),
                        itemCount: cards.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 0),
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return GestureDetector(
                            onTap:
                                () => NavigationService.navigateTo(
                                  context,
                                  CardDetailsScreen(card: card),
                                ),
                            child: Semantics(
                              label: '${AppStrings.cardLabel}: ${card.name}',
                              child: CreditCardTile(
                                key: ValueKey(card.id),
                                card: card,
                              ),
                            ),
                          );
                        },
                      ),
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
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(creditCardListProvider),
                      child: Text(AppStrings.retryButtonLabel),
                    ),
                  ],
                ),
              ),
        ),
      ),
      floatingActionButton: Semantics(
        label: AppStrings.addCard,
        child: FloatingActionButton(
          onPressed:
              () => NavigationService.navigateTo(
                context,
                AddCardScreen(user: user),
              ),
          tooltip: AppStrings.addCard,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildEmptyStateNoCards(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return EmptyStateWidget(
      message: AppStrings.noCardsMessage,
      buttonText: AppStrings.addCardButton,
      onButtonPressed:
          () =>
              NavigationService.navigateTo(context, AddCardScreen(user: user)),
    );
  }
}
