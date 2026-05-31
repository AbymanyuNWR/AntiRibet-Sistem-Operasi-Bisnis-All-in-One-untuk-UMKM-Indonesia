<?php

namespace App\Http\Controllers\Api\Public;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Business;
use App\Models\CatalogItem;

class PublicBusinessController extends Controller
{
    /**
     * Get detail bisnis berdasarkan slug untuk Mini Website Flutter.
     */
    public function show($slug)
    {
        $business = Business::where('slug', $slug)->first();

        if (!$business) {
            return response()->json([
                'success' => false,
                'message' => 'Toko tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $business
        ]);
    }

    /**
     * Get katalog menu untuk bisnis tersebut.
     */
    public function catalog($slug)
    {
        $business = Business::where('slug', $slug)->first();

        if (!$business) {
            return response()->json(['success' => false, 'message' => 'Toko tidak ditemukan'], 404);
        }

        $catalog = CatalogItem::where('business_id', $business->id)
            ->where('is_available', true)
            ->orderBy('category_id')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $catalog
        ]);
    }
}
