# Fitur NFC Scanner - Scan dan Cek Saldo Kartu

## ✅ Yang Telah Dibuat:

### 1. File Baru:
- ✅ `lib/screens/nfc_screen.dart` - Screen untuk scan NFC dengan UI lengkap
- ✅ `NFC_FEATURE_README.md` - Dokumentasi fitur

### 2. Update Files:
- ✅ `lib/screens/home_screen.dart` - Menambahkan tombol Quick Action "Scan NFC"
- ✅ `pubspec.yaml` - Menambahkan `nfc_manager: ^3.5.0`
- ✅ `android/app/src/main/AndroidManifest.xml` - Menambahkan NFC permission

## 🎯 Fitur NFC Scanner:

### Kemampuan:
1. **Deteksi Ketersediaan NFC**
   - Cek apakah device support NFC
   - Indikator status NFC (aktif/tidak aktif)

2. **Scan Kartu NFC**
   - Scan kartu e-money (Flazz, E-Money, TapCash, Brizzi, dll)
   - Deteksi kartu debit/kredit
   - Baca UID kartu
   - Deteksi jenis kartu

3. **Informasi yang Ditampilkan:**
   - Jenis/tipe kartu
   - ID kartu (UID)
   - Saldo (untuk kartu yang didukung)
   - Riwayat scan

4. **UI/UX:**
   - Animasi scanning dengan progress indicator
   - Dialog hasil scan dengan informasi lengkap
   - Quick action button di home screen
   - Popup navigasi ke NFC screen
   - List riwayat scan
   - Info kartu yang didukung

### Kartu yang Didukung:
- ✅ Flazz BCA
- ✅ E-Money Mandiri
- ✅ TapCash BNI
- ✅ Brizzi BRI
- ✅ JakCard
- ✅ Kartu NFC lainnya

## 📱 Cara Menggunakan:

### Di Home Screen:
1. Lihat tombol **"Scan NFC"** di Quick Actions (kiri atas)
2. Tap tombol tersebut
3. Popup konfirmasi akan muncul
4. Tap **"Buka Scanner"**

### Di NFC Scanner Screen:
1. Pastikan NFC aktif di perangkat
2. Tap area scan yang besar (dengan icon NFC)
3. Tempelkan kartu NFC di belakang perangkat
4. Tunggu hasil scan
5. Lihat informasi kartu yang terdeteksi

## ⚙️ Setup:

### Langkah 1: Install Dependency
```bash
flutter pub get
```

### Langkah 2: Build Ulang APK
Karena ada perubahan di AndroidManifest, perlu build ulang:
```bash
flutter clean
flutter build apk --debug
```

### Langkah 3: Install & Test
```bash
flutter install
```

Atau jalankan dengan:
```bash
flutter run
```

## 🔧 Permissions yang Ditambahkan:

### Android (AndroidManifest.xml):
```xml
<!-- NFC Permission -->
<uses-permission android:name="android.permission.NFC" />
<uses-feature android:name="android.hardware.nfc" android:required="false" />
```

## ⚠️ Catatan Penting:

### Tentang Saldo Kartu:
1. **Saldo terenkripsi**: Kebanyakan kartu e-money Indonesia menggunakan enkripsi proprietary
2. **Perlu kunci khusus**: Untuk membaca saldo aktual, diperlukan kunci enkripsi dari penerbit kartu
3. **Tidak semua kartu bisa dibaca**: Hanya informasi umum (UID, jenis kartu) yang bisa dibaca
4. **Security**: Saldo tidak ditampilkan untuk alasan keamanan

### Info Teknis:
- **NfcA Tags**: Digunakan untuk kebanyakan e-money cards
- **IsoDep Tags**: Untuk beberapa kartu debit/kredit
- **NDEF**: Untuk kartu yang menyimpan data dalam format NDEF

## 🧪 Testing:

### Test dengan kartu berikut:
1. **Kartu E-Money**:
   - Flazz BCA
   - E-Money Mandiri
   - TapCash BNI
   - Brizzi BRI
   - JakCard

2. **Kartu Lain**:
   - Kartu akses gedung
   - Kartu transportasi
   - Tag NFC kosong

### Expected Results:
- ✅ Deteksi jenis kartu
- ✅ Baca UID kartu
- ✅ Tampilkan dalam riwayat scan
- ⚠️ Saldo mungkin tidak terbaca (normal untuk kartu terenkripsi)

## 🎨 UI Features:

### Home Screen Quick Actions:
- Card "Scan NFC" dengan icon dan deskripsi
- Warna teal untuk NFC
- Popup dialog sebelum navigate

### NFC Screen:
- Status indicator (NFC available/not)
- Large scan area dengan animasi
- Chip list untuk kartu yang didukung
- Scan history list
- Info box dengan tips

### Result Dialog:
- Jenis kartu
- ID kartu
- Status saldo
- Warning tentang enkripsi
- Tombol "Scan Lagi"

## 📝 Flow Aplikasi:

```
Home Screen
    ↓
Tap "Scan NFC" Quick Action
    ↓
Popup Dialog Konfirmasi
    ↓
Tap "Buka Scanner"
    ↓
NFC Scanner Screen
    ↓
Tap "Tap untuk Scan"
    ↓
Tempelkan Kartu
    ↓
Hasil Scan (Dialog)
    ↓
Scan Lagi atau Tutup
```

## 🔮 Future Improvements:

1. **Balance Reading**: Implementasi baca saldo untuk kartu specific (butuh kunci enkripsi)
2. **Transaction History**: Baca history transaksi dari kartu
3. **Card Registration**: Simpan dan kelola multiple kartu
4. **Auto Transaction**: Otomatis buat transaksi dari scan NFC
5. **Card Linking**: Link kartu NFC dengan akun di app

## 🐛 Troubleshooting:

### NFC tidak tersedia:
- Pastikan device support NFC
- Aktifkan NFC di Settings > Connected devices > Connection preferences > NFC

### Kartu tidak terdeteksi:
- Tempelkan kartu di belakang device
- Coba posisi berbeda
- Pastikan kartu tidak rusak

### Saldo tidak terbaca:
- Normal untuk kebanyakan kartu e-money
- Kartu menggunakan enkripsi proprietary
- Hanya info dasar (UID, type) yang bisa dibaca

## 📄 Dependencies:

```yaml
nfc_manager: ^3.5.0
```

Package ini menyediakan:
- NFC scanning
- Tag detection
- NDEF reading
- Platform tags (NfcA, NfcB, IsoDep, dll)

---

**Catatan**: Fitur ini sudah siap digunakan! Jalankan `flutter pub get` dan rebuild aplikasi untuk mencoba fitur NFC Scanner. 🎉
