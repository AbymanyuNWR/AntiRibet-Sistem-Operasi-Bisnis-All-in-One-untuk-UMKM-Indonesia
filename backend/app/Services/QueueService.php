<?php

namespace App\Services;

use App\Models\Queue;
use App\Models\Transaction;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;
use Exception;

class QueueService
{
    /**
     * Generate nomor antrean berikutnya secara aman (locking).
     * Format: A-001, A-002, dst (reset setiap hari).
     */
    public function generateQueueNumber(int $businessId, int $transactionId, string $prefix = 'A'): Queue
    {
        $today = Carbon::today()->toDateString();

        return DB::transaction(function () use ($businessId, $transactionId, $prefix, $today) {
            // Lock baris terakhir antrean untuk toko ini hari ini
            $latestQueue = Queue::where('business_id', $businessId)
                ->where('queue_date', $today)
                ->lockForUpdate()
                ->orderBy('id', 'desc')
                ->first();

            $nextNumber = 1;
            if ($latestQueue) {
                // Ekstrak angka dari format "A-001"
                $parts = explode('-', $latestQueue->queue_number);
                if (count($parts) === 2) {
                    $nextNumber = intval($parts[1]) + 1;
                }
            }

            $queueString = $prefix . '-' . str_pad($nextNumber, 3, '0', STR_PAD_LEFT);

            // Simpan ke database
            return Queue::create([
                'business_id' => $businessId,
                'transaction_id' => $transactionId,
                'queue_number' => $queueString,
                'queue_date' => $today,
                'status' => 'waiting',
            ]);
        });
    }
}
