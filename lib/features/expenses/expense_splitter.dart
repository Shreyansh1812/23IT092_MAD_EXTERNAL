import 'expense_model.dart';

class Debt {
  final String debtor;
  final String creditor;
  final double amount;

  Debt(this.debtor, this.creditor, this.amount);
}

class ExpenseSplitter {
  static List<Debt> calculateSettlements(List<Expense> expenses, List<String> participants) {
    Map<String, double> balances = { for (var p in participants) p : 0.0 };

    for (var expense in expenses) {
      double splitAmount = expense.amount / expense.splitBetween.length;
      
      // Creditor (paid the expense)
      balances[expense.paidBy] = (balances[expense.paidBy] ?? 0) + expense.amount;

      // Debtors (split the expense)
      for (var person in expense.splitBetween) {
        balances[person] = (balances[person] ?? 0) - splitAmount;
      }
    }

    List<MapEntry<String, double>> debtors = [];
    List<MapEntry<String, double>> creditors = [];

    balances.forEach((person, balance) {
      if (balance < -0.01) {
        debtors.add(MapEntry(person, -balance));
      } else if (balance > 0.01) {
        creditors.add(MapEntry(person, balance));
      }
    });

    debtors.sort((a, b) => b.value.compareTo(a.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    List<Debt> settlements = [];
    int i = 0, j = 0;

    while (i < debtors.length && j < creditors.length) {
      double debt = debtors[i].value;
      double credit = creditors[j].value;
      double settledAmount = debt < credit ? debt : credit;

      settlements.add(Debt(debtors[i].key, creditors[j].key, settledAmount));

      debtors[i] = MapEntry(debtors[i].key, debt - settledAmount);
      creditors[j] = MapEntry(creditors[j].key, credit - settledAmount);

      if (debtors[i].value < 0.01) i++;
      if (creditors[j].value < 0.01) j++;
    }

    return settlements;
  }
}
