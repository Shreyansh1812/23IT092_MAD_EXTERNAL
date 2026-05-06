import 'package:flutter/material.dart';
import '../itinerary/itinerary_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String tripId;

  const DashboardScreen({super.key, required this.tripId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      Center(child: Text('Dashboard Summary for Trip: ${widget.tripId}')),
      ItineraryScreen(tripId: widget.tripId),
      Center(child: Text('Expenses for Trip: ${widget.tripId}')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'Trip Dashboard'
              : _currentIndex == 1
                  ? 'Itinerary'
                  : 'Expenses',
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Summary',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Itinerary',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Expenses',
          ),
        ],
      ),
    );
  }
}

