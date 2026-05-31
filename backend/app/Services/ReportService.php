<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\PlatformFee;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class ReportService
{
    /**
     * Hitung total omset dan jumlah transaksi harian.
     */
    public function getDailyMetrics(int $businessId, string $date)
    {
        return Transaction::where('business_id', $businessId)
            ->whereDate('created_at', $date)
            ->where('status', 'paid')
            ->selectRaw('COUNT(*) as total_transactions, SUM(total_amount) as total_revenue')
            ->first();
    }

    /**
     * Laporan khusus Super Admin: Total platform fee Rp500 dari semua merchant hari ini.
     */
    public function getSuperAdminDailyFee(string $date)
    {
        return PlatformFee::whereDate('created_at', $date)
            ->sum('amount');
    }
}
