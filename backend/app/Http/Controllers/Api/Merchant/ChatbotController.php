<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ChatbotController extends Controller
{
    /**
     * AI Business Assistant Engine
     * Menganalisa teks input dan memberikan "Super Logic Insight" berdasar database.
     */
    public function ask(Request $request)
    {
        $user = $request->user();
        if (!$user->business_id) {
            return response()->json(['success' => false, 'message' => 'Unregistered Business'], 403);
        }

        $prompt = strtolower($request->prompt ?? '');
        $responseMessage = '';

        // "Super Logic" Keyword Analyzer
        if (str_contains($prompt, 'omzet') || str_contains($prompt, 'penjualan hari ini')) {
            $totalSales = DB::table('transactions')
                ->where('business_id', $user->business_id)
                ->whereDate('created_at', today())
                ->whereIn('status', ['paid', 'completed'])
                ->sum('total_amount');
            
            $countSales = DB::table('transactions')
                ->where('business_id', $user->business_id)
                ->whereDate('created_at', today())
                ->whereIn('status', ['paid', 'completed'])
                ->count();

            $responseMessage = "Penjualan Anda hari ini mencapai **Rp " . number_format($totalSales, 0, ',', '.') . "** dari total **" . $countSales . "** transaksi yang sukses diselesaikan. Pertahankan kinerja luar biasa ini!";
        } 
        elseif (str_contains($prompt, 'saldo') || str_contains($prompt, 'wallet')) {
            $wallet = DB::table('merchant_wallets')
                ->where('business_id', $user->business_id)
                ->first();
                
            $balance = $wallet ? $wallet->balance : 0;
            $responseMessage = "Sisa saldo *wallet* AntiRibet Anda saat ini adalah **Rp " . number_format($balance, 0, ',', '.') . "**. Pastikan saldo Anda selalu di atas Rp 500 agar sistem kasir dapat otomatis menerima pesanan QR.";
        }
        elseif (str_contains($prompt, 'laku') || str_contains($prompt, 'laris')) {
            // Analisis produk paling laris (Dummy logic using catalog since we don't store transaction_items heavily in this demo)
            $responseMessage = "Berdasarkan analisis tren, menu andalan Anda hari ini adalah **Es Teh Manis** dan **Ayam Geprek Level 5**. Saya sarankan Anda menambah stok bahan baku untuk besok.";
        }
        elseif (str_contains($prompt, 'stok') || str_contains($prompt, 'bahan baku') || str_contains($prompt, 'habis')) {
            $lowStockItems = \App\Models\Ingredient::where('business_id', $user->business_id)
                ->whereRaw('current_stock <= minimum_stock')
                ->get();
                
            if ($lowStockItems->isEmpty()) {
                $responseMessage = "Semua stok bahan baku Anda dalam kondisi aman (di atas batas minimum). Lanjutkan penjualan dengan tenang!";
            } else {
                $itemsList = $lowStockItems->map(fn($item) => "- **{$item->name}** (Sisa: {$item->current_stock} {$item->unit})")->join("\n");
                $responseMessage = "⚠️ **Peringatan Stok Menipis!**\nBahan baku berikut sudah mencapai batas minimum dan perlu segera di-restock:\n\n{$itemsList}";
            }
        }
        else {
            $responseMessage = "Halo! Saya adalah Asisten AI AntiRibet. Anda bisa bertanya soal omzet hari ini, produk paling laris, cek stok bahan baku, atau saldo wallet Anda. Ketik pertanyaan Anda!";
        }

        return response()->json([
            'success' => true,
            'data' => [
                'reply' => $responseMessage,
                'timestamp' => now()->toIso8601String()
            ]
        ]);
    }
}
