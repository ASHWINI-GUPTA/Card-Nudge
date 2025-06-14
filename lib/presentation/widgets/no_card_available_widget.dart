import 'package:card_nudge/constants/app_strings.dart';
import 'package:card_nudge/presentation/providers/user_provider.dart';
import 'package:card_nudge/presentation/screens/add_card_screen.dart';
import 'package:card_nudge/presentation/widgets/empty_state_widget.dart';
import 'package:card_nudge/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoCardAvailableWidget extends StatelessWidget {
  const NoCardAvailableWidget({
    super.key,
    required this.context,
    required this.ref,
  });

  final BuildContext context;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    return EmptyStateWidget(
      message: AppStrings.cardsScreenEmptyStateTitle,
      buttonText: AppStrings.buttonAddCard,
      onButtonPressed:
          () =>
              NavigationService.navigateTo(context, AddCardScreen(user: user)),
    );
  }
}
