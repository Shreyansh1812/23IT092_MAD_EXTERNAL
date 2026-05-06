import 'package:uuid/uuid.dart';

class ItineraryActivity {
  final String id;
  final String tripId;
  final DateTime date;
  final String description;
  final String? time;
  final String? notes;

  ItineraryActivity({
    String? id,
    required this.tripId,
    required this.date,
    required this.description,
    this.time,
    this.notes,
  }) : id = id ?? const Uuid().v4();
}
