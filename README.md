# TikTok RTMP Key Generator

**Language / Bahasa:** [English](#english) | [Bahasa Indonesia](#bahasa-indonesia)

---

<a name="english"></a>
##  English

### TikTok RTMP Key Generator

An Android application to generate TikTok RTMP stream keys for use with OBS Studio or other streaming applications.

### Features

- ✅ TikTok login via WebView
- ✅ Generate RTMP stream key
- ✅ Get Base Stream URL
- ✅ Get Share URL for live stream
- ✅ Option to enable replay
- ✅ Option to close room when stream ends
- ✅ Region priority selection
- ✅ Option to mark content as mature content
- ✅ Button to end stream
- ✅ Copy to clipboard for all stream information
- ✅ Thumbnail upload support
- ✅ Game tag selection for gaming streams
- ✅ Topic/category selection

### Requirements

- Flutter SDK 3.10.0 or higher
- Android Studio or VS Code with Flutter extension
- Android device or emulator with Android 5.0 (API 21) or higher

### Installation

1. Clone or download this repository
2. Install dependencies:
```bash
flutter pub get
```

3. Build the application for Android:
```bash
flutter build apk
```

Or run on device/emulator:
```bash
flutter run
```

### How to Use

1. **Login to TikTok**
   - Open the application
   - Click the "Login TikTok" button
   - Login using your TikTok account in WebView
   - After successful login, you will return to the main page

2. **Import Cookies (Alternative)**
   - Click "Import Cookies from File"
   - Select your cookies.json file
   - Cookies will be saved permanently

3. **Generate Stream Key**
   - Enter stream title (required)
   - Select topic/category (optional)
   - Select game tag if topic is Gaming (optional)
   - Select region priority
   - Choose stream type
   - Enable desired options (replay, close room, mature content)
   - Select thumbnail from gallery (optional)
   - Click "Go Live" button

4. **Use Stream Key**
   - After the stream key is successfully generated, you will see:
     - RTMP URL (full URL)
     - Share URL
   - Click the "Copy" button to copy the required information
   - Use the RTMP URL in OBS Studio or other streaming applications

5. **End Stream**
   - Click the "End Stream" button to end the stream

### Important Notes

- Make sure you have TikTok LIVE access to use this application
- Cookies will be stored locally on your device
- If you encounter an error "Please login first", try logging out and logging in again
- Stream key is only valid while the stream is active
- The application supports both English and Indonesian languages

### Troubleshooting

#### Error "Please login first"
- Make sure you have logged in correctly
- Try logging out and logging in again
- Make sure cookies are saved correctly

#### Error when generating stream key
- Make sure you have TikTok LIVE access
- Check internet connection
- Make sure stream title is not empty
- Verify that cookies are valid and not expired

#### Cookies not saved
- Make sure the application has permission to save data
- Try clearing the app cache and logging in again

#### Performance Issues / Lag when Scrolling
- The app has been optimized for smooth scrolling
- If you experience lag, try:
  - Restart the application
  - Clear app cache
  - Update to the latest version

### Build APK

To create an installable APK file:

```bash
flutter build apk --release
```

APK file will be located at: `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (for Google Play)

```bash
flutter build appbundle --release
```

AAB file will be located at: `build/app/outputs/bundle/release/app-release.aab`

### Language Selection

The application supports multiple languages:
- English (en)
- Indonesian (id)

The language will be automatically detected based on your device settings, or you can change it in the app settings.

### Credits & Acknowledgments

This Android application is based on the original Python implementation by [Loukious](https://github.com/Loukious). Special thanks to the creator for providing the Python source code that made this Android implementation possible.

**Original Repository:** [TikTokStreamKeyGenerator](https://github.com/Loukious/TikTokStreamKeyGenerator)

The Python script served as the foundation and reference for implementing the TikTok RTMP stream key generation functionality in this Flutter/Android application.

### Disclaimer

This application is not affiliated with TikTok. Use at your own responsibility.

---

<a name="bahasa-indonesia"></a>
## Bahasa Indonesia

### TikTok RTMP Key Generator

Aplikasi Android untuk generate RTMP stream key TikTok untuk digunakan dengan OBS Studio atau aplikasi streaming lainnya.

### Fitur

- ✅ Login TikTok melalui WebView
- ✅ Generate RTMP stream key
- ✅ Mendapatkan Base Stream URL
- ✅ Mendapatkan Share URL untuk live stream
- ✅ Opsi untuk enable replay
- ✅ Opsi untuk close room saat stream selesai
- ✅ Pilihan region priority
- ✅ Opsi untuk menandai konten sebagai mature content
- ✅ Tombol untuk end stream
- ✅ Copy to clipboard untuk semua informasi stream
- ✅ Dukungan upload thumbnail
- ✅ Pilihan game tag untuk streaming gaming
- ✅ Pilihan topik/kategori

### Requirements

- Flutter SDK 3.10.0 atau lebih tinggi
- Android Studio atau VS Code dengan Flutter extension
- Android device atau emulator dengan Android 5.0 (API 21) atau lebih tinggi

### Installation

1. Clone atau download repository ini
2. Install dependencies:
```bash
flutter pub get
```

3. Build aplikasi untuk Android:
```bash
flutter build apk
```

Atau jalankan di device/emulator:
```bash
flutter run
```

### Cara Menggunakan

1. **Login TikTok**
   - Buka aplikasi
   - Klik tombol "Login TikTok"
   - Login menggunakan akun TikTok Anda di WebView
   - Setelah login berhasil, Anda akan kembali ke halaman utama

2. **Import Cookies (Alternatif)**
   - Klik "Import Cookies from File"
   - Pilih file cookies.json Anda
   - Cookies akan disimpan secara permanen

3. **Generate Stream Key**
   - Masukkan judul stream (wajib)
   - Pilih topik/kategori (opsional)
   - Pilih game tag jika topik adalah Gaming (opsional)
   - Pilih region priority
   - Pilih tipe stream
   - Aktifkan opsi yang diinginkan (replay, close room, mature content)
   - Pilih thumbnail dari gallery (opsional)
   - Klik tombol "Go Live"

4. **Gunakan Stream Key**
   - Setelah stream key berhasil di-generate, Anda akan melihat:
     - RTMP URL (full URL lengkap)
     - Share URL
   - Klik tombol "Copy" untuk menyalin informasi yang diperlukan
   - Gunakan RTMP URL di OBS Studio atau aplikasi streaming lainnya

5. **End Stream**
   - Klik tombol "End Stream" untuk mengakhiri stream

### Catatan Penting

- Pastikan Anda memiliki akses TikTok LIVE untuk menggunakan aplikasi ini
- Cookies akan disimpan secara lokal di device Anda
- Jika mengalami error "Silakan login terlebih dahulu", coba logout dan login ulang
- Stream key hanya valid selama stream aktif
- Aplikasi mendukung bahasa Inggris dan Indonesia

### Troubleshooting

#### Error "Silakan login terlebih dahulu"
- Pastikan Anda sudah login dengan benar
- Coba logout dan login ulang
- Pastikan cookies tersimpan dengan benar

#### Error saat generate stream key
- Pastikan Anda memiliki akses TikTok LIVE
- Periksa koneksi internet
- Pastikan judul stream tidak kosong
- Verifikasi bahwa cookies valid dan tidak expired

#### Cookies tidak tersimpan
- Pastikan aplikasi memiliki permission untuk menyimpan data
- Coba clear cache aplikasi dan login ulang

#### Masalah Performa / Lag saat Scrolling
- Aplikasi telah dioptimasi untuk scrolling yang smooth
- Jika mengalami lag, coba:
  - Restart aplikasi
  - Clear cache aplikasi
  - Update ke versi terbaru

### Build APK

Untuk membuat file APK yang bisa di-install:

```bash
flutter build apk --release
```

File APK akan berada di: `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (untuk Google Play)

```bash
flutter build appbundle --release
```

File AAB akan berada di: `build/app/outputs/bundle/release/app-release.aab`

### Pemilihan Bahasa

Aplikasi mendukung beberapa bahasa:
- English (en)
- Indonesian (id)

Bahasa akan otomatis terdeteksi berdasarkan pengaturan device Anda, atau Anda bisa mengubahnya di pengaturan aplikasi.

### Kredit & Ucapan Terima Kasih

Aplikasi Android ini didasarkan pada implementasi Python asli oleh [Loukious](https://github.com/Loukious). Terima kasih khusus kepada pembuatnya karena telah menyediakan source code Python yang memungkinkan implementasi Android ini dibuat.

**Repository Asli:** [TikTokStreamKeyGenerator](https://github.com/Loukious/TikTokStreamKeyGenerator)

Script Python tersebut menjadi fondasi dan referensi untuk mengimplementasikan fungsi generate TikTok RTMP stream key dalam aplikasi Flutter/Android ini.


### Disclaimer

Aplikasi ini tidak berafiliasi dengan TikTok. Gunakan dengan tanggung jawab Anda sendiri.

---

**Language / Bahasa:** [English](#english) | [Bahasa Indonesia](#bahasa-indonesia)
