class Transaction {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionCategory category;
  final String? notes;
  final String? receiptImagePath;
  final bool isIncome;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.notes,
    this.receiptImagePath,
    this.isIncome = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.name,
      'notes': notes,
      'receiptImagePath': receiptImagePath,
      'isIncome': isIncome ? 1 : 0,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TransactionCategory.lainnya,
      ),
      notes: map['notes'],
      receiptImagePath: map['receiptImagePath'],
      isIncome: map['isIncome'] == 1,
    );
  }

  Transaction copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? date,
    TransactionCategory? category,
    String? notes,
    String? receiptImagePath,
    bool? isIncome,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}

enum TransactionCategory {
  transfer,
  jajan,
  cicilan,
  kontrakan,
  transportasi,
  belanja,
  kesehatan,
  pendidikan,
  hiburan,
  utilitas,
  makananMinuman,
  lainnya;

  String get displayName {
    switch (this) {
      case TransactionCategory.transfer:
        return 'Transfer';
      case TransactionCategory.jajan:
        return 'Jajan';
      case TransactionCategory.cicilan:
        return 'Cicilan';
      case TransactionCategory.kontrakan:
        return 'Kontrakan';
      case TransactionCategory.transportasi:
        return 'Transportasi';
      case TransactionCategory.belanja:
        return 'Belanja';
      case TransactionCategory.kesehatan:
        return 'Kesehatan';
      case TransactionCategory.pendidikan:
        return 'Pendidikan';
      case TransactionCategory.hiburan:
        return 'Hiburan';
      case TransactionCategory.utilitas:
        return 'Utilitas (Listrik, Air, dll)';
      case TransactionCategory.makananMinuman:
        return 'Makanan & Minuman';
      case TransactionCategory.lainnya:
        return 'Lainnya';
    }
  }

  String get icon {
    switch (this) {
      case TransactionCategory.transfer:
        return '💸';
      case TransactionCategory.jajan:
        return '🍬';
      case TransactionCategory.cicilan:
        return '💳';
      case TransactionCategory.kontrakan:
        return '🏠';
      case TransactionCategory.transportasi:
        return '🚗';
      case TransactionCategory.belanja:
        return '🛒';
      case TransactionCategory.kesehatan:
        return '⚕️';
      case TransactionCategory.pendidikan:
        return '📚';
      case TransactionCategory.hiburan:
        return '🎮';
      case TransactionCategory.utilitas:
        return '⚡';
      case TransactionCategory.makananMinuman:
        return '🍔';
      case TransactionCategory.lainnya:
        return '📝';
    }
  }
}
