import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  List<Transaction> get expenses =>
      _transactions.where((t) => !t.isIncome).toList();
  List<Transaction> get incomes =>
      _transactions.where((t) => t.isIncome).toList();

  double get totalExpenses =>
      expenses.fold(0, (sum, item) => sum + item.amount);
  double get totalIncomes => incomes.fold(0, (sum, item) => sum + item.amount);
  double get balance => totalIncomes - totalExpenses;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    _transactions = await DatabaseHelper.instance.readAllTransactions();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await DatabaseHelper.instance.createTransaction(transaction);
    await loadTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await DatabaseHelper.instance.updateTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    await loadTransactions();
  }

  List<Transaction> getTransactionsByMonth(int year, int month) {
    return _transactions.where((t) {
      return t.date.year == year && t.date.month == month;
    }).toList();
  }

  Map<TransactionCategory, double> getCategoryExpenses() {
    final Map<TransactionCategory, double> categoryExpenses = {};

    for (var transaction in expenses) {
      categoryExpenses[transaction.category] =
          (categoryExpenses[transaction.category] ?? 0) + transaction.amount;
    }

    return categoryExpenses;
  }

  Map<TransactionCategory, List<Transaction>> groupByCategory() {
    final Map<TransactionCategory, List<Transaction>> grouped = {};

    for (var transaction in _transactions) {
      if (!grouped.containsKey(transaction.category)) {
        grouped[transaction.category] = [];
      }
      grouped[transaction.category]!.add(transaction);
    }

    return grouped;
  }
}
