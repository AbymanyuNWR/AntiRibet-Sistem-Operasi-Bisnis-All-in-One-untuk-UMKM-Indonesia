<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BookingController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        if (!$user->business_id) return response()->json(['success' => false, 'message' => 'No business linked'], 400);

        $bookings = DB::table('bookings')
            ->where('business_id', $user->business_id)
            ->orderBy('booking_time', 'asc')
            ->get();

        return response()->json(['success' => true, 'data' => $bookings]);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        
        $id = DB::table('bookings')->insertGetId([
            'business_id' => $user->business_id,
            'customer_name' => $request->customer_name,
            'customer_phone' => $request->customer_phone,
            'booking_time' => $request->booking_time,
            'service_name' => $request->service_name,
            'price' => $request->price ?? 0,
            'status' => 'pending',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json(['success' => true, 'data' => ['id' => $id]]);
    }

    public function updateStatus(Request $request, $id)
    {
        $user = $request->user();
        
        $booking = DB::table('bookings')->where('id', $id)->where('business_id', $user->business_id)->first();
        if (!$booking) return response()->json(['success' => false], 404);

        $status = $request->status; // confirmed, completed, cancelled

        // Jika selesai, potong saldo wallet
        if ($status == 'completed' && $booking->status != 'completed') {
            $wallet = DB::table('merchant_wallets')->where('business_id', $user->business_id)->first();
            if (!$wallet || $wallet->balance < 500) {
                return response()->json(['success' => false, 'message' => 'Saldo tidak cukup untuk menyelesaikan booking.'], 400);
            }

            // Potong saldo
            DB::table('merchant_wallets')->where('id', $wallet->id)->decrement('balance', 500);
            DB::table('platform_fees')->insert([
                'business_id' => $user->business_id,
                'source_type' => 'booking',
                'source_id' => $id,
                'fee_amount' => 500,
                'status' => 'charged',
                'created_at' => now()
            ]);
        }

        DB::table('bookings')->where('id', $id)->update(['status' => $status, 'updated_at' => now()]);
        return response()->json(['success' => true, 'message' => 'Status updated']);
    }
}
