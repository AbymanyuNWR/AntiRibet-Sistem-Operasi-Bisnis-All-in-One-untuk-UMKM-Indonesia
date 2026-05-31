<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class InvoiceController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        if (!$user->business_id) return response()->json(['success' => false], 400);

        $invoices = DB::table('invoices')
            ->where('business_id', $user->business_id)
            ->orderBy('id', 'desc')
            ->get();

        // decode JSON
        $invoices->transform(function ($item) {
            $item->items = json_decode($item->items);
            return $item;
        });

        return response()->json(['success' => true, 'data' => $invoices]);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        
        $invoiceNumber = 'INV-' . strtoupper(uniqid());

        $id = DB::table('invoices')->insertGetId([
            'business_id' => $user->business_id,
            'invoice_number' => $invoiceNumber,
            'client_name' => $request->client_name,
            'client_email' => $request->client_email,
            'items' => json_encode($request->items),
            'total_amount' => $request->total_amount,
            'status' => 'unpaid',
            'due_date' => $request->due_date,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json(['success' => true, 'data' => ['id' => $id, 'invoice_number' => $invoiceNumber]]);
    }

    public function updateStatus(Request $request, $id)
    {
        $user = $request->user();
        $status = $request->status; // paid, cancelled

        $invoice = DB::table('invoices')->where('id', $id)->where('business_id', $user->business_id)->first();
        if (!$invoice) return response()->json(['success' => false], 404);

        if ($status == 'paid' && $invoice->status != 'paid') {
            $wallet = DB::table('merchant_wallets')->where('business_id', $user->business_id)->first();
            if (!$wallet || $wallet->balance < 500) {
                return response()->json(['success' => false, 'message' => 'Saldo tidak cukup untuk menandai Invoice Lunas.'], 400);
            }

            DB::table('merchant_wallets')->where('id', $wallet->id)->decrement('balance', 500);
            DB::table('platform_fees')->insert([
                'business_id' => $user->business_id,
                'source_type' => 'invoice',
                'source_id' => $id,
                'fee_amount' => 500,
                'status' => 'charged',
                'created_at' => now()
            ]);
        }

        DB::table('invoices')->where('id', $id)->update(['status' => $status, 'updated_at' => now()]);
        return response()->json(['success' => true, 'message' => 'Status updated']);
    }
}
