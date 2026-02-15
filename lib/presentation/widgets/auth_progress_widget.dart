import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/navigation_service.dart';
import '../providers/supabase_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/user_provider.dart';
import 'credit_card_color_dot_indicator.dart';

// Constants for UI elements
const _emojiSize = 48.0;
const _spacingSmall = 8.0;
const _spacingMedium = 16.0;
const _spacingLarge = 24.0;
const _horizontalPadding = 32.0;

class AuthProgress extends ConsumerStatefulWidget {
  const AuthProgress({super.key});

  @override
  ConsumerState<AuthProgress> createState() => _AuthProgressState();
}

class _AuthProgressState extends ConsumerState<AuthProgress> {
  bool _isSyncing = false;
  bool _isUserLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserAndSync();
  }

  Future<void> _checkUserAndSync() async {
    final supabaseService = ref.read(supabaseServiceProvider);

    // Parse User Details
    setState(() {
      _isUserLoading = true;
      _isSyncing = false;
    });

    await supabaseService.syncUserDetails();

    var user = ref.watch(userProvider);
    if (user != null) {
      setState(() {
        _isUserLoading = false;
        _isSyncing = true;
      });
    } else {
      // Wait for user to be loaded
      await Future.delayed(const Duration(milliseconds: 500));
      user = ref.watch(userProvider);
      if (user == null) {
        setState(() {
          _isUserLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user details')),
        );
        await NavigationService.goToRoute(
          context,
          '/error?message=Failed to load user details',
        );
        return;
      }
    }

    try {
      final syncService = ref.read(syncServiceProvider);

      if (syncService.isInitialized) {
        if (mounted) {
          NavigationService.goToRoute(context, '/home');
        }
        // Run sync in background
        syncService.syncData().catchError((e) {
          debugPrint('Background sync error: $e');
        });
      } else {
        await syncService.initialSync(user.id);
        if (mounted) {
          NavigationService.goToRoute(context, '/home');
        }
      }

      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
      if (mounted) {
        await NavigationService.goToRoute(
          context,
          '/error?message=Sync failed: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🚀', style: TextStyle(fontSize: _emojiSize)),
                const SizedBox(height: _spacingMedium),
                const CreditCardColorDotIndicator(),
                const SizedBox(height: _spacingLarge),
                Text(
                  _isUserLoading
                      ? 'Loading your profile... 🌟'
                      : 'Setting up your cards... 💳✨',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: _spacingSmall),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _horizontalPadding,
                  ),
                  child: Text(
                    _isUserLoading
                        ? "We're fetching your details to get started! 😊"
                        : _isSyncing
                        ? "We're syncing your cards and banks to get you started! 😊"
                        : 'Sync complete! Redirecting... 🎉',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withAlpha(
                        179,
                      ), // 0.7 opacity (179/255)
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
