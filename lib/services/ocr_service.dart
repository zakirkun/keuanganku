import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/transaction.dart';

class ReceiptItem {
  final String name;
  final int quantity;
  final double price;
  final double total;

  ReceiptItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'price': price,
        'total': total,
      };
}

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<Map<String, dynamic>> scanReceipt(String imagePath) async {
    final inputImage = InputImage.fromFile(File(imagePath));
    final RecognizedText recognizedText =
        await _textRecognizer.processImage(inputImage);

    String fullText = recognizedText.text;
    List<String> lines = fullText.split('\n');

    // Advanced extraction
    Map<String, dynamic> merchantInfo = _extractMerchantInfo(recognizedText, lines);
    List<ReceiptItem> items = _extractLineItems(lines);
    Map<String, double> amounts = _extractAllAmounts(lines);
    DateTime? date = _extractDate(fullText);
    String? paymentMethod = _extractPaymentMethod(lines);
    TransactionCategory category = _categorizeReceipt(
      fullText,
      merchantInfo['name'],
      items,
    );

    // Determine the final amount (prefer total, then grand total, then subtotal)
    double? finalAmount = amounts['total'] ??
        amounts['grandTotal'] ??
        amounts['subtotal'] ??
        amounts['amount'];

    return {
      'amount': finalAmount,
      'merchantName': merchantInfo['name'],
      'merchantAddress': merchantInfo['address'],
      'merchantPhone': merchantInfo['phone'],
      'date': date,
      'category': category,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': amounts['subtotal'],
      'tax': amounts['tax'],
      'discount': amounts['discount'],
      'total': amounts['total'],
      'paymentMethod': paymentMethod,
      'fullText': fullText,
      'confidence': _calculateConfidence(merchantInfo, finalAmount, date),
    };
  }

  Map<String, dynamic> _extractMerchantInfo(
      RecognizedText recognizedText, List<String> lines) {
    String? name;
    String? address;
    String? phone;

    // Merchant name is usually in the first 1-3 lines
    if (recognizedText.blocks.isNotEmpty) {
      var firstBlock = recognizedText.blocks.first;
      var firstLines = firstBlock.text.split('\n').take(3).toList();
      
      // Find the longest line in first block as merchant name
      name = firstLines.reduce((a, b) => a.length > b.length ? a : b).trim();
    }

    // Extract phone number
    final phonePattern = RegExp(r'(?:telp|phone|hp|wa)[:\s]*(\+?\d[\d\s\-()]+)',
        caseSensitive: false);
    for (var line in lines) {
      final match = phonePattern.firstMatch(line);
      if (match != null) {
        phone = match.group(1)?.replaceAll(RegExp(r'[\s\-()]'), '');
        break;
      }
    }

    // Extract address (lines with street keywords)
    final addressKeywords = [
      'jl',
      'jalan',
      'street',
      'st.',
      'no.',
      'blok',
      'rt',
      'rw'
    ];
    for (var line in lines.take(10)) {
      // Check first 10 lines
      if (addressKeywords.any((kw) => line.toLowerCase().contains(kw)) &&
          line.length > 10 &&
          !_isAmountLine(line)) {
        address = line.trim();
        break;
      }
    }

    return {
      'name': name,
      'address': address,
      'phone': phone,
    };
  }

  List<ReceiptItem> _extractLineItems(List<String> lines) {
    List<ReceiptItem> items = [];

    // Pattern for line items: Name Qty x Price = Total or Name Price
    final patterns = [
      // Pattern: Item 2 x 10000 = 20000
      RegExp(
          r'^(.+?)\s+(\d+)\s*[xX*]\s*(\d{1,3}(?:[.,]\d{3})*)\s*=?\s*(\d{1,3}(?:[.,]\d{3})*)',
          caseSensitive: false),
      // Pattern: Item 10000
      RegExp(r'^(.+?)\s+(\d{1,3}(?:[.,]\d{3})*)\s*$', caseSensitive: false),
    ];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.length < 5) continue;

      // Skip lines that are clearly headers or footers
      if (_isHeaderOrFooter(line)) continue;

      // Try pattern with quantity
      var match = patterns[0].firstMatch(line);
      if (match != null) {
        try {
          String itemName = match.group(1)!.trim();
          int quantity = int.parse(match.group(2)!);
          double price = _parseAmount(match.group(3)!);
          double total = _parseAmount(match.group(4)!);

          if (itemName.length > 2 && price > 0) {
            items.add(ReceiptItem(
              name: itemName,
              quantity: quantity,
              price: price,
              total: total,
            ));
          }
        } catch (e) {
          // Skip invalid items
        }
        continue;
      }

      // Try simple pattern (item + price)
      match = patterns[1].firstMatch(line);
      if (match != null) {
        try {
          String itemName = match.group(1)!.trim();
          double price = _parseAmount(match.group(2)!);

          // Only add if name is reasonable and not a total line
          if (itemName.length > 2 &&
              itemName.length < 50 &&
              price > 0 &&
              !_isTotalLine(itemName)) {
            items.add(ReceiptItem(
              name: itemName,
              quantity: 1,
              price: price,
              total: price,
            ));
          }
        } catch (e) {
          // Skip invalid items
        }
      }
    }

    return items;
  }

  Map<String, double> _extractAllAmounts(List<String> lines) {
    Map<String, double> amounts = {};

    final patterns = {
      'subtotal': [
        RegExp(r'subtotal[\s:]*(?:rp\.?)?\s*(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)',
            caseSensitive: false),
      ],
      'tax': [
        RegExp(r'(?:pajak|tax|ppn|pb1)[\s:]*(?:rp\.?)?\s*(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)',
            caseSensitive: false),
        RegExp(r'(?:service|layanan)[\s:]*(?:rp\.?)?\s*(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)',
            caseSensitive: false),
      ],
      'discount': [
        RegExp(r'(?:diskon|discount|potongan)[\s:]*(?:rp\.?)?\s*(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)',
            caseSensitive: false),
      ],
      'total': [
        RegExp(r'(?:^|\s)total[\s:]*(?:rp\.?)?\s*(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)',
            caseSensitive: false),
        RegExp(r'grand\s*total[\s:]*(?:rp\.?)?\s*(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)',
            caseSensitive: false),
      ],
      'payment': [
        RegExp(r'(?:bayar|payment|paid|cash|tunai)[\s:]*(?:rp\.?)?\s*(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)',
            caseSensitive: false),
      ],
      'change': [
        RegExp(r'(?:kembali|change|kembalian)[\s:]*(?:rp\.?)?\s*(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)',
            caseSensitive: false),
      ],
    };

    for (var line in lines) {
      for (var entry in patterns.entries) {
        for (var pattern in entry.value) {
          final match = pattern.firstMatch(line);
          if (match != null) {
            try {
              double value = _parseAmount(match.group(1)!);
              amounts[entry.key] = value;
              break;
            } catch (e) {
              continue;
            }
          }
        }
      }
    }

    // Calculate grand total if not found
    if (amounts['grandTotal'] == null && amounts['total'] != null) {
      amounts['grandTotal'] = amounts['total']!;
    }

    // If no specific total found, look for any large amount
    if (amounts['total'] == null) {
      for (var line in lines) {
        final amountMatch = RegExp(
                r'(?:rp\.?)?\s*(\d{1,3}(?:[.,]\d{3}){2,}(?:[.,]\d{2})?)',
                caseSensitive: false)
            .firstMatch(line);
        if (amountMatch != null) {
          try {
            double value = _parseAmount(amountMatch.group(1)!);
            if (value > 1000) {
              // Minimum reasonable amount
              amounts['amount'] = value;
            }
          } catch (e) {
            continue;
          }
        }
      }
    }

    return amounts;
  }

  String? _extractPaymentMethod(List<String> lines) {
    final paymentPatterns = {
      'Cash': ['cash', 'tunai', 'uang tunai'],
      'Debit': ['debit', 'kartu debit', 'atm'],
      'Credit': ['credit', 'kartu kredit', 'cc'],
      'E-Wallet': [
        'gopay',
        'ovo',
        'dana',
        'shopeepay',
        'linkaja',
        'e-wallet',
        'qris'
      ],
      'Transfer': ['transfer', 'bank transfer'],
    };

    for (var line in lines) {
      String lowerLine = line.toLowerCase();
      for (var entry in paymentPatterns.entries) {
        if (entry.value.any((method) => lowerLine.contains(method))) {
          return entry.key;
        }
      }
    }

    return null;
  }

  double _parseAmount(String amountStr) {
    // Remove dots (thousand separator) and replace comma with dot (decimal)
    amountStr = amountStr.replaceAll('.', '').replaceAll(',', '.');
    return double.parse(amountStr);
  }

  bool _isHeaderOrFooter(String line) {
    final headerFooterKeywords = [
      'terima kasih',
      'thank you',
      'selamat',
      'welcome',
      'customer',
      'kasir',
      'cashier',
      'npwp',
      'pkp',
      'struk',
      'receipt',
    ];

    String lowerLine = line.toLowerCase();
    return headerFooterKeywords.any((kw) => lowerLine.contains(kw)) ||
        line.length < 3;
  }

  bool _isTotalLine(String text) {
    final totalKeywords = [
      'total',
      'subtotal',
      'grand',
      'amount',
      'bayar',
      'kembali',
      'change'
    ];
    String lowerText = text.toLowerCase();
    return totalKeywords.any((kw) => lowerText.contains(kw));
  }

  bool _isAmountLine(String line) {
    return RegExp(r'\d{1,3}(?:[.,]\d{3})+').hasMatch(line);
  }

  DateTime? _extractDate(String text) {
    // Indonesian date patterns
    final patterns = [
      // DD/MM/YYYY or DD-MM-YYYY
      RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})'),
      // YYYY/MM/DD or YYYY-MM-DD
      RegExp(r'(\d{2,4})[/-](\d{1,2})[/-](\d{1,2})'),
      // DD MMM YYYY (e.g., 15 Jan 2024)
      RegExp(
          r'(\d{1,2})\s+(jan|feb|mar|apr|mei|may|jun|jul|aug|agu|sep|oct|okt|nov|dec|des)\w*\s+(\d{2,4})',
          caseSensitive: false),
    ];

    final monthMap = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'mei': 5,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'agu': 8,
      'sep': 9,
      'oct': 10,
      'okt': 10,
      'nov': 11,
      'dec': 12,
      'des': 12,
    };

    // Try pattern with month name
    final monthMatch = patterns[2].firstMatch(text.toLowerCase());
    if (monthMatch != null) {
      try {
        int day = int.parse(monthMatch.group(1)!);
        String monthStr = monthMatch.group(2)!.toLowerCase().substring(0, 3);
        int month = monthMap[monthStr] ?? 1;
        int year = int.parse(monthMatch.group(3)!);

        if (year < 100) year += 2000;

        return DateTime(year, month, day);
      } catch (e) {
        // Continue to next pattern
      }
    }

    // Try numeric patterns
    for (var i = 0; i < 2; i++) {
      final match = patterns[i].firstMatch(text);
      if (match != null) {
        try {
          int first = int.parse(match.group(1)!);
          int second = int.parse(match.group(2)!);
          int third = int.parse(match.group(3)!);

          int day, month, year;

          if (third > 31) {
            // Third part is year
            day = first;
            month = second;
            year = third;
          } else if (first > 31) {
            // First part is year
            year = first;
            month = second;
            day = third;
          } else {
            // Assume DD/MM/YYYY
            day = first;
            month = second;
            year = third;
          }

          if (year < 100) year += 2000;
          if (month > 12 || day > 31) continue;

          return DateTime(year, month, day);
        } catch (e) {
          continue;
        }
      }
    }

    return null;
  }

  TransactionCategory _categorizeReceipt(
      String text, String? merchantName, List<ReceiptItem> items) {
    text = text.toLowerCase();
    merchantName = merchantName?.toLowerCase() ?? '';

    // Check items for better categorization
    List<String> itemNames =
        items.map((item) => item.name.toLowerCase()).toList();
    String allItems = itemNames.join(' ');

    // Supermarket/Grocery
    if (_containsAny(text + ' ' + merchantName, [
          'indomaret',
          'alfamart',
          'supermarket',
          'hypermart',
          'superindo',
          'giant',
          'carrefour',
          'lotte',
        ]) ||
        _containsAny(allItems, [
          'susu',
          'roti',
          'telur',
          'minyak',
          'gula',
          'beras',
          'sabun',
          'shampo',
          'pasta'
        ])) {
      return TransactionCategory.belanja;
    }

    // Food & Beverage
    if (_containsAny(text + ' ' + merchantName, [
          'mcdonald',
          'kfc',
          'burger',
          'pizza',
          'resto',
          'restaurant',
          'cafe',
          'coffee',
          'kopi',
          'bakery',
          'bakmi',
          'mie',
          'nasi',
          'ayam',
          'sate',
          'bakso'
        ]) ||
        _containsAny(allItems, [
          'nasi',
          'mie',
          'ayam',
          'ikan',
          'soto',
          'gado',
          'rendang',
          'coffee',
          'kopi',
          'teh',
          'juice'
        ])) {
      return TransactionCategory.makananMinuman;
    }

    // Transportation
    if (_containsAny(text + ' ' + merchantName,
        ['grab', 'gojek', 'taxi', 'uber', 'bensin', 'pertamina', 'spbu', 'shell', 'parkir'])) {
      return TransactionCategory.transportasi;
    }

    // Healthcare
    if (_containsAny(text + ' ' + merchantName, [
      'apotik',
      'apotek',
      'pharmacy',
      'kimia farma',
      'guardian',
      'century',
      'rumah sakit',
      'hospital',
      'klinik',
      'dokter',
      'doctor'
    ])) {
      return TransactionCategory.kesehatan;
    }

    // Utilities
    if (_containsAny(text + ' ' + merchantName,
        ['listrik', 'pln', 'pdam', 'air', 'token', 'pulsa', 'internet', 'wifi'])) {
      return TransactionCategory.utilitas;
    }

    // Entertainment
    if (_containsAny(text + ' ' + merchantName, [
      'bioskop',
      'cinema',
      'cgv',
      'xxi',
      'game',
      'playstation',
      'timezone',
      'karaoke'
    ])) {
      return TransactionCategory.hiburan;
    }

    return TransactionCategory.lainnya;
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  double _calculateConfidence(
      Map<String, dynamic> merchantInfo, double? amount, DateTime? date) {
    double confidence = 0.0;

    if (merchantInfo['name'] != null && merchantInfo['name'].length > 3) {
      confidence += 0.3;
    }
    if (amount != null && amount > 0) confidence += 0.4;
    if (date != null) confidence += 0.2;
    if (merchantInfo['address'] != null) confidence += 0.05;
    if (merchantInfo['phone'] != null) confidence += 0.05;

    return confidence;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
