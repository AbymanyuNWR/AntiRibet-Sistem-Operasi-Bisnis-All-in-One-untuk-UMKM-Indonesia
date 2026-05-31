<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminReportController extends Controller
{
    public function dashboard(Request $request)
    {
        // Pastikan hanya super_admin yang bisa akses ini (idealnya pakai role checking)

        // KPI 1: Total Merchants
        $totalMerchants = DB::table('businesses')->count();

        // KPI 2: Total Platform Fee (Total pendapatan bersih platform)
        $totalPlatformFee = DB::table('platform_fees')
            ->where('status', 'charged')
            ->sum('fee_amount');

        // KPI 3: Total Transaksi Berhasil
        $totalSuccessfulTransactions = DB::table('transactions')
            ->whereIn('status', ['paid', 'completed'])
            ->count();

        // Ambil daftar Merchant untuk tabel
        $merchants = DB::table('businesses')->select('id', 'name', 'slug', 'category', 'status', 'created_at')
            ->orderBy('created_at', 'desc')
            ->get();

        // Coba kita lihat merchant_wallets untuk digabungkan ke data merchants
        $wallets = DB::table('merchant_wallets')->get()->keyBy('business_id');
        
        $merchantsData = $merchants->map(function ($merchant) use ($wallets) {
            $wallet = $wallets->get($merchant->id);
            return [
                'id' => $merchant->id,
                'name' => $merchant->name,
                'category' => $merchant->category,
                'balance' => $wallet ? $wallet->balance : 0,
                'joined_at' => substr($merchant->created_at, 0, 10),
                'status' => $merchant->status,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => [
                'kpi' => [
                    'total_merchants' => $totalMerchants,
                    'total_platform_revenue' => $totalPlatformFee,
                    'total_successful_transactions' => $totalSuccessfulTransactions,
                ],
                'merchants' => $merchantsData
            ]
        ]);
    }
}
