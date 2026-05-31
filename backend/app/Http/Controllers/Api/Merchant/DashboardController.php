<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $businessId = $user ? $user->business_id : 1; 

        // 1. Total Penjualan Hari Ini
        $today = Carbon::today();
        $totalSales = DB::table('transactions')
            ->where('business_id', $businessId)
            ->where('status', 'completed')
            ->whereDate('created_at', $today)
            ->sum('total_amount');

        // 2. Total Pesanan Hari Ini
        $totalOrders = DB::table('transactions')
            ->where('business_id', $businessId)
            ->where('status', 'completed')
            ->whereDate('created_at', $today)
            ->count();

        // 3. Sisa Saldo Wallet
        $wallet = DB::table('merchant_wallets')
            ->where('business_id', $businessId)
            ->first();

        $balance = $wallet ? $wallet->balance : 0;

        $business = DB::table('businesses')->where('id', $businessId)->first();
        $slug = $business ? $business->slug : 'unknown-business';

        return response()->json([
            'success' => true,
            'data' => [
                'business_slug' => $slug,
                'total_sales_today' => $totalSales,
                'total_orders_today' => $totalOrders,
                'wallet_balance' => $balance,
            ]
        ]);
    }
}
