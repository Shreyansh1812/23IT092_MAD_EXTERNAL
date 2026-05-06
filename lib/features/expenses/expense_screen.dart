import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'expense_provider.dart';
import 'expense_model.dart';
import '../trips/trip_provider.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  final String tripId;
  const ExpenseScreen({super.key, required this.tripId});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allExpenses = ref.watch(expenseProvider);
    final expenses = allExpenses.where((e) => e.tripId == widget.tripId).toList();
    final trips = ref.watch(tripProvider);
    final trip = trips.firstWhere((t) => t.id == widget.tripId,
        orElse: () => trips.isEmpty ? throw Exception() : trips.first);
    final participants = trip.participants;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Expenses'),
            Tab(text: 'Settlements'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // --- All Expenses Tab ---
              expenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 80,
                              color: theme.colorScheme.primary.withOpacity(0.4)),
                          const SizedBox(height: 16),
                          Text('No expenses yet',
                              style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6))),
                          const SizedBox(height: 8),
                          Text('Tap + to add an expense',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.4))),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        final perPerson =
                            expense.amount / expense.splitBetween.length;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: theme.colorScheme.outlineVariant
                                    .withOpacity(0.5)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.payments_outlined,
                                  color:
                                      theme.colorScheme.onTertiaryContainer),
                            ),
                            title: Text(expense.description,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Paid by: ${expense.paidBy}'),
                                Text(
                                    DateFormat('MMM d, y').format(expense.date),
                                    style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.5),
                                        fontSize: 12)),
                                Text(
                                    '₹${perPerson.toStringAsFixed(2)}/person · ${expense.splitBetween.length} people',
                                    style: TextStyle(
                                        color: theme.colorScheme.secondary,
                                        fontSize: 12)),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${expense.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                if (expense.category != null)
                                  Text(expense.category!,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.5))),
                              ],
                            ),
                            onLongPress: () => _confirmDelete(context, ref, expense.id),
                          ),
                        );
                      },
                    ),

              // --- Settlements Tab ---
              _SettlementsView(tripId: widget.tripId, participants: participants),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Remove this expense?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                ref.read(expenseProvider.notifier).deleteExpense(id);
                Navigator.pop(ctx);
              },
              child:
                  const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settlements View
// ---------------------------------------------------------------------------
class _SettlementsView extends ConsumerWidget {
  final String tripId;
  final List<String> participants;
  const _SettlementsView(
      {required this.tripId, required this.participants});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allExpenses = ref.watch(expenseProvider);
    final expenses =
        allExpenses.where((e) => e.tripId == tripId).toList();

    if (expenses.isEmpty) {
      return Center(
        child: Text('No expenses to settle',
            style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5))),
      );
    }

    // Calculate per-participant totals
    final Map<String, double> paid = {for (var p in participants) p: 0.0};
    final Map<String, double> share = {for (var p in participants) p: 0.0};

    for (var e in expenses) {
      paid[e.paidBy] = (paid[e.paidBy] ?? 0) + e.amount;
      final perPerson = e.amount / e.splitBetween.length;
      for (var p in e.splitBetween) {
        share[p] = (share[p] ?? 0) + perPerson;
      }
    }

    final Map<String, double> balances = {};
    for (var p in participants) {
      balances[p] = (paid[p] ?? 0) - (share[p] ?? 0);
    }

    // Greedy settlement algorithm
    final debtors = balances.entries
        .where((e) => e.value < -0.01)
        .map((e) => MapEntry(e.key, -e.value))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final creditors = balances.entries
        .where((e) => e.value > 0.01)
        .map((e) => MapEntry(e.key, e.value))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final List<Map<String, dynamic>> settlements = [];
    int i = 0, j = 0;
    while (i < debtors.length && j < creditors.length) {
      final debt = debtors[i].value;
      final credit = creditors[j].value;
      final settled = debt < credit ? debt : credit;
      settlements.add({
        'from': debtors[i].key,
        'to': creditors[j].key,
        'amount': settled,
      });
      debtors[i] = MapEntry(debtors[i].key, debt - settled);
      creditors[j] = MapEntry(creditors[j].key, credit - settled);
      if (debtors[i].value < 0.01) i++;
      if (creditors[j].value < 0.01) j++;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Per-participant summary
        Text('Summary per Participant',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...participants.map((p) {
          final balance = balances[p] ?? 0;
          final isPositive = balance >= 0;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                  color: isPositive
                      ? Colors.green.withOpacity(0.4)
                      : Colors.red.withOpacity(0.4)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                child: Text(p[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white)),
              ),
              title: Text(p, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                  'Paid: ₹${(paid[p] ?? 0).toStringAsFixed(2)}  |  Share: ₹${(share[p] ?? 0).toStringAsFixed(2)}'),
              trailing: Text(
                '${isPositive ? '+' : ''}₹${balance.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ),
          );
        }),
        if (settlements.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Who Owes Whom',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...settlements.map((s) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: theme.colorScheme.errorContainer.withOpacity(0.3),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: const Icon(Icons.arrow_forward, color: Colors.red),
                  title: Text(
                    '${s['from']} owes ${s['to']}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Text(
                    '₹${(s['amount'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 15),
                  ),
                ),
              )),
        ] else
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Card(
              color: Colors.green.withOpacity(0.1),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: const ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('All settled up! 🎉',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
      ],
    );
  }
}
