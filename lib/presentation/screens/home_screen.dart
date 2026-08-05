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

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.credit_card_outlined),
      selectedIcon: Icon(Icons.credit_card),
      label: 'Cards',
    ),
    NavigationDestination(
      icon: Icon(Icons.event_note_outlined),
      selectedIcon: Icon(Icons.event_note),
      label: 'Dues',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  void _showDemoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.science_outlined, color: Colors.lightBlue),
                SizedBox(width: 8),
                Text('Demo Mode Active'),
              ],
            ),
            content: const Text(
              'You are currently running in Demo Mode. Your card dues and details are stored locally.\n\n'
              'To sync your cards across devices, please sign in with an account.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue Demo'),
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
                child: const Text('Exit & Sign In'),
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

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
        selectedIndex: _selectedIndex,
        destinations: [
          ..._destinations,
          if (isDemo)
            const NavigationDestination(
              icon: Icon(Icons.science_outlined, color: Colors.lightBlue),
              selectedIcon: Icon(Icons.science, color: Colors.lightBlue),
              label: 'Demo Mode',
            ),
        ],
        onDestinationSelected: (index) {
          if (isDemo && index == _destinations.length) {
            _showDemoDialog(context);
          } else {
            setState(() => _selectedIndex = index);
          }
        },
      ),
    );
  }
}
