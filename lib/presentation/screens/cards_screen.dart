import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_strings.dart';
import '../../services/navigation_service.dart';
import '../providers/credit_card_provider.dart';
import '../widgets/credit_card_tile.dart';
import 'add_card_screen.dart';
import 'card_details_screen.dart';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(creditCardListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: AppStrings.cardsTitle,
          child: Text(
            AppStrings.cardsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(creditCardListProvider);
        },
        child: cardsAsync.when(
          data:
              (cards) =>
                  cards.isEmpty
                      ? Center(
                        child: Semantics(
                          label: AppStrings.noCardsMessage,
                          child: Text(
                            AppStrings.noCardsMessage,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
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
                                  CardDetailsScreen(cardId: card.id),
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
                      child: Text(AppStrings.retryButton),
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
              () =>
                  NavigationService.navigateTo(context, const AddCardScreen()),
          tooltip: AppStrings.addCard,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
