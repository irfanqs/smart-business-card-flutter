# Smart Business Card

Aplikasi tugas kuliah untuk kartu nama digital dan relasi profesional. Android memakai Flutter; profil publik dan dashboard admin memakai Flutter Web dari kode yang sama. Data disimpan di Supabase. Alur dan cakupan lengkap ada di [PRD.md](PRD.md).

## Yang perlu dipasang di Mac

1. Pasang [Flutter SDK](https://docs.flutter.dev/install) melalui ekstensi Flutter di VS Code atau instalasi manual. **Dart sudah termasuk dalam Flutter SDK.** Tambahkan direktori `flutter/bin` ke `PATH`.
2. Pasang [Android Studio dan Android SDK](https://docs.flutter.dev/platform-integration/android/setup) untuk menjalankan emulator atau membangun APK. Ponsel Android fisik dapat menggantikan emulator, tetapi Android SDK tetap diperlukan untuk build.
3. Jalankan `flutter doctor`, lalu selesaikan komponen Android yang diminta. Setelah itu jalankan `flutter pub get` di folder proyek.

SDK Flutter Anda berada di `/Users/irfanqobus/Desktop/joki-projek/flutter`. Jika perintah `flutter` belum dikenali di Terminal, tambahkan direktori `/Users/irfanqobus/Desktop/joki-projek/flutter/bin` ke `PATH`.

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
