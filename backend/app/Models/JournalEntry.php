<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class JournalEntry extends Model
{
    use HasFactory;

    protected $fillable = [
        'business_id',
        'reference_type',
        'reference_id',
        'description',
        'entry_date',
    ];

    public function lines()
    {
        return $this->hasMany(JournalLine::class);
    }
}
