# Layanan gratis dan perubahan kata sandi saat masuk

Aplikasi Android dan halaman profil publik dibuat dari Flutter; halaman web dibatasi untuk membaca profil publik dan dihosting pada Cloudflare Pages Free. Supabase Free dipakai untuk akun email dan kata sandi, data relasi, tautan berbagi, serta foto profil. Pilihan ini memenuhi kebutuhan sinkronisasi dan berbagi tanpa layanan berbayar, dengan konsekuensi proyek Supabase Free dapat dijeda setelah tidak aktif. Pendaftaran tidak memerlukan verifikasi email. Karena tidak ada layanan pengirim email pemulihan, pengguna hanya dapat mengganti kata sandi saat masih masuk; alur "Lupa Kata Sandi" saat keluar dari akun tidak disediakan.

Cakupan halaman web dan bantuan pemulihan akun kemudian diubah atas permintaan pengguna; lihat [ADR 0004](0004-dashboard-admin.md).
