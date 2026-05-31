<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Subscription extends Model
{
    use HasFactory;

    protected $fillable = [
        'business_id',
        'plan_name',
        'price',
        'valid_until',
        'status',
    ];

    public function business()
    {
        return $this->belongsTo(Business::class);
    }
}
