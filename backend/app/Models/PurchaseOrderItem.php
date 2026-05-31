<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PurchaseOrderItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'purchase_order_id',
        'ingredient_id',
        'quantity',
        'unit_price',
        'subtotal',
    ];

    public function ingredient()
    {
        return $this->belongsTo(Ingredient::class);
    }
}
