<?php

namespace App\Http\Controllers\Api\Public;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PublicBookingController extends Controller
{
    /**
     * Pelanggan membuat reservasi online
     */
    public function makeBooking(Request $request, $slug)
    {
        $business = DB::table('businesses')->where('slug', $slug)->first();
        if (!$business) {
            return response()->json(['success' => false, 'message' => 'Toko tidak ditemukan'], 404);
        }

        $request->validate([
            'customer_name' => 'required|string|max:255',
            'customer_phone' => 'required|string|max:20',
            'booking_date' => 'required|date',
            'booking_time' => 'required'
        ]);

        $id = DB::table('bookings')->insertGetId([
            'business_id' => $business->id,
            'customer_name' => $request->customer_name,
            'customer_phone' => $request->customer_phone,
            'booking_date' => $request->booking_date,
            'booking_time' => $request->booking_time,
            'status' => 'pending',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Reservasi berhasil dibuat. Menunggu konfirmasi toko.',
            'data' => [
                'id' => $id,
                'customer_name' => $request->customer_name,
                'booking_date' => $request->booking_date,
                'booking_time' => $request->booking_time
            ]
        ]);
    }
}
