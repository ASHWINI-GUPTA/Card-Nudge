import 'package:card_nudge/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _errorEmojis = [
  '😕',
  '😟',
  '😥',
  '😓',
  '🤔',
  '😶',
  '😑',
  '🙁',
  '😬',
  '😔',
  '👨‍🔧',
  '🤦‍♀️',
  '🙈',
  '🤦',
  '🤦‍♂️',
];
const _emojiSize = 64.0;

class ErrorScreen extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const ErrorScreen({super.key, this.message, this.onRetry});

  String _getRandomEmoji() {
    final now = DateTime.now();
    return _errorEmojis[(now.microsecond + now.second) % _errorEmojis.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark
                  ? colorScheme.error.withAlpha(120)
                  : colorScheme.error.withAlpha(220),
              isDark
                  ? colorScheme.errorContainer.withAlpha(160)
                  : colorScheme.errorContainer.withAlpha(240),
            ],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Emoji
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
                      const SizedBox(height: 20),
                      // Headline
                      Text(
                        'Something went wrong!',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      // Description
                      Text(
                        message ?? AppStrings.errorGeneric,

                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.white70 : Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (onRetry != null) ...[
                            ElevatedButton.icon(
                              onPressed: onRetry,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text(AppStrings.buttonRetry),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isDark
                                        ? Colors.white12
                                        : colorScheme.primary,
                                foregroundColor:
                                    isDark
                                        ? Colors.white
                                        : colorScheme.onPrimary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side:
                                      isDark
                                          ? const BorderSide(
                                            color: Colors.white24,
                                          )
                                          : BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                          ],
                          ElevatedButton.icon(
                            onPressed: () => context.go('/'),
                            icon: const Icon(Icons.home, size: 24),
                            label: Text(
                              AppStrings.buttonHome,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isDark
                                      ? colorScheme.errorContainer.withAlpha(
                                        120,
                                      )
                                      : Colors.white,
                              foregroundColor:
                                  isDark ? Colors.white : colorScheme.error,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side:
                                    isDark
                                        ? const BorderSide(
                                          color: Colors.white24,
                                        )
                                        : BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
