import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../local_storage/hive_storage_service.dart';
import 'trip_model.dart';

class TripNotifier extends Notifier<List<Trip>> {
  @override
  List<Trip> build() {
    return HiveStorageService.getTrips();
  }

  Future<void> addTrip(Trip trip) async {
    await HiveStorageService.saveTrip(trip);
    state = [...state, trip];
  }

  Future<void> updateTrip(Trip trip) async {
    await HiveStorageService.saveTrip(trip);
    state = [
      for (final t in state)
        if (t.id == trip.id) trip else t
    ];
  }

  Future<void> deleteTrip(String id) async {
    await HiveStorageService.deleteTrip(id);
    state = state.where((t) => t.id != id).toList();
  }
}

final tripProvider = NotifierProvider<TripNotifier, List<Trip>>(() {
  return TripNotifier();
});
