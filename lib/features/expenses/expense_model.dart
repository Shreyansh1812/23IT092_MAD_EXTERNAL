import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final String tripId;
  final double amount;
  final String paidBy;
  final String description;
  final DateTime date;
  final List<String> splitBetween;
  final String? category;

  Expense({
    String? id,
    required this.tripId,
    required this.amount,
    required this.paidBy,
    required this.description,
    required this.date,
    required this.splitBetween,
    this.category,
  }) : id = id ?? const Uuid().v4();
}
