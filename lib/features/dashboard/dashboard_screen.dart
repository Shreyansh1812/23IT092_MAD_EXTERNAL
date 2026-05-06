import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final String tripId;

  const DashboardScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Dashboard'),
      ),
      body: Center(
        child: Text('Dashboard for trip: $tripId'),
      ),
    );
  }
}
