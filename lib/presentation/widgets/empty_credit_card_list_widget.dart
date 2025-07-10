import 'package:card_nudge/helper/app_localizations_extension.dart';
import 'package:card_nudge/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/user_provider.dart';
import '../screens/add_card_screen.dart';
import 'no_data_placeholder_widget.dart';

class EmptyCreditCardListWidget extends StatelessWidget {
  const EmptyCreditCardListWidget({
    super.key,
    required this.context,
    required this.ref,
  });

  final BuildContext context;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    return NoDataPlaceholderWidget(
      message: context.l10n.cardsScreenEmptyStateTitle,
      buttonText: context.l10n.buttonAddCard,
      onButtonPressed:
          () =>
              NavigationService.navigateTo(context, AddCardScreen(user: user)),
    );
  }
}
