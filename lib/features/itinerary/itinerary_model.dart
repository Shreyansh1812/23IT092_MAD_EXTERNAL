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

  ItineraryActivity copyWith({
    String? id,
    String? tripId,
    DateTime? date,
    String? description,
    String? time,
    String? notes,
  }) {
    return ItineraryActivity(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      date: date ?? this.date,
      description: description ?? this.description,
      time: time ?? this.time,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'date': date.toIso8601String(),
      'description': description,
      'time': time,
      'notes': notes,
    };
  }

  factory ItineraryActivity.fromJson(Map<String, dynamic> json) {
    return ItineraryActivity(
      id: json['id'] as String?,
      tripId: json['tripId'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      time: json['time'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
