<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Business;
use App\Models\Subscription;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class PlatformAdminController extends Controller
{
    public function getDashboard(Request $request)
    {
        $totalMerchants = Business::count();
        $totalRevenue = Subscription::sum('price');
        $activeSubscriptions = Subscription::where('status', 'active')->count();

        return response()->json([
            'success' => true,
            'data' => [
                'total_merchants' => $totalMerchants,
                'total_saas_revenue' => $totalRevenue,
                'active_subscriptions' => $activeSubscriptions,
            ]
        ]);
    }

    public function getMerchants(Request $request)
    {
        $businesses = Business::with('owner')->get();
        
        $businessesData = $businesses->map(function ($business) {
            $subscription = Subscription::where('business_id', $business->id)->first();
            return [
                'id' => $business->id,
                'name' => $business->name,
                'owner_name' => $business->owner ? $business->owner->name : 'Unknown',
                'subscription_status' => $subscription ? $subscription->status : 'none',
                'valid_until' => $subscription ? $subscription->valid_until : null,
            ];
        });

        return response()->json(['success' => true, 'data' => $businessesData]);
    }

    public function renewSubscription(Request $request, $businessId)
    {
        return DB::transaction(function () use ($businessId) {
            $business = Business::findOrFail($businessId);
            $subscription = Subscription::firstOrNew(['business_id' => $business->id]);

            $subscription->plan_name = 'Premium';
            $subscription->price = 300000;
            // Extend by 30 days from now or from valid_until
            $currentValid = $subscription->valid_until ? Carbon::parse($subscription->valid_until) : Carbon::now();
            $subscription->valid_until = $currentValid->isFuture() ? $currentValid->addDays(30) : Carbon::now()->addDays(30);
            $subscription->status = 'active';
            $subscription->save();

            return response()->json(['success' => true, 'message' => 'Subscription berhasil diperpanjang', 'data' => $subscription]);
        });
    }

    public function lockSubscription(Request $request, $businessId)
    {
        return DB::transaction(function () use ($businessId) {
            $subscription = Subscription::where('business_id', $businessId)->firstOrFail();
            $subscription->status = 'expired';
            $subscription->save();

            return response()->json(['success' => true, 'message' => 'Aplikasi merchant berhasil dikunci (Expired)']);
        });
    }
}
