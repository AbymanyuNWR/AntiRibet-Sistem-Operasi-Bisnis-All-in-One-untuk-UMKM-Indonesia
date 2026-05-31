<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\ReportService;

class ReportController extends Controller
{
    protected $reportService;

    public function __construct(ReportService $reportService)
    {
        $this->reportService = $reportService;
    }

    /**
     * Dashboard Laporan Harian Merchant.
     */
    public function daily(Request $request)
    {
        $businessId = $request->user()->business_id;
        $date = date('Y-m-d');
        
        $metrics = $this->reportService->getDailyMetrics($businessId, $date);

        return response()->json([
            'success' => true,
            'data' => [
                'date' => $date,
                'total_revenue' => $metrics->total_revenue ?? 0,
                'total_transactions' => $metrics->total_transactions ?? 0,
            ]
        ]);
    }
}
