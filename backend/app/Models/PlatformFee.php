<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PlatformFee extends Model
{
    protected $fillable = ['business_id', 'transaction_id', 'amount'];

    public function business() { return $this->belongsTo(Business::class); }
    public function transaction() { return $this->belongsTo(Transaction::class); }
}
