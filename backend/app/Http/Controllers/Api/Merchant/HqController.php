<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Outlet;
use App\Models\Transaction;
use App\Models\StockTransfer;
use App\Models\Ingredient;
use Illuminate\Support\Facades\DB;

class HqController extends Controller
{
    public function getGlobalDashboard(Request $request)
    {
        // For simulation, assuming all outlets belong to the super owner's business_id
        $businessId = $request->user()->business_id;

        $totalOmzet = Transaction::where('business_id', $businessId)->sum('total_amount');
        $totalTransaksi = Transaction::where('business_id', $businessId)->count();
        $outletsCount = Outlet::where('business_id', $businessId)->count();

        return response()->json([
            'success' => true,
            'data' => [
                'total_omzet' => $totalOmzet,
                'total_transaksi' => $totalTransaksi,
                'outlets_count' => $outletsCount,
            ]
        ]);
    }

    public function getOutlets(Request $request)
    {
        $outlets = Outlet::where('business_id', $request->user()->business_id)->get();
        return response()->json(['success' => true, 'data' => $outlets]);
    }

    public function transferStock(Request $request)
    {
        $request->validate([
            'from_outlet_id' => 'required|exists:outlets,id',
            'to_outlet_id' => 'required|exists:outlets,id',
            'ingredient_id' => 'required|exists:ingredients,id',
            'quantity' => 'required|numeric|min:0.1',
        ]);

        return DB::transaction(function () use ($request) {
            $businessId = $request->user()->business_id;
            
            // Logic ini disederhanakan. Idealnya masing-masing outlet punya stok terpisah.
            // Karena ingredient kita global per business_id, kita simulasikan transfer
            // dengan sekadar memvalidasi dan mencatat log mutasi antar cabang.
            
            $ingredient = Ingredient::where('business_id', $businessId)
                ->where('id', $request->ingredient_id)
                ->lockForUpdate()
                ->firstOrFail();

            if ($ingredient->current_stock < $request->quantity) {
                return response()->json(['success' => false, 'message' => 'Stok di Gudang Asal tidak cukup.'], 400);
            }

            // Simulasi mutasi (Bisa menambahkan field per-outlet stock di masa depan)
            // Di sini kita anggap HQ memindahkan stok global ke cabang tertentu.
            // Untuk super logic saat ini, kita kurangi stok global jika dikirim ke outlet luar,
            // atau cukup catat log pergerakannya.
            // Kita akan mencatat log mutasi saja.
            
            $transfer = StockTransfer::create([
                'business_id' => $businessId,
                'from_outlet_id' => $request->from_outlet_id,
                'to_outlet_id' => $request->to_outlet_id,
                'ingredient_id' => $request->ingredient_id,
                'quantity' => $request->quantity,
                'status' => 'completed'
            ]);

            return response()->json(['success' => true, 'message' => 'Transfer stok berhasil', 'data' => $transfer]);
        });
    }
}
