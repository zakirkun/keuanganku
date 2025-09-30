import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/transaction.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<Map<String, dynamic>> scanReceipt(String imagePath) async {
    final inputImage = InputImage.fromFile(File(imagePath));
    final RecognizedText recognizedText =
        await _textRecognizer.processImage(inputImage);

    String fullText = recognizedText.text;
    
    // Extract information from receipt
    double? amount = _extractAmount(fullText);
    String? merchantName = _extractMerchantName(recognizedText);
    DateTime? date = _extractDate(fullText);
    TransactionCategory category = _categorizeReceipt(fullText, merchantName);

    return {
      'amount': amount,
      'merchantName': merchantName,
      'date': date,
      'category': category,
      'fullText': fullText,
    };
  }

  double? _extractAmount(String text) {
    // Look for common patterns: Total, Subtotal, etc
    final patterns = [
      RegExp(r'total[\s:]*rp?\.?\s*(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)',
          caseSensitive: false),
      RegExp(r'rp\.?\s*(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)',
          caseSensitive: false),
      RegExp(r'(\d{1,3}(?:[.,]\d{3})+(?:[.,]\d{2})?)')
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String amountStr = match.group(1) ?? '';
        // Remove dots and replace comma with dot for decimal
        amountStr = amountStr.replaceAll('.', '').replaceAll(',', '.');
        try {
          return double.parse(amountStr);
        } catch (e) {
          continue;
        }
      }
    }
    return null;
  }

  String? _extractMerchantName(RecognizedText recognizedText) {
    // Usually merchant name is in the first few lines
    if (recognizedText.blocks.isNotEmpty) {
      return recognizedText.blocks.first.text.split('\n').first;
    }
    return null;
  }

  DateTime? _extractDate(String text) {
    // Common Indonesian date patterns
    final patterns = [
      RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})'),
      RegExp(r'(\d{2,4})[/-](\d{1,2})[/-](\d{1,2})'),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          int day = int.parse(match.group(1)!);
          int month = int.parse(match.group(2)!);
          int year = int.parse(match.group(3)!);

          if (year < 100) year += 2000;

          return DateTime(year, month, day);
        } catch (e) {
          continue;
        }
      }
    }
    return null;
  }

  TransactionCategory _categorizeReceipt(String text, String? merchantName) {
    text = text.toLowerCase();
    merchantName = merchantName?.toLowerCase() ?? '';

    // Keyword-based categorization
    if (_containsAny(text, [
      'indomaret',
      'alfamart',
      'supermarket',
      'minimarket',
      'superindo'
    ]) ||
        _containsAny(merchantName, ['indomaret', 'alfamart', 'superindo'])) {
      return TransactionCategory.belanja;
    }

    if (_containsAny(
        text, ['mcdonald', 'kfc', 'burger', 'pizza', 'resto', 'cafe', 'coffee', 'kopi'])) {
      return TransactionCategory.makananMinuman;
    }

    if (_containsAny(text, ['grab', 'gojek', 'taxi', 'bensin', 'pertamina', 'spbu'])) {
      return TransactionCategory.transportasi;
    }

    if (_containsAny(text, ['apotik', 'pharmacy', 'rumah sakit', 'klinik', 'dokter'])) {
      return TransactionCategory.kesehatan;
    }

    if (_containsAny(text, ['listrik', 'pln', 'pdam', 'air', 'token'])) {
      return TransactionCategory.utilitas;
    }

    return TransactionCategory.lainnya;
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  void dispose() {
    _textRecognizer.close();
  }
}
