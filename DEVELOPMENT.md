# Panduan Pengembangan

## Setup Awal

### 1. Persiapan Environment
Pastikan Anda sudah menginstall:
- Flutter SDK 3.9.2 atau lebih baru
- Android SDK (untuk build Android)
- Xcode (untuk build iOS - hanya di macOS)

### 2. Konfigurasi OCR

Untuk menggunakan fitur OCR (scan struk), Anda perlu:

#### Android
Tambahkan di `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdkVersion 21  // ML Kit memerlukan minimal SDK 21
    }
}
```

#### iOS
Tambahkan di `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi membutuhkan akses kamera untuk scan struk</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi membutuhkan akses galeri untuk memilih foto struk</string>
```

### 3. Build & Run

```bash
# Debug mode
flutter run

# Release mode (Android)
flutter build apk --release

# Release mode (iOS)
flutter build ios --release
```

## Arsitektur Aplikasi

### State Management
Aplikasi menggunakan **Provider** untuk state management. Provider dipilih karena:
- Mudah dipelajari
- Terintegrasi baik dengan Flutter
- Cocok untuk aplikasi skala menengah
- Performant dan efisien

### Database
Menggunakan **SQLite** melalui package `sqflite`:
- Database lokal di device
- Tidak memerlukan koneksi internet
- Cepat dan ringan

### Struktur Data

#### Transaction Model
```dart
class Transaction {
  int? id;
  String title;
  double amount;
  DateTime date;
  TransactionCategory category;
  String? notes;
  String? receiptImagePath;
  bool isIncome;
}
```

## Cara Menambahkan Fitur Baru

### 1. Menambah Kategori Baru

Edit file `lib/models/transaction.dart`:

```dart
enum TransactionCategory {
  // ... kategori existing
  kategoriBaru,  // tambahkan di sini
}

// Tambahkan display name
case TransactionCategory.kategoriBaru:
  return 'Kategori Baru';

// Tambahkan icon
case TransactionCategory.kategoriBaru:
  return '🆕';
```

### 2. Menambah Field di Transaction

1. Tambahkan field di model:
```dart
class Transaction {
  // ... field existing
  final String? fieldBaru;
}
```

2. Update database schema di `database_helper.dart`:
```dart
await db.execute('''
  CREATE TABLE transactions (
    -- ... kolom existing
    fieldBaru TEXT
  )
''');
```

3. Update `toMap()` dan `fromMap()` methods

### 3. Menambah Screen Baru

1. Buat file di `lib/screens/`
2. Import di `home_screen.dart`
3. Tambahkan route/navigation

## Testing

### Manual Testing Checklist

- [ ] Tambah transaksi pemasukan
- [ ] Tambah transaksi pengeluaran
- [ ] Edit transaksi
- [ ] Hapus transaksi
- [ ] Scan struk dari kamera
- [ ] Scan struk dari galeri
- [ ] Lihat statistik
- [ ] Lihat kategori
- [ ] Cek perhitungan saldo
- [ ] Cek chart pie
- [ ] Cek chart bar

### Unit Testing

Tambahkan unit test di folder `test/`:
```dart
test('Calculate balance correctly', () {
  // Test logic
});
```

## Optimisasi Performa

### 1. Database
- Gunakan index untuk query yang sering digunakan
- Batch insert untuk multiple records
- Lazy loading untuk data besar

### 2. UI
- Gunakan `const` constructor dimana memungkinkan
- Implement pagination untuk list panjang
- Lazy load images

### 3. Memory
- Dispose controller dengan benar
- Close database connection
- Clear cache images

## Troubleshooting

### OCR Tidak Berfungsi

1. Cek permission kamera dan galeri
2. Pastikan ML Kit terinstall dengan benar
3. Test dengan gambar yang jelas

### Database Error

1. Clear app data
2. Uninstall dan install ulang
3. Cek versi database

### Build Error

```bash
flutter clean
flutter pub get
flutter run
```

## Best Practices

1. **Gunakan const dimana memungkinkan**
2. **Dispose semua controller**
3. **Handle null safety dengan baik**
4. **Tambahkan error handling**
5. **Gunakan meaningful variable names**
6. **Comment untuk logika kompleks**
7. **Format code dengan `flutter format`**

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [SQLite in Flutter](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [ML Kit Text Recognition](https://pub.dev/packages/google_mlkit_text_recognition)
- [FL Chart](https://pub.dev/packages/fl_chart)
