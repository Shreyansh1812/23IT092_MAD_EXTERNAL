import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/validators.dart';
import '../../core/theme.dart';
import 'trip_model.dart';
import 'trip_provider.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _participants = [];
  final _participantController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _participantController.dispose();
    super.dispose();
  }

  void _saveTrip() {
    if (_formKey.currentState!.validate()) {
      final dateError = Validators.validateDates(_startDate, _endDate);
      if (dateError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dateError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final partError = Validators.validateParticipants(_participants);
      if (partError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(partError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final newTrip = Trip(
        name: _nameController.text.trim(),
        destination: _destinationController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        participants: _participants,
      );

      ref.read(tripProvider.notifier).addTrip(newTrip);
      context.pop();
    }
  }

  void _addParticipant() {
    final text = _participantController.text.trim();
    if (text.isNotEmpty && !_participants.contains(text)) {
      setState(() {
        _participants.add(text);
        _participantController.clear();
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? (_startDate ?? DateTime.now())),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradient = isDark ? AppTheme.darkPrimaryGradient : AppTheme.primaryGradient;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Trip'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Header banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flight_takeoff_rounded,
                      color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Plan your adventure',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                      Text('Fill in the details below',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Trip Name
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Trip Name',
                hintText: 'e.g. Goa Beach Trip',
                prefixIcon: Icon(Icons.luggage_rounded),
              ),
              validator: Validators.requiredString,
            ),
            const SizedBox(height: 14),

            // Destination
            TextFormField(
              controller: _destinationController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Destination',
                hintText: 'e.g. Goa, India',
                prefixIcon: Icon(Icons.location_on_rounded),
              ),
              validator: Validators.requiredString,
            ),
            const SizedBox(height: 14),

            // Date pickers
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: _startDate == null
                        ? 'Start Date'
                        : DateFormat('MMM d, y').format(_startDate!),
                    isSet: _startDate != null,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateButton(
                    label: _endDate == null
                        ? 'End Date'
                        : DateFormat('MMM d, y').format(_endDate!),
                    isSet: _endDate != null,
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Participants section
            Text('Participants',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _participantController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Add Participant',
                      hintText: 'Enter name',
                      prefixIcon: Icon(Icons.person_add_rounded),
                    ),
                    onSubmitted: (_) => _addParticipant(),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _addParticipant,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 18),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_participants.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Add at least one participant',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4)),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _participants
                    .map((p) => Chip(
                          avatar: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary,
                            child: Text(p[0].toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11)),
                          ),
                          label: Text(p),
                          onDeleted: () =>
                              setState(() => _participants.remove(p)),
                          deleteIconColor:
                              theme.colorScheme.onSurface.withOpacity(0.5),
                        ))
                    .toList(),
              ),

            const SizedBox(height: 32),

            // ── Confirmation Button ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  onPressed: _saveTrip,
                  icon: const Icon(Icons.check_circle_rounded, size: 22),
                  label: const Text('Create Trip'),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final bool isSet;
  final VoidCallback onTap;

  const _DateButton(
      {required this.label, required this.isSet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSet
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSet
                ? theme.colorScheme.primary.withOpacity(0.5)
                : theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: isSet ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 15,
              color: isSet
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.45),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSet ? FontWeight.w600 : FontWeight.w400,
                  color: isSet
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.45),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
