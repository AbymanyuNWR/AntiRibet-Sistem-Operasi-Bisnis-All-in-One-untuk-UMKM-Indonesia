<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Queue extends Model
{
    protected $fillable = ['business_id', 'transaction_id', 'queue_number', 'queue_date', 'status'];

    public function business() { return $this->belongsTo(Business::class); }
    public function transaction() { return $this->belongsTo(Transaction::class); }
}
