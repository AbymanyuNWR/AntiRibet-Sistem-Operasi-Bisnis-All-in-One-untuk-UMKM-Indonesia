<?php

namespace App\Services;

use App\Models\MerchantWallet;
use App\Models\WalletTransaction;
use Illuminate\Support\Facades\DB;
use Exception;

class WalletService
{
    /**
     * Potong saldo merchant sebesar fee transaksi
     */
    public function deductFee(int $businessId, ?int $transactionId, float $amount = 500.0)
    {
        $wallet = MerchantWallet::where('business_id', $businessId)->lockForUpdate()->first();
        
        if (!$wallet || $wallet->balance < $amount) {
            throw new Exception("Saldo tidak mencukupi (Min. Rp{$amount})");
        }
        
        $wallet->balance -= $amount;
        $wallet->save();
        
        WalletTransaction::create([
            'merchant_wallet_id' => $wallet->id,
            'type' => 'debit',
            'amount' => $amount,
            'reference_id' => 'TRX-' . $transactionId,
            'description' => "Fee transaksi berhasil (ID: {$transactionId})"
        ]);
        
        return $wallet;
    }
}
