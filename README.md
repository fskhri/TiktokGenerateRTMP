# TikTok RTMP Key Generator

Aplikasi Android untuk generate RTMP stream key TikTok untuk digunakan dengan OBS Studio atau aplikasi streaming lainnya.

## Fitur

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

## Requirements

- Flutter SDK 3.10.0 atau lebih tinggi
- Android Studio atau VS Code dengan Flutter extension
- Android device atau emulator dengan Android 5.0 (API 21) atau lebih tinggi

## Installation

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

## Cara Menggunakan

1. **Login TikTok**
   - Buka aplikasi
   - Klik tombol "Login TikTok"
   - Login menggunakan akun TikTok Anda di WebView
   - Setelah login berhasil, Anda akan kembali ke halaman utama

2. **Generate Stream Key**
   - Masukkan judul stream (wajib)
   - Masukkan Game Tag ID (opsional)
   - Pilih region priority
   - Aktifkan opsi yang diinginkan (replay, close room, mature content)
   - Klik "Generate Stream Key"

3. **Gunakan Stream Key**
   - Setelah stream key berhasil di-generate, Anda akan melihat:
     - Base Stream URL
     - Stream Key
     - Full RTMP URL
     - Share URL
   - Klik tombol "Copy" untuk menyalin informasi yang diperlukan
   - Gunakan Base Stream URL dan Stream Key di OBS Studio atau aplikasi streaming lainnya

4. **End Stream**
   - Klik tombol "End Stream" untuk mengakhiri stream

## Catatan Penting

- Pastikan Anda memiliki akses TikTok LIVE untuk menggunakan aplikasi ini
- Cookies akan disimpan secara lokal di device Anda
- Jika mengalami error "Silakan login terlebih dahulu", coba logout dan login ulang
- Stream key hanya valid selama stream aktif

## Troubleshooting

### Error "Silakan login terlebih dahulu"
- Pastikan Anda sudah login dengan benar
- Coba logout dan login ulang
- Pastikan cookies tersimpan dengan benar

### Error saat generate stream key
- Pastikan Anda memiliki akses TikTok LIVE
- Periksa koneksi internet
- Pastikan judul stream tidak kosong

### Cookies tidak tersimpan
- Pastikan aplikasi memiliki permission untuk menyimpan data
- Coba clear cache aplikasi dan login ulang

## Build APK

Untuk membuat file APK yang bisa di-install:

```bash
flutter build apk --release
```

File APK akan berada di: `build/app/outputs/flutter-apk/app-release.apk`

## Build App Bundle (untuk Google Play)

```bash
flutter build appbundle --release
```

File AAB akan berada di: `build/app/outputs/bundle/release/app-release.aab`

## License

Project ini dibuat untuk keperluan edukasi dan penggunaan pribadi.

## Disclaimer

Aplikasi ini tidak berafiliasi dengan TikTok. Gunakan dengan tanggung jawab Anda sendiri.
