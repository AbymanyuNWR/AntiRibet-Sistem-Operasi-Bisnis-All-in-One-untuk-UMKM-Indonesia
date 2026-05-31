<?php

namespace App\Http\Controllers\Api\Public;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PublicQueueController extends Controller
{
    /**
     * Pelanggan mengambil antrean online
     */
    public function takeQueue(Request $request, $slug)
    {
        $business = DB::table('businesses')->where('slug', $slug)->first();
        if (!$business) {
            return response()->json(['success' => false, 'message' => 'Toko tidak ditemukan'], 404);
        }

        $request->validate([
            'customer_name' => 'required|string|max:255'
        ]);

        // Hitung antrean hari ini
        $lastQueue = DB::table('queues')
            ->where('business_id', $business->id)
            ->whereDate('created_at', today())
            ->orderBy('id', 'desc')
            ->first();
            
        $nextNum = $lastQueue ? intval($lastQueue->queue_number) + 1 : 1;
        $queueNumber = str_pad($nextNum, 3, '0', STR_PAD_LEFT);

        $id = DB::table('queues')->insertGetId([
            'business_id' => $business->id,
            'queue_number' => $queueNumber,
            'customer_name' => $request->customer_name,
            'status' => 'waiting',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Antrean berhasil diambil',
            'data' => [
                'id' => $id,
                'queue_number' => $queueNumber,
                'customer_name' => $request->customer_name
            ]
        ]);
    }
}
