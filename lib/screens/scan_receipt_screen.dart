import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ocr_service.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

class ScanReceiptScreen extends StatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  State<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends State<ScanReceiptScreen> {
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService();
  
  File? _image;
  bool _isProcessing = false;
  Map<String, dynamic>? _scannedData;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isProcessing = true;
        });

        // Process OCR
        final result = await _ocrService.scanReceipt(pickedFile.path);
        
        setState(() {
          _scannedData = result;
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createTransaction() {
    if (_scannedData == null) return;

    final transaction = Transaction(
      title: _scannedData!['merchantName'] ?? 'Transaksi',
      amount: _scannedData!['amount'] ?? 0.0,
      date: _scannedData!['date'] ?? DateTime.now(),
      category: _scannedData!['category'] ?? TransactionCategory.lainnya,
      receiptImagePath: _image?.path,
      isIncome: false,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transaction: transaction),
      ),
    );
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Struk'),
        actions: [
          if (_scannedData != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _createTransaction,
              tooltip: 'Buat Transaksi',
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showImageSourceDialog,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan Struk'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isProcessing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memproses gambar...'),
            SizedBox(height: 8),
            Text(
              'Mengekstrak informasi dari struk',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_image == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Scan Struk Belanja',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Ambil foto atau pilih gambar struk untuk otomatis mengekstrak informasi transaksi',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.check_circle, size: 16),
                  label: const Text('Merchant', style: TextStyle(fontSize: 12)),
                ),
                Chip(
                  avatar: const Icon(Icons.check_circle, size: 16),
                  label: const Text('Total', style: TextStyle(fontSize: 12)),
                ),
                Chip(
                  avatar: const Icon(Icons.check_circle, size: 16),
                  label: const Text('Items', style: TextStyle(fontSize: 12)),
                ),
                Chip(
                  avatar: const Icon(Icons.check_circle, size: 16),
                  label: const Text('Tanggal', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Receipt Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _image!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          
          if (_scannedData != null) ...[
            // Confidence indicator
            if (_scannedData!['confidence'] != null)
              _buildConfidenceIndicator(_scannedData!['confidence']),
            
            const SizedBox(height: 16),
            
            // Main Info Section
            const Text(
              'Informasi Merchant',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              'Nama',
              _scannedData!['merchantName'] ?? 'Tidak terdeteksi',
              Icons.store,
            ),
            if (_scannedData!['merchantAddress'] != null)
              _buildInfoCard(
                'Alamat',
                _scannedData!['merchantAddress'],
                Icons.location_on,
              ),
            if (_scannedData!['merchantPhone'] != null)
              _buildInfoCard(
                'Telepon',
                _scannedData!['merchantPhone'],
                Icons.phone,
              ),
            
            const SizedBox(height: 24),
            
            // Transaction Info
            const Text(
              'Detail Transaksi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Amounts
            if (_scannedData!['subtotal'] != null)
              _buildAmountCard(
                'Subtotal',
                _scannedData!['subtotal'],
                Icons.receipt,
              ),
            if (_scannedData!['tax'] != null)
              _buildAmountCard(
                'Pajak/Service',
                _scannedData!['tax'],
                Icons.percent,
              ),
            if (_scannedData!['discount'] != null)
              _buildAmountCard(
                'Diskon',
                _scannedData!['discount'],
                Icons.discount,
                isDiscount: true,
              ),
            _buildAmountCard(
              'Total',
              _scannedData!['amount'],
              Icons.payments,
              isTotal: true,
            ),
            
            _buildInfoCard(
              'Tanggal',
              _scannedData!['date'] != null
                  ? _formatDate(_scannedData!['date'])
                  : 'Tidak terdeteksi',
              Icons.calendar_today,
            ),
            _buildInfoCard(
              'Kategori',
              (_scannedData!['category'] as TransactionCategory?)?.displayName ??
                  'Tidak terdeteksi',
              Icons.category,
            ),
            if (_scannedData!['paymentMethod'] != null)
              _buildInfoCard(
                'Metode Pembayaran',
                _scannedData!['paymentMethod'],
                Icons.credit_card,
              ),
            
            // Line Items
            if (_scannedData!['items'] != null &&
                (_scannedData!['items'] as List).isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Item Belanja',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildItemsList(_scannedData!['items'] as List),
            ],
            
            const SizedBox(height: 24),
            
            // Action Button
            FilledButton.icon(
              onPressed: _createTransaction,
              icon: const Icon(Icons.add),
              label: const Text('Buat Transaksi'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Debug: Show raw text (optional, can be removed)
            if (_scannedData!['fullText'] != null)
              ExpansionTile(
                title: const Text('Teks Mentah (Debug)'),
                leading: const Icon(Icons.text_fields),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _scannedData!['fullText'],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator(double confidence) {
    Color color;
    String label;
    IconData icon;

    if (confidence >= 0.8) {
      color = Colors.green;
      label = 'Akurasi Tinggi';
      icon = Icons.check_circle;
    } else if (confidence >= 0.5) {
      color = Colors.orange;
      label = 'Akurasi Sedang';
      icon = Icons.info;
    } else {
      color = Colors.red;
      label = 'Akurasi Rendah';
      icon = Icons.warning;
    }

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: confidence,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(confidence * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(String label, double? value, IconData icon,
      {bool isTotal = false, bool isDiscount = false}) {
    if (value == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isTotal ? Colors.teal.withOpacity(0.1) : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isTotal
              ? Colors.teal
              : isDiscount
                  ? Colors.orange
                  : null,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : null,
          ),
        ),
        trailing: Text(
          '${isDiscount ? '-' : ''}Rp ${_formatNumber(value)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 18 : 16,
            color: isTotal
                ? Colors.teal
                : isDiscount
                    ? Colors.orange
                    : null,
          ),
        ),
      ),
    );
  }

  Widget _buildItemsList(List items) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.teal.withOpacity(0.1),
              child: Text(
                '${item['quantity']}x',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              item['name'],
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: Text(
              'Rp ${_formatNumber(item['price'])}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              'Rp ${_formatNumber(item['total'])}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
