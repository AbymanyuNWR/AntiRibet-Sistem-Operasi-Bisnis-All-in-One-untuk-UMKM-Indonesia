<?php

namespace App\Services;

use App\Models\Invoice;
use Exception;

class InvoiceService
{
    protected WalletService $walletService;

    public function __construct(WalletService $walletService)
    {
        $this->walletService = $walletService;
    }

    public function createInvoice(int $businessId, array $data)
    {
        return Invoice::create([
            'business_id' => $businessId,
            'invoice_number' => $data['invoice_number'],
            'customer_id' => $data['customer_id'] ?? null,
            'total_amount' => $data['total_amount'],
            'paid_amount' => 0,
            'status' => 'draft',
        ]);
    }

    public function recordPayment(int $businessId, int $invoiceId, float $amount)
    {
        $invoice = Invoice::where('id', $invoiceId)->where('business_id', $businessId)->first();
        if (!$invoice) {
            throw new Exception("Invoice not found");
        }

        $wasUnpaid = in_array($invoice->status, ['draft', 'sent']);

        $invoice->paid_amount += $amount;

        if ($invoice->paid_amount >= $invoice->total_amount) {
            $invoice->status = 'paid';
        } else {
            $invoice->status = 'partially_paid';
        }

        $invoice->save();

        // Platform fee deducted ONLY ONCE when first payment is made
        if ($wasUnpaid) {
            $this->walletService->deductFee($businessId, null);
        }

        return $invoice;
    }
}
