# ANTI RIBET: TECHNICAL BLUEPRINT
**Arsitektur Sistem, Flutter, dan Laravel API**

## 1. Arsitektur Sistem Utama (High-Level)
AntiRibet berjalan di atas arsitektur Client-Server yang dipisahkan secara tegas (*Decoupled*).
```text
[Flutter Clients] ---> (HTTPS/JSON) ---> [Laravel API (Backend)]
(Web, Android, iOS)                           |
                                              v
                              [PostgreSQL] -- [Redis] -- [S3 Storage]
```
- **Flutter** berfungsi murni sebagai UI dan pengatur State. Tidak ada logika perhitungan uang di Flutter.
- **Laravel** bertindak sebagai *Brain* dan *Gatekeeper*.
- **PostgreSQL** menyimpan kebenaran absolut (*Single Source of Truth*).
- **Redis & Reverb** menyediakan kemampuan *real-time* (WebSocket) untuk notifikasi pesanan QR.

## 2. Flutter Feature-First Architecture
Daripada mengelompokkan *file* berdasarkan tipe (semua *screens* di satu folder, semua *models* di satu folder), AntiRibet menggunakan pendekatan berbasis Fitur (*Feature-First*):

```text
lib/
├── core/
│   ├── network/ (Dio Interceptors)
│   ├── utils/ (Formatter Rupiah, Date)
│   └── widgets/ (Button, Input universal)
├── features/
│   ├── auth/
│   │   ├── data/ (Auth API, Secure Storage)
│   │   ├── domain/ (Auth Entity)
│   │   └── presentation/ (LoginScreen)
│   ├── pos/
│   │   ├── presentation/ (PosScreen, CartWidget)
│   │   └── providers/ (CartStateNotifier)
│   ├── wallet/
│   └── catalog/
└── app/
    └── router.dart (GoRouter setup)
```

## 3. Laravel API & Service Layer Architecture
Laravel diatur menggunakan pola `Controller -> Service -> Model`. 
Controller tidak boleh berisi logika bisnis yang berat (misal memotong saldo atau menghitung pajak).

```php
// CONTOH CONTROLLER (Bersih)
class PosController extends Controller {
    public function checkout(CheckoutRequest $request, TransactionService $service) {
        $transaction = $service->processPosCheckout(
            $request->validated(), 
            auth()->user()->business_id
        );
        return response()->json(['success' => true, 'data' => $transaction]);
    }
}
```

## 4. API Endpoint Structure & Auth Flow
Auth Flow:
1. Flutter mengirim email & password ke `/api/auth/login`.
2. Laravel Sanctum menerbitkan Token.
3. Flutter menyimpan token di *Secure Storage*.
4. Setiap request Flutter menyertakan header `Authorization: Bearer <token>`.

## 5. Logika Transaksi & Real-time (WebSocket)
**QR Order Logic:**
1. Customer *Scan* QR (membuka URL `/public/businesses/kopi-senja/orders`).
2. Pelanggan memilih menu dan Submit. API membuat transaksi (status: `pending`).
3. Laravel memanggil `OrderCreated::dispatch($transaction)`.
4. Event ini di-broadcast oleh **Laravel Reverb** via WebSocket.
5. Flutter Web (Dashboard Kasir Kopi Senja) *listening* ke channel `business.ID.orders`.
6. Terdengar bunyi *ting!* di tablet kasir, dan UI terupdate secara instan.

## 6. Security & Data Protection
- **CORS & Rate Limiting:** Dibatasi 60 request/menit untuk API publik untuk menghindari *Brute-force* atau serangan *DDoS*.
- **Database Transaction:** Logika potong *Wallet* selalu diapit `DB::beginTransaction()` dan `DB::commit()`. Jika terjadi *crash* di tengah eksekusi, uang tidak hilang (*Rollback* otomatis).
- **Idempotency Key:** Untuk menghindari *Double Checkout* (koneksi lemot lalu kasir memencet bayar 3 kali), API mengenali request berulang berdasarkan ID *Cart* yang sama.

## 7. Testing & Deployment Strategy
- **Flutter Testing:** *Widget Tests* untuk memastikan tombol checkout bisa ditekan. *Integration Tests* untuk alur login.
- **Laravel Testing:** *PestPHP / PHPUnit* untuk Feature Test (Memastikan potong saldo tidak lebih, tidak kurang dari Rp500).
- **Deployment Pipeline:**
  - *Backend:* GitHub Actions CI/CD -> VPS Ubuntu -> Nginx -> PHP 8.3 FPM.
  - *Frontend Web:* Firebase Hosting atau Cloudflare Pages (untuk kecepatan global CDN).
  - *Mobile Apps:* Fastlane -> Google Play Store & Apple App Store.

## 8. Monitoring & Backup
- Sentry diintegrasikan di Laravel dan Flutter untuk mendeteksi *Fatal Crash* secara otomatis.
- Cron Job menjalankan skrip *Backup* PostgreSQL setiap jam 03:00 pagi dan mengunggah *dump file* ke AWS S3 dengan retensi 30 hari.
