<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use App\Models\Transaction;

class OrderUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public Transaction $transaction;
    public string $message;

    /**
     * Create a new event instance.
     */
    public function __construct(Transaction $transaction, string $message = 'Pesanan diupdate.')
    {
        $this->transaction = $transaction;
        $this->message = $message;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        // Broadcast ke channel spesifik transaksi (untuk customer)
        return [
            new Channel('order.' . $this->transaction->transaction_number),
        ];
    }
    
    /**
     * Data yang dibroadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'transaction_id' => $this->transaction->id,
            'transaction_number' => $this->transaction->transaction_number,
            'status' => $this->transaction->status,
            'message' => $this->message,
        ];
    }
}
