<?php

namespace App\Services;

use App\Models\Booking;
use Exception;

class BookingService
{
    protected WalletService $walletService;

    public function __construct(WalletService $walletService)
    {
        $this->walletService = $walletService;
    }

    public function createBooking(int $businessId, array $data)
    {
        return Booking::create([
            'business_id' => $businessId,
            'customer_name' => $data['customer_name'],
            'customer_phone' => $data['customer_phone'] ?? null,
            'booking_date' => $data['booking_date'],
            'booking_time' => $data['booking_time'],
            'guest_count' => $data['guest_count'] ?? 1,
            'status' => 'pending',
        ]);
    }

    public function completeBooking(int $businessId, int $bookingId)
    {
        $booking = Booking::where('id', $bookingId)->where('business_id', $businessId)->first();
        if (!$booking) {
            throw new Exception("Booking not found");
        }

        if ($booking->status === 'completed') {
            return $booking; // Already completed
        }

        $booking->status = 'completed';
        $booking->save();

        // Deduct platform fee for successful booking
        $this->walletService->deductFee($businessId, null); // passing null for transaction_id as it's a booking

        return $booking;
    }
}
