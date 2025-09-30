import 'package:flutter_test/flutter_test.dart';
import 'package:keuanganku/models/transaction.dart';

void main() {
  group('Transaction Model Tests', () {
    test('Transaction should be created with required fields', () {
      final transaction = Transaction(
        title: 'Test Transaction',
        amount: 100000,
        date: DateTime.now(),
        category: TransactionCategory.jajan,
        isIncome: false,
      );

      expect(transaction.title, 'Test Transaction');
      expect(transaction.amount, 100000);
      expect(transaction.category, TransactionCategory.jajan);
      expect(transaction.isIncome, false);
    });

    test('Transaction should convert to map correctly', () {
      final now = DateTime.now();
      final transaction = Transaction(
        title: 'Test',
        amount: 50000,
        date: now,
        category: TransactionCategory.belanja,
        isIncome: false,
      );

      final map = transaction.toMap();
      
      expect(map['title'], 'Test');
      expect(map['amount'], 50000);
      expect(map['category'], 'belanja');
      expect(map['isIncome'], 0);
    });

    test('Transaction should be created from map', () {
      final map = {
        'id': 1,
        'title': 'Test Transaction',
        'amount': 75000.0,
        'date': DateTime.now().toIso8601String(),
        'category': 'jajan',
        'notes': 'Test notes',
        'receiptImagePath': null,
        'isIncome': 0,
      };

      final transaction = Transaction.fromMap(map);

      expect(transaction.id, 1);
      expect(transaction.title, 'Test Transaction');
      expect(transaction.amount, 75000.0);
      expect(transaction.category, TransactionCategory.jajan);
      expect(transaction.isIncome, false);
    });
  });

  group('TransactionCategory Tests', () {
    test('Category should have correct display name', () {
      expect(TransactionCategory.jajan.displayName, 'Jajan');
      expect(TransactionCategory.kontrakan.displayName, 'Kontrakan');
      expect(TransactionCategory.transportasi.displayName, 'Transportasi');
    });

    test('Category should have icon', () {
      expect(TransactionCategory.jajan.icon, '🍬');
      expect(TransactionCategory.kontrakan.icon, '🏠');
      expect(TransactionCategory.transportasi.icon, '🚗');
    });
  });
}
