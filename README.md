# Smart Business Card

Aplikasi tugas kuliah untuk kartu nama digital dan relasi profesional. Android memakai Flutter; profil publik dan dashboard admin memakai Flutter Web dari kode yang sama. Data disimpan di Supabase. Alur dan cakupan lengkap ada di [PRD.md](PRD.md).

## Versi yang dipakai

Proyek ini dibangun dan diuji dengan versi berikut. Versi lain yang lebih baru biasanya tetap berjalan, kecuali Java (lihat catatan di bawah tabel).

| Komponen | Versi | Keterangan |
|---|---|---|
| Flutter | 3.47.6 (stable) | Minimal Dart SDK `>=3.5.0 <4.0.0` sesuai `pubspec.yaml` |
| Dart | 3.13.5 | Sudah termasuk di Flutter SDK |
| Java (JDK) | **17** | Wajib. Java 25 bawaan Android Studio terbaru tidak cocok dengan Gradle 8.14 |
| Gradle | 8.14 | `android/gradle/wrapper/gradle-wrapper.properties`, diunduh otomatis |
| Android Gradle Plugin | 8.11.1 | `android/settings.gradle.kts` |
| Kotlin | 2.2.20 | `android/settings.gradle.kts` |
| Android compileSdk / targetSdk | 36 | Bawaan Flutter (`flutter.compileSdkVersion`) |
| Android minSdk | 24 (Android 7.0) | Bawaan Flutter (`flutter.minSdkVersion`) |
| Android NDK | 28.2.13676358 | Diunduh otomatis saat build pertama (sekitar 2 GB) |
| Android build-tools | 36.0.0 | Dipasang lewat Android Studio / SDK Manager |

Paket Flutter utama (versi terkunci di `pubspec.lock`):

| Paket | Versi | Fungsi |
|---|---|---|
| `supabase_flutter` | 2.18.0 | Auth, database, storage, Edge Function |
| `qr_flutter` | 4.1.0 | Membuat gambar QR |
| `mobile_scanner` | 7.4.2 | Memindai QR dengan kamera |
| `image_picker` | 1.2.4 | Memilih foto profil |
| `share_plus` | 11.1.0 | Berbagi tautan kartu |
| `url_launcher` | 6.3.3 | Membuka email, telepon, LinkedIn |
| `flutter_local_notifications` | 19.5.0 | Notifikasi pengingat follow-up |
| `timezone` | 0.10.1 | Jadwal notifikasi |
| `intl` | 0.20.3 | Format tanggal |
| `app_links` | 6.4.1 | Deep link `smartcard://save/<token>` |
| `gal` | 2.3.3 | Menyimpan gambar QR ke galeri |

Backend memakai Supabase (Postgres + Auth + Storage) dan Edge Function berbasis Deno dengan `@supabase/supabase-js@2`.

## Yang perlu dipasang

1. Pasang [Flutter SDK](https://docs.flutter.dev/install) dan tambahkan direktori `flutter/bin` ke `PATH`. **Dart sudah termasuk dalam Flutter SDK.**
2. Pasang [Android Studio dan Android SDK](https://docs.flutter.dev/platform-integration/android/setup). Ponsel Android fisik dapat menggantikan emulator, tetapi Android SDK tetap diperlukan untuk build.
3. Pasang JDK 17 dan arahkan Flutter ke JDK tersebut. Contoh di Mac dengan Homebrew:

   ```sh
   brew install openjdk@17
   flutter config --jdk-dir="$(brew --prefix openjdk@17)/libexec/openjdk.jdk/Contents/Home"
   ```

4. Jalankan `flutter doctor` dan pastikan baris Java menunjukkan versi 17. Setelah itu jalankan `flutter pub get` di folder proyek.
5. Sediakan ruang disk kosong minimal 6–8 GB untuk build Android pertama (Gradle, NDK, dan hasil build).

## Supabase

Proyek `vwdbfmhklsvsyigesfvy` sudah terhubung. Migrasi awal, bucket foto, dan ketiga Edge Function sudah dipasang. URL serta publishable key (kunci publik untuk aplikasi klien) sudah menjadi nilai bawaan di `lib/core.dart`; `--dart-define` tetap dapat dipakai untuk mengganti proyek saat pengembangan.

Untuk proyek Supabase lain, lakukan langkah berikut:

1. Buat proyek baru di [Supabase](https://supabase.com/dashboard). Salin **Project URL** dan **publishable/anon key** dari Project Settings → API. Jangan masukkan `service_role`/secret key ke aplikasi atau repo.
2. Di Authentication → Providers → Email, nonaktifkan konfirmasi email agar pendaftaran bisa langsung masuk sesuai PRD.
3. Buka SQL Editor dan jalankan seluruh isi [migrasi awal](supabase/migrations/202610060001_initial.sql). Ini membuat tabel, kebijakan akses, trigger akun, dan bucket foto.
4. Pasang [Supabase CLI](https://supabase.com/docs/guides/local-development/cli/getting-started) atau gunakan `npx supabase`. Dari folder proyek, jalankan:

   ```sh
   npx supabase login
   npx supabase link --project-ref REF_PROYEK
   npx supabase functions deploy public-card --no-verify-jwt
   npx supabase functions deploy account-admin --no-verify-jwt
   npx supabase functions deploy change-password --no-verify-jwt
   ```

   Ketiga fungsi melakukan pemeriksaan akses sendiri. Kunci administratif hanya tersedia di lingkungan Edge Function milik Supabase.
5. Untuk membuat admin pertama, daftarkan satu akun melalui aplikasi Android, lalu jalankan di SQL Editor:

   ```sql
   update public.accounts set role = 'admin' where email = 'email-admin-anda@example.com';
   ```

   Akun tersebut kemudian masuk melalui halaman web `/admin`. Akun biasa tidak bisa memberi dirinya peran admin.

## Jalankan aplikasi

`PUBLIC_BASE_URL` adalah alamat **Flutter Web yang sudah di-host**, misalnya `https://kartu-saya.pages.dev`. Nilai ini dipakai untuk membentuk tautan QR. Tanpa nilai tersebut, login dan penyimpanan data tetap berfungsi, tetapi tautan berbagi belum bisa dibuat.

Lihat ID perangkat dengan `flutter devices`, lalu jalankan:

```sh
flutter run -d ID_PERANGKAT_ANDROID \
  --dart-define=PUBLIC_BASE_URL=https://kartu-saya.pages.dev
```

Untuk APK demonstrasi:

```sh
flutter build apk --release \
  --dart-define=PUBLIC_BASE_URL=https://kartu-saya.pages.dev
```

Hasilnya berada di `build/app/outputs/flutter-apk/app-release.apk`. APK dapat dibagikan kepada peserta demonstrasi secara langsung.

## Profil publik dan dashboard admin di browser

Build Flutter Web dengan `PUBLIC_BASE_URL` yang sama:

```sh
flutter build web --release \
  --dart-define=PUBLIC_BASE_URL=https://kartu-saya.pages.dev
```

Unggah isi `build/web` sebagai situs statis pada [Cloudflare Pages Direct Upload](https://developers.cloudflare.com/pages/get-started/direct-upload/). Berkas `web/_redirects` memastikan alamat `/p/<token>` dan `/admin` diarahkan ke Flutter Web. Alamat root juga membuka login admin. Setelah mendapat domain Pages, pakai domain itu sebagai `PUBLIC_BASE_URL` dan build ulang Android serta Web.

## Catatan penggunaan

- QR baru dibuat setiap kali halaman berbagi dibuka, berlaku 24 jam, dan tetap membuka data kartu terbaru. Salinan relasi tetap dapat diedit sendiri.
- Pengingat disimpan di Supabase dan notifikasi lokal dijadwalkan pada perangkat Android yang sedang dipakai. Perangkat lain akan menjadwalkan ulang saat aplikasi dibuka dan data disinkronkan.
- Jika lupa sandi setelah keluar, admin mengatur ulang ke sandi sementara lewat browser. Tidak ada email pemulihan.
- Supabase Free dapat berhenti sementara setelah tidak aktif; buka kembali proyek sebelum demonstrasi.
