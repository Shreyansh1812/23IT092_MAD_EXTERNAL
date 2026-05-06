import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/validators.dart';
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

  void _saveTrip() {
    if (_formKey.currentState!.validate()) {
      final error = Validators.validateDates(_startDate, _endDate);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        return;
      }
      
      final partError = Validators.validateParticipants(_participants);
      if (partError != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(partError)));
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
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? (_startDate ?? DateTime.now())),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Trip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTrip,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Trip Name',
                border: OutlineInputBorder(),
              ),
              validator: Validators.requiredString,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination',
                border: OutlineInputBorder(),
              ),
              validator: Validators.requiredString,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_startDate == null ? 'Start Date' : DateFormat.yMMMd().format(_startDate!)),
                    onPressed: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_endDate == null ? 'End Date' : DateFormat.yMMMd().format(_endDate!)),
                    onPressed: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Participants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _participantController,
                    decoration: const InputDecoration(
                      labelText: 'Add Participant',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addParticipant,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _participants.map((p) => Chip(
                label: Text(p),
                onDeleted: () {
                  setState(() {
                    _participants.remove(p);
                  });
                },
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
