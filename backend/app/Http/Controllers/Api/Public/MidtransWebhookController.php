<?php

namespace App\Http\Controllers\Api\Public;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\MidtransService;
use Exception;
use Illuminate\Support\Facades\Log;

class MidtransWebhookController extends Controller
{
    protected MidtransService $midtransService;

    public function __construct(MidtransService $midtransService)
    {
        $this->midtransService = $midtransService;
    }

    /**
     * Endpoint untuk menerima webhook dari Midtrans
     */
    public function handle(Request $request)
    {
        try {
            $payload = $request->all();
            
            // Log payload untuk debugging
            Log::info('Midtrans Webhook Received', $payload);

            $this->midtransService->handleNotification($payload);

            return response()->json(['success' => true]);
        } catch (Exception $e) {
            Log::error('Midtrans Webhook Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }
}
