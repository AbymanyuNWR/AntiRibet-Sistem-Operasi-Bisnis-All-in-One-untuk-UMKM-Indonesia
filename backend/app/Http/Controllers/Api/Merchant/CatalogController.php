<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\CatalogItem;

class CatalogController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $businessId = $user ? $user->business_id : 1; 

        $items = CatalogItem::where('business_id', $businessId)->get();

        return response()->json([
            'success' => true,
            'data' => $items,
        ]);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        if (!$user->business_id) return response()->json(['success' => false], 400);

        $item = CatalogItem::create([
            'business_id' => $user->business_id,
            'name' => $request->name,
            'description' => $request->description,
            'price' => $request->price,
            'category_id' => null, // MVP
            'image_url' => $request->image_url,
            'is_available' => $request->is_available ?? true,
        ]);

        if ($request->has('recipe_items') && is_array($request->recipe_items)) {
            foreach ($request->recipe_items as $recipe) {
                \App\Models\RecipeItem::create([
                    'catalog_item_id' => $item->id,
                    'ingredient_id' => $recipe['ingredient_id'],
                    'quantity_required' => $recipe['quantity_required']
                ]);
            }
        }

        return response()->json(['success' => true, 'data' => ['id' => $item->id]]);
    }

    public function update(Request $request, $id)
    {
        $user = $request->user();
        $item = CatalogItem::where('id', $id)->where('business_id', $user->business_id)->first();
        
        if (!$item) return response()->json(['success' => false], 404);

        $item->update([
            'name' => $request->name ?? $item->name,
            'description' => $request->description ?? $item->description,
            'price' => $request->price ?? $item->price,
            'is_available' => $request->has('is_available') ? $request->is_available : $item->is_available,
        ]);

        return response()->json(['success' => true]);
    }

    public function destroy(Request $request, $id)
    {
        $user = $request->user();
        CatalogItem::where('id', $id)->where('business_id', $user->business_id)->delete();
        
        return response()->json(['success' => true]);
    }
}
