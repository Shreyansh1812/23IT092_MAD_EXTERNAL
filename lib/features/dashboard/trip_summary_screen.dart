import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../trips/trip_provider.dart';
import '../expenses/expense_provider.dart';
import '../../core/theme.dart';

class TripSummaryScreen extends ConsumerWidget {
  final String tripId;
  const TripSummaryScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final trips = ref.watch(tripProvider);
    final allExpenses = ref.watch(expenseProvider);

    final trip = trips.firstWhere((t) => t.id == tripId,
        orElse: () => trips.isEmpty ? throw Exception() : trips.first);
    final expenses = allExpenses.where((e) => e.tripId == tripId).toList();

    final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final duration = trip.endDate.difference(trip.startDate).inDays;

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

    final gradient = isDark ? AppTheme.darkPrimaryGradient : AppTheme.primaryGradient;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        // Hero card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trip.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$duration days',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 6),
                  Text(trip.destination,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14)),
                  const SizedBox(width: 16),
                  const Icon(Icons.calendar_today_rounded,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${DateFormat('MMM d').format(trip.startDate)} – ${DateFormat('MMM d').format(trip.endDate)}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _HeroStat(
                      label: 'Total Spent',
                      value: '₹${totalExpenses.toStringAsFixed(0)}'),
                  Container(width: 1, height: 36, color: Colors.white24),
                  _HeroStat(
                      label: 'Travellers',
                      value: '${trip.participants.length}'),
                  Container(width: 1, height: 36, color: Colors.white24),
                  _HeroStat(
                      label: 'Expenses',
                      value: '${expenses.length}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Stat grid
        Row(
          children: [
            _StatCard2(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Total Expenses',
              value: '₹${totalExpenses.toStringAsFixed(2)}',
              gradient: AppTheme.primaryGradient,
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            _StatCard2(
              icon: Icons.pending_actions_rounded,
              label: 'Pending',
              value: '$pendingCount unsettled',
              gradient: pendingCount > 0
                  ? AppTheme.sunsetGradient
                  : const LinearGradient(
                      colors: [Color(0xFF00C853), Color(0xFF69F0AE)]),
              isDark: isDark,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Participants
        Text('Participants',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...trip.participants.map((p) {
          final balance = (paid[p] ?? 0) - (share[p] ?? 0);
          final isPositive = balance >= 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1C1C35)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPositive
                    ? Colors.green.withOpacity(0.4)
                    : Colors.red.withOpacity(0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isPositive ? Colors.green : Colors.red)
                      .withOpacity(isDark ? 0.1 : 0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      p[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        'Paid: ₹${(paid[p] ?? 0).toStringAsFixed(0)}  ·  Share: ₹${(share[p] ?? 0).toStringAsFixed(0)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}₹${balance.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 24),

        // Recent expenses
        if (expenses.isNotEmpty) ...[
          Text('Recent Expenses',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...expenses.reversed.take(3).map((e) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C35) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppTheme.oceanGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.receipt_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.description,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          Text('Paid by ${e.paidBy}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5))),
                        ],
                      ),
                    ),
                    Text(
                      '₹${e.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _StatCard2 extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final LinearGradient gradient;
  final bool isDark;

  const _StatCard2({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C35) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: gradient.colors.first.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 12),
            Text(value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text(label,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.55))),
          ],
        ),
      ),
    );
  }
}
