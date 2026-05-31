<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Business;
use App\Models\MerchantWallet;
use App\Services\QueueService;
use App\Services\WalletService;
use Illuminate\Support\Facades\DB;

class ConcurrencyTest extends TestCase
{
    use RefreshDatabase;

    public function test_queue_generation_handles_concurrency()
    {
        $business = Business::create(['name' => 'Klinik Test', 'slug' => 'klinik-test']);
        $walletService = new WalletService();
        $queueService = new QueueService($walletService);

        // We can't truly test concurrency in a single PHP process easily without extensions or PCNTL,
        // but we can test that the method works sequentially and does not error out.
        // For actual concurrency tests, we would need to make parallel HTTP requests to the app.

        $transaction = \App\Models\Transaction::create([
            'business_id' => $business->id,
            'transaction_number' => 'TRX-Q-1',
            'idempotency_key' => 'trx-q-1',
            'total_amount' => 0,
            'payment_method' => 'cash',
            'status' => 'paid',
            'type' => 'queue'
        ]);

        $q1 = $queueService->generateQueueNumber($business->id, $transaction->id);
        $q2 = $queueService->generateQueueNumber($business->id, $transaction->id);

        $this->assertEquals('A-001', $q1->queue_number);
        $this->assertEquals('A-002', $q2->queue_number);
    }
}
