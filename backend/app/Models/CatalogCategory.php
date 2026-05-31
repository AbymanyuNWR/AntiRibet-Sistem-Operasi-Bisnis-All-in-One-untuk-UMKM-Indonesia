<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CatalogCategory extends Model
{
    protected $fillable = ['business_id', 'name'];

    public function business() { return $this->belongsTo(Business::class); }
    public function items() { return $this->hasMany(CatalogItem::class, 'category_id'); }
}
