<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Customer;

class CrmController extends Controller
{
    public function getLeaderboard(Request $request)
    {
        $businessId = $request->user()->business_id;

        $customers = Customer::where('business_id', $businessId)
            ->orderBy('points', 'desc')
            ->orderBy('total_spent', 'desc')
            ->take(50)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $customers
        ]);
    }
}
