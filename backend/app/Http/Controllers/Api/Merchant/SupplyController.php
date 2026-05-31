<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Supplier;
use App\Models\PurchaseOrder;
use App\Models\PurchaseOrderItem;
use App\Models\Ingredient;
use Illuminate\Support\Facades\DB;

class SupplyController extends Controller
{
    public function getSuppliers(Request $request)
    {
        $suppliers = Supplier::where('business_id', $request->user()->business_id)->get();
        return response()->json(['success' => true, 'data' => $suppliers]);
    }

    public function createSupplier(Request $request)
    {
        $request->validate(['name' => 'required']);
        $supplier = Supplier::create([
            'business_id' => $request->user()->business_id,
            'name' => $request->name,
            'contact' => $request->contact,
            'address' => $request->address,
        ]);
        return response()->json(['success' => true, 'data' => $supplier]);
    }

    public function getPurchaseOrders(Request $request)
    {
        $pos = PurchaseOrder::with(['supplier', 'items.ingredient'])
            ->where('business_id', $request->user()->business_id)
            ->orderBy('created_at', 'desc')
            ->get();
        return response()->json(['success' => true, 'data' => $pos]);
    }

    public function createPurchaseOrder(Request $request)
    {
        $request->validate([
            'supplier_id' => 'required|exists:suppliers,id',
            'items' => 'required|array|min:1',
            'items.*.ingredient_id' => 'required|exists:ingredients,id',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.unit_price' => 'required|numeric|min:0',
        ]);

        return DB::transaction(function () use ($request) {
            $businessId = $request->user()->business_id;
            
            $po = PurchaseOrder::create([
                'po_number' => 'PO-' . time() . rand(10, 99),
                'business_id' => $businessId,
                'supplier_id' => $request->supplier_id,
                'status' => 'pending',
                'total_amount' => 0
            ]);

            $total = 0;
            foreach ($request->items as $item) {
                $subtotal = $item['quantity'] * $item['unit_price'];
                $total += $subtotal;

                PurchaseOrderItem::create([
                    'purchase_order_id' => $po->id,
                    'ingredient_id' => $item['ingredient_id'],
                    'quantity' => $item['quantity'],
                    'unit_price' => $item['unit_price'],
                    'subtotal' => $subtotal,
                ]);
            }

            $po->total_amount = $total;
            $po->save();

            return response()->json(['success' => true, 'data' => $po->load('items')]);
        });
    }

    public function markAsReceived(Request $request, $id)
    {
        return DB::transaction(function () use ($request, $id) {
            $businessId = $request->user()->business_id;
            
            $po = PurchaseOrder::where('business_id', $businessId)
                ->where('id', $id)
                ->lockForUpdate()
                ->firstOrFail();

            if ($po->status === 'received') {
                return response()->json(['success' => false, 'message' => 'PO sudah diterima sebelumnya'], 400);
            }

            // SUPER LOGIC: Inject to Inventory
            $items = PurchaseOrderItem::where('purchase_order_id', $po->id)->get();
            foreach ($items as $item) {
                $ingredient = Ingredient::where('id', $item->ingredient_id)
                    ->where('business_id', $businessId)
                    ->lockForUpdate()
                    ->first();
                
                if ($ingredient) {
                    $ingredient->current_stock += $item->quantity;
                    $ingredient->save();
                }
            }

            $po->status = 'received';
            $po->save();

            return response()->json(['success' => true, 'message' => 'Barang diterima dan stok gudang berhasil ditambahkan!', 'data' => $po]);
        });
    }
}
