# Product Requirements Document — Smart Business Card

**Status:** Draf untuk ditinjau  
**Tanggal:** 6 Oktober 2026  
**Platform:** Android untuk pengguna; browser untuk profil publik dan dashboard admin  
**Bahasa antarmuka:** Indonesia  
**Acuan:** delapan wireframe yang diberikan, diagram aktivitas dan use case sebagai penjelas alur, serta keputusan pada [ADR 0001](docs/adr/0001-wireframe-menentukan-cakupan.md), [ADR 0002](docs/adr/0002-qr-berbagi-berlaku-24-jam.md), [ADR 0003](docs/adr/0003-layanan-gratis-dan-pemulihan-akun.md), dan [ADR 0004](docs/adr/0004-dashboard-admin.md).

## 1. Ringkasan produk

Smart Business Card membantu profesional individu membuat satu kartu nama digital, membagikannya melalui QR atau tautan, lalu menyimpan dan mengelola relasi profesional. Profil yang dibagikan dapat dibuka di browser tanpa akun. Pengguna aplikasi dapat menyimpan salinan kontak, menempatkannya dalam satu kategori, menulis banyak catatan interaksi, dan memasang satu pengingat tindak lanjut aktif per relasi. Admin mempunyai dashboard sederhana untuk membantu pengelolaan akun dan kata sandi.

Proyek ini dibuat untuk tugas perkuliahan. Keberhasilan utamanya adalah alur dari pembuatan kartu sampai pengelolaan relasi dapat didemonstrasikan dengan data sungguhan, menggunakan layanan gratis dan antarmuka yang mengikuti wireframe.

## 2. Tujuan dan ukuran keberhasilan

### Tujuan

1. Pengguna dapat mendaftar, masuk, membuat kartu, mengeditnya, dan memilih apakah kartu bisa dilihat publik.
2. QR dan tautan yang dibuat pada halaman berbagi dapat membuka profil terbaru selama 24 jam.
3. Pengunjung tanpa akun dapat membaca profil publik melalui browser.
4. Pengguna Android dapat menyimpan kontak dari QR atau memasukkannya manual, lalu mencari, mengelompokkan, dan mengelolanya.
5. Pengguna dapat mencatat beberapa interaksi dan menerima notifikasi lokal untuk tindak lanjut.
6. Kartu dan relasi tersedia kembali ketika pengguna masuk pada perangkat Android lain dengan akun yang sama.
7. Admin dapat membantu pengguna yang kehilangan akses akun tanpa perlu melihat kata sandi lama.

### Kriteria demonstrasi

Satu demonstrasi selesai bila dua akun Android dapat dibuat; akun A membuat dan membagikan kartu; akun B atau browser tanpa akun membuka QR; akun B menyimpan A sebagai relasi, menambah catatan dan pengingat; akun A mengedit kartunya dan browser melihat perubahan; salinan relasi B tetap dapat disunting sendiri. Admin dapat melihat akun A/B, menonaktifkan lalu mengaktifkan satu akun, dan menetapkan sandi sementara agar pengguna dapat masuk serta menggantinya. Semua langkah menggunakan data yang disimpan, bukan angka atau profil contoh yang ditanam dalam aplikasi.

## 3. Pengguna dan batas cakupan

**Pengguna utama:** profesional individu yang bertukar identitas saat bertemu orang baru dan ingin mengingat tindak lanjutnya.

**Pengunjung profil:** penerima QR atau tautan yang mungkin belum memiliki aplikasi maupun akun.

**Admin:** pengelola tugas kuliah yang diberi akses khusus untuk membantu pengelolaan akun pengguna.

**Dalam cakupan:** delapan layar inti wireframe; layar pendukung untuk daftar/masuk, pengaturan akun dan ubah kata sandi, kamera pemindai QR, tambah kontak manual, detail relasi dengan linimasa, pengingat, daftar pengingat, bantuan singkat, tentang aplikasi, serta dashboard admin sederhana. Layar pendukung hanya memuat fungsi yang dibutuhkan oleh alur yang sudah disetujui.

**Di luar cakupan:** pemindaian foto kartu fisik/OCR, NFC, lencana verifikasi, beberapa kartu per akun, kolaborasi dua arah antarrelasi, pengingat melalui server, pendaftaran atau pengelolaan relasi pengguna di web, pemulihan kata sandi secara mandiri saat keluar dari akun, pembuatan/penghapusan akun melalui admin, operasi data saat offline, dan publikasi ke Play Store.

## 4. Prinsip dan asumsi produk

- Satu akun mempunyai satu kartu digital aktif yang dapat diedit kapan saja. Tidak ada arsip tahunan.
- Hanya nama lengkap yang wajib pada kartu. Foto dan kolom profesional lain boleh kosong. Logo perusahaan pada wireframe dihilangkan.
- Profil publik menampilkan hanya kolom kartu yang terisi. Email, telepon, dan LinkedIn termasuk informasi publik ketika kartu terlihat.
- Relasi dan catatan adalah milik pribadi pengguna yang menyimpannya. Salinan kontak tidak berubah otomatis saat kartu sumber diedit.
- Menghitung “Kartu Dibagikan” berarti menghitung tindakan berbagi yang dimulai dari aplikasi: salin tautan, buka menu berbagi, atau unduh QR. Angka ini tidak mengklaim bahwa penerima benar-benar melihat kartu.
- “Relasi Baru” berarti relasi yang ditambahkan dalam 30 hari terakhir.
- Jika visibilitas kartu dihidupkan kembali, tautan lama yang belum mencapai batas 24 jam dapat dipakai lagi; tautan kedaluwarsa tetap tidak berlaku.
- Untuk kebutuhan demonstrasi, cara memasang APK bagi pengunjung yang belum memiliki aplikasi akan disediakan bersama distribusi proyek; halaman publik cukup menampilkan petunjuk tersebut.
- Admin menyampaikan sandi sementara kepada pemilik akun di luar aplikasi. Dashboard tidak mengirim pesan atau email.

## 5. Peta layar

| Layar | Asal | Tugas utama |
| --- | --- | --- |
| Daftar, Masuk | Pendukung | Mengakses akun dengan email dan kata sandi. |
| Beranda | Wireframe 1 | Melihat kartu ringkas, statistik, relasi terbaru, dan pengingat. |
| Kartu Saya | Wireframe 2 | Melihat kartu sendiri dan membuka tindakan edit atau berbagi. |
| Buat/Edit Kartu | Wireframe 3 | Mengisi data kartu dan melihat pratinjau sebelum menyimpan. |
| QR Code/Bagikan Kartu | Wireframe 4 | Membuat QR, menyalin tautan, membuka menu berbagi, dan mengunduh gambar QR. |
| Profil Publik | Wireframe 5 | Membaca kartu melalui browser atau aplikasi, lalu membuka aplikasi untuk menyimpan relasi. |
| Simpan/Detail Relasi | Wireframe 6 dengan perluasan yang disepakati | Menyimpan kontak, memilih kategori, melihat dan mengubah salinan, catatan, serta pengingat. |
| Relasi | Wireframe 7 | Menelusuri, mencari, memfilter, menambah manual, dan memindai QR. |
| Profil | Wireframe 8 | Mengatur visibilitas, notifikasi, akun, bantuan, dan keluar. |
| Pemindai QR | Pendukung | Membaca QR aplikasi melalui kamera Android. |
| Pengingat mendatang | Pendukung dari ikon lonceng | Melihat pengingat aktif dan membuka relasinya. |
| Pengaturan Akun | Pendukung dari “Edit Profil Akun” | Melihat email akun dan mengubah kata sandi saat masuk. |
| Masuk Admin | Pendukung khusus browser | Masuk menggunakan akun yang sudah diberi peran admin. |
| Dashboard Admin | Tambahan yang diminta setelah wireframe | Melihat ringkasan jumlah akun, mencari akun, melihat status, dan membuka tindakan akun. |
| Dialog Tindakan Admin | Pendukung dashboard | Mengonfirmasi status akun atau menampilkan sandi sementara sekali setelah reset. |

Navigasi utama Android memakai empat tab pada wireframe: **Beranda, Kartu Saya, Relasi, Profil**. Halaman edit, berbagi, pemindaian, dan detail dibuka dari tab terkait. Pengunjung browser mendapat profil publik dan keadaan gagal yang relevan; admin yang masuk melalui browser mendapat dashboard tersendiri. Akun pengguna biasa tidak dapat membuka dashboard admin.

## 6. Alur pengguna

### 6.1 Pengguna baru membuat kartu

1. Pengguna mendaftar dengan email dan kata sandi, lalu masuk tanpa verifikasi email.
2. Jika belum mempunyai kartu, aplikasi mengarahkan ke pembuatan kartu atau menampilkan ajakan membuat kartu pada Beranda/Kartu Saya.
3. Pengguna mengisi nama dan kolom opsional, mengunggah foto bila ingin, melihat pratinjau, lalu menyimpan.
4. Kartu tampil di Kartu Saya dan Beranda. Visibilitas publik dapat diubah pada Profil.

### 6.2 Membagikan dan membuka kartu

1. Pemilik membuka halaman Bagikan Kartu. Aplikasi membuat satu tautan acak baru dengan masa berlaku 24 jam dan menampilkan QR dari tautan itu.
2. Salin Tautan, Bagikan Pesan, dan Unduh Gambar memakai tautan/QR yang sedang tampil. Membuka halaman ini kembali menghasilkan tautan baru; tautan lama tetap berlaku sampai masa berlakunya selesai.
3. Penerima memindai QR melalui kamera umum atau aplikasi. Profil terbuka di browser tanpa login selama tautan berlaku dan visibilitas kartu aktif.
4. Profil mengambil data kartu terbaru ketika dibuka. Jika pemilik mematikan visibilitas, semua tautan langsung menampilkan keadaan profil tidak tersedia.
5. Tombol Simpan ke Relasi membuka aplikasi Android. Jika belum terpasang, browser menampilkan petunjuk instalasi. Jika belum masuk, aplikasi meminta login lalu melanjutkan penyimpanan selama tautan masih berlaku.

### 6.3 Menyimpan dan mengelola relasi

1. Dari QR valid, pengguna melihat profil dan memilih Simpan ke Relasi. Aplikasi membuat salinan data kontak.
2. Pengguna dapat memilih satu kategori dari Partner, Klien, Prospek, atau Teman Profesional. Tanggal/lokasi pertemuan dan catatan awal boleh ditambahkan.
3. Dari daftar Relasi, pengguna juga dapat menambah kontak manual; hanya nama wajib.
4. Pengguna dapat mengedit salinan kontak, mengganti kategori, membuat beberapa catatan interaksi bertanggal, serta memasang satu pengingat aktif.
5. Menghapus relasi memerlukan konfirmasi dan menghapus catatan serta pengingat milik pengguna itu. Kartu milik orang lain tidak terpengaruh.

### 6.4 Admin membantu akses akun

1. Admin masuk melalui browser dengan akun yang sudah diberi peran admin. Pendaftaran umum tidak dapat menghasilkan akun admin.
2. Dashboard menampilkan jumlah akun pengguna, jumlah aktif/nonaktif, pencarian email, dan tabel akun dengan statusnya.
3. Admin dapat menonaktifkan atau mengaktifkan akun pengguna setelah konfirmasi. Saat nonaktif, akun tidak dapat memakai data aplikasi atau membagikan profil publik; datanya tetap tersimpan untuk diaktifkan kembali.
4. Jika pengguna lupa sandi setelah keluar, admin memilih **Atur Ulang Sandi**. Layanan membuat sandi sementara yang kuat, mengganti sandi akun, lalu menampilkannya sekali kepada admin untuk disampaikan kepada pemilik akun.
5. Pengguna masuk dengan sandi sementara dan wajib menggantinya sebelum memakai fitur lain. Admin tidak melihat sandi lama dan tidak dapat membuka catatan relasi pengguna.

## 7. Kebutuhan fungsional

### A. Akun dan profil

| ID | Kebutuhan |
| --- | --- |
| AK-01 | Daftar dan masuk memakai email serta kata sandi; pendaftaran tidak mewajibkan verifikasi email. |
| AK-02 | Sesi masuk bertahan saat aplikasi ditutup dan dapat dipakai kembali pada perangkat Android lain. |
| AK-03 | Profil Akun menampilkan email sebagai informasi hanya baca. Nama dan foto yang tampil di header Profil mengikuti kartu digital. |
| AK-04 | Pengguna yang sedang masuk dapat mengubah kata sandinya dan keluar dari akun. Layar login tidak menyediakan “Lupa Kata Sandi” mandiri; saat pendaftaran aplikasi menjelaskan bahwa bila kehilangan akses setelah keluar, pengguna perlu meminta bantuan admin. |
| AK-05 | Data pribadi tiap akun hanya dapat dibaca/diubah oleh pemilik akun. |

### B. Kartu digital

| ID | Kebutuhan |
| --- | --- |
| KR-01 | Satu akun hanya mempunyai satu kartu aktif. Membuat ulang ketika kartu sudah ada membuka editor kartu tersebut. |
| KR-02 | Kolom kartu: nama lengkap wajib; foto profil, jabatan, perusahaan, industri, kota, email publik, nomor telepon publik, URL LinkedIn, dan bio singkat opsional. |
| KR-03 | Foto menerima JPG/PNG dengan ukuran berkas maksimal 2 MB seperti wireframe. Jika tidak ada foto, tampilkan inisial atau placeholder. |
| KR-04 | Editor menampilkan pratinjau dan perubahan disimpan hanya setelah pengguna menekan Simpan. |
| KR-05 | Kartu Saya menampilkan data yang sudah tersimpan serta tindakan Tampilkan QR, Edit Kartu, dan Bagikan Kartu. |
| KR-06 | Saat sakelar visibilitas publik mati, profil publik tidak dapat dibuka melalui QR atau tautan apa pun; pemilik tetap dapat melihat dan mengedit kartunya. |

### C. QR, tautan, dan profil publik

| ID | Kebutuhan |
| --- | --- |
| BG-01 | Membuka halaman QR membuat tautan unik dan sulit ditebak yang berlaku 24 jam sejak dibuat. QR mengodekan tautan tersebut. |
| BG-02 | Tombol Salin Tautan menyalin tautan yang sama dengan QR di layar. Bagikan Pesan membuka menu berbagi Android; Unduh Gambar menyimpan QR sebagai gambar. |
| BG-03 | Profil publik tersedia di browser tanpa login dan menampilkan data kartu terbaru yang terisi, beserta tindakan email, telepon, dan LinkedIn jika tersedia. |
| BG-04 | Tautan kedaluwarsa, tidak dikenal, atau kartu yang disembunyikan menampilkan pesan yang berbeda dan tidak membocorkan data kartu. |
| BG-05 | QR lama yang belum kedaluwarsa tetap berlaku setelah QR baru dibuat, selama visibilitas publik aktif. |
| BG-06 | Memindai QR selain tautan aplikasi menampilkan “QR tidak dikenali”; QR kedaluwarsa meminta QR baru dari pemilik. |
| BG-07 | Data pribadi relasi, catatan, dan pengingat tidak pernah muncul pada profil publik. |

### D. Relasi, pencarian, dan linimasa

| ID | Kebutuhan |
| --- | --- |
| RL-01 | Kontak dari QR disimpan sebagai salinan yang dapat disunting. Kontak manual mewajibkan nama; jabatan, perusahaan, email, telepon, LinkedIn, dan kategori opsional saat dibuat. |
| RL-02 | Satu relasi mempunyai paling banyak satu kategori dari empat kategori tetap; kategori boleh belum dipilih saat kontak pertama kali dibuat. |
| RL-03 | Memindai ulang kartu yang sudah terhubung membuka relasi lama dan tidak membuat duplikat. |
| RL-04 | Jika kontak manual mempunyai email atau telepon yang sama dengan kartu hasil pemindaian, aplikasi menawarkan untuk menghubungkannya. Penggabungan memerlukan persetujuan pengguna dan tidak menimpa suntingan atau catatan pribadi. |
| RL-05 | Daftar Relasi dapat dicari berdasarkan nama atau perusahaan, difilter berdasarkan kategori, dan diurutkan menurut waktu penambahan terbaru. |
| RL-06 | Setiap relasi mempunyai beberapa Catatan Interaksi. Setiap catatan berisi tanggal, teks wajib, dan lokasi opsional; dapat dibuat, diedit, dan dihapus. Urutan tampilan terbaru terlebih dahulu. |
| RL-07 | Menu relasi menyediakan Edit dan Hapus. Hapus meminta konfirmasi lalu menghapus catatan dan pengingat terkait. |
| RL-08 | Tombol telepon, email, dan LinkedIn membuka aplikasi terkait bila data tersebut tersedia. |

### E. Pengingat dan Beranda

| ID | Kebutuhan |
| --- | --- |
| PG-01 | Satu relasi dapat memiliki paling banyak satu pengingat aktif dengan tanggal dan waktu di masa depan. Pengguna dapat mengubah atau menghapusnya. |
| PG-02 | Notifikasi lokal dijadwalkan pada perangkat Android yang dipakai. Mengubah/menghapus pengingat memperbarui atau membatalkan notifikasi terkait. |
| PG-03 | Ikon lonceng membuka daftar pengingat mendatang. Menekan pengingat membuka detail relasinya. |
| PG-04 | Saat sakelar Notifikasi Pengingat dimatikan, pengingat tetap tersimpan tetapi notifikasi lokal dibatalkan. Saat diaktifkan lagi, jadwal yang masih di masa depan dibuat ulang. |
| PG-05 | Beranda menampilkan kartu ringkas, relasi terbaru, Total Relasi, Kartu Dibagikan, dan Relasi Baru dalam 30 hari terakhir berdasarkan data akun yang nyata. |
| PG-06 | Pusat Bantuan & FAQ dan Tentang Aplikasi menampilkan informasi statis singkat sesuai entri pada Profil. |

### F. Dashboard admin

| ID | Kebutuhan |
| --- | --- |
| AD-01 | Dashboard hanya tersedia di browser bagi akun yang diberi peran admin oleh pengelola proyek. Pengguna biasa dan pengunjung tanpa akun ditolak. |
| AD-02 | Tampilan sederhana berisi ringkasan total akun pengguna, aktif, dan nonaktif; kolom cari email; serta tabel email, tanggal daftar, status, dan tindakan. |
| AD-03 | Admin dapat menonaktifkan dan mengaktifkan akun pengguna setelah dialog konfirmasi. Admin tidak dapat menonaktifkan akunnya sendiri. |
| AD-04 | Akun nonaktif tidak dapat masuk atau memakai data aplikasi; profil publiknya tidak dapat dibuka. Mengaktifkannya kembali tidak menghapus data sebelumnya. |
| AD-05 | Admin dapat meminta sandi sementara acak untuk akun pengguna. Sandi baru ditampilkan sekali dengan tombol Salin, tidak disimpan sebagai teks biasa pada tabel aplikasi atau log. |
| AD-06 | Setelah reset admin, pengguna harus mengganti sandi sementara pada login berikutnya sebelum membuka fitur aplikasi. |
| AD-07 | Dashboard tidak memperlihatkan sandi lama, kartu pribadi yang tersembunyi, daftar relasi, catatan, atau pengingat pengguna. |
| AD-08 | Admin dapat keluar dan mengganti sandi akunnya sendiri. Dashboard tidak membuat atau menghapus akun pengguna. |

## 8. Aturan validasi dan keadaan gagal

- Nama kartu dan nama kontak manual tidak boleh kosong setelah spasi dihapus. Email, nomor telepon, dan LinkedIn boleh kosong; bila diisi, format yang jelas salah diberi pesan di dekat kolom.
- Bio memakai batas 160 karakter sesuai wireframe. Foto di atas 2 MB atau selain JPG/PNG ditolak dengan pesan yang jelas.
- Pengingat harus berada di masa depan. Jika izin notifikasi Android belum diberikan, jadwal tetap tersimpan dan layar menjelaskan cara mengaktifkan izin.
- Saat tidak ada internet, login, penyimpanan, sinkronisasi, pembuatan QR, dan pembukaan profil publik menampilkan keadaan koneksi. Tidak ada antrean perubahan offline; notifikasi lokal yang sudah terjadwal tetap dapat berjalan.
- Jika tautan habis saat pengguna sedang masuk ke aplikasi untuk menyimpan relasi, tampilkan pesan kedaluwarsa dan minta QR baru. Jangan membuat relasi dari tautan yang tidak lagi sah.
- Jika pemilik mencoba memindai QR miliknya sendiri, arahkan ke Kartu Saya alih-alih membuat relasi dengan dirinya sendiri.
- Bila daftar relasi atau pengingat kosong, tampilkan keadaan kosong dengan tindakan yang sesuai, bukan angka/kartu contoh.
- Pada dashboard admin, pencarian tanpa hasil dan kegagalan tindakan menampilkan pesan yang jelas. Reset sandi dan perubahan status tidak dianggap berhasil sebelum server mengonfirmasinya.

### Panduan antarmuka

- Pertahankan struktur informasi dan navigasi empat tab dari wireframe; tampilan akhir boleh memperjelas hierarki, jarak, warna, dan ikon tanpa menambah fungsi yang belum disepakati.
- Semua label, validasi, dan keadaan kosong menggunakan bahasa Indonesia. Data contoh Andi Pratama pada wireframe hanya referensi tata letak, bukan isi bawaan akun baru.
- Nama, tombol utama, dan status QR harus mudah dibaca pada layar Android ukuran ponsel; tindakan yang tidak tersedia karena data kosong disembunyikan atau dinonaktifkan dengan jelas.
- Hilangkan tulisan NFC, verifikasi, logo perusahaan, dan angka statistik contoh dari tampilan final.
- Dashboard admin memakai tata letak browser sederhana: judul, tiga kartu ringkasan, satu pencarian, tabel pengguna, dan dialog konfirmasi. [Wireframe dashboard](docs/admin-dashboard-wireframe.svg) dan [dialog sandi sementara](docs/admin-reset-dialog-wireframe.svg) menjadi acuan visual awal.

## 9. Model data konseptual

| Entitas | Data inti | Hubungan dan aturan |
| --- | --- | --- |
| Akun | ID, email, peran, status, wajib ubah sandi | Satu akun pengguna memiliki satu kartu dan banyak relasi; kredensial dikelola layanan autentikasi, bukan tabel aplikasi. Peran admin diberikan melalui proses terbatas. |
| Kartu Digital | Pemilik, kolom profesional, foto, visibilitas, waktu ubah | Satu kartu aktif per akun. |
| Tautan Berbagi | Kartu pemilik, token acak, dibuat pada, berakhir pada | Banyak tautan dapat masih aktif untuk satu kartu; hanya membuka kartu jika belum kedaluwarsa dan visibilitas aktif. |
| Relasi | Pemilik, ID kartu sumber bila ada, salinan kolom kontak, kategori, waktu tambah | Milik pribadi satu akun; sumber boleh kosong untuk kontak manual. |
| Catatan Interaksi | Relasi, tanggal, lokasi, teks | Banyak catatan per relasi. |
| Pengingat | Relasi, waktu pengingat | Maksimal satu pengingat aktif per relasi. |
| Aktivitas Berbagi | Pemilik kartu, jenis tindakan, waktu | Dipakai untuk angka Kartu Dibagikan; mencatat tindakan di aplikasi, bukan jumlah penerima. |

## 10. Akses data dan perilaku privasi

1. Akun pengguna hanya boleh membaca dan mengubah kartu, relasi, catatan, pengingat, dan aktivitas berbagi miliknya. Dashboard admin tidak membuka isi catatan pribadi pengguna.
2. Pengunjung tanpa akun hanya menerima kolom kartu publik setelah token tautan divalidasi dan visibilitas kartu aktif.
3. Token publik tidak memberikan akses langsung ke tabel relasi, catatan, atau pengingat.
4. Mematikan visibilitas menutup tampilan profil saat itu juga. Menghidupkannya kembali membuat tautan yang masih dalam masa 24 jam dapat dipakai lagi; tautan yang sudah lewat waktu tetap kedaluwarsa.
5. Foto profil yang dipilih untuk kartu publik diperlakukan sebagai bagian dari kartu yang dibagikan. Aplikasi tidak menampilkan foto melalui profil publik ketika visibilitas mati.
6. Pemeriksaan peran admin dan status akun terjadi pada layanan/server, bukan hanya dengan menyembunyikan tombol di browser. Kunci rahasia untuk operasi akun hanya berada di server.
7. Saat akun dinonaktifkan, pemeriksaan status juga menutup akses data dan profil publik dari sesi yang masih aktif; reset sandi sementara membatasi akun ke layar ganti sandi sampai perubahan selesai.

## 11. Rancangan teknis dan batas layanan

- **Android:** Flutter/Dart untuk semua layar utama, kamera QR, berbagi melalui Android, dan notifikasi lokal.
- **Browser:** build Flutter Web dari codebase yang sama untuk profil publik dan dashboard admin. Build statis dihosting pada Cloudflare Pages Free.
- **Cloud:** Supabase Free untuk autentikasi email dan kata sandi, database, serta penyimpanan foto. Validasi token 24 jam, visibilitas, peran admin, dan status akun dilakukan pada akses data; data pribadi dilindungi kebijakan akses per pemilik.
- **Operasi admin:** fungsi server Supabase Edge Function memverifikasi sesi dan peran admin sebelum memanggil API administratif dengan kunci rahasia server. Fungsi kecil ini memakai TypeScript sesuai runtime Supabase; seluruh antarmuka Android dan browser tetap Flutter/Dart. Kunci itu tidak dikirim ke Flutter Android/Web. Paket Free mencakup kuota Edge Function untuk cakupan tugas kuliah.
- **Email:** pendaftaran tanpa verifikasi; tidak ada email pemulihan atau pengirim SMTP proyek. Pengguna mengubah kata sandi dari sesi yang sedang masuk, sedangkan pemulihan setelah keluar dibantu admin.
- **Koneksi:** operasi data membutuhkan internet. Proyek Supabase Free dapat dijeda setelah satu minggu tidak aktif; aktifkan kembali dan periksa akun demo sebelum presentasi.
- **Biaya:** desain penggunaan memakai paket gratis. Pemakaian perlu tetap berada dalam kuota layanan tersebut.

Rujukan layanan: [Flutter Web](https://docs.flutter.dev/platform-integration/web/building), [Supabase untuk Flutter](https://supabase.com/docs/guides/getting-started/quickstarts/flutter), [Supabase Free](https://supabase.com/pricing), [Cloudflare Pages Free](https://developers.cloudflare.com/pages/platform/limits/), [API admin Supabase](https://supabase.com/docs/reference/javascript/auth-admin-updateuserbyid), [runtime Edge Function](https://supabase.com/docs/guides/functions), [kuota Edge Function](https://supabase.com/docs/guides/functions/pricing/).

## 12. Kriteria penerimaan

1. **Akun:** pengguna dapat mendaftar dan masuk pada Android, menutup lalu membuka aplikasi tanpa kehilangan sesi, masuk pada perangkat lain, mengubah kata sandi saat masuk, dan keluar.
2. **Kartu:** pengguna baru dapat menyimpan kartu hanya dengan nama; data, foto, dan pratinjau yang disimpan tampil sama di Beranda, Kartu Saya, dan profil publik.
3. **QR:** dua kali membuka halaman berbagi menghasilkan QR berbeda. Keduanya membuka profil selama masing-masing 24 jam; setelah kedaluwarsa, hanya pesan kedaluwarsa tampil.
4. **Visibilitas:** ketika kartu disembunyikan, browser tidak menampilkan data melalui tautan yang sebelumnya aktif; saat diaktifkan lagi, tautan yang belum kedaluwarsa berfungsi.
5. **Profil tanpa aplikasi:** QR dibuka di browser Android tanpa login; tombol Simpan ke Relasi meminta aplikasi dan login bila diperlukan.
6. **Salinan:** perubahan kartu sumber terlihat pada profil publik tetapi tidak mengubah salinan relasi yang sudah disimpan atau catatan pribadi.
7. **Relasi:** pengguna dapat menambah kontak manual, menyimpan dari QR, mencari, memfilter, mengedit, dan menghapusnya. Pemindaian ulang tidak membuat duplikat.
8. **Catatan:** satu relasi dapat mempunyai beberapa entri bertanggal yang dapat diedit dan dihapus, urut dari terbaru.
9. **Pengingat:** membuat, mengubah, dan menghapus pengingat mengubah notifikasi lokal sesuai jadwal; sakelar notifikasi membatalkan dan menjadwalkan ulang notifikasi masa depan.
10. **Data nyata:** angka Beranda dan daftar Relasi berubah sesuai tindakan akun, tanpa data contoh bawaan.
11. **Kondisi gagal:** QR asing, tautan kedaluwarsa, kartu tersembunyi, izin notifikasi ditolak, dan jaringan terputus masing-masing memberi pesan yang dapat dipahami.
12. **Admin:** akun biasa tidak bisa membuka dashboard atau menjalankan operasi admin. Admin dapat mencari akun, menonaktifkan/mengaktifkannya, dan mereset sandi ke nilai sementara tanpa melihat sandi lama maupun data relasi pribadi.
13. **Sandi sementara:** sesudah reset admin, sandi sementara hanya ditampilkan sekali kepada admin; pengguna masuk dengannya dan harus membuat sandi baru sebelum membuka Beranda.

## 13. Urutan pengerjaan yang disarankan

1. Dasar Flutter Android/Web, navigasi, autentikasi, peran admin, status akun, dan aturan akses data.
2. Kartu digital, editor, foto, visibilitas, dan pratinjau.
3. Tautan berbagi 24 jam, QR, profil publik browser, dan alur kembali ke aplikasi.
4. Relasi manual/QR, duplikat, pencarian, filter, serta tindakan kontak.
5. Catatan interaksi, pengingat lokal, statistik Beranda, dan keadaan gagal.
6. Dashboard admin sederhana, reset sandi sementara, penyelarasan visual dengan wireframe, serta persiapan data dan APK demonstrasi.
