import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'itinerary_provider.dart';
import 'itinerary_model.dart';
import '../../core/theme.dart';

class ItineraryScreen extends ConsumerWidget {
  final String tripId;

  const ItineraryScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allActivities = ref.watch(itineraryProvider);
    final activities = allActivities.where((a) => a.tripId == tripId).toList();
    final theme = Theme.of(context);

    // Group activities by date
    final groupedActivities = <String, List<ItineraryActivity>>{};
    for (var activity in activities) {
      final dateKey = DateFormat('yyyy-MM-dd').format(activity.date);
      if (!groupedActivities.containsKey(dateKey)) {
        groupedActivities[dateKey] = [];
      }
      groupedActivities[dateKey]!.add(activity);
    }

    
    // Sort keys
    final sortedDates = groupedActivities.keys.toList()..sort();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: activities.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 80,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No activities planned',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add an activity to your itinerary',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final dateStr = sortedDates[index];
                final dateActivities = groupedActivities[dateStr]!;
                // Sort activities by time if possible, simple approach
                dateActivities.sort((a, b) => (a.time ?? '24:00').compareTo(b.time ?? '24:00'));

                final displayDate = DateFormat('EEEE, MMM d').format(DateTime.parse(dateStr));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        displayDate,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    ...dateActivities.map((activity) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.access_time_rounded,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(
                              activity.description,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: activity.notes != null && activity.notes!.isNotEmpty
                                ? Text(activity.notes!)
                                : null,
                            trailing: Text(
                              activity.time ?? 'Anytime',
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onLongPress: () {
                              // Delete option
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Activity'),
                                  content: const Text('Are you sure you want to delete this activity?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ref.read(itineraryProvider.notifier).deleteActivity(activity.id);
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddActivityDialog(context, ref, tripId);
        },
        child: const Icon(Icons.add_task),
      ),
    );
  }

  void _showAddActivityDialog(BuildContext context, WidgetRef ref, String tripId) {
    final formKey = GlobalKey<FormState>();
    String description = '';
    String? time;
    String? notes;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Activity'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'e.g., Visit Museum',
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        onSaved: (value) => description = value!,
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Date: ${DateFormat('MMM d, yyyy').format(selectedDate)}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() => selectedDate = date);
                          }
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Time (Optional)',
                          hintText: 'e.g., 10:00 AM',
                        ),
                        onSaved: (value) => time = value?.isEmpty ?? true ? null : value,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                        ),
                        maxLines: 2,
                        onSaved: (value) => notes = value?.isEmpty ?? true ? null : value,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      final activity = ItineraryActivity(
                        tripId: tripId,
                        date: selectedDate,
                        description: description,
                        time: time,
                        notes: notes,
                      );
                      ref.read(itineraryProvider.notifier).addActivity(activity);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
