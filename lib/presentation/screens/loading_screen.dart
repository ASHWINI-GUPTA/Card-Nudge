import 'package:flutter/material.dart';
import '../widgets/credit_card_color_dot_indicator.dart';

const bankPaymentCardSettingsEmojis = [
  '🏦', // Bank
  '💳', // Credit Card
  '🏧', // ATM
  '💰', // Money Bag
  '💸', // Money with Wings
  '🧾', // Receipt
  '📈', // Chart Increasing
  '📉', // Chart Decreasing
  '🔒', // Security/Lock
  '⚙️', // Settings
  '🔔', // Notification/Reminder
  '🗓️', // Calendar (for due dates)
  '✅', // Success/Checkmark
  '🔄', // Sync/Refresh
  '🪙', // Coin
  '🧑‍💼', // Banker/Account
];

const _emojiSize = 64.0;

class LoadingIndicatorScreen extends StatelessWidget {
  const LoadingIndicatorScreen({super.key});

  String _getRandomEmoji() {
    final now = DateTime.now();
    return bankPaymentCardSettingsEmojis[(now.microsecond + now.second) %
        bankPaymentCardSettingsEmojis.length];
  }

  @override
  Widget build(BuildContext context) {
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
                'Loading, please wait...',
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
