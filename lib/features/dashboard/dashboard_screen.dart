import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../itinerary/itinerary_screen.dart';
import '../expenses/expense_screen.dart';
import '../expenses/add_expense_dialog.dart';
import '../trips/trip_provider.dart';
import 'trip_summary_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final String tripId;
  const DashboardScreen({super.key, required this.tripId});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  static const _titles = ['Trip Dashboard', 'Itinerary', 'Expenses'];

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripProvider);
    final tripExists = trips.any((t) => t.id == widget.tripId);
    if (!tripExists) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final trip = trips.firstWhere((t) => t.id == widget.tripId);

    final screens = [
      TripSummaryScreen(tripId: widget.tripId),
      ItineraryScreen(tripId: widget.tripId),
      ExpenseScreen(tripId: widget.tripId),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
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
      floatingActionButton: _currentIndex == 1
          ? null // Itinerary has its own FAB
          : _currentIndex == 2
              ? FloatingActionButton.extended(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddExpenseDialog(
                        tripId: widget.tripId,
                        participants: trip.participants,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Expense'),
                )
              : null,
    );
  }
}


