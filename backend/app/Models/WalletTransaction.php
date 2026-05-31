<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class WalletTransaction extends Model
{
    protected $fillable = ['merchant_wallet_id', 'type', 'amount', 'reference_id', 'description'];

    public function wallet() { return $this->belongsTo(MerchantWallet::class, 'merchant_wallet_id'); }
}
