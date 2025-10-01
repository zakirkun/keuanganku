# Setup Splash Screen & Onboarding

## Perubahan yang telah dibuat:

### 1. File Baru:
- ✅ `lib/screens/splash_screen.dart` - Splash screen dengan animasi
- ✅ `lib/screens/onboarding_screen.dart` - Onboarding screen dengan 4 halaman

### 2. Dependency Baru:
- ✅ `shared_preferences: ^2.2.2` ditambahkan ke `pubspec.yaml`

### 3. Update Files:
- ✅ `lib/main.dart` - Menggunakan SplashScreen sebagai home

## Cara Menjalankan:

### Langkah 1: Install Dependencies
```bash
flutter pub get
```

### Langkah 2: Hot Restart
Tekan `R` (Shift+R) di terminal Flutter untuk hot restart, atau restart aplikasi.

## Fitur Splash Screen & Onboarding:

### Splash Screen:
- ✨ Animasi fade in & scale logo
- ⏱️ Duration 2 detik
- 🔄 Auto redirect ke onboarding (pertama kali) atau home screen
- 🎨 Background gradient dengan warna tema

### Onboarding Screen (4 Halaman):
1. **Kelola Keuangan** - Pengenalan aplikasi
2. **Scan Struk Belanja** - Fitur OCR
3. **Statistik & Laporan** - Fitur analytics
4. **Mulai Menabung** - Call to action

### Fitur Onboarding:
- 📱 Page indicator dengan animasi
- ⏭️ Tombol "Lewati" untuk skip onboarding
- ➡️ Tombol "Selanjutnya" / "Mulai"
- 🎨 Setiap halaman dengan warna berbeda
- 💾 Menyimpan status dengan SharedPreferences (tidak tampil lagi setelah pertama kali)

## Flow Aplikasi:

```
Splash Screen (2 detik)
    |
    ├─> First Time? → Onboarding Screen → Home Screen
    └─> Not First Time? → Home Screen
```

## Testing:

### Reset Onboarding (untuk testing):
1. Uninstall aplikasi
2. Install ulang
   
ATAU

Hapus data aplikasi dari Settings Android:
- Settings > Apps > KeuanganKu > Storage > Clear Data

## Catatan:
- Onboarding hanya muncul sekali saat pertama kali membuka aplikasi
- Splash screen selalu muncul setiap kali aplikasi dibuka
- Menggunakan SharedPreferences untuk menyimpan flag `isFirstTime`
