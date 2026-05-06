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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'amount': amount,
      'paidBy': paidBy,
      'description': description,
      'date': date.toIso8601String(),
      'splitBetween': splitBetween,
      'category': category,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String?,
      tripId: json['tripId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidBy: json['paidBy'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      splitBetween: List<String>.from(json['splitBetween']),
      category: json['category'] as String?,
    );
  }
}
