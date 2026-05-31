<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    protected $fillable = [
        'business_id', 'transaction_number', 'total_amount', 'status', 
        'payment_method', 'idempotency_key', 'table_number', 'items',
        'customer_id', 'points_earned', 'points_redeemed', 'kitchen_status'
    ];

    protected $casts = [
        'items' => 'array'
    ];

    public function business() { return $this->belongsTo(Business::class); }
    public function platformFee()
    {
        return $this->hasOne(PlatformFee::class);
    }

    public function delivery()
    {
        return $this->hasOne(Delivery::class);
    }
}
