<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CatalogItem extends Model
{
    protected $fillable = ['business_id', 'category_id', 'name', 'description', 'price', 'image_url', 'is_available'];

    public function category() { return $this->belongsTo(CatalogCategory::class); }
    
    public function business()
    {
        return $this->belongsTo(Business::class);
    }

    public function recipeItems()
    {
        return $this->hasMany(RecipeItem::class);
    }
}
