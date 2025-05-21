import 'package:card_nudge/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_strings.dart';
import '../providers/credit_card_provider.dart';
import '../widgets/credit_card_tile.dart';
import 'add_card_screen.dart';

class CardListScreen extends ConsumerWidget {
  const CardListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the synchronous List<CreditCardModel> from creditCardListProvider
    final cards = ref.watch(creditCardListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: AppStrings.cardsTitle,
          child: const Text(AppStrings.cardsTitle),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate provider to trigger reload
          ref.invalidate(creditCardListProvider);
          // Wait for the notifier's loadCards to complete
          await ref.read(creditCardListProvider.notifier).loadCards();
        },
        child:
            cards.isEmpty
                ? Center(
                  child: Semantics(
                    label: AppStrings.noCardsMessage,
                    child: Text(
                      AppStrings.noCardsMessage,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
                : ListView.separated(
                  padding: const EdgeInsets.all(16.0), // Use constant padding
                  physics: const BouncingScrollPhysics(),
                  itemCount: cards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return CreditCard(
                      key: ValueKey(card.id), // Unique key for each card
                      card: card,
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => NavigationService.navigateTo(context, const AddCardScreen()),
        tooltip: AppStrings.addCard, // Accessibility
        child: const Icon(Icons.add),
      ),
    );
  }
}
