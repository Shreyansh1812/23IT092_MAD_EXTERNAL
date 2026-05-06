import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'trip_provider.dart';
import 'package:intl/intl.dart';
import '../expenses/expense_provider.dart';

class TripListScreen extends ConsumerWidget {
  const TripListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'My Trips',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.flight_takeoff_rounded,
                    size: 80,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => context.push('/search'),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () => context.push('/search'),
              ),
            ],
          ),
          if (trips.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.card_travel_rounded,
                      size: 80,
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No trips planned yet',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to create your first adventure!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final trip = trips[index];
                    final duration = trip.endDate.difference(trip.startDate).inDays;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => context.push('/dashboard/${trip.id}'),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.surface,
                                theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        trip.name,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '$duration Days',
                                        style: TextStyle(
                                          color: theme.colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 16, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        trip.destination,
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.secondary),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${DateFormat('MMM d, y').format(trip.startDate)} - ${DateFormat('MMM d, y').format(trip.endDate)}',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      height: 30,
                                      child: Stack(
                                        children: List.generate(
                                          trip.participants.length > 3 ? 3 : trip.participants.length,
                                          (i) => Positioned(
                                            left: i * 15.0,
                                            child: CircleAvatar(
                                              radius: 14,
                                              backgroundColor: theme.colorScheme.primary,
                                              child: Text(
                                                trip.participants[i][0].toUpperCase(),
                                                style: const TextStyle(fontSize: 12, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (trip.participants.length > 3)
                                      Text(
                                        '+${trip.participants.length - 3} more',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    const Spacer(),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: trips.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-trip'),
        icon: const Icon(Icons.add),
        label: const Text('New Trip'),
        elevation: 4,
      ),
    );
  }
}
