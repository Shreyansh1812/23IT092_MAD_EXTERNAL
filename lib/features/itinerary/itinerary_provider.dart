import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../local_storage/hive_storage_service.dart';
import 'itinerary_model.dart';

class ItineraryNotifier extends Notifier<List<ItineraryActivity>> {
  @override
  List<ItineraryActivity> build() {
    return HiveStorageService.getAllItineraries();
  }

  Future<void> addActivity(ItineraryActivity activity) async {
    await HiveStorageService.saveItinerary(activity);
    state = [...state, activity];
  }

  Future<void> deleteActivity(String id) async {
    await HiveStorageService.deleteItinerary(id);
    state = state.where((activity) => activity.id != id).toList();
  }
}

final itineraryProvider = NotifierProvider<ItineraryNotifier, List<ItineraryActivity>>(() {
  return ItineraryNotifier();
});

