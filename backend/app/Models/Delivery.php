<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Delivery extends Model
{
    use HasFactory;

    protected $fillable = [
        'business_id',
        'transaction_id',
        'driver_id',
        'status',
        'delivery_address',
        'assigned_at',
        'delivered_at',
    ];

    public function transaction()
    {
        return $this->belongsTo(Transaction::class);
    }

    public function driver()
    {
        return $this->belongsTo(User::class, 'driver_id');
    }
}
