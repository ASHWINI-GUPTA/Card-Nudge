// import 'package:card_nudge/presentation/screens/upcoming_due_screen.dart';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'cards_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CardsScreen(),
    // const UpcomingDueScreen(),
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
    // NavigationDestination(
    //   icon: Icon(Icons.event_note_outlined),
    //   selectedIcon: Icon(Icons.event_note),
    //   label: 'Due',
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: _destinations,
        onDestinationSelected:
            (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
