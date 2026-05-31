<?php

namespace App\Http\Controllers\Api\Public;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Business;
use App\Models\Transaction;
use App\Events\OrderCreated;

class PublicOrderController extends Controller
{
    /**
     * Submit pesanan baru dari QR Order Pelanggan.
     * Tidak butuh token auth, tapi butuh token QR validasi (opsional).
     */
    public function store(Request $request, $slug)
    {
        $business = Business::where('slug', $slug)->first();
        if (!$business) return response()->json(['success' => false, 'message' => 'Toko tidak ditemukan'], 404);

        $request->validate([
            'table_number' => 'required',
            'items' => 'required|array',
            'total_amount' => 'required|numeric'
        ]);

        $invoiceNumber = 'ORD-' . strtoupper(uniqid());
        $paymentMethod = $request->payment_method ?? 'cash';
        
        $transaction = Transaction::create([
            'business_id' => $business->id,
            'transaction_number' => $invoiceNumber,
            'total_amount' => $request->total_amount,
            'status' => 'pending', // Menunggu kasir atau midtrans
            'payment_method' => $paymentMethod,
            'table_number' => $request->table_number ?? '0',
            'items' => $request->items,
        ]);

        // Trigger Reverb Broadcast Event
        broadcast(new OrderCreated($transaction))->toOthers();

        $paymentUrl = null;
        if ($paymentMethod == 'online') {
            // Simulasi Midtrans Snap API call
            $paymentUrl = "https://app.sandbox.midtrans.com/snap/v2/vtweb/simulated-token-$invoiceNumber";
        }

        return response()->json([
            'success' => true, 
            'message' => 'Pesanan berhasil dikirim ke dapur!',
            'data' => [
                'id' => $transaction->id, 
                'invoice_number' => $invoiceNumber,
                'payment_url' => $paymentUrl
            ]
        ]);
    }
}
