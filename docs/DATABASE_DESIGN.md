# ANTI RIBET: DATABASE DESIGN BLUEPRINT
**PostgreSQL Multi-Tenant Relational Schema**

## 1. Konsep Dasar & Arsitektur
AntiRibet menggunakan **Multi-Tenant Shared Database** dengan skema *Single Database*.
Tenant Key utama adalah `business_id`. Hal ini dipilih untuk menjaga kesederhanaan pada fase MVP dan kemudahan pemeliharaan dibanding membuat database per-merchant.

**Aturan Emas (Golden Rules):**
1. Setiap tabel yang menyimpan data spesifik milik merchant WAJIB memiliki kolom `business_id`.
2. Akses dari frontend (API) TIDAK BOLEH mengirimkan `business_id`. `business_id` diambil dari *user context* (Token Sanctum) di sisi Laravel.
3. Foreign key wajib menggunakan constraint yang sesuai (contoh: hapus katalog menolak jika masih ada transaksi terkait -> `ON DELETE RESTRICT`).

## 2. Daftar Tabel Lengkap
### A. Core Identity
- `users` (Akses login)
- `businesses` (Profil merchant)
- `branches` (Cabang bisnis - disiapkan untuk scale-up)
- `business_settings` (Konfigurasi pajak, jam buka)
- `business_staff` (Penugasan role spesifik)

### B. Catalog & Resources
- `catalog_categories` (Kategori: Minuman, Layanan, Alat)
- `catalog_items` (Menu, Produk, Jasa, Item Rental)
- `resources` (Meja, Dokter, Kapster, Ruangan)

### C. Transactions & Payment (Universal)
- `transactions` (Tabel sentral seluruh transaksi POS/QR/Booking)
- `transaction_items` (Detail keranjang)
- `payments` (Pencatatan uang masuk dari customer ke merchant)

### D. Wallet & Fee System (Inti AntiRibet)
- `merchant_wallets` (Saldo terkini merchant)
- `wallet_transactions` (Mutasi masuk/keluar)
- `platform_fees` (Potongan Rp500 dari AntiRibet)
- `topups` (Riwayat pengisian saldo manual)

### E. Modul Layanan Khusus
- `bookings` (Jadwal reservasi)
- `queues` (Sistem antrean)
- `invoices` (Sistem tagihan dengan DP)
- `invoice_items`

### F. CRM & Analytics
- `customers` (Database pelanggan merchant)
- `daily_business_summaries` (Agregasi omzet harian per merchant)
- `daily_platform_summaries` (Agregasi total revenue AntiRibet)

### G. Governance & Support
- `audit_logs` (Jejak perubahan sensitif)
- `disputes` (Komplain potongan fee)
- `support_tickets` (Bantuan)

## 3. Struktur Tabel & Field Penting

### Table: `businesses`
- `id` (PK, UUID/BigInt)
- `slug` (String, Unique, Index) -> URL mini website
- `name` (String)
- `logo` (String, Nullable)
- `status` (Enum: active, inactive, suspended)

### Table: `merchant_wallets`
- `id` (PK)
- `business_id` (FK -> businesses, Unique)
- `balance` (Decimal/BigInt, Default 0)
- `bonus_balance` (Decimal/BigInt, Default 0)
- `status` (Enum: active, locked)

### Table: `catalog_items`
- `id` (PK)
- `business_id` (FK, Index)
- `type` (Enum: product, service, package, rental_item)
- `name` (String)
- `price` (Decimal 15,2)
- `is_available` (Boolean)

### Table: `transactions`
- `id` (PK)
- `business_id` (FK, Index)
- `source` (Enum: pos, qr_order, booking, queue, invoice, manual)
- `status` (Enum: draft, pending, accepted, paid, completed, voided, refunded, cancelled)
- `total_amount` (Decimal)
- `customer_id` (FK -> customers, Nullable)

### Table: `platform_fees`
- `id` (PK)
- `business_id` (FK)
- `transaction_id` (FK -> transactions, Unique) -> Memastikan 1 trx hanya 1 fee.
- `fee_amount` (Decimal, default 500)
- `status` (Enum: charged, refunded, pending)
- `charged_at` (Timestamp)

## 4. Wallet Transaction Logic & Platform Fee Logic
**Kasus Sukses (Fee Charged):**
1. Transaction status berubah menjadi `paid` atau `completed`.
2. Laravel memanggil `DB::beginTransaction()`.
3. Mengunci wallet: `SELECT * FROM merchant_wallets WHERE business_id = ? FOR UPDATE`.
4. Memeriksa apakah `transaction_id` sudah ada di tabel `platform_fees` (Idempotency).
5. Jika belum, kurangi `merchant_wallets.balance -= 500`.
6. Insert ke `platform_fees` (status: charged).
7. Insert ke `wallet_transactions` (type: debit, amount: 500, ref: fee).
8. `DB::commit()`.

**Kasus Batal (Refund Fee):**
1. Transaction status menjadi `voided`.
2. Laravel memeriksa `platform_fees` untuk transaksi tersebut.
3. Jika status `charged`, maka kembalikan saldo: `merchant_wallets.balance += 500`.
4. Update `platform_fees` status menjadi `refunded`.
5. Insert ke `wallet_transactions` (type: credit, amount: 500, ref: refund).

## 5. Indexing Strategy
- `idx_business_slug` pada `businesses.slug` (Cepat memuat mini website).
- `idx_transactions_business_status` pada `transactions(business_id, status)` (Cepat memuat dashboard order aktif).
- `idx_wallet_trx_business_created` pada `wallet_transactions(business_id, created_at)` (Laporan mutasi wallet).

## 6. Audit Log
Tabel `audit_logs` akan mencatat:
- `id`, `business_id`, `user_id`
- `action` (contoh: `TRANSACTION_VOID`, `TOPUP_APPROVED`, `ITEM_DELETED`)
- `old_values` (JSON)
- `new_values` (JSON)
- `ip_address`, `created_at`

## 7. ERD Tekstual
```text
businesses 1:1 merchant_wallets
businesses 1:N users
businesses 1:N catalog_items
businesses 1:N transactions
transactions 1:N transaction_items
transactions 1:1 platform_fees
merchant_wallets 1:N wallet_transactions
```

## 8. Alasan Desain
Desain ini menjadikan entitas **Transactions** sebagai jantung sistem. Apapun layanannya (Meja QR, Kasir, Booking, atau Invoice), mereka bermuara di tabel yang sama. Ini membuat perhitungan Omzet dan perhitungan Platform Fee (Rp 500) sangat tersentralisasi dan bebas kebocoran.
