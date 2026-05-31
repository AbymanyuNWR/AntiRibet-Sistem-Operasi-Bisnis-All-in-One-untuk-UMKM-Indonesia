<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class StockTransfer extends Model
{
    use HasFactory;

    protected $fillable = [
        'business_id',
        'from_outlet_id',
        'to_outlet_id',
        'ingredient_id',
        'quantity',
        'status',
    ];

    public function fromOutlet()
    {
        return $this->belongsTo(Outlet::class, 'from_outlet_id');
    }

    public function toOutlet()
    {
        return $this->belongsTo(Outlet::class, 'to_outlet_id');
    }

    public function ingredient()
    {
        return $this->belongsTo(Ingredient::class);
    }
}
