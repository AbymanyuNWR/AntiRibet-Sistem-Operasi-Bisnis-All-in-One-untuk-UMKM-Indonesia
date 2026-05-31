<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Customer extends Model
{
    protected $fillable = ['business_id', 'name', 'phone', 'email', 'total_spent', 'last_visit', 'points'];
    
    protected $casts = [
        'total_spent' => 'decimal:2',
        'last_visit' => 'datetime',
    ];

    public function business()
    {
        return $this->belongsTo(Business::class);
    }
}
