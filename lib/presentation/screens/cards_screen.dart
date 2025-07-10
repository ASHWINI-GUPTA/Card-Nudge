import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_strings.dart';
import '../../services/navigation_service.dart';
import '../providers/credit_card_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/credit_card_color_dot_indicator.dart';
import '../widgets/credit_card_details_list_tile.dart';
import '../widgets/empty_credit_card_list_widget.dart';
import '../widgets/data_sync_progress_bar.dart';
import 'add_card_screen.dart';
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
          AppStrings.cardsScreenTitle,
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
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
          data:
              (cards) =>
                  cards.isEmpty
                      ? EmptyCreditCardListWidget(context: context, ref: ref)
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
                              label:
                                  '${AppStrings.cardsScreenTitle}: ${card.name}',
                              child: CreditCardDetailsListTile(
                                key: ValueKey(card.id),
                                cardId: card.id,
                              ),
                            ),
                          );
                        },
                      ),
          loading: () => const Center(child: CreditCardColorDotIndicator()),
          error:
              (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Semantics(
                      label: AppStrings.cardsScreenErrorTitle,
                      child: Text(
                        '${AppStrings.cardsScreenErrorTitle}: $error',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(creditCardProvider),
                      child: Text(AppStrings.buttonRetry),
                    ),
                  ],
                ),
              ),
        ),
      ),
      floatingActionButton: Semantics(
        label: AppStrings.buttonAddCard,
        child: FloatingActionButton(
          onPressed:
              () => NavigationService.navigateTo(
                context,
                AddCardScreen(user: user),
              ),
          tooltip: AppStrings.buttonAddCard,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
