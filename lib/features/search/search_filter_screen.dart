import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../trips/trip_provider.dart';
import '../expenses/expense_provider.dart';

class SearchFilterScreen extends ConsumerStatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  ConsumerState<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends ConsumerState<SearchFilterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedParticipant;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trips = ref.watch(tripProvider);
    final allExpenses = ref.watch(expenseProvider);

    final filteredTrips = trips
        .where((t) =>
            t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            t.destination.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // All participants across trips
    final allParticipants = trips
        .expand((t) => t.participants)
        .toSet()
        .toList()
      ..sort();

    var filteredExpenses = allExpenses.toList();
    if (_selectedParticipant != null) {
      filteredExpenses = filteredExpenses
          .where((e) =>
              e.paidBy == _selectedParticipant ||
              e.splitBetween.contains(_selectedParticipant))
          .toList();
    }
    if (_dateRange != null) {
      filteredExpenses = filteredExpenses.where((e) {
        return !e.date.isBefore(_dateRange!.start) &&
            !e.date.isAfter(_dateRange!.end);
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filteredExpenses = filteredExpenses
          .where((e) =>
              e.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Trips'),
            Tab(text: 'Expenses'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
              ],
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Expense filters (only visible on expenses tab)
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              if (_tabController.index != 1) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedParticipant,
                        hint: const Text('Filter by person'),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All')),
                          ...allParticipants.map((p) =>
                              DropdownMenuItem(value: p, child: Text(p))),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedParticipant = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.date_range, size: 16),
                      label: Text(_dateRange == null
                          ? 'Date'
                          : '${DateFormat('d MMM').format(_dateRange!.start)}–${DateFormat('d MMM').format(_dateRange!.end)}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                      onPressed: () async {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDateRange: _dateRange,
                        );
                        setState(() => _dateRange = range);
                      },
                    ),
                    if (_dateRange != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => setState(() => _dateRange = null),
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // --- Trips Tab ---
                filteredTrips.isEmpty
                    ? Center(
                        child: Text('No trips found',
                            style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5))))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredTrips.length,
                        itemBuilder: (context, index) {
                          final trip = filteredTrips[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                  color: theme.colorScheme.outlineVariant
                                      .withOpacity(0.5)),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary,
                                child: Text(trip.name[0].toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                              title: Text(trip.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '${trip.destination} · ${trip.participants.length} participants'),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 14),
                              onTap: () =>
                                  context.push('/dashboard/${trip.id}'),
                            ),
                          );
                        },
                      ),

                // --- Expenses Tab ---
                filteredExpenses.isEmpty
                    ? Center(
                        child: Text('No expenses found',
                            style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5))))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = filteredExpenses[index];
                          final tripName = trips
                              .firstWhere((t) => t.id == expense.tripId,
                                  orElse: () => trips.first)
                              .name;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                  color: theme.colorScheme.outlineVariant
                                      .withOpacity(0.5)),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.receipt,
                                    color:
                                        theme.colorScheme.onTertiaryContainer,
                                    size: 20),
                              ),
                              title: Text(expense.description,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '$tripName · Paid by ${expense.paidBy} · ${DateFormat('MMM d').format(expense.date)}'),
                              trailing: Text(
                                '₹${expense.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
