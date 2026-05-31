<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Auth\AuthController;
use App\Http\Controllers\Api\Merchant\DashboardController;
use App\Http\Controllers\Api\Merchant\PosController;
use App\Http\Controllers\Api\Merchant\WalletController;

/*
|--------------------------------------------------------------------------
| API Routes - Antiribet Flutter Backend
|--------------------------------------------------------------------------
|
| Sesuai dengan Blueprint Antiribet Flutter-first architecture.
|
*/

// Authentication
Route::prefix('auth')->group(function () {
    Route::post('login', [AuthController::class, 'login']);
    Route::post('register', [AuthController::class, 'register']);
    
    // Protected auth routes
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('me', [AuthController::class, 'me']);
    });
});

// Merchant App Mode (Protected by Sanctum)
use App\Http\Controllers\Api\Merchant\CatalogController;
use App\Http\Controllers\Api\Merchant\DashboardController;
use App\Http\Controllers\Api\Merchant\WalletController;
use App\Http\Controllers\Api\Merchant\TransactionController;
use App\Http\Controllers\Api\Merchant\BookingController;
use App\Http\Controllers\Api\Merchant\QueueController;
use App\Http\Controllers\Api\Merchant\InvoiceController;
use App\Http\Controllers\Api\Merchant\StaffController;

// Admin Mode
use App\Http\Controllers\Api\Admin\AdminTopupController;
use App\Http\Controllers\Api\Admin\AdminReportController;

Route::middleware(['auth:sanctum'])->prefix('admin')->group(function () {
    Route::get('/dashboard', [AdminReportController::class, 'dashboard']);
    Route::get('/topups', [AdminTopupController::class, 'index']);
    Route::post('/topups/{id}/approve', [AdminTopupController::class, 'approve']);
});

// Public Mode (No Auth)
use App\Http\Controllers\Api\Public\PublicBusinessController;
use App\Http\Controllers\Api\Public\PublicOrderController;
use App\Http\Controllers\Api\Public\PaymentCallbackController;

Route::prefix('public')->group(function () {
    Route::get('/businesses/{slug}', [PublicBusinessController::class, 'show']);
    Route::get('/businesses/{slug}/catalog', [PublicBusinessController::class, 'catalog']);
    Route::post('/businesses/{slug}/orders', [PublicOrderController::class, 'store']);
    Route::post('/payment/midtrans/callback', [PaymentCallbackController::class, 'midtransCallback']);
});

Route::middleware(['auth:sanctum'])->prefix('merchant')->group(function () {
    Route::get('/catalog', [CatalogController::class, 'index']);
    Route::post('/catalog', [CatalogController::class, 'store']);
    Route::put('/catalog/{id}', [CatalogController::class, 'update']);
    Route::delete('/catalog/{id}', [CatalogController::class, 'destroy']);
    
    Route::post('/pos/transactions', [TransactionController::class, 'checkout']);
    
    // Dashboard
    Route::get('/dashboard', [DashboardController::class, 'index']);
    
    // Staff Management
    Route::get('/staff', [StaffController::class, 'index']);
    Route::post('/staff', [StaffController::class, 'store']);
    Route::delete('/staff/{id}', [StaffController::class, 'destroy']);
    
    // Booking, Queue, Invoice
    Route::get('/bookings', [BookingController::class, 'index']);
    Route::post('/bookings', [BookingController::class, 'store']);
    Route::post('/bookings/{id}/status', [BookingController::class, 'updateStatus']);

    Route::get('/queues', [QueueController::class, 'index']);
    Route::post('/queues', [QueueController::class, 'store']);
    Route::post('/queues/{id}/status', [QueueController::class, 'updateStatus']);

    Route::get('/invoices', [InvoiceController::class, 'index']);
    Route::post('/invoices', [InvoiceController::class, 'store']);
    Route::post('/invoices/{id}/status', [InvoiceController::class, 'updateStatus']);
    
    // Wallet
    Route::get('/wallet', [WalletController::class, 'index']);
    Route::post('/wallet/topup', [WalletController::class, 'topUp']);

    
    // POS & Transactions
    Route::prefix('pos')->group(function () {
        Route::post('transactions', [PosController::class, 'storeTransaction']);
    });
    
    // Wallet
    Route::prefix('wallet')->group(function () {
        Route::get('/', [WalletController::class, 'index']);
        Route::post('topups', [WalletController::class, 'requestTopup']);
    });
});

// Public Website Mode (Untuk QR Order & Mini Website Flutter)
Route::prefix('public')->group(function () {
    Route::get('businesses/{slug}', [\App\Http\Controllers\Api\Public\PublicBusinessController::class, 'show']);
    Route::get('businesses/{slug}/catalog', [\App\Http\Controllers\Api\Public\PublicBusinessController::class, 'catalog']);
    Route::post('businesses/{slug}/orders', [\App\Http\Controllers\Api\Public\PublicOrderController::class, 'store']);
});
