<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\MerchantWallet;
use App\Models\PlatformFee;
use App\Models\WalletTransaction;
use Illuminate\Support\Facades\DB;
use App\Events\OrderUpdated;
use Exception;

class TransactionService
{
    /**
     * Memproses transaksi POS Kasir.
     * Mengunci wallet, memotong saldo Rp500, dan menyimpan data transaksi.
     */
    public function processPosTransaction(int $businessId, array $cartItems, string $paymentMethod, ?string $customerPhone = null, int $redeemPoints = 0, ?string $idempotencyKey = null): Transaction
    {
        return DB::transaction(function () use ($businessId, $cartItems, $paymentMethod, $customerPhone, $redeemPoints, $idempotencyKey) {
            // 1. Hitung total amount (Dummy logic)
            $totalAmount = collect($cartItems)->sum(fn($item) => $item['price'] * $item['qty']);

            $customerId = null;
            $pointsEarned = 0;
            
            // 2. Logic CRM Loyalti
            if ($customerPhone) {
                // Lock customer if exists, or create new
                $customer = \App\Models\Customer::firstOrCreate(
                    ['business_id' => $businessId, 'phone' => $customerPhone],
                    ['name' => 'Pelanggan ' . substr($customerPhone, -4)]
                );
                
                // Refresh lock
                $customer = \App\Models\Customer::where('id', $customer->id)->lockForUpdate()->first();
                $customerId = $customer->id;

                // Redeem points (1 point = Rp 100)
                if ($redeemPoints > 0 && $customer->points >= $redeemPoints) {
                    $discount = $redeemPoints * 100;
                    $totalAmount = max(0, $totalAmount - $discount);
                    $customer->points -= $redeemPoints;
                } else {
                    $redeemPoints = 0; // Jika poin ga cukup
                }

                // Earn points (Rp 10.000 = 1 point)
                $pointsEarned = floor($totalAmount / 10000);
                $customer->points += $pointsEarned;
                $customer->total_spent += $totalAmount;
                $customer->last_visit = now();
                $customer->save();
            }

            // 3. Lock wallet merchant untuk mencegah race condition (super logic)
            $wallet = MerchantWallet::where('business_id', $businessId)->lockForUpdate()->first();
            
            if (!$wallet) {
                throw new Exception("Wallet merchant tidak ditemukan.");
            }

            // Fee platform Antiribet
            $feeAmount = 500;

            // 4. Validasi saldo cukup untuk dipotong fee
            if ($wallet->balance < $feeAmount) {
                throw new Exception("Saldo wallet tidak cukup untuk membayar fee platform Rp 500. Silakan Top Up.");
            }

            // 5. Buat Transaksi
            $transaction = Transaction::create([
                'business_id' => $businessId,
                'transaction_number' => 'TRX-' . time() . rand(100, 999),
                'total_amount' => $totalAmount,
                'status' => 'paid',
                'payment_method' => $paymentMethod,
                'items' => $cartItems,
                'customer_id' => $customerId,
                'points_earned' => $pointsEarned,
                'points_redeemed' => $redeemPoints,
                'idempotency_key' => $idempotencyKey,
            ]);

            // 6. Update Shift Kasir jika metode pembayaran tunai
            if ($paymentMethod === 'cash') {
                $user = auth()->user();
                if ($user) {
                    $shift = \App\Models\CashShift::where('user_id', $user->id)
                        ->where('business_id', $businessId)
                        ->where('status', 'open')
                        ->first();
                    if ($shift) {
                        $shift->increment('expected_cash', $totalAmount);
                    }
                }
            }

            // 5. Potong Saldo & Catat Log Wallet
            $wallet->balance -= $feeAmount;
            $wallet->save();

            WalletTransaction::create([
                'merchant_wallet_id' => $wallet->id,
                'type' => 'debit',
                'amount' => $feeAmount,
                'reference_id' => $transaction->id,
                'description' => 'Platform fee potongan Rp500 untuk ' . $transaction->transaction_number
            ]);

            // 6. Catat Platform Fee untuk laporan admin
            PlatformFee::create([
                'business_id' => $businessId,
                'transaction_id' => $transaction->id,
                'amount' => $feeAmount,
            ]);

            // 7. [SUPER LOGIC] Potong Inventory Berdasarkan Resep (BOM) & Hitung COGS
            $totalCogs = 0;
            foreach ($cartItems as $item) {
                if (isset($item['catalog_item_id'])) {
                    $recipeItems = \App\Models\RecipeItem::where('catalog_item_id', $item['catalog_item_id'])->get();
                    
                    foreach ($recipeItems as $recipe) {
                        $totalNeeded = $recipe->quantity_required * ($item['quantity'] ?? $item['qty'] ?? 1);
                        
                        // Lock ingredient row
                        $ingredient = \App\Models\Ingredient::where('id', $recipe->ingredient_id)
                            ->lockForUpdate()
                            ->first();
                            
                        if ($ingredient) {
                            $ingredient->current_stock -= $totalNeeded;
                            $ingredient->save();
                            
                            $totalCogs += ($ingredient->unit_cost * $totalNeeded);
                        }
                    }
                }
            }

            // 8. Jurnal Akuntansi (Super Logic)
            self::_createSalesJournal($businessId, $transaction->id, $totalAmount, $totalCogs);

            // 9. Broadcast pesanan ke Layar Dapur (KDS)
            try {
                broadcast(new \App\Events\KitchenStatusUpdated($transaction))->toOthers();
            } catch (\Exception $e) {
                // Ignore if reverb is down
            }

            return $transaction;
        });
    }

    /**
     * Memproses penerimaan pesanan QR Pelanggan oleh Kasir.
     * Mengunci wallet, memotong saldo Rp500, dan mengubah status menjadi paid/cooking.
     */
    public function acceptPendingOrder(int $businessId, int $transactionId): Transaction
    {
        return DB::transaction(function () use ($businessId, $transactionId) {
            $transaction = Transaction::where('business_id', $businessId)
                ->where('id', $transactionId)
                ->lockForUpdate()
                ->first();

            if (!$transaction) {
                throw new Exception("Pesanan tidak ditemukan.");
            }

            if ($transaction->status !== 'pending') {
                throw new Exception("Pesanan ini sudah diproses sebelumnya.");
            }

            // Lock wallet merchant
            $wallet = MerchantWallet::where('business_id', $businessId)->lockForUpdate()->first();
            
            if (!$wallet) {
                throw new Exception("Wallet merchant tidak ditemukan.");
            }

            // Fee platform Antiribet
            $feeAmount = 500;

            if ($wallet->balance < $feeAmount) {
                throw new Exception("Saldo wallet tidak cukup untuk menerima pesanan (Biaya Rp 500). Silakan Top Up.");
            }

            // Update Transaksi
            $transaction->status = 'paid';
            $transaction->save();

            // Potong Saldo & Catat Log
            $wallet->balance -= $feeAmount;
            $wallet->save();

            WalletTransaction::create([
                'merchant_wallet_id' => $wallet->id,
                'type' => 'debit',
                'amount' => $feeAmount,
                'reference_id' => $transaction->id,
                'description' => 'Platform fee potongan Rp500 untuk pesanan QR ' . $transaction->transaction_number
            ]);

            PlatformFee::create([
                'business_id' => $businessId,
                'transaction_id' => $transaction->id,
                'amount' => $feeAmount,
            ]);

            // [SUPER LOGIC] Potong Inventory Berdasarkan Resep (BOM) & Hitung COGS
            $totalCogs = 0;
            if (is_array($transaction->items)) {
                foreach ($transaction->items as $item) {
                    if (isset($item['catalog_item_id'])) {
                        $recipeItems = \App\Models\RecipeItem::where('catalog_item_id', $item['catalog_item_id'])->get();
                        
                        foreach ($recipeItems as $recipe) {
                            $totalNeeded = $recipe->quantity_required * ($item['quantity'] ?? $item['qty'] ?? 1);
                            
                            $ingredient = \App\Models\Ingredient::where('id', $recipe->ingredient_id)
                                ->lockForUpdate()
                                ->first();
                                
                            if ($ingredient) {
                                $ingredient->current_stock -= $totalNeeded;
                                $ingredient->save();
                                
                                $totalCogs += ($ingredient->unit_cost * $totalNeeded);
                            }
                        }
                    }
                }
            }

            // Jurnal Akuntansi (Super Logic)
            self::_createSalesJournal($businessId, $transaction->id, $transaction->total_amount, $totalCogs);

            // Beritahu pelanggan bahwa pesanan diterima (via WebSocket)
            broadcast(new OrderUpdated($transaction, 'Pesanan Anda sedang dimasak!'))->toOthers();
            
            // Broadcast ke KDS (Kitchen Display System)
            try {
                broadcast(new \App\Events\KitchenStatusUpdated($transaction))->toOthers();
            } catch (\Exception $e) {
                // Ignore if reverb is down
            }

            return $transaction;
        });
    }

    private static function _createSalesJournal(int $businessId, int $transactionId, float $totalAmount, float $totalCogs)
    {
        $accKas = \App\Models\Account::where('business_id', $businessId)->where('account_code', '1001')->first();
        $accPersediaan = \App\Models\Account::where('business_id', $businessId)->where('account_code', '1002')->first();
        $accPendapatan = \App\Models\Account::where('business_id', $businessId)->where('account_code', '4001')->first();
        $accHPP = \App\Models\Account::where('business_id', $businessId)->where('account_code', '5001')->first();

        if ($accKas && $accPendapatan) {
            $journal = \App\Models\JournalEntry::create([
                'business_id' => $businessId,
                'reference_type' => 'Transaction',
                'reference_id' => $transactionId,
                'description' => 'Penjualan Kasir POS',
                'entry_date' => now(),
            ]);

            // Debit Kas
            \App\Models\JournalLine::create(['journal_entry_id' => $journal->id, 'account_id' => $accKas->id, 'debit' => $totalAmount, 'credit' => 0]);
            // Kredit Pendapatan
            \App\Models\JournalLine::create(['journal_entry_id' => $journal->id, 'account_id' => $accPendapatan->id, 'debit' => 0, 'credit' => $totalAmount]);

            // Jika ada HPP
            if ($totalCogs > 0 && $accHPP && $accPersediaan) {
                // Debit HPP
                \App\Models\JournalLine::create(['journal_entry_id' => $journal->id, 'account_id' => $accHPP->id, 'debit' => $totalCogs, 'credit' => 0]);
                // Kredit Persediaan
                \App\Models\JournalLine::create(['journal_entry_id' => $journal->id, 'account_id' => $accPersediaan->id, 'debit' => 0, 'credit' => $totalCogs]);
            }
        }
    }
}
