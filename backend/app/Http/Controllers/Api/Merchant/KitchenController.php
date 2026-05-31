<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Transaction;

class KitchenController extends Controller
{
    public function getOrders(Request $request)
    {
        $user = $request->user();
        
        $orders = Transaction::where('business_id', $user->business_id)
            ->where('status', 'paid')
            ->whereIn('kitchen_status', ['pending', 'cooking', 'ready'])
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $orders
        ]);
    }

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'kitchen_status' => 'required|in:pending,cooking,ready,served'
        ]);

        $user = $request->user();
        
        $order = Transaction::where('business_id', $user->business_id)
            ->findOrFail($id);

        $order->kitchen_status = $request->kitchen_status;
        $order->save();

        // Broadcast to KDS via pusher/reverb
        broadcast(new \App\Events\KitchenStatusUpdated($order))->toOthers();

        return response()->json([
            'success' => true,
            'message' => 'Status dapur diperbarui.',
            'data' => $order
        ]);
    }
}
