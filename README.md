# KeuanganKu - Aplikasi Pencatat Keuangan

Aplikasi manajemen keuangan pribadi yang dibuat dengan Flutter, dilengkapi dengan fitur OCR untuk scan struk, kategorisasi otomatis pengeluaran, dan visualisasi data keuangan.

## 🌟 Fitur Utama

### 1. **Pencatatan Keuangan**
- Tambah, edit, dan hapus transaksi
- Kategorisasi pemasukan dan pengeluaran
- Pencatatan tanggal transaksi
- Tambahkan catatan untuk setiap transaksi

### 2. **Scan Struk (OCR)**
- Scan struk menggunakan kamera atau dari galeri
- Ekstraksi otomatis:
  - Nama merchant
  - Total pembayaran
  - Tanggal transaksi
- Kategorisasi otomatis berdasarkan merchant

### 3. **Kategori Pengeluaran**
Aplikasi sudah dilengkapi dengan kategori pengeluaran yang lengkap:
- 💸 Transfer
- 🍬 Jajan
- 💳 Cicilan
- 🏠 Kontrakan
- 🚗 Transportasi
- 🛒 Belanja
- ⚕️ Kesehatan
- 📚 Pendidikan
- 🎮 Hiburan
- ⚡ Utilitas (Listrik, Air, dll)
- 🍔 Makanan & Minuman
- 📝 Lainnya

### 4. **Visualisasi Data**
- **Dashboard Saldo**: Melihat total saldo, pemasukan, dan pengeluaran
- **Pie Chart**: Distribusi pengeluaran berdasarkan kategori
- **Bar Chart**: Tren pengeluaran 7 hari terakhir
- **Ringkasan Kategori**: Detail pengeluaran per kategori dengan persentase

### 5. **Pengelompokan Otomatis**
- Transaksi otomatis dikelompokkan berdasarkan kategori
- Statistik per kategori
- Persentase pengeluaran untuk setiap kategori

## 🚀 Cara Menjalankan Aplikasi

### Prerequisites
- Flutter SDK (versi 3.9.2 atau lebih baru)
- Android Studio atau VS Code
- Emulator atau device fisik

### Langkah-langkah

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

## 📂 Struktur Folder

```
lib/
├── database/
│   └── database_helper.dart        # Database handler
├── models/
│   └── transaction.dart            # Model transaksi
├── providers/
│   └── transaction_provider.dart   # State management
├── screens/
│   ├── home_screen.dart           # Halaman utama
│   ├── add_transaction_screen.dart # Tambah/edit transaksi
│   ├── statistics_screen.dart      # Halaman statistik
│   └── scan_receipt_screen.dart    # Halaman scan struk
├── services/
│   └── ocr_service.dart           # Service OCR
├── widgets/
│   ├── balance_card.dart          # Widget kartu saldo
│   ├── transaction_list.dart      # Widget daftar transaksi
│   └── category_summary.dart      # Widget ringkasan kategori
└── main.dart                       # Entry point
```

**Dibuat dengan ❤️ menggunakan Flutter**
