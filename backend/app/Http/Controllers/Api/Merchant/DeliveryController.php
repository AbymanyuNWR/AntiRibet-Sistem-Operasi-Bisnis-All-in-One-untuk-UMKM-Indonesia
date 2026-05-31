<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Delivery;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class DeliveryController extends Controller
{
    public function getDrivers(Request $request)
    {
        $drivers = User::where('business_id', $request->user()->business_id)
            ->where('role', 'driver')
            ->get();
        return response()->json(['success' => true, 'data' => $drivers]);
    }

    public function getDeliveries(Request $request)
    {
        $user = $request->user();
        $query = Delivery::with(['transaction', 'driver'])
            ->where('business_id', $user->business_id);

        if ($user->role === 'driver') {
            $query->where('driver_id', $user->id);
        }

        $deliveries = $query->orderBy('created_at', 'desc')->get();
        return response()->json(['success' => true, 'data' => $deliveries]);
    }

    public function getPendingTransactions(Request $request)
    {
        $businessId = $request->user()->business_id;
        // Ambil transaksi yang tipe-nya belum ada di deliveries, asumsi status paid (siap antar)
        $transactions = Transaction::where('business_id', $businessId)
            ->where('status', 'paid')
            ->whereDoesntHave('delivery')
            ->get();
        return response()->json(['success' => true, 'data' => $transactions]);
    }

    public function assignDriver(Request $request)
    {
        $request->validate([
            'transaction_id' => 'required|exists:transactions,id',
            'driver_id' => 'required|exists:users,id',
            'delivery_address' => 'required|string',
        ]);

        $delivery = Delivery::create([
            'business_id' => $request->user()->business_id,
            'transaction_id' => $request->transaction_id,
            'driver_id' => $request->driver_id,
            'status' => 'assigned',
            'delivery_address' => $request->delivery_address,
            'assigned_at' => now()
        ]);

        return response()->json(['success' => true, 'message' => 'Kurir berhasil di-assign', 'data' => $delivery]);
    }

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:on_the_way,delivered'
        ]);

        return DB::transaction(function () use ($request, $id) {
            $delivery = Delivery::where('business_id', $request->user()->business_id)
                ->where('id', $id)
                ->lockForUpdate()
                ->firstOrFail();

            $delivery->status = $request->status;

            if ($request->status === 'delivered') {
                $delivery->delivered_at = now();
                
                // Update status transaksi
                $transaction = Transaction::find($delivery->transaction_id);
                if ($transaction) {
                    $transaction->status = 'completed'; // Atau biarkan paid, tapi tandai selesai
                    $transaction->save();
                }
            }

            $delivery->save();

            return response()->json(['success' => true, 'message' => 'Status pengiriman diupdate', 'data' => $delivery]);
        });
    }
}
