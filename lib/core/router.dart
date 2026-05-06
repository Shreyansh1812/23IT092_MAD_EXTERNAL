import 'package:go_router/go_router.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/trips/trip_list_screen.dart';
import '../features/trips/create_trip_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TripListScreen(),
    ),
    GoRoute(
      path: '/create-trip',
      builder: (context, state) => const CreateTripScreen(),
    ),
    GoRoute(
      path: '/dashboard/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DashboardScreen(tripId: id);
      },
    ),
  ],
);
