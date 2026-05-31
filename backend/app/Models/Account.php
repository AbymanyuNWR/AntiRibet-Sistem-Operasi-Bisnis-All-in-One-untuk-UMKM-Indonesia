<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Account extends Model
{
    use HasFactory;

    protected $fillable = [
        'business_id',
        'account_code',
        'name',
        'type', // asset, liability, equity, revenue, expense
    ];
}
