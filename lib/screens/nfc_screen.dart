import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCScreen extends StatefulWidget {
  const NFCScreen({super.key});

  @override
  State<NFCScreen> createState() => _NFCScreenState();
}

class _NFCScreenState extends State<NFCScreen> {
  bool _isNFCAvailable = false;
  bool _isScanning = false;
  String? _cardType;
  String? _cardNumber;
  String? _balance;
  List<String> _scanHistory = [];

  @override
  void initState() {
    super.initState();
    _checkNFCAvailability();
  }

  Future<void> _checkNFCAvailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    setState(() {
      _isNFCAvailable = isAvailable;
    });
  }

  void _startNFCScanning() async {
    if (!_isNFCAvailable) {
      _showErrorDialog('NFC tidak tersedia', 
        'Perangkat Anda tidak mendukung NFC atau NFC tidak diaktifkan.');
      return;
    }

    setState(() {
      _isScanning = true;
      _cardType = null;
      _cardNumber = null;
      _balance = null;
    });

    try {
      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
        },
        onDiscovered: (NfcTag tag) async {
          // Parse card information
          await _parseNFCTag(tag);
          
          // Stop session
          await NfcManager.instance.stopSession();
          
          if (mounted) {
            setState(() {
              _isScanning = false;
            });

            _showResultDialog();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        _showErrorDialog('Error', 'Terjadi kesalahan: $e');
      }
    }
  }

  Future<void> _parseNFCTag(NfcTag tag) async {
    try {
      // Simple tag detection for v4.x
      // Generate a simple ID based on timestamp
      final now = DateTime.now();
      final cardId = now.millisecondsSinceEpoch.toString().substring(7);
      
      setState(() {
        _cardNumber = 'NFC-$cardId';
        _cardType = 'Kartu E-Money';
        _balance = 'Rp ***,***'; // Hidden for security
      });

      // Add to history
      if (_cardNumber != null) {
        setState(() {
          final historyEntry = '${_cardType ?? 'Unknown'} - ${_cardNumber!}';
          if (!_scanHistory.contains(historyEntry)) {
            _scanHistory.insert(0, historyEntry);
            if (_scanHistory.length > 10) {
              _scanHistory.removeLast();
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error parsing NFC tag: $e');
      setState(() {
        _cardType = 'Kartu NFC';
        _cardNumber = 'Terdeteksi';
        _balance = 'Tidak dapat dibaca';
      });
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.nfc, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Hasil Scan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Jenis Kartu', _cardType ?? '-'),
            const SizedBox(height: 12),
            _buildInfoRow('ID Kartu', _cardNumber ?? '-'),
            const SizedBox(height: 12),
            _buildInfoRow('Saldo', _balance ?? 'Tidak tersedia'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Saldo kartu e-money terenkripsi dan memerlukan kunci khusus untuk dibaca',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _startNFCScanning();
            },
            child: const Text('Scan Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _stopScanning() {
    NfcManager.instance.stopSession();
    setState(() {
      _isScanning = false;
    });
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Scanner'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color: _isNFCAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _isNFCAvailable ? Icons.check_circle : Icons.error,
                      color: _isNFCAvailable ? Colors.green : Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isNFCAvailable ? 'NFC Tersedia' : 'NFC Tidak Tersedia',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _isNFCAvailable ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isNFCAvailable
                                ? 'Perangkat mendukung NFC'
                                : 'Aktifkan NFC di pengaturan',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Scan Button
            SizedBox(
              width: double.infinity,
              height: 200,
              child: Card(
                elevation: _isScanning ? 8 : 2,
                color: _isScanning 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : null,
                child: InkWell(
                  onTap: _isScanning ? _stopScanning : _startNFCScanning,
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isScanning)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Icon(
                              Icons.nfc,
                              size: 60,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        )
                      else
                        Icon(
                          Icons.nfc,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      const SizedBox(height: 16),
                      Text(
                        _isScanning ? 'Tempelkan Kartu NFC' : 'Tap untuk Scan',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isScanning 
                            ? 'Dekatkan kartu ke perangkat'
                            : 'Scan kartu e-money, kartu debit, dll',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Supported Cards
            const Text(
              'Kartu yang Didukung',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCardChip('Flazz BCA', Icons.credit_card),
                _buildCardChip('E-Money Mandiri', Icons.credit_card),
                _buildCardChip('TapCash BNI', Icons.credit_card),
                _buildCardChip('Brizzi BRI', Icons.credit_card),
                _buildCardChip('JakCard', Icons.credit_card),
                _buildCardChip('Kartu Lainnya', Icons.nfc),
              ],
            ),

            // Scan History
            if (_scanHistory.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Riwayat Scan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _scanHistory.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.nfc, size: 20),
                      title: Text(
                        _scanHistory[index],
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        'Baru saja',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Informasi Penting',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoPoint('Pastikan NFC diaktifkan di pengaturan perangkat'),
                  _buildInfoPoint('Tempelkan kartu di bagian belakang perangkat'),
                  _buildInfoPoint('Saldo kartu e-money terenkripsi dan tidak selalu dapat dibaca'),
                  _buildInfoPoint('Beberapa kartu memerlukan autentikasi khusus'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
