# Dashboard admin untuk akun dan kata sandi

Setelah PRD awal dibuat, pengguna meminta dashboard admin sederhana melalui browser. Dashboard hanya menyediakan daftar/pencarian akun, aktifkan/nonaktifkan akun, dan reset ke sandi sementara; pembuatan serta penghapusan akun tidak diperlukan. Permintaan ini menambah pengecualian eksplisit pada batas wireframe di ADR 0001 dan menyediakan bantuan pemulihan akun tanpa email pengirim yang sebelumnya tidak tersedia pada ADR 0003. Admin tidak melihat kata sandi lama; tindakan administratif dilakukan melalui fungsi server yang memeriksa peran admin dan menyimpan kunci rahasia di server.

Antarmuka Android dan browser tetap memakai Flutter/Dart. Rancangan teknis saat ini memakai fungsi server kecil TypeScript sesuai runtime Supabase Edge Functions untuk tindakan admin; ini perlu dikonfirmasi bila syarat perkuliahan mengharuskan seluruh kode memakai Dart.
