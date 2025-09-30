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
          ],
        ),
      );
    }

    if (_image == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Belum ada struk yang dipindai',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Tekan tombol di bawah untuk memulai scan struk',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
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
            const Text(
              'Hasil Scan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Merchant',
              _scannedData!['merchantName'] ?? 'Tidak terdeteksi',
              Icons.store,
            ),
            _buildInfoCard(
              'Jumlah',
              _scannedData!['amount'] != null
                  ? 'Rp ${_scannedData!['amount']}'
                  : 'Tidak terdeteksi',
              Icons.money,
            ),
            _buildInfoCard(
              'Tanggal',
              _scannedData!['date'] != null
                  ? _scannedData!['date'].toString().split(' ')[0]
                  : 'Tidak terdeteksi',
              Icons.calendar_today,
            ),
            _buildInfoCard(
              'Kategori',
              (_scannedData!['category'] as TransactionCategory?)?.displayName ??
                  'Tidak terdeteksi',
              Icons.category,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _createTransaction,
              icon: const Icon(Icons.add),
              label: const Text('Buat Transaksi'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ],
      ),
    );
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
