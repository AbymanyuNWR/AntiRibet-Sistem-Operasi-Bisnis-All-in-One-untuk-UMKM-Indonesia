<div align="center">

# ⚡ AntiRibet

### **Sistem Operasi Bisnis All-in-One untuk UMKM Indonesia**

**Satu platform. Satu biaya transaksi. Zero ribet.**

[![Flutter](https://img.shields.io/badge/Flutter-3.22-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Laravel](https://img.shields.io/badge/Laravel-11-FF2D20?style=for-the-badge&logo=laravel&logoColor=white)](https://laravel.com)
[![Dart](https://img.shields.io/badge/Dart-3.1-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

<br>

![AntiRibet Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-lightgrey?style=for-the-badge)

</div>

---

## 📖 Table of Contents

- [Tentang AntiRibet](#-tentang-antiribet)
- [Masalah yang Diselesaikan](#-masalah-yang-diselesaikan)
- [Fitur Utama](#-fitur-utama)
- [Arsitektur Sistem](#-arsitektur-sistem)
- [Tech Stack](#-tech-stack)
- [Struktur Proyek](#-struktur-proyek)
- [Alur Bisnis](#-alur-bisnis)
- [Database Design](#-database-design)
- [Cara Instalasi](#-cara-instalasi)
- [API Documentation](#-api-documentation)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Business Model](#-business-model)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Tentang AntiRibet

**AntiRibet** adalah platform manajemen bisnis all-in-one yang dirancang khusus untuk UMKM Indonesia. Platform ini menggabungkan POS (Kasir), QR Ordering, Booking, Manajemen Antrian, Invoicing, CRM, Inventori, HRIS, Akuntansi, Manajemen Armada Pengiriman, Marketing Automation, dan Manajemen Franchise dalam satu ekosistem tunggal.

### 💡 Visi

> *Membuat setiap UMKM di Indonesia bisa berbisnis secara digital dengan cara yang super mudah dan terjangkau — tanpa biaya langganan, tanpa ribet.*

### 💰 Model Bisnis

| Komponen | Keterangan |
|----------|------------|
| Biaya Platform | **Rp 500 per transaksi berhasil** |
| Biaya Langganan | **GRATIS (Zero monthly fee)** |
| Target Pengguna | UMKM, Kedai, Restoran, Salon, Bengkel, Toko Retail |
| Revenue Model | Transaction fee-based (Rp 500/tx的成功) |

---

## 🔍 Masalah yang Diselesaikan

| Masalah | Solusi AntiRibet |
|---------|------------------|
| Kasir manual dengan kertas | POS digital dengan pencetakan struk otomatis |
| Tidak bisa terima pesanan online | QR Ordering — pelanggan pesan dari HP sendiri |
| Sulit kelola stok | Inventori otomatis dengan BOM deduction |
| Tidak punya data penjualan | Dashboard analitik real-time |
| Pelanggan tidak loyal | CRM dengan poin & leaderboard |
| Sulit kelola karyawan | HRIS dengan absensi & payroll |
| Tidak punya website | Mini-website gratis per bisnis |
| Biaya SaaS mahal | Hanya Rp 500/transaksi — tanpa langganan |

---

## 🚀 Fitur Utama

<details>
<summary><b>💳 Point of Sale (POS / Kasir)</b></summary>

- Checkout cepat dengan satu sentuhan
- Dukungan multiple payment method (Cash, QRIS, GoPay, QR Payment)
- Cetak struk otomatis via Bluetooth printer
- Kirim struk via WhatsApp
- Mode offline — transaksi tersimpan lokal & disync otomatis
- Shift management (buka/tutup kasir)
- Void & retur transaksi

</details>

<details>
<summary><b>📱 QR Ordering</b></summary>

- Generate QR code per meja/outlet
- Pelanggan scan → buka menu → pesan dari HP
- Pesan langsung masuk ke Kitchen Display System (KDS)
- Real-time notifikasi ke kasir & dapur
- Support multiple meja secara bersamaan

</details>

<details>
<summary><b>📋 Manajemen Katalog</b></summary>

- CRUD produk & layanan
- Kategori produk (Makanan, Minuman, Layanan, dll)
- Upload foto produk
- Harga berbeda per outlet
- Status aktif/non-aktif produk
- BOM (Bill of Materials) untuk resep

</details>

<details>
<summary><b>💰 Wallet & Billing</b></summary>

- Saldo merchant digital
- Top-up via Midtrans (VA, QRIS, GoPay)
- Riwayat transaksi lengkap
- Automatic platform fee deduction (Rp 500/tx)
- Export laporan keuangan

</details>

<details>
<summary><b>📊 Dashboard & Laporan</b></summary>

- Real-time analytics (omzet, transaksi, rata-rata)
- Grafik penjualan harian/mingguan/bulanan
- Top produk terlaris
- AI Chatbot untuk analisis data
- Export laporan PDF & Excel

</details>

<details>
<summary><b>👥 CRM (Customer Relationship)</b></summary>

- Database pelanggan otomatis
- Sistem poin loyalitas
- Leaderboard pelanggan
- Customer segmentation
- WhatsApp broadcast marketing

</details>

<details>
<summary><b>📦 Inventori</b></summary>

- Tracking stok real-time
- BOM (Bill of Materials) deduction
- Stock transfer antar outlet
- Low stock alert
- Purchase order ke supplier

</details>

<details>
<summary><b>👨‍💼 HRIS (Human Resources)</b></summary>

- Absensi clock-in/out
- Manajemen shift karyawan
- Hitung otomatis payroll
- Role-based access control (Admin, Kasir, Dapur, Manager)

</details>

<details>
<summary><b>🍳 Kitchen Display System (KDS)</b></summary>

- Display pesanan masuk secara real-time
- Update status pesanan (Diproses → Siap)
- Prioritas pesanan
- Timer persiapan makanan

</details>

<details>
<summary><b>📅 Booking & Reservasi</b></summary>

- Reservasi meja/layanan
- Kalender visual
- Konfirmasi otomatis via WhatsApp
- Integrasi dengan antrian

</details>

<details>
<summary><b>🔢 Antrian (Queue)</b></summary>

- Nomor antrian otomatis
- Display monitor TV untuk antrian
- Status: Menunggu → Diproses → Siap
- Pelanggan bisa ambil nomor dari QR

</details>

<details>
<summary><b>📄 Invoicing</b></summary>

- Buat invoice B2B
- Support DP (Down Payment)
- Tracking status bayar
- Cetak PDF invoice

</details>

<details>
<summary><b>🚚 Delivery & Fleet</b></summary>

- Assign driver
- Tracking pengiriman
- Status real-time untuk pelanggan

</details>

<details>
<summary><b>📣 Marketing</b></summary>

- Campaign management
- WhatsApp broadcast
- Promo & diskon
- Customer segmentation

</details>

<details>
<summary><b>🏢 Multi-Outlet & Franchise (HQ)</b></summary>

- Dashboard HQ untuk multi-outlet
- Sinkronisasi data antar outlet
- Manajemen franchise
- Consolidated reporting

</details>

<details>
<summary><b>🌐 Public Mini-Website</b></summary>

- Website bisnis otomatis per merchant
- Menu online untuk customer
- Form booking & antrian
- SEO-friendly

</details>

---

## 🏗️ Arsitektur Sistem

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ Android  │  │   iOS    │  │   Web    │  │ Windows  │       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
│       └──────────────┴──────────────┴──────────────┘            │
│                          Flutter 3.22                           │
└──────────────────────────┬──────────────────────────────────────┘
                           │ REST API + WebSocket
┌──────────────────────────┴──────────────────────────────────────┐
│                        SERVER LAYER                             │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   Laravel 11 API                         │   │
│  │  ┌─────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐  │   │
│  │  │Controllers│  │ Services │  │  Models  │  │Events  │  │   │
│  │  └─────────┘  └──────────┘  └──────────┘  └────────┘  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                          │                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                     │
│  │PostgreSQL│  │  Redis   │  │  Reverb  │                     │
│  │   15     │  │ (Cache)  │  │(WebSocket│                     │
│  └──────────┘  └──────────┘  └──────────┘                     │
└─────────────────────────────────────────────────────────────────┘
```

### 🔐 Authentication Flow

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  Login   │────▶│  Sanctum │────▶│  Token   │────▶│  Secure  │
│  Screen  │     │  Verify  │     │ Generated│     │ Storage  │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
                                                          │
                    ┌─────────────────────────────────────┘
                    ▼
              ┌──────────┐     ┌──────────┐     ┌──────────┐
              │ DioClient│────▶│ Interceptor│───▶│ Auto-    │
              │ (API)    │     │ (Attach)  │     │ Attach   │
              └──────────┘     └──────────┘     └──────────┘
```

### 🔄 Transaction Flow (POS)

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│ Add Item │────▶│ Checkout │────▶│ Payment  │────▶│ Process  │
│ to Cart  │     │ Dialog   │     │ Confirm  │     │ Payment  │
└──────────┘     └──────────┘     └──────────┘     └────┬─────┘
                                                         │
                    ┌────────────────────────────────────┐
                    ▼                                    ▼
              ┌──────────┐     ┌──────────┐     ┌──────────┐
              │ Create   │     │ Deduct   │     │ Print    │
              │ Transaction│───▶│ Inventory│────▶│ Receipt  │
              └──────────┘     └──────────┘     └──────────┘
                    │
                    ▼
              ┌──────────┐     ┌──────────┐
              │ Wallet   │────▶│ Platform │
              │ Deduct   │     │ Fee Rp500│
              └──────────┘     └──────────┘
```

---

## 🛠️ Tech Stack

### Frontend — Flutter App

| Teknologi | Versi | Fungsi |
|-----------|-------|--------|
| Flutter | 3.22 | Cross-platform UI framework |
| Dart | 3.1+ | Programming language |
| flutter_bloc | 8.1.3 | State management (BLoC pattern) |
| go_router | 12.0.0 | Declarative routing |
| dio | 5.3.3 | HTTP client with interceptors |
| drift | 2.12.0 | Local SQLite database (offline) |
| flutter_secure_storage | 9.0.0 | Secure token storage |
| freezed | - | Immutable data classes |
| google_fonts | 6.1.0 | Typography (Plus Jakarta Sans) |
| fl_chart | 0.68.0 | Charts & analytics |
| pdf + printing | - | Invoice/receipt generation |
| intl | 0.18.1 | Rupiah formatting, date locale |
| uuid | 4.4.0 | Unique ID generation |

### Backend — Laravel API

| Teknologi | Versi | Fungsi |
|-----------|-------|--------|
| Laravel | 11.31 | PHP API framework |
| PHP | 8.2+ | Server-side language |
| Laravel Sanctum | - | Token-based API auth |
| Laravel Reverb | - | WebSocket server (real-time) |
| PostgreSQL | 15 | Primary database |
| Redis | Alpine | Cache, queue, session |
| Laravel Sail | - | Docker dev environment |
| Vite | 6 | Frontend asset bundler |
| Tailwind CSS | 3 | Utility-first CSS |
| PHPUnit | 11 | Testing framework |

### Infrastructure

| Teknologi | Fungsi |
|-----------|--------|
| Docker + Docker Compose | Containerized deployment |
| Nginx | Reverse proxy / web server |
| GitHub Actions | CI/CD pipelines |
| Midtrans | Payment gateway integration |

---

## 📁 Struktur Proyek

```
antiribet.com/
├── 📱 app/                          # Flutter Application
│   ├── lib/
│   │   ├── main.dart                # Entry point
│   │   ├── app/
│   │   │   ├── router.dart          # GoRouter configuration
│   │   │   └── theme.dart           # Theme definitions
│   │   ├── core/
│   │   │   ├── components/          # Reusable UI widgets
│   │   │   ├── layout/              # MainLayout (sidebar + bottom nav)
│   │   │   ├── network/             # DioClient, AuthService
│   │   │   ├── services/            # Printer, Sync services
│   │   │   └── theme/               # V2 Theme system
│   │   └── features/                # Feature modules (24 modules)
│   │       ├── auth/                # Login, Register
│   │       ├── pos/                 # Point of Sale
│   │       ├── dashboard/           # Analytics dashboard
│   │       ├── catalog/             # Product management
│   │       ├── wallet/              # Merchant wallet
│   │       ├── booking/             # Reservations
│   │       ├── queue/               # Queue management
│   │       ├── invoice/             # B2B invoicing
│   │       ├── qr/                  # QR code generator
│   │       ├── qr_order/            # QR ordering system
│   │       ├── kitchen/             # Kitchen Display System
│   │       ├── inventory/           # Stock management
│   │       ├── crm/                 # Customer loyalty
│   │       ├── reports/             # Analytics & AI chatbot
│   │       ├── staff/               # Staff management
│   │       ├── hris/                # Attendance & payroll
│   │       ├── delivery/            # Fleet management
│   │       ├── marketing/           # Campaign tools
│   │       ├── supply/              # Supplier & purchase orders
│   │       ├── hq/                  # Franchise/multi-outlet
│   │       ├── platform/            # SaaS platform admin
│   │       ├── admin/               # Super admin dashboard
│   │       ├── business_site/       # Onboarding & public site
│   │       └── printer/             # Printer settings
│   ├── pubspec.yaml
│   └── test/
│
├── 🖥️ backend/                      # Laravel 11 API
│   ├── app/
│   │   ├── Http/Controllers/Api/    # REST API controllers
│   │   ├── Models/                  # 28 Eloquent models
│   │   ├── Services/                # 10 business services
│   │   └── Events/                  # WebSocket events
│   ├── routes/api.php               # API routes
│   ├── database/
│   │   ├── migrations/              # 36 database migrations
│   │   └── seeders/                 # Database seeders
│   ├── nginx/                       # Nginx config
│   ├── Dockerfile                   # PHP-FPM container
│   └── composer.json
│
├── 🌐 company-profile-web/          # React Company Profile
│   ├── src/
│   └── package.json
│
├── 📄 website/                      # Static Landing Page
│   ├── index.html
│   ├── style.css
│   └── script.js
│
├── 📚 docs/                         # Documentation
│   ├── ANTI_RIBET_MASTER_DOCUMENT.md
│   ├── DATABASE_DESIGN.md
│   ├── TECHNICAL_BLUEPRINT.md
│   ├── FLOWCHARTS.md
│   └── ALUR_LOGIKA.md
│
├── 🐳 docker-compose.yml            # Docker orchestration
├── ⚙️ start_server.bat              # Start backend (Windows)
├── ⚙️ start_frontend.bat            # Start Flutter (Windows)
└── 📄 README.md                     # You are here!
```

---

## 🔄 Alur Bisnis

### 👤 Customer Flow

```
Scan QR Code di Meja
       │
       ▼
Buka Menu Bisnis (Public Site)
       │
       ▼
Pilih Produk → Tambah ke Keranjang
       │
       ▼
Pilih Metode Bayar (Cash / QRIS / GoPay)
       │
       ▼
Pesan Masuk ke Sistem (POS + Kitchen)
       │
       ▼
Bayar di Kasir / Online
       │
       ▼
Terima Struk (Cetak / WhatsApp)
       │
       ▼
Dapat Poin Loyalitas (CRM)
```

### 🏪 Merchant Flow

```
Buka Aplikasi → Login
       │
       ▼
Buka Shift Kasir (Modal Awal)
       │
       ▼
───────┼───────────────────────────────
       │                               │
   POS Mode                      Dashboard Mode
       │                               │
  Scan/Pilih Produk              Lihat Analitik
       │                               │
  Tambah ke Keranjang            Kelola Katalog
       │                               │
  Proses Pembayaran              Kelola Stok
       │                               │
  Cetak Struk                   Kelola Karyawan
       │                               │
  Tutup Shift                   Lihat Laporan
       │                               │
───────┼───────────────────────────────
       │
       ▼
Saldo Terpotong (Fee Rp 500)
```

### 💸 Money Flow

```
Customer Bayar Rp 50.000
       │
       ▼
┌──────────────────────────────┐
│  Transaction Service         │
│  - Pessimistic Locking       │
│  - Atomic DB Transaction     │
└──────────────┬───────────────┘
               │
       ┌───────┴───────┐
       ▼               ▼
┌─────────────┐  ┌─────────────┐
│ Merchant    │  │ Platform    │
│ Wallet      │  │ Fee         │
│ Rp 49.500   │  │ Rp 500      │
└─────────────┘  └─────────────┘
       │               │
       ▼               ▼
┌─────────────┐  ┌─────────────┐
│ Bisa Top-Up │  │ Revenue     │
│ atau Tarik  │  │ Analytics   │
└─────────────┘  └─────────────┘
```

---

## 🗃️ Database Design

### Entity Relationship

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   businesses │────<│    outlets    │────<│ catalog_items│
└──────┬───────┘     └──────┬───────┘     └──────────────┘
       │                    │
       │              ┌─────┴──────┐
       │              │ transactions│
       │              └─────┬──────┘
       │                    │
┌──────┴───────┐     ┌─────┴──────┐
│   users      │     │  wallet_   │
│  (merchants) │     │ transactions│
└──────────────┘     └────────────┘
       │
┌──────┴───────┐
│  customers   │────<│ bookings │
│  (CRM)       │────<│ queues   │
└──────────────┘
```

### Key Tables (36 Migrations)

| Table | Deskripsi |
|-------|-----------|
| `businesses` | Data bisnis/merchant |
| `users` | Pengguna dengan role (owner, cashier, kitchen, manager) |
| `outlets` | Multiple outlet per bisnis |
| `catalog_items` | Produk & layanan |
| `catalog_categories` | Kategori produk |
| `transactions` | Transaksi POS |
| `merchant_wallet` | Saldo merchant |
| `wallet_transactions` | Riwayat wallet |
| `platform_fees` | Fee Rp 500 per transaksi |
| `customers` | Database pelanggan |
| `bookings` | Reservasi |
| `queues` | Antrian |
| `invoices` | Invoice B2B |
| `journal_entries` | Double-entry accounting |
| `journal_lines` | Detail jurnal |
| `attendance` | Absensi karyawan |
| `payroll` | Gaji karyawan |
| `deliveries` | Pengiriman |
| `campaigns` | Marketing campaigns |
| `cash_shifts` | Shift kasir |
| `ingredients` | Bahan baku |
| `recipe_items` | Resep produk |
| `stock_transfers` | Transfer stok antar outlet |
| `purchase_orders` | PO ke supplier |
| `suppliers` | Data supplier |
| `subscriptions` | Status langganan |

---

## 🚀 Cara Instalasi

### Prasyarat

| Tool | Versi | Install |
|------|-------|---------|
| Flutter SDK | 3.22+ | [flutter.dev](https://flutter.dev) |
| Dart SDK | 3.1+ | (included with Flutter) |
| PHP | 8.2+ | [php.net](https://php.net) |
| Composer | 2+ | [getcomposer.org](https://getcomposer.org) |
| PostgreSQL | 15+ | [postgresql.org](https://www.postgresql.org) |
| Redis | 7+ | [redis.io](https://redis.io) |
| Docker | 24+ | [docker.com](https://docker.com) (opsional) |

### 📋 Quick Start

#### 1. Clone Repository

```bash
git clone https://github.com/username/antiribet.com.git
cd antiribet.com
```

#### 2. Setup Backend (Laravel)

```bash
cd backend

# Install dependencies
composer install

# Copy environment file
cp .env.example .env

# Generate app key
php artisan key:generate

# Configure database di .env
# DB_CONNECTION=pgsql
# DB_HOST=127.0.0.1
# DB_PORT=5432
# DB_DATABASE=antiribet
# DB_USERNAME=postgres
# DB_PASSWORD=your_password

# Run migrations
php artisan migrate

# Seed database (opsional)
php artisan db:seed

# Start development server
php artisan serve --port=8000
```

#### 3. Setup Frontend (Flutter)

```bash
cd app

# Get dependencies
flutter pub get

# Run in development (Chrome)
flutter run -d chrome

# Run in development (Android)
flutter run -d <device_id>

# Build release APK
flutter build apk --release
```

#### 4. Setup dengan Docker (Opsional)

```bash
# Start all services
docker-compose up -d

# Run migrations inside container
docker-compose exec app php artisan migrate

# View logs
docker-compose logs -f
```

### ⚡ Quick Scripts (Windows)

```batch
# Start backend server (port 8000)
start_server.bat

# Start Flutter in Chrome
start_frontend.bat
```

### ⚡ Quick Scripts (Linux/Mac)

```bash
# Start backend
cd backend && php artisan serve --port=8000 &

# Start Flutter
cd app && flutter run -d chrome
```

---

## 📡 API Documentation

### Base URL

```
Development: http://127.0.0.1:8000/api
Production:  https://api.antiribet.com/api
```

### 🔐 Authentication

```
POST /auth/login
POST /auth/register
POST /auth/logout
GET  /auth/me
```

### 🏪 Merchant Endpoints

```
# Dashboard
GET  /merchant/dashboard

# POS
GET  /merchant/catalog
POST /merchant/pos/transactions
GET  /merchant/pos/transactions/pending
POST /merchant/pos/transactions/{id}/accept

# Shift
GET  /merchant/shift/current
POST /merchant/shift/open
POST /merchant/shift/close

# Wallet
GET  /merchant/wallet
POST /merchant/wallet/topup

# Catalog
POST /merchant/catalog
PUT  /merchant/catalog/{id}
DELETE /merchant/catalog/{id}

# Queue
GET  /merchant/queue
POST /merchant/queue/{id}/next

# Booking
GET  /merchant/bookings
PUT  /merchant/bookings/{id}/confirm

# HRIS
GET  /merchant/attendance
POST /merchant/attendance/clock-in
POST /merchant/attendance/clock-out
GET  /merchant/payroll

# Reports
GET  /merchant/reports/sales
GET  /merchant/reports/accounting

# CRM
GET  /merchant/customers
GET  /merchant/customers/leaderboard

# Marketing
POST /merchant/campaigns
POST /merchant/campaigns/{id}/broadcast
```

### 🌐 Public Endpoints

```
GET  /public/businesses/{slug}
POST /public/businesses/{slug}/orders
POST /public/businesses/{slug}/queue
POST /public/businesses/{slug}/booking
POST /public/payment/midtrans/callback
```

### 🔑 Admin Endpoints

```
GET  /admin/dashboard
GET  /admin/topups
POST /admin/topups/{id}/approve
```

---

## 🔄 CI/CD Pipeline

### GitHub Actions Workflows

#### 1. `deploy.yml` — Full CI/CD Pipeline

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   PHP 8.3   │───▶│   Laravel   │───▶│  Flutter    │───▶│    VPS      │
│   Setup     │    │   Tests     │    │  Analyze +  │    │  Deploy     │
│             │    │             │    │  Tests      │    │  (main)     │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

- **Trigger**: Push to `main` branch
- **Steps**: PHP Setup → Composer Install → Laravel Tests → Flutter Setup → Flutter Analyze → Flutter Tests → VPS Deploy

#### 2. `flutter_build.yml` — APK Build

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Java 17   │───▶│  Flutter    │───▶│  Upload     │
│   Setup     │    │  Build APK  │    │  Artifact   │
└─────────────┘    └─────────────┘    └─────────────┘
```

- **Trigger**: Changes in `app/**` on `main`
- **Output**: Release APK uploaded as GitHub artifact

---

## 💰 Business Model

### Pricing Structure

| Komponen | Biaya |
|----------|-------|
| Platform Fee | Rp 500 / transaksi berhasil |
| Langganan Bulanan | GRATIS |
| Setup Fee | GRATIS |
| Biaya Cetak Struk | GRATIS |
| QR Code Generator | GRATIS |
| Mini Website | GRATIS |

### Revenue Projection

| Transaksi/Bulan | Revenue Platform |
|-----------------|------------------|
| 1.000 | Rp 500.000 |
| 5.000 | Rp 2.500.000 |
| 10.000 | Rp 5.000.000 |
| 50.000 | Rp 25.000.000 |
| 100.000 | Rp 50.000.000 |

### Unit Economics

- **CAC (Customer Acquisition Cost)**: ~Rp 50.000 (referral + organic)
- **LTV (Lifetime Value)**: ~Rp 600.000/tahun (100 tx/bulan × Rp 500 × 12)
- **LTV/CAC Ratio**: 12x
- **Payback Period**: < 2 bulan

---

## 🗺️ Roadmap

### ✅ Phase 1 — MVP (Completed)

- [x] Authentication (Login/Register)
- [x] POS (Point of Sale) dengan cart & checkout
- [x] Katalog produk
- [x] Dashboard analitik
- [x] Wallet & billing
- [x] Struk cetak
- [x] Mode offline

### 🔄 Phase 2 — Core Features (In Progress)

- [x] QR Ordering
- [x] Kitchen Display System (KDS)
- [x] Queue management
- [x] Booking & reservasi
- [x] Staff management
- [x] Shift management
- [ ] Real-time WebSocket notifications

### 📋 Phase 3 — Business Tools

- [x] Inventori dengan BOM
- [x] CRM dengan poin loyalitas
- [x] Laporan penjualan
- [x] Accounting (double-entry)
- [x] HRIS (absensi + payroll)
- [x] Invoicing B2B
- [ ] WhatsApp Business API integration
- [ ] Multi-outlet management

### 🚀 Phase 4 — Scale

- [ ] Franchise/HQ dashboard
- [ ] Marketing automation
- [ ] AI chatbot untuk analisis
- [ ] Delivery fleet management
- [ ] Public mini-website
- [ ] Mobile app publishing (Play Store & App Store)

### 🌟 Phase 5 — Ecosystem

- [ ] Marketplace integrasi
- [ ] Payment gateway multi-provider
- [ ] API untuk third-party
- [ ] White-label solution
- [ ] Enterprise features

---

## 🤝 Contributing

Kami sangat terbuka untuk kontribusi! Berikut cara berkontribusi:

### Development Setup

1. Fork repository ini
2. Clone fork Anda
3. Buat feature branch: `git checkout -b feature/fitur-baru`
4. Commit perubahan: `git commit -m 'Add fitur baru'`
5. Push ke branch: `git push origin feature/fitur-baru`
6. Buat Pull Request

### Commit Convention

```
feat: menambahkan fitur baru
fix: memperbaiki bug
docs: update dokumentasi
style: formatting, tidak mempengaruhi kode
refactor: refactoring kode
test: menambahkan test
chore: maintenance tasks
```

### Code Style

- **Flutter**: Ikuti [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- **Laravel**: Ikuti [PSR-12](https://www.php-fig.org/psr/psr-12/)
- **Branch Naming**: `feature/nama-fitur`, `fix/nama-bug`, `docs/nama-dokumen`

---

## 📄 License

MIT License - lihat [LICENSE](LICENSE) untuk detail.

```
MIT License

Copyright (c) 2024 AntiRibet

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 📞 Kontak & Dukungan

| Channel | Link |
|---------|------|
| GitHub Issues | [Buka Issue](https://github.com/username/antiribet.com/issues) |
| Email | support@antiribet.com |
| Website | [antiribet.com](https://antiribet.com) |

---

<div align="center">

### ⭐ Star repositori ini jika Anda mendukung UMKM Indonesia!

**Dibuat dengan ❤️ untuk UMKM Indonesia**

![Footer](https://img.shields.io/badge/Made_with-Flutter%20%2B%20Laravel-02569B?style=for-the-badge)

</div>
