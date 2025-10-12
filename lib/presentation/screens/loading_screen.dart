import 'package:card_nudge/helper/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../helper/emoji_helper.dart';
import '../widgets/credit_card_color_dot_indicator.dart';

const _emojiSize = 64.0;

class LoadingIndicatorScreen extends ConsumerWidget {
  const LoadingIndicatorScreen({super.key});

  String _getRandomEmoji() {
    final now = DateTime.now();
    return paymentCardEmojiList[(now.microsecond + now.second) %
        paymentCardEmojiList.length];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withAlpha(26),
              colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(scale: value, child: child),
                  );
                },
                child: Text(
                  _getRandomEmoji(),
                  style: const TextStyle(fontSize: _emojiSize),
                ),
              ),
              const SizedBox(height: 32),
              const CreditCardColorDotIndicator(),
              const SizedBox(height: 32),
              Text(
                context.l10n.loading,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
