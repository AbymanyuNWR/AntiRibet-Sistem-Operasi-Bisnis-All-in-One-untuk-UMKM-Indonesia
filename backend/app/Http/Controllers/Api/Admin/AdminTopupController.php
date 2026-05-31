<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class AdminTopupController extends Controller
{
    /**
     * Get all pending topups.
     * Note: In a real app, you would add admin middleware.
     */
    public function index()
    {
        $topups = DB::table('topups')
            ->join('businesses', 'topups.business_id', '=', 'businesses.id')
            ->select('topups.*', 'businesses.name as business_name')
            ->orderBy('topups.created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $topups
        ]);
    }

    /**
     * Approve a topup request.
     */
    public function approve($id)
    {
        try {
            DB::beginTransaction();

            // Lock topup to prevent double approval
            $topup = DB::table('topups')->where('id', $id)->lockForUpdate()->first();

            if (!$topup) {
                DB::rollBack();
                return response()->json(['success' => false, 'message' => 'Top Up tidak ditemukan'], 404);
            }

            if ($topup->status !== 'pending') {
                DB::rollBack();
                return response()->json(['success' => false, 'message' => 'Top Up sudah diproses sebelumnya'], 400);
            }

            // Get and lock wallet
            $wallet = DB::table('merchant_wallets')
                ->where('business_id', $topup->business_id)
                ->lockForUpdate()
                ->first();

            if (!$wallet) {
                DB::rollBack();
                return response()->json(['success' => false, 'message' => 'Wallet merchant tidak ditemukan'], 404);
            }

            $newBalance = $wallet->balance + $topup->amount;

            // Update wallet balance
            DB::table('merchant_wallets')
                ->where('id', $wallet->id)
                ->update(['balance' => $newBalance, 'updated_at' => Carbon::now()]);

            // Insert wallet transaction
            DB::table('wallet_transactions')->insert([
                'merchant_wallet_id' => $wallet->id,
                'business_id' => $topup->business_id,
                'type' => 'credit',
                'amount' => $topup->amount,
                'balance_before' => $wallet->balance,
                'balance_after' => $newBalance,
                'reference_type' => 'topup',
                'reference_id' => $topup->id,
                'description' => 'Top Up Saldo Berhasil disetujui Admin',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ]);

            // Update topup status
            DB::table('topups')->where('id', $id)->update([
                'status' => 'approved',
                'approved_at' => Carbon::now(),
                // 'approved_by' => auth()->id(), // For real implementation
                'updated_at' => Carbon::now(),
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Top Up berhasil disetujui. Saldo merchant bertambah Rp ' . $topup->amount
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Admin Approve Topup Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Gagal menyetujui top up'], 500);
        }
    }
}
