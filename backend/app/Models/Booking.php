<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    protected $fillable = ['business_id', 'customer_name', 'customer_phone', 'booking_date', 'booking_time', 'guest_count', 'table_number', 'status'];

    public function business() { return $this->belongsTo(Business::class); }
}
