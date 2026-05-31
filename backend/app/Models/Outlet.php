<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Outlet extends Model
{
    use HasFactory;

    protected $fillable = [
        'business_id',
        'name',
        'address',
    ];

    public function business()
    {
        return $this->belongsTo(Business::class);
    }
}
