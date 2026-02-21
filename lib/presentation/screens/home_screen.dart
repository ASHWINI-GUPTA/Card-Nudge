import 'package:card_nudge/presentation/screens/setting_screen.dart';
import 'package:card_nudge/presentation/widgets/update_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'cards_screen.dart';
import 'due_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Check for app updates after the first frame is rendered.
    // The InAppUpdateService has built-in cooldown (24h) and re-entrancy
    // guards, so this is safe to call on every HomeScreen mount without
    // risk of looping or spamming the Play Store API.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
        selectedIndex: _selectedIndex,
        destinations: _destinations,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
