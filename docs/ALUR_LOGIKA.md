# ALUR LOGIKA ANTIRIBET (SUPER LENGKAP & SUPER DETAIL)

Berikut adalah seluruh alur logika Antiribet versi paling lengkap, rapi, dan berjalan secara logis dari awal sampai akhir.

Saya susun dengan pola:
IDE PRODUK -> USER ROLE -> MODUL SISTEM -> ALUR BISNIS -> ALUR TEKNIS -> ALUR UANG -> ALUR DATABASE -> ALUR ERROR / EDGE CASE -> ALUR ADMIN -> ALUR SCALE

---

# 1. Logika utama Antiribet
Antiribet adalah platform all-in-one untuk membantu semua jenis bisnis punya:
1. Mini website
2. Katalog produk / layanan
3. Kasir / POS
4. QR order
5. Booking
6. Antrean
7. Invoice
8. Customer database
9. Laporan
10. Staff management
11. Saldo deposit
12. Fee Rp500 per transaksi berhasil

Alur paling dasarnya:
Merchant daftar -> Merchant membuat profil bisnis -> Merchant mengisi katalog produk/layanan -> Merchant bisa memakai kasir, QR order, booking, antrean, invoice -> Customer melakukan transaksi -> Transaksi berhasil -> Saldo merchant dipotong Rp500 -> Fee Rp500 menjadi revenue Antiribet -> Merchant melihat laporan -> Super admin melihat revenue platform

Inti logikanya: Antiribet menyediakan sistem bisnis. Merchant membayar Antiribet hanya saat ada transaksi berhasil.

---

# 2. Prinsip besar sistem
Supaya sistemnya tidak kacau, Antiribet harus punya prinsip berikut:
1. Flutter hanya sebagai frontend / aplikasi.
2. Laravel API adalah pusat logic bisnis.
3. PostgreSQL adalah sumber data utama.
4. Redis dipakai untuk queue, cache, dan realtime support.
5. Semua data bisnis dipisahkan dengan business_id.
6. Semua transaksi uang harus tercatat.
7. Semua perubahan saldo harus punya riwayat.
8. Semua fee Rp500 harus terhubung ke transaksi.
9. Satu transaksi tidak boleh kena fee dua kali.
10. Customer membayar langsung ke merchant untuk MVP.
11. Antiribet mendapat uang dari saldo deposit merchant.
12. Merchant tidak perlu bayar bulanan.
13. Merchant tidak perlu aplikasi kasir lain.
14. Semua fitur harus modular.
15. Semua role staff harus punya batas akses.

Kalimat paling penting:
Flutter menampilkan. Laravel memutuskan. PostgreSQL menyimpan. Redis mempercepat. Reverb memberi realtime.

---

# 3. Pembagian sistem besar
Antiribet dibagi menjadi 2 bagian besar:
1. Product & Business System
2. Technical & Development System

Tapi secara operasional, sistemnya berjalan dari 4 sisi:
1. Customer
2. Merchant / Owner
3. Staff / Kasir / Operator
4. Super Admin Antiribet

Dan secara teknologi berjalan dari 4 layer:
1. Flutter App
2. Laravel API
3. PostgreSQL Database
4. Redis / Queue / Realtime / Storage

---

# 4. Role pengguna dalam Antiribet
## 4.1 Customer
Customer adalah orang yang membeli / booking / antre / memakai layanan bisnis.
Customer bisa: melihat mini website bisnis, melihat katalog, scan QR, membuat order, booking jadwal, ambil antrean, melihat status order, melihat invoice. Customer tidak wajib login untuk MVP (Semakin sedikit hambatan, semakin besar kemungkinan customer jadi transaksi).

## 4.2 Merchant Owner
Merchant owner adalah pemilik bisnis. Owner bisa: daftar bisnis, mengatur profil bisnis, mengatur katalog, memakai kasir, melihat transaksi, melihat laporan, top up saldo, melihat riwayat saldo, mengatur staff, mengatur booking / antrean / invoice, mengatur QR. Owner adalah pemegang akses utama untuk bisnisnya.

## 4.3 Staff
Staff bisa berupa: kasir, waiter, operator, admin booking, admin antrean, kitchen/barista, staff layanan. Staff hanya boleh mengakses fitur sesuai role.
Contoh Kasir: akses POS, buat transaksi, cetak struk.
Contoh Kitchen: lihat order masuk, ubah status order.
Contoh Manager: lihat laporan, kelola transaksi.

## 4.4 Super Admin Antiribet
Super admin adalah kamu sebagai pemilik platform. Super admin bisa: melihat semua merchant, melihat semua top up, approve top up, reject top up, melihat revenue platform, melihat total transaksi, melihat merchant saldo rendah, melihat merchant saldo minus, memberi saldo bonus, suspend merchant, melihat dispute fee, melihat laporan sistem.

---

# 5. Entitas utama sistem
User, Business, Branch, Staff, Customer, Catalog, Resource, Transaction, Payment, Wallet, Topup, Platform Fee, Booking, Queue, Invoice, Report, Audit Log.

Kunci utama: `business_id` (Semua data harus punya business_id untuk Multi-Tenancy).

---

# 6. Alur utama dari awal sampai bisnis aktif
## 6.1 Merchant daftar
Merchant membuka Antiribet -> Klik daftar bisnis -> Isi nama, email, password, nomor WhatsApp -> Laravel membuat user -> Laravel membuat business awal -> Laravel membuat wallet merchant -> Laravel membuat setting default -> Merchant masuk ke setup wizard.

## 6.2 Merchant setup bisnis
Pilih jenis bisnis (Coffee shop, Barbershop, Laundry, dll) -> Isi detail -> Upload logo -> Pilih fitur -> Tambah produk pertama -> Sistem membuat mini website -> Status bisnis menjadi active.

## 6.3 Sistem membuat preset bisnis
Sistem mengotomatisasi fitur sesuai jenis bisnis. Misalnya Coffee Shop mengaktifkan (Mini website, Katalog, Kasir, QR meja, Laporan).

---

# 7. Alur mini website
Customer membuka antiribet.id/kopi-senja -> Laravel menerima slug "kopi-senja" -> Laravel mengambil profil & katalog -> Flutter Web menampilkan mini website.

---

# 8. Alur katalog
Merchant menambah produk -> Validasi -> Disimpan di PostgreSQL & Foto di S3 -> Tampil di mini website. Jika item habis (is_available = false), item tetap tampil tapi disabled agar tidak bisa dicheckout.

---

# 9. Alur POS / Kasir
## 9.1 Alur POS normal
Kasir memilih produk -> Tambah diskon/pajak -> Pilih pembayaran -> Selesaikan Transaksi -> Flutter kirim cart ke Laravel -> Laravel validasi item & hitung ulang harga asli -> Create transaction -> Potong saldo Rp500 -> Buat platform_fee -> Cetak struk.

## 9.2 Kenapa backend harus hitung ulang?
Karena frontend bisa dimanipulasi. Flutter menghitung untuk tampilan. Laravel menghitung untuk kebenaran (sumber harga selalu ditarik paksa dari database).

## 9.3 Status transaksi POS
draft, pending, paid, completed, voided, refunded, cancelled. Fee dikenakan di status paid/completed.

---

# 10. Alur QR Order
Merchant generate QR (Resources). Customer scan QR meja -> Laravel validasi table token -> Checkout -> Order status pending (Fee belum dipotong).
Staff accept order -> Status menjadi accepted -> Saldo dipotong Rp500.
Staff reject order -> Status rejected -> Tidak ada fee.
Order dibatalkan setelah accepted -> Saldo di-refund Rp500 (Fee_refund).

---

# 11. Alur booking
Customer booking -> Pending -> Merchant Konfirmasi (Confirmed) -> Status menjadi completed/paid -> Fee Rp500 dikenakan. Jika customer No-Show, tidak ada fee.

---

# 12. Alur antrean
Ambil nomor (Waiting) -> Dipanggil (Called) -> Dilayani (Serving) -> Selesai (Completed). Fee dikenakan saat status Completed karena itu menandakan transaksi sukses.

---

# 13. Alur invoice
Buat Invoice (Draft/Sent) -> Customer bayar DP (Partially Paid) -> Transaksi valid -> Fee Rp500 dikenakan. Lunas -> Paid (Tidak ada fee kedua).

---

# 14. Alur wallet / saldo deposit
Wallet dibuat saat bisnis dibuat (Balance = 0). Merchant Top Up manual -> Status Pending -> Super Admin Approve -> Saldo bertambah. Saat transaksi valid, sistem melakukan **Wallet Lock (Pessimistic Locking)**, memotong Rp500, dan mencatatnya ke Platform Fee.

---

# 15. Alur saldo rendah dan saldo habis
Jika saldo < Rp10.000 (Warning). Jika saldo minus mencapai batas (misal -Rp10.000), sistem mengunci pembuatan transaksi baru sampai Merchant melakukan Top Up.

---

# 16. Alur trial transaksi
50 Transaksi pertama gratis. Trial_quota berkurang. Saldo tidak dipotong, tapi audit tetap dicatat sebagai waived_trial.

---

# 17. Alur laporan merchant
Request /api/merchant/reports/daily. Laravel menghitung data secara backend (Omzet, Metode pembayaran, Transaksi, Fee). Flutter menampilkan grafis chart.

---

# 18. Alur laporan platform
Super admin melihat akumulasi transaksi. Revenue platform nyata dihitung dari platform_fees yang statusnya "charged", BUKAN dari nominal uang deposit top up.

---

# 19. Alur realtime
Order Checkout / Saldo Berubah / Antrean Dipanggil -> Laravel dispatch event (OrderCreated, dll) -> Reverb broadcast websocket -> Flutter menerima update seketika tanpa refresh.

---

# 20. Alur permission
Frontend menyembunyikan, Backend mengamankan. Setiap hit API (contoh: /api/merchant/wallet) akan dilewati pengecekan Role Permission (RBAC Middleware). Jika gagal, return 403 Forbidden.

---

# 21. Alur audit log
Aksi penting dicatat ke database (topup.approved, refund fee, suspend bisnis, void transaksi) agar tidak ada penyalahgunaan dari Super Admin maupun Kasir.

---

# 22. Alur error dan edge case
Saldo tidak cukup -> Transaksi ditolak.
Double click checkout -> Idempotency key mencegah transaksi dobel.
Internet putus -> Sinkronisasi offline SQLite di HP.

---

# 23. Alur security
Simpan token di secure storage, Rate Limiting, Business Isolation (Multi-Tenancy), Database Transaction, Wallet Lock, Validasi File, Idempotency.

---

# 24. Alur deployment
## 24.1 Laravel API
Code push ke repository -> Deploy ke VPS -> composer install -> php artisan migrate -> php artisan config:cache -> Restart PHP-FPM -> Restart queue worker -> Restart Reverb

## 24.2 Flutter Web
flutter build web -> Upload build ke server/CDN -> Nginx serve static files

## 24.3 Android
flutter build appbundle -> Upload ke Google Play Console

## 24.4 iOS
flutter build ipa -> Upload ke App Store Connect

---

# 25. Alur backup
Setiap hari: Backup PostgreSQL -> Backup storage penting -> Simpan ke lokasi aman -> Log hasil backup.
Setiap bulan: Test restore.

---

# 26. Alur pembangunan MVP
Urutan paling logis:
1. Setup Laravel API
2. Setup PostgreSQL
3. Setup Flutter project
4. Auth login/register
5. Business profile
6. Wallet default
7. Catalog
8. POS Lite
9. Transaction
10. Payment manual
11. Fee Rp500
12. Wallet transaction
13. Top up manual
14. Super admin approve top up
15. Report dasar

Setelah MVP inti jalan:
16. Mini website
17. QR order
18. Booking
19. Antrean
20. Invoice
21. Realtime
22. Mobile polish
23. Android/iOS release

---

# 27. Alur sistem lengkap dalam satu diagram
Merchant daftar -> Business dibuat -> Wallet dibuat -> Merchant setup profil -> Merchant isi katalog -> Merchant mulai transaksi (POS/QR/Booking/Antrean) -> Transaksi valid -> Laravel cek wallet -> Saldo dipotong Rp500 -> platform_fee dibuat -> wallet_transaction dibuat -> report update -> realtime update dashboard -> revenue Antiribet bertambah.

---

# 28. Alur uang lengkap dalam satu diagram
CUSTOMER -> bayar produk/jasa -> MERCHANT -> sebelumnya top up saldo -> ANTIRIBET -> potong saldo Rp500 saat transaksi valid -> REVENUE PLATFORM.
Antiribet tidak memegang uang customer. Antiribet memotong saldo merchant Rp500.

---

# 29. Alur teknis lengkap dalam satu diagram
Flutter App -> API Request -> Laravel Controller -> Form Request Validation -> Service Layer -> Database Transaction -> Eloquent Models -> PostgreSQL -> Event Dispatch -> Redis Queue / Reverb -> Flutter Realtime Update.

---

# 30. Kesimpulan logika final
Antiribet harus berjalan dengan logika ini:
- Flutter adalah aplikasi lintas platform.
- Laravel adalah pusat keputusan.
- PostgreSQL adalah sumber data.
- Redis mempercepat proses.
- Reverb membuat realtime.
- Wallet menjadi pusat monetisasi.
- Fee Rp500 hanya dikenakan pada transaksi valid.
- Top up adalah deposit, bukan revenue langsung.
- Revenue dihitung dari platform_fee charged.
- Semua data merchant dipisahkan dengan business_id.
- Semua transaksi uang harus tercatat.
- Semua perubahan penting harus masuk audit_log.
