<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MerchantWallet extends Model
{
    protected $fillable = ['business_id', 'balance'];

    public function business() { return $this->belongsTo(Business::class); }
    public function walletTransactions() { return $this->hasMany(WalletTransaction::class); }
}
