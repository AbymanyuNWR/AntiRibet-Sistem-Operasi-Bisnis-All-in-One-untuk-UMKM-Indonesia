<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Auth\AuthController;
use App\Http\Controllers\Api\Merchant\PosController;

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
use App\Http\Controllers\Api\Merchant\ShiftController;
use App\Http\Controllers\Api\Merchant\KitchenController;
use App\Http\Controllers\Api\Merchant\SupplyController;
use App\Http\Controllers\Api\Merchant\AccountingController;
use App\Http\Controllers\Api\Merchant\HrmController;
use App\Http\Controllers\Api\Merchant\DeliveryController;
use App\Http\Controllers\Api\Merchant\MarketingController;
use App\Http\Controllers\Api\Merchant\HqController;
use App\Http\Controllers\Api\Merchant\PlatformAdminController;
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
    Route::post('/businesses/{slug}/orders', [PublicOrderController::class, 'store']);
    Route::post('/businesses/{slug}/queue', [\App\Http\Controllers\Api\Public\PublicQueueController::class, 'takeQueue']);
    Route::post('/businesses/{slug}/booking', [\App\Http\Controllers\Api\Public\PublicBookingController::class, 'makeBooking']);
    Route::post('/payment/midtrans/callback', [PaymentCallbackController::class, 'midtransCallback']);
});

Route::middleware(['auth:sanctum'])->prefix('merchant')->group(function () {
    Route::get('/catalog', [CatalogController::class, 'index']);
    Route::post('/catalog', [CatalogController::class, 'store']);
    Route::put('/catalog/{id}', [CatalogController::class, 'update']);
    Route::delete('/catalog/{id}', [CatalogController::class, 'destroy']);
    
    // Inventory Routes
    Route::get('/inventory', [\App\Http\Controllers\Api\Merchant\InventoryController::class, 'index']);
    Route::post('/inventory', [\App\Http\Controllers\Api\Merchant\InventoryController::class, 'store']);
    Route::put('/inventory/{id}/restock', [\App\Http\Controllers\Api\Merchant\InventoryController::class, 'restock']);
    
    // CRM Routes
    Route::get('/crm/leaderboard', [\App\Http\Controllers\Api\Merchant\CrmController::class, 'getLeaderboard']);
    
    // AI Chatbot Route
    Route::post('/chatbot', [\App\Http\Controllers\Api\Merchant\ChatbotController::class, 'ask']);
    
    Route::get('/pos/transactions/pending', [TransactionController::class, 'getPendingOrders']);
    Route::post('/pos/transactions', [TransactionController::class, 'checkout']);
    Route::post('/pos/transactions/{id}/accept', [TransactionController::class, 'acceptPendingOrder']);
    
    // Dashboard
    Route::get('/dashboard', [DashboardController::class, 'index']);
    
    // Shift
    Route::get('/shift/current', [ShiftController::class, 'current']);
    Route::post('/shift/open', [ShiftController::class, 'open']);
    Route::post('/shift/close', [ShiftController::class, 'close']);
    
    // Kitchen
    Route::get('/kitchen/orders', [KitchenController::class, 'getOrders']);
    Route::post('/kitchen/orders/{id}/status', [KitchenController::class, 'updateStatus']);
    
    // Supply Chain & PO
    Route::get('/suppliers', [SupplyController::class, 'getSuppliers']);
    Route::post('/suppliers', [SupplyController::class, 'createSupplier']);
    Route::get('/purchase-orders', [SupplyController::class, 'getPurchaseOrders']);
    Route::post('/purchase-orders', [SupplyController::class, 'createPurchaseOrder']);
    Route::post('/purchase-orders/{id}/receive', [SupplyController::class, 'markAsReceived']);
    
    // Accounting
    Route::get('/accounting/pnl', [AccountingController::class, 'getProfitAndLoss']);
    
    // Staff Management
    Route::get('/staff', [StaffController::class, 'index']);
    Route::post('/staff', [StaffController::class, 'store']);
    Route::delete('/staff/{id}', [StaffController::class, 'destroy']);
    
    // HRIS & Payroll
    Route::get('/hr/staff', [HrmController::class, 'getStaff']);
    Route::post('/hr/attendance/clock-in', [HrmController::class, 'clockIn']);
    Route::post('/hr/attendance/clock-out', [HrmController::class, 'clockOut']);
    Route::post('/hr/payroll/generate', [HrmController::class, 'generatePayroll']);
    Route::get('/hr/payrolls', [HrmController::class, 'getPayrolls']);
    Route::post('/hr/payrolls/{id}/pay', [HrmController::class, 'payPayroll']);
    
    // Delivery & Fleet Management
    Route::get('/delivery/drivers', [DeliveryController::class, 'getDrivers']);
    Route::get('/delivery', [DeliveryController::class, 'getDeliveries']);
    Route::get('/delivery/pending-transactions', [DeliveryController::class, 'getPendingTransactions']);
    Route::post('/delivery/assign', [DeliveryController::class, 'assignDriver']);
    Route::post('/delivery/{id}/status', [DeliveryController::class, 'updateStatus']);
    
    // Marketing Auto-Pilot
    Route::get('/marketing/campaigns', [MarketingController::class, 'index']);
    Route::post('/marketing/campaigns', [MarketingController::class, 'store']);
    Route::post('/marketing/campaigns/{id}/broadcast', [MarketingController::class, 'broadcast']);
    
    // HQ / Franchise Management
    Route::get('/hq/dashboard', [HqController::class, 'getGlobalDashboard']);
    Route::get('/hq/outlets', [HqController::class, 'getOutlets']);
    Route::post('/hq/stock-transfer', [HqController::class, 'transferStock']);
    
    // SaaS Platform Admin (God Mode)
    Route::get('/platform/dashboard', [PlatformAdminController::class, 'getDashboard']);
    Route::get('/platform/merchants', [PlatformAdminController::class, 'getMerchants']);
    Route::post('/platform/merchants/{id}/renew', [PlatformAdminController::class, 'renewSubscription']);
    Route::post('/platform/merchants/{id}/lock', [PlatformAdminController::class, 'lockSubscription']);
    
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

    // End of merchant routes
});

// Public Website Mode (Untuk QR Order & Mini Website Flutter)
Route::prefix('public')->group(function () {
    Route::get('businesses/{slug}', [\App\Http\Controllers\Api\Public\PublicBusinessController::class, 'show']);
    Route::get('businesses/{slug}/catalog', [\App\Http\Controllers\Api\Public\PublicBusinessController::class, 'catalog']);
    Route::post('businesses/{slug}/orders', [\App\Http\Controllers\Api\Public\PublicOrderController::class, 'store']);
});
