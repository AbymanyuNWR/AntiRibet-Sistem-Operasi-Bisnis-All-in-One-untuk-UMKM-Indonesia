<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\MerchantWallet;
use App\Models\WalletTransaction;

class WalletController extends Controller
{
    /**
     * Get wallet balance
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $businessId = $user ? $user->business_id : 1; 

        $wallet = MerchantWallet::with(['walletTransactions' => function ($query) {
            $query->orderBy('created_at', 'desc')->limit(10);
        }])->where('business_id', $businessId)->first();

        return response()->json([
            'success' => true,
            'data' => [
                'wallet' => $wallet,
                'transactions' => $wallet ? $wallet->walletTransactions : [],
            ]
        ]);
    }

    /**
     * Request Top Up
     */
    public function topUp(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:10000',
        ]);

        $user = $request->user();
        $businessId = $user ? $user->business_id : 1; 

        $wallet = MerchantWallet::where('business_id', $businessId)->first();

        if (!$wallet) {
            return response()->json(['success' => false, 'message' => 'Wallet not found'], 404);
        }

        WalletTransaction::create([
            'merchant_wallet_id' => $wallet->id,
            'type' => 'credit',
            'amount' => $request->amount,
            'description' => 'Top Up Request (Pending)',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Request Top Up berhasil. Menunggu persetujuan Admin.',
        ]);
    }
}
