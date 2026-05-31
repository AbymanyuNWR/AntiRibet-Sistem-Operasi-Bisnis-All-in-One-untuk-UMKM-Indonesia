<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Ingredient;

class InventoryController extends Controller
{
    public function index(Request $request)
    {
        $businessId = $request->user()->business_id;
        $ingredients = Ingredient::where('business_id', $businessId)->get();
        
        return response()->json([
            'success' => true,
            'data' => $ingredients
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'unit' => 'required|string',
            'current_stock' => 'required|numeric',
            'minimum_stock' => 'required|numeric',
        ]);

        $ingredient = Ingredient::create([
            'business_id' => $request->user()->business_id,
            'name' => $request->name,
            'unit' => $request->unit,
            'current_stock' => $request->current_stock,
            'minimum_stock' => $request->minimum_stock,
        ]);

        return response()->json([
            'success' => true,
            'data' => $ingredient,
            'message' => 'Bahan baku berhasil ditambahkan'
        ]);
    }

    public function restock(Request $request, $id)
    {
        $request->validate([
            'add_stock' => 'required|numeric|min:0.1'
        ]);

        $ingredient = Ingredient::where('business_id', $request->user()->business_id)->findOrFail($id);
        $ingredient->current_stock += $request->add_stock;
        $ingredient->save();

        return response()->json([
            'success' => true,
            'message' => 'Stok berhasil diperbarui',
            'data' => $ingredient
        ]);
    }
}
