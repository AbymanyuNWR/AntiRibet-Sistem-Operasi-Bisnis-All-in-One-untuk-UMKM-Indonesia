<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Business extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'slug', 'description', 'logo_url'];

    public function users() { return $this->hasMany(User::class); }
    public function wallet() { return $this->hasOne(MerchantWallet::class); }
    public function transactions() { return $this->hasMany(Transaction::class); }
    public function catalogCategories() { return $this->hasMany(CatalogCategory::class); }
    public function catalogItems() { return $this->hasMany(CatalogItem::class); }
    public function bookings() { return $this->hasMany(Booking::class); }
    public function queues() { return $this->hasMany(Queue::class); }
}
