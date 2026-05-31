<?php

namespace App\Services;

use Exception;
use App\Models\Transaction;

class MidtransService
{
    protected string $serverKey;
    protected bool $isProduction;

    public function __construct()
    {
        // Untuk mock di MVP tanpa library `midtrans/midtrans-php` yang riil
        // kita asumsikan env variable exists
        $this->serverKey = env('MIDTRANS_SERVER_KEY', 'SB-Mid-server-xxx');
        $this->isProduction = env('MIDTRANS_IS_PRODUCTION', false);
    }

    /**
     * Generate Snap Token (Mocked for Super Logic Implementation without actual composer require yet)
     * Pada produksi, di sini kita akan memanggil \Midtrans\Snap::getSnapToken($params);
     */
    public function getSnapToken(Transaction $transaction): string
    {
        // Build payload
        $payload = [
            'transaction_details' => [
                'order_id' => $transaction->transaction_number,
                'gross_amount' => (int) $transaction->total_amount,
            ],
            // 'customer_details' => [...], // optional
        ];

        // Karena kita belum install library midtrans, kita mock response
        // Di aplikasi nyata, ini me-return Snap Token riil
        return "mocked-snap-token-{$transaction->transaction_number}";
    }

    /**
     * Handle webhook dari Midtrans
     */
    public function handleNotification(array $payload): void
    {
        // Dalam implementasi nyata: verifikasi signature key
        // $signatureKey = hash('sha512', $payload['order_id'] . $payload['status_code'] . $payload['gross_amount'] . $this->serverKey);
        // if ($signatureKey !== $payload['signature_key']) throw new Exception("Invalid Signature");

        $transactionNumber = $payload['order_id'] ?? null;
        $transactionStatus = $payload['transaction_status'] ?? null;

        if (!$transactionNumber || !$transactionStatus) {
            return;
        }

        $transaction = Transaction::where('transaction_number', $transactionNumber)->first();
        
        if (!$transaction) {
            return;
        }

        // Midtrans Status Mapping
        if ($transactionStatus == 'settlement' || $transactionStatus == 'capture') {
            $transaction->status = 'paid';
            $transaction->save();
            
            // Trigger Wallet Deduction
            // Gunakan WalletService melalui DI di tempat lain atau panggil langsung
            $walletService = app(WalletService::class);
            $walletService->deductFee($transaction->business_id, $transaction->id);

        } elseif ($transactionStatus == 'cancel' || $transactionStatus == 'deny' || $transactionStatus == 'expire') {
            $transaction->status = 'void';
            $transaction->save();
        }
    }
}
