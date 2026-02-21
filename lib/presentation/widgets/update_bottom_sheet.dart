import 'package:flutter/material.dart';

import '../../services/in_app_update_service.dart';
import 'credit_card_color_dot_indicator.dart';

/// A minimal, polished bottom sheet that notifies the user about an available
/// app update. Offers "Update" and "Skip" actions.
///
/// Usage:
/// ```dart
/// UpdateBottomSheet.show(context);
/// ```
class UpdateBottomSheet extends StatefulWidget {
  const UpdateBottomSheet({super.key});

  /// Shows the update bottom sheet if an update is available.
  ///
  /// This is the primary entry point. It checks for an update via
  /// [InAppUpdateService] and only shows the sheet if one is found.
  /// All errors are silently caught to avoid disrupting the user.
  static Future<void> show(BuildContext context) async {
    try {
      final result = await InAppUpdateService.instance.checkForUpdate();

      if (!result.updateAvailable) return;

      // Guard: ensure context is still mounted before showing the sheet
      if (!context.mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        isDismissible: true,
        enableDrag: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => const UpdateBottomSheet(),
      );
    } catch (e) {
      // Silently fail — update prompts should never crash the app
      debugPrint('[UpdateBottomSheet] Error showing update sheet: $e');
    }
  }

  @override
  State<UpdateBottomSheet> createState() => _UpdateBottomSheetState();
}

class _UpdateBottomSheetState extends State<UpdateBottomSheet> {
  bool _isUpdating = false;

  Future<void> _onUpdate() async {
    if (_isUpdating) return;

    setState(() => _isUpdating = true);

    final success = await InAppUpdateService.instance.startFlexibleUpdate();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      // The flexible update downloads in the background.
      // completeFlexibleUpdate() will be called when the download is ready,
      // typically on next app restart or via a separate trigger.
    } else {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Could not start update. Please try again later.',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _onSkip() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Icon
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.system_update_rounded,
                size: 32,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Update Available',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'A new version of the app is ready. Update now for the latest improvements and fixes.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                // Skip button
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isUpdating ? null : _onSkip,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Later',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Update button
                Expanded(
                  child: FilledButton(
                    onPressed: _isUpdating ? null : _onUpdate,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isUpdating
                            ? const CreditCardColorDotIndicator()
                            : const Text(
                              'Update',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
