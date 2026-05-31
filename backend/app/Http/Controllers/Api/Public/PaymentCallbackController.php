<?php

namespace App\Http\Controllers\Api\Public;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Transaction;
use App\Events\OrderUpdated;

class PaymentCallbackController extends Controller
{
    public function midtransCallback(Request $request)
    {
        $payload = $request->all();
        $orderId = $payload['order_id'] ?? null;
        $transactionStatus = $payload['transaction_status'] ?? null;

        if (!$orderId || !$transactionStatus) {
            return response()->json(['message' => 'Invalid payload'], 400);
        }

        $transaction = DB::table('transactions')->where('invoice_number', $orderId)->first();

        if (!$transaction) {
            return response()->json(['message' => 'Transaction not found'], 404);
        }

        if ($transactionStatus == 'settlement' || $transactionStatus == 'capture') {
            DB::table('transactions')->where('id', $transaction->id)->update([
                'status' => 'completed',
                'updated_at' => now(),
            ]);

            // Broadcast event so cashier & customer knows it is paid
            $txModel = Transaction::find($transaction->id);
            if ($txModel) broadcast(new OrderUpdated($txModel, 'Pembayaran Lunas!'))->toOthers();

            return response()->json(['message' => 'Success']);
        }

        if ($transactionStatus == 'cancel' || $transactionStatus == 'deny' || $transactionStatus == 'expire') {
            DB::table('transactions')->where('id', $transaction->id)->update([
                'status' => 'cancelled',
                'updated_at' => now(),
            ]);
            
            // Broadcast event
            $txModel = Transaction::find($transaction->id);
            if ($txModel) broadcast(new OrderUpdated($txModel, 'Pesanan Dibatalkan/Expired'))->toOthers();

            return response()->json(['message' => 'Cancelled']);
        }

        return response()->json(['message' => 'Status ignored']);
    }
}
