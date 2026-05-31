<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\CashShift;
use Carbon\Carbon;

class ShiftController extends Controller
{
    public function current(Request $request)
    {
        $user = $request->user();
        
        $shift = CashShift::where('user_id', $user->id)
            ->where('business_id', $user->business_id)
            ->where('status', 'open')
            ->first();
            
        return response()->json([
            'success' => true,
            'data' => $shift
        ]);
    }

    public function open(Request $request)
    {
        $request->validate([
            'starting_cash' => 'required|numeric|min:0'
        ]);

        $user = $request->user();

        // Cek jika sudah ada shift yang open
        $existing = CashShift::where('user_id', $user->id)
            ->where('business_id', $user->business_id)
            ->where('status', 'open')
            ->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => 'Shift sudah terbuka.'
            ], 400);
        }

        $shift = CashShift::create([
            'business_id' => $user->business_id,
            'user_id' => $user->id,
            'opened_at' => now(),
            'starting_cash' => $request->starting_cash,
            'expected_cash' => $request->starting_cash,
            'status' => 'open'
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Shift berhasil dibuka.',
            'data' => $shift
        ]);
    }

    public function close(Request $request)
    {
        $request->validate([
            'actual_cash' => 'required|numeric|min:0'
        ]);

        $user = $request->user();

        $shift = CashShift::where('user_id', $user->id)
            ->where('business_id', $user->business_id)
            ->where('status', 'open')
            ->first();

        if (!$shift) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak ada shift aktif.'
            ], 404);
        }

        $actualCash = $request->actual_cash;
        $difference = $actualCash - $shift->expected_cash;

        $shift->update([
            'closed_at' => now(),
            'actual_cash' => $actualCash,
            'difference' => $difference,
            'status' => 'closed'
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Shift ditutup.',
            'data' => $shift
        ]);
    }
}
