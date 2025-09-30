# Changelog

Semua perubahan penting pada project ini akan didokumentasikan di file ini.

## [1.0.0] - 2025-09-30

### ✨ Fitur Baru
- **Pencatatan Transaksi**
  - Tambah, edit, dan hapus transaksi
  - Kategorisasi pemasukan dan pengeluaran
  - Pencatatan tanggal transaksi
  - Tambahkan catatan untuk setiap transaksi

- **Scan Struk (OCR)**
  - Scan struk menggunakan kamera
  - Scan struk dari galeri
  - Ekstraksi otomatis nama merchant
  - Ekstraksi otomatis jumlah pembayaran
  - Ekstraksi otomatis tanggal transaksi
  - Kategorisasi otomatis berdasarkan merchant

- **12 Kategori Pengeluaran**
  - Transfer
  - Jajan
  - Cicilan
  - Kontrakan
  - Transportasi
  - Belanja
  - Kesehatan
  - Pendidikan
  - Hiburan
  - Utilitas (Listrik, Air, dll)
  - Makanan & Minuman
  - Lainnya

- **Visualisasi Data**
  - Dashboard dengan kartu saldo
  - Total pemasukan dan pengeluaran
  - Saldo keseluruhan
  - Pie chart distribusi pengeluaran
  - Bar chart pengeluaran 7 hari terakhir
  - Ringkasan per kategori dengan persentase

- **Pengelompokan Otomatis**
  - Transaksi otomatis dikelompokkan berdasarkan kategori
  - Sorting berdasarkan jumlah terbesar
  - Progress bar visual untuk setiap kategori

### 🛠️ Teknologi
- Flutter 3.9.2
- Provider untuk state management
- SQLite untuk database lokal
- Google ML Kit untuk OCR
- FL Chart untuk visualisasi
- Material 3 design

### 📱 Platform Support
- Android (minSdk 21+)
- iOS (iOS 12+)
- Belum support Web dan Desktop

### 🐛 Known Issues
- OCR accuracy tergantung pada kualitas foto
- Beberapa format tanggal mungkin tidak terdeteksi
- Merchant recognition terbatas pada merchant populer Indonesia

### 📝 Notes
- Data tersimpan lokal di device
- Belum ada fitur backup/restore
- Belum ada fitur cloud sync
