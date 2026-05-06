import 'package:hive_flutter/hive_flutter.dart';
import '../features/trips/trip_model.dart';
import '../features/expenses/expense_model.dart';
import '../features/itinerary/itinerary_model.dart';

class HiveStorageService {
  static const String _tripsBoxName = 'tripsBox';
  
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_tripsBoxName);
  }

  static Box get _tripsBox => Hive.box(_tripsBoxName);

  // Trips
  static Future<void> saveTrip(Trip trip) async {
    await _tripsBox.put(trip.id, trip.toJson());
  }

  static Future<void> deleteTrip(String id) async {
    await _tripsBox.delete(id);
  }

  static List<Trip> getTrips() {
    return _tripsBox.values.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return Trip.fromJson(map);
    }).toList();
  }
}
