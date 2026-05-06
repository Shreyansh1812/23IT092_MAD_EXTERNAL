import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../trips/trip_provider.dart';
import '../expenses/expense_provider.dart';

class TripSummaryScreen extends ConsumerWidget {
  final String tripId;
  const TripSummaryScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final trips = ref.watch(tripProvider);
    final allExpenses = ref.watch(expenseProvider);

    final trip = trips.firstWhere((t) => t.id == tripId,
        orElse: () => trips.isEmpty ? throw Exception() : trips.first);
    final expenses =
        allExpenses.where((e) => e.tripId == tripId).toList();

    final totalExpenses =
        expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final duration = trip.endDate.difference(trip.startDate).inDays;

    // Calculate pending balances
    final Map<String, double> paid = {for (var p in trip.participants) p: 0.0};
    final Map<String, double> share = {for (var p in trip.participants) p: 0.0};
    for (var e in expenses) {
      paid[e.paidBy] = (paid[e.paidBy] ?? 0) + e.amount;
      final perPerson = e.amount / e.splitBetween.length;
      for (var p in e.splitBetween) {
        share[p] = (share[p] ?? 0) + perPerson;
      }
    }
    final pendingCount = trip.participants
        .where((p) => ((paid[p] ?? 0) - (share[p] ?? 0)) < -0.01)
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Hero card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(trip.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(trip.destination,
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                      '${DateFormat('MMM d').format(trip.startDate)} – ${DateFormat('MMM d, y').format(trip.endDate)}',
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Stat cards
        Row(
          children: [
            _StatCard(
              icon: Icons.monetization_on,
              label: 'Total Expenses',
              value: '₹${totalExpenses.toStringAsFixed(2)}',
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            _StatCard(
              icon: Icons.group,
              label: 'Participants',
              value: '${trip.participants.length}',
              color: theme.colorScheme.secondary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatCard(
              icon: Icons.pending_actions,
              label: 'Pending Balances',
              value: '$pendingCount people',
              color: pendingCount > 0 ? Colors.orange : Colors.green,
            ),
            const SizedBox(width: 12),
            _StatCard(
              icon: Icons.today,
              label: 'Duration',
              value: '$duration days',
              color: theme.colorScheme.tertiary,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Participants section
        Text('Participants',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: trip.participants.map((p) {
            final balance = (paid[p] ?? 0) - (share[p] ?? 0);
            final color = balance >= 0 ? Colors.green : Colors.red;
            return Chip(
              avatar: CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                child: Text(p[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              label: Text('$p  ${balance >= 0 ? '+' : ''}₹${balance.toStringAsFixed(0)}'),
              labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
              side: BorderSide(color: color.withOpacity(0.5)),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Recent expenses
        if (expenses.isNotEmpty) ...[
          Text('Recent Expenses',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...expenses.reversed.take(3).map((e) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.receipt,
                      color: theme.colorScheme.onSecondaryContainer, size: 20),
                ),
                title: Text(e.description,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(e.paidBy),
                trailing: Text('₹${e.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary)),
              )),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: color)),
            Text(label,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}
