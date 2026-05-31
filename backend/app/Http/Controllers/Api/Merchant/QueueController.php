<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class QueueController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        if (!$user->business_id) return response()->json(['success' => false], 400);

        $queues = DB::table('queues')
            ->where('business_id', $user->business_id)
            ->whereIn('status', ['waiting', 'calling', 'serving'])
            ->orderBy('id', 'asc')
            ->get();

        return response()->json(['success' => true, 'data' => $queues]);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        
        // Auto increment queue number
        $lastQueue = DB::table('queues')
            ->where('business_id', $user->business_id)
            ->whereDate('created_at', today())
            ->orderBy('id', 'desc')
            ->first();
            
        $nextNum = $lastQueue ? intval($lastQueue->queue_number) + 1 : 1;
        $queueNumber = str_pad($nextNum, 3, '0', STR_PAD_LEFT);

        $id = DB::table('queues')->insertGetId([
            'business_id' => $user->business_id,
            'queue_number' => $queueNumber,
            'customer_name' => $request->customer_name ?? 'Pelanggan',
            'status' => 'waiting',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json(['success' => true, 'data' => ['id' => $id, 'queue_number' => $queueNumber]]);
    }

    public function updateStatus(Request $request, $id)
    {
        $user = $request->user();
        $status = $request->status; // calling, serving, completed, skipped

        $queue = DB::table('queues')->where('id', $id)->where('business_id', $user->business_id)->first();
        if (!$queue) return response()->json(['success' => false], 404);

        if ($status == 'completed' && $queue->status != 'completed') {
            $wallet = DB::table('merchant_wallets')->where('business_id', $user->business_id)->first();
            if (!$wallet || $wallet->balance < 500) {
                return response()->json(['success' => false, 'message' => 'Saldo tidak cukup untuk menyelesaikan antrean.'], 400);
            }

            DB::table('merchant_wallets')->where('id', $wallet->id)->decrement('balance', 500);
            DB::table('platform_fees')->insert([
                'business_id' => $user->business_id,
                'source_type' => 'queue',
                'source_id' => $id,
                'fee_amount' => 500,
                'status' => 'charged',
                'created_at' => now()
            ]);
        }

        DB::table('queues')->where('id', $id)->update(['status' => $status, 'updated_at' => now()]);
        return response()->json(['success' => true, 'message' => 'Status updated']);
    }
}
