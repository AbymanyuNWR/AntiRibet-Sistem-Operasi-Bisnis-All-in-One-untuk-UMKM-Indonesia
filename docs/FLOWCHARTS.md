# ANTI RIBET: FLOWCHARTS & ALUR LOGIKA
Dokumen ini berisi representasi visual (Mermaid) dari alur transaksi dan arsitektur di AntiRibet.

## 1. Alur Transaksi Kasir (POS) & Potong Fee
```mermaid
sequenceDiagram
    participant C as Kasir (Flutter)
    participant API as Laravel API
    participant DB as PostgreSQL
    participant W as Wallet Service

    C->>API: POST /pos/transactions (Cart Data)
    API->>DB: Validasi Item & Harga
    DB-->>API: Item Valid
    API->>W: Request Lock Wallet Merchant (Rp 500)
    W->>DB: SELECT ... FOR UPDATE (Kunci Baris Saldo)
    DB-->>W: Locked
    W->>W: Cek Saldo > Rp 500
    W->>DB: Saldo = Saldo - 500
    W->>DB: Insert `platform_fees` & `wallet_transactions`
    W->>DB: INSERT `transactions` (Status: Paid)
    DB-->>W: Commit Transaction
    W-->>API: Transaksi Sukses & Saldo Terpotong
    API-->>C: Response 200 OK + Data Struk
    C->>C: Print Struk (PDF)
```

## 2. Alur Top Up Merchant
```mermaid
sequenceDiagram
    participant M as Merchant (Dashboard)
    participant A as Super Admin
    participant API as Laravel API
    participant DB as PostgreSQL

    M->>API: POST /wallet/topup (Rp 50.000 + Bukti TF)
    API->>DB: Insert `topups` (Status: Pending)
    API-->>M: Request Diterima
    A->>API: GET /admin/topups
    API-->>A: Tampilkan Pending Top Up
    A->>A: Cek Mutasi Bank AntiRibet
    A->>API: POST /admin/topups/{id}/approve
    API->>DB: Update `topups` (Status: Approved)
    API->>DB: merchant_wallets.balance += 50.000
    API->>DB: Insert `wallet_transactions` (Type: Credit)
    DB-->>API: Commit
    API-->>A: Approved Success
```

## 3. Alur QR Order (Dengan Notifikasi Realtime)
```mermaid
sequenceDiagram
    participant P as Pelanggan (Browser)
    participant API as Laravel API
    participant WS as Reverb (WebSocket)
    participant K as Kasir (Tablet)

    P->>API: Scan QR & Checkout Keranjang
    API->>API: Validasi Token QR (Cegah Spam)
    API->>DB: Insert `transactions` (Status: Pending)
    API->>WS: Broadcast Event `OrderCreated`
    WS-->>K: Push Notif (Pesanan Baru Meja 5!)
    API-->>P: Status: Menunggu Konfirmasi
    K->>API: Kasir Klik "Terima Pesanan"
    API->>API: Panggil Wallet Service (Potong Rp 500)
    API->>DB: Update `transactions` (Status: Accepted)
    API-->>K: Berhasil Diterima
    API-->>P: Pesanan Diproses!
```

## 4. Alur Bisnis: Lifecycle Merchant
```mermaid
stateDiagram-v2
    [*] --> Lead
    Lead --> Registered: Buat Akun
    Registered --> Onboarding: Setup Bisnis & Katalog
    Onboarding --> TrialActive: Dapat 50 Kuota Trx
    TrialActive --> ActiveMerchant: Top Up Pertama (Manual)
    ActiveMerchant --> GrowthMerchant: Trx Stabil
    ActiveMerchant --> AtRisk: Saldo Menipis, Jarang Login
    AtRisk --> Churn: Tidak Aktif > 3 Bulan
    AtRisk --> ActiveMerchant: Kampanye / Bantuan Sukses
```
