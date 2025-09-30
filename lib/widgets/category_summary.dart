import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class CategorySummary extends StatelessWidget {
  const CategorySummary({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final categoryExpenses = provider.getCategoryExpenses();

    if (categoryExpenses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Belum ada pengeluaran',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final totalExpenses = provider.totalExpenses;
    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedCategories.map((entry) {
        final category = entry.key;
        final amount = entry.value;
        final percentage = totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0.0;

        return _CategoryItem(
          category: category,
          amount: amount,
          percentage: percentage,
        );
      }).toList(),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final TransactionCategory category;
  final double amount;
  final double percentage;

  const _CategoryItem({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(category.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        currencyFormat.format(amount),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getCategoryColor(category),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(TransactionCategory category) {
    final colors = {
      TransactionCategory.transfer: Colors.blue,
      TransactionCategory.jajan: Colors.pink,
      TransactionCategory.cicilan: Colors.orange,
      TransactionCategory.kontrakan: Colors.brown,
      TransactionCategory.transportasi: Colors.green,
      TransactionCategory.belanja: Colors.purple,
      TransactionCategory.kesehatan: Colors.red,
      TransactionCategory.pendidikan: Colors.indigo,
      TransactionCategory.hiburan: Colors.amber,
      TransactionCategory.utilitas: Colors.teal,
      TransactionCategory.makananMinuman: Colors.deepOrange,
      TransactionCategory.lainnya: Colors.grey,
    };
    return colors[category] ?? Colors.grey;
  }
}
