import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../local_storage/hive_storage_service.dart';
import 'expense_model.dart';

class ExpenseNotifier extends Notifier<List<Expense>> {
  @override
  List<Expense> build() {
    return HiveStorageService.getAllExpenses();
  }

  Future<void> addExpense(Expense expense) async {
    await HiveStorageService.saveExpense(expense);
    state = [...state, expense];
  }

  Future<void> deleteExpense(String id) async {
    await HiveStorageService.deleteExpense(id);
    state = state.where((e) => e.id != id).toList();
  }
}

final expenseProvider = NotifierProvider<ExpenseNotifier, List<Expense>>(() {
  return ExpenseNotifier();
});
