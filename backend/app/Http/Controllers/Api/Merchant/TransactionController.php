<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\TransactionService;

class TransactionController extends Controller
{
    protected TransactionService $transactionService;

    public function __construct(TransactionService $transactionService)
    {
        $this->transactionService = $transactionService;
    }

    public function checkout(Request $request)
    {
        $user = $request->user();
        $businessId = $user ? $user->business_id : 1; 

        $items = $request->input('items', []);
        $paymentMethod = $request->input('payment_method', 'cash');
        $customerPhone = $request->input('customer_phone', null);
        $redeemPoints = $request->input('redeem_points', 0);
        $idempotencyKey = $request->input('idempotency_key');

        if (empty($items)) {
            return response()->json(['success' => false, 'message' => 'Cart is empty'], 400);
        }

        // Idempotency Check (Offline Sync Protection)
        if ($idempotencyKey) {
            $existingTx = \App\Models\Transaction::where('business_id', $businessId)
                ->where('idempotency_key', $idempotencyKey)
                ->first();
                
            if ($existingTx) {
                return response()->json([
                    'success' => true,
                    'message' => 'Transaksi sudah pernah diproses sebelumnya (Idempotent).',
                    'data' => $existingTx
                ]);
            }
        }

        try {
            $transaction = $this->transactionService->processPosTransaction($businessId, $items, $paymentMethod, $customerPhone, $redeemPoints, $idempotencyKey);

            return response()->json([
                'success' => true,
                'message' => 'Transaksi berhasil diproses. Saldo dipotong Rp500.',
                'data' => $transaction
            ]);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Gagal memproses transaksi: ' . $e->getMessage()], 500);
        }
    }

    public function acceptPendingOrder(Request $request, $id)
    {
        $user = $request->user();
        $businessId = $user ? $user->business_id : 1; 

        try {
            $transaction = $this->transactionService->acceptPendingOrder($businessId, $id);

            return response()->json([
                'success' => true,
                'message' => 'Pesanan diterima. Saldo dipotong Rp500.',
                'data' => $transaction
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 400);
        }
    }

    public function getPendingOrders(Request $request)
    {
        $user = $request->user();
        $businessId = $user ? $user->business_id : 1; 

        $pendingOrders = \App\Models\Transaction::where('business_id', $businessId)
            ->where('status', 'pending')
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $pendingOrders
        ]);
    }
}
