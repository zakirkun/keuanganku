import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(double amount) {
    return _currencyFormat.format(amount);
  }
}

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  static String formatDateDay(DateTime date) {
    return DateFormat('EEE', 'id_ID').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'id_ID').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
  }
}

class AppConstants {
  // App info
  static const String appName = 'KeuanganKu';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'keuanganku.db';
  static const int databaseVersion = 1;
  
  // Preferences
  static const String prefThemeMode = 'theme_mode';
  static const String prefCurrency = 'currency';
  
  // OCR
  static const List<String> merchantKeywords = [
    'indomaret',
    'alfamart',
    'mcdonald',
    'kfc',
    'grab',
    'gojek',
  ];
}
