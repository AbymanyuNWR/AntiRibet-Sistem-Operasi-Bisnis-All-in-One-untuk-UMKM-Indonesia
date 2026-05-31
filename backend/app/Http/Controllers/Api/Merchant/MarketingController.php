<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Campaign;
use App\Models\Customer;
use Carbon\Carbon;

class MarketingController extends Controller
{
    public function index(Request $request)
    {
        $campaigns = Campaign::where('business_id', $request->user()->business_id)
            ->orderBy('created_at', 'desc')
            ->get();
        return response()->json(['success' => true, 'data' => $campaigns]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'target_audience' => 'required|in:all,sleeping,loyal',
            'message' => 'required|string',
            'discount_percentage' => 'nullable|numeric',
        ]);

        $campaign = Campaign::create([
            'business_id' => $request->user()->business_id,
            'name' => $request->name,
            'target_audience' => $request->target_audience,
            'message' => $request->message,
            'discount_percentage' => $request->discount_percentage ?? 0,
            'status' => 'draft',
        ]);

        return response()->json(['success' => true, 'data' => $campaign]);
    }

    public function broadcast(Request $request, $id)
    {
        $businessId = $request->user()->business_id;
        $campaign = Campaign::where('business_id', $businessId)->findOrFail($id);

        if ($campaign->status === 'broadcasted') {
            return response()->json(['success' => false, 'message' => 'Campaign ini sudah pernah dibroadcast.'], 400);
        }

        // Super Logic: Filter Target Audience
        $query = Customer::where('business_id', $businessId);

        if ($campaign->target_audience === 'sleeping') {
            // Pelanggan yang tidak berkunjung dalam 30 hari terakhir
            $query->where('last_visit', '<', Carbon::now()->subDays(30));
        } elseif ($campaign->target_audience === 'loyal') {
            // Pelanggan dengan poin >= 50
            $query->where('points', '>=', 50);
        }

        $customers = $query->get();
        $count = $customers->count();

        // Di sini seharusnya ada integrasi ke API WhatsApp (seperti Twilio, Watzap, Fonnte) atau Email (Mailgun, Sendgrid)
        // Kita simulasikan berhasil mengirim
        
        $campaign->status = 'broadcasted';
        $campaign->recipients_count = $count;
        $campaign->save();

        return response()->json([
            'success' => true, 
            'message' => "Berhasil mem-broadcast pesan ke $count pelanggan!",
            'data' => $campaign
        ]);
    }
}
