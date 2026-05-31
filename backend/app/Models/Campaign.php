<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Campaign extends Model
{
    use HasFactory;

    protected $fillable = [
        'business_id',
        'name',
        'target_audience',
        'message',
        'discount_percentage',
        'status',
        'recipients_count',
    ];

    public function business()
    {
        return $this->belongsTo(Business::class);
    }
}
