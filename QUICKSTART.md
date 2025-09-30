# 🚀 Quick Start Guide - KeuanganKu

## Persiapan Awal

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Jalankan Aplikasi

#### Development Mode
```bash
flutter run
```

#### Pilih Device
```bash
# Lihat daftar device yang tersedia
flutter devices

# Run di device tertentu
flutter run -d <device-id>
```

## 📱 Panduan Penggunaan

### Menambah Transaksi Manual

1. Tekan tombol **"Tambah"** (FAB di kanan bawah)
2. Pilih jenis transaksi: **Pemasukan** atau **Pengeluaran**
3. Isi form:
   - **Judul**: Nama transaksi (contoh: "Belanja Bulanan")
   - **Jumlah**: Nominal dalam Rupiah (contoh: 500000)
   - **Kategori**: Pilih dari dropdown (contoh: "Belanja")
   - **Tanggal**: Tap untuk memilih tanggal
   - **Catatan**: (Opsional) Tambahkan catatan
4. Tekan **"Simpan"**

### Scan Struk Belanja

1. Tekan icon **kamera** di kanan atas (AppBar)
2. Pilih sumber:
   - **Kamera**: Ambil foto struk langsung
   - **Galeri**: Pilih foto struk yang sudah ada
3. Aplikasi akan otomatis:
   - Mendeteksi merchant/toko
   - Mengekstrak total pembayaran
   - Mendeteksi tanggal transaksi
   - Mengkategorikan berdasarkan jenis merchant
4. Review hasil scan
5. Tekan **"Buat Transaksi"** untuk melanjutkan
6. Edit jika perlu, lalu **"Simpan"**

### Melihat Statistik

1. Tap tab **"Statistik"** di bottom navigation
2. Lihat:
   - **Pie Chart**: Distribusi pengeluaran per kategori
   - **Bar Chart**: Tren pengeluaran 7 hari terakhir
   - **Legend**: Kategori dengan ikon warna

### Melihat Pengeluaran per Kategori

1. Tap tab **"Kategori"** di bottom navigation
2. Lihat ringkasan:
   - Total pengeluaran per kategori
   - Persentase dari total
   - Progress bar visual
3. Sorted dari pengeluaran terbesar

### Edit/Hapus Transaksi

1. Di tab **"Beranda"**, tap transaksi yang ingin diedit
2. Edit field yang diperlukan
3. Pilihan:
   - Tekan **"Simpan"** untuk update
   - Tekan icon **hapus** untuk delete
   - Tekan **back** untuk cancel

## 🎯 Tips & Trik

### OCR Best Practices

1. **Kualitas Foto**
   - Pastikan struk dalam kondisi baik (tidak kusut)
   - Cahaya cukup terang
   - Fokus pada teks
   - Tidak blur

2. **Posisi Foto**
   - Struk lurus (tidak miring)
   - Seluruh struk masuk frame
   - Background kontras

3. **Format Struk**
   - Struk dari merchant populer lebih akurat
   - Format Indonesia lebih baik terdeteksi
   - Total dengan format "Rp" atau "Total:" lebih mudah

### Kategorisasi Otomatis

Aplikasi akan mendeteksi kategori berdasarkan keyword:

| Keyword | Kategori |
|---------|----------|
| Indomaret, Alfamart, Supermarket | Belanja |
| McDonald's, KFC, Restaurant, Cafe | Makanan & Minuman |
| Grab, Gojek, Taxi, Bensin | Transportasi |
| Apotik, Rumah Sakit, Klinik | Kesehatan |
| PLN, PDAM, Token Listrik | Utilitas |

### Keyboard Shortcuts (Testing)

```bash
# Hot reload
r

# Hot restart
R

# Clear console
c

# Quit
q
```

## 🐛 Troubleshooting

### OCR Tidak Mendeteksi Angka

**Solusi:**
- Pastikan angka jelas terbaca
- Coba ambil foto ulang dengan pencahayaan lebih baik
- Edit manual jumlah setelah scan

### Kategori Salah Terdeteksi

**Solusi:**
- Edit transaksi setelah dibuat
- Pilih kategori yang benar dari dropdown

### Aplikasi Crash di Android

**Solusi:**
```bash
# Clear cache
flutter clean
flutter pub get
flutter run
```

### Permission Denied (Camera/Gallery)

**Solusi:**
1. Buka Settings > Apps > KeuanganKu
2. Permissions > Enable Camera dan Storage
3. Restart aplikasi

## 📊 Sample Data untuk Testing

Tambahkan transaksi berikut untuk melihat chart dan statistik:

```
1. Belanja Bulanan - Rp 2.000.000 - Belanja
2. Bayar Kontrakan - Rp 3.500.000 - Kontrakan
3. Makan Siang - Rp 50.000 - Makanan & Minuman
4. Grab ke Kantor - Rp 35.000 - Transportasi
5. Bayar Listrik - Rp 250.000 - Utilitas
6. Cicilan Motor - Rp 1.200.000 - Cicilan
7. Jajan Kopi - Rp 25.000 - Jajan
8. Transfer ke Ortu - Rp 500.000 - Transfer
```

## 🔍 Feature Testing Checklist

- [ ] Tambah transaksi pemasukan
- [ ] Tambah transaksi pengeluaran
- [ ] Edit transaksi
- [ ] Hapus transaksi (dengan konfirmasi)
- [ ] Scan struk dari kamera
- [ ] Scan struk dari galeri
- [ ] OCR detection bekerja
- [ ] Lihat pie chart
- [ ] Lihat bar chart
- [ ] Lihat kategori summary
- [ ] Pull to refresh di beranda
- [ ] Navigasi antar tab
- [ ] Dark mode (otomatis dari sistem)

## 🎓 Learning Resources

### Flutter
- [Flutter Docs](https://docs.flutter.dev/)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)

### Packages Used
- [Provider](https://pub.dev/packages/provider)
- [SQLite](https://pub.dev/packages/sqflite)
- [ML Kit](https://pub.dev/packages/google_mlkit_text_recognition)
- [FL Chart](https://pub.dev/packages/fl_chart)

## 📝 Next Steps

Setelah familiar dengan aplikasi:

1. Tambahkan lebih banyak transaksi
2. Coba fitur scan struk
3. Lihat statistik berkembang
4. Explore semua kategori
5. Customize sesuai kebutuhan

---

**Happy Tracking! 💰**

Jika ada pertanyaan atau bug, silakan buat issue di repository.
