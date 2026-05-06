import 'package:hive_flutter/hive_flutter.dart';
import '../features/trips/trip_model.dart';
import '../features/expenses/expense_model.dart';
import '../features/itinerary/itinerary_model.dart';

class HiveStorageService {
  static const String _tripsBoxName = 'tripsBox';
  static const String _itineraryBoxName = 'itineraryBox';
  static const String _expensesBoxName = 'expensesBox';
  
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_tripsBoxName);
    await Hive.openBox(_itineraryBoxName);
    await Hive.openBox(_expensesBoxName);
  }

  static Box get _tripsBox => Hive.box(_tripsBoxName);
  static Box get _itineraryBox => Hive.box(_itineraryBoxName);
  static Box get _expensesBox => Hive.box(_expensesBoxName);

  // --- Trips ---
  static Future<void> saveTrip(Trip trip) async {
    await _tripsBox.put(trip.id, trip.toJson());
  }

  static Future<void> deleteTrip(String id) async {
    await _tripsBox.delete(id);
    // Also delete associated itineraries and expenses
    final itineraries = getItineraries(id);
    for (var i in itineraries) {
      await deleteItinerary(i.id);
    }
  }

  static List<Trip> getTrips() {
    return _tripsBox.values.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return Trip.fromJson(map);
    }).toList();
  }

  // --- Itineraries ---
  static Future<void> saveItinerary(ItineraryActivity activity) async {
    await _itineraryBox.put(activity.id, activity.toJson());
  }

  static Future<void> deleteItinerary(String id) async {
    await _itineraryBox.delete(id);
  }

  static List<ItineraryActivity> getItineraries(String tripId) {
    return _itineraryBox.values.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return ItineraryActivity.fromJson(map);
    }).where((activity) => activity.tripId == tripId).toList();
  }

  static List<ItineraryActivity> getAllItineraries() {
    return _itineraryBox.values.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return ItineraryActivity.fromJson(map);
    }).toList();
  }
}
