import 'package:card_nudge/presentation/screens/setting_screen.dart';
import 'package:card_nudge/presentation/widgets/update_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_screen.dart';
import 'cards_screen.dart';
import 'due_screen.dart';
import '../providers/user_provider.dart';
import '../providers/router_provider.dart';
import '../../services/navigation_service.dart';
import '../../helper/app_localizations_extension.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Check for app updates after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        UpdateBottomSheet.show(context);
      }
    });
  }

  final List<Widget> _screens = const [
    DashboardScreen(),
    CardsScreen(),
    DueScreen(),
    SettingsScreen(),
  ];

  List<NavigationDestination> _getDestinations(BuildContext context) {
    return [
      NavigationDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard),
        label: context.l10n.dashboard,
      ),
      NavigationDestination(
        icon: const Icon(Icons.credit_card_outlined),
        selectedIcon: const Icon(Icons.credit_card),
        label: context.l10n.cards,
      ),
      NavigationDestination(
        icon: const Icon(Icons.event_note_outlined),
        selectedIcon: const Icon(Icons.event_note),
        label: context.l10n.dues,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: context.l10n.settings,
      ),
    ];
  }

  void _showDemoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.science_outlined, color: Colors.lightBlue),
                const SizedBox(width: 8),
                Text(context.l10n.demoModeActive),
              ],
            ),
            content: Text(context.l10n.demoModeDescription),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.continueDemo),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await ref.read(userProvider.notifier).clearUserDetails();
                  final navContext = notificationNavigatorKey.currentContext;
                  if (navContext != null) {
                    NavigationService.goToRoute(navContext, '/auth');
                  }
                },
                child: Text(context.l10n.exitAndSignIn),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(userProvider);
    final isDemo = user?.id == 'demo-user';

    final destinations = _getDestinations(context);

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
        selectedIndex: _selectedIndex,
        destinations: [
          ...destinations,
          if (isDemo)
            NavigationDestination(
              icon: const Icon(Icons.science_outlined, color: Colors.lightBlue),
              selectedIcon: const Icon(Icons.science, color: Colors.lightBlue),
              label: context.l10n.demoMode,
            ),
        ],
        onDestinationSelected: (index) {
          if (isDemo && index == destinations.length) {
            _showDemoDialog(context);
          } else {
            setState(() => _selectedIndex = index);
          }
        },
      ),
    );
  }
}
