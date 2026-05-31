<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Business;
use App\Models\User;
use App\Models\MerchantWallet;
use App\Models\Transaction;
use App\Services\WalletService;

class PlatformFeeTest extends TestCase
{
    use RefreshDatabase;

    public function test_transaction_deducts_platform_fee()
    {
        $business = Business::create(['name' => 'Kopi Senja Test', 'slug' => 'kopi-senja-test']);
        $wallet = MerchantWallet::create(['business_id' => $business->id, 'balance' => 10000]);
        $user = User::create([
            'business_id' => $business->id,
            'name' => 'Owner',
            'email' => 'owner@test.com',
            'password' => bcrypt('password'),
            'role' => 'merchant_owner'
        ]);

        $walletService = new WalletService();

        $transaction = Transaction::create([
            'business_id' => $business->id,
            'transaction_number' => 'TRX-12345',
            'idempotency_key' => 'test-key-1',
            'total_amount' => 50000,
            'payment_method' => 'cash',
            'status' => 'paid',
            'type' => 'pos',
            'cashier_name' => 'Owner',
        ]);

        // Mock fee deduction
        $walletService->deductFee($business->id, $transaction->id);

        $wallet->refresh();

        $this->assertEquals(9500, $wallet->balance);
        $this->assertDatabaseHas('wallet_transactions', [
            'merchant_wallet_id' => $wallet->id,
            'type' => 'debit',
            'amount' => 500,
        ]);
    }
}
