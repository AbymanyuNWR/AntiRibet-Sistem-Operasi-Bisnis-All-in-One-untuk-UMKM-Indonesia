<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Business;
use App\Models\MerchantWallet;
use App\Services\InvoiceService;
use App\Services\WalletService;

class InvoiceFeeTest extends TestCase
{
    use RefreshDatabase;

    public function test_invoice_fee_deducted_only_once()
    {
        $business = Business::create(['name' => 'Event Organizer Test', 'slug' => 'event-organizer-test']);
        $wallet = MerchantWallet::create(['business_id' => $business->id, 'balance' => 10000]);
        
        $walletService = new WalletService();
        $invoiceService = new InvoiceService($walletService);

        $invoice = $invoiceService->createInvoice($business->id, [
            'invoice_number' => 'INV-001',
            'total_amount' => 5000000,
        ]);

        $this->assertEquals('draft', $invoice->status);
        $this->assertEquals(10000, $wallet->fresh()->balance);

        // First payment (DP)
        $invoiceService->recordPayment($business->id, $invoice->id, 2000000);
        
        $this->assertEquals(9500, $wallet->fresh()->balance); // Fee deducted
        $this->assertDatabaseCount('wallet_transactions', 1);

        // Second payment (Lunas)
        $invoiceService->recordPayment($business->id, $invoice->id, 3000000);

        // Fee should NOT be deducted again
        $this->assertEquals(9500, $wallet->fresh()->balance);
        $this->assertDatabaseCount('wallet_transactions', 1);
    }
}
