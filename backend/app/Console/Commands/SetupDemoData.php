<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class SetupDemoData extends Command
{
    protected $signature = 'demo:setup';
    protected $description = 'Setup demo business and seed sample data for testing';

    public function handle()
    {
        $this->info('Setting up demo data...');

        // 1. Cek / buat business
        $business = DB::table('businesses')->first();
        if (!$business) {
            $bizId = DB::table('businesses')->insertGetId([
                'name' => 'AntiRibet Demo Cafe',
                'slug' => 'antiribet-demo',
                'owner_id' => 1,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            $this->info("Business created: ID $bizId");
        } else {
            $bizId = $business->id;
            $this->info("Using existing business: ID $bizId ({$business->name})");
        }

        // 2. Link semua user yang belum punya business_id
        $updated = DB::table('users')
            ->whereNull('business_id')
            ->update(['business_id' => $bizId]);
        $this->info("Linked $updated user(s) to business $bizId");

        // 3. Buat wallet jika belum ada
        $wallet = DB::table('merchant_wallets')->where('business_id', $bizId)->first();
        if (!$wallet) {
            DB::table('merchant_wallets')->insert([
                'business_id' => $bizId,
                'balance' => 500000,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            $this->info('Wallet created: Rp 500.000');
        } else {
            $this->info("Wallet exists: Rp {$wallet->balance}");
        }

        // 4. Seed sample catalog jika kosong
        $catalogCount = DB::table('catalog_items')->where('business_id', $bizId)->count();
        if ($catalogCount === 0) {
            $items = [
                ['name' => 'Nasi Goreng Spesial', 'description' => 'Nasi goreng dengan topping ayam dan telur', 'price' => 25000, 'category' => 'Makanan'],
                ['name' => 'Mie Ayam Bakso', 'description' => 'Mie ayam kuah dengan bakso sapi', 'price' => 22000, 'category' => 'Makanan'],
                ['name' => 'Ayam Bakar', 'description' => 'Ayam kampung bakar bumbu rempah', 'price' => 35000, 'category' => 'Makanan'],
                ['name' => 'Es Teh Manis', 'description' => 'Teh manis dingin segar', 'price' => 5000, 'category' => 'Minuman'],
                ['name' => 'Es Jeruk', 'description' => 'Jeruk peras segar dingin', 'price' => 8000, 'category' => 'Minuman'],
                ['name' => 'Kopi Hitam', 'description' => 'Kopi tubruk tradisional', 'price' => 7000, 'category' => 'Minuman'],
                ['name' => 'Pisang Goreng', 'description' => 'Pisang goreng tepung crispy', 'price' => 12000, 'category' => 'Snack'],
                ['name' => 'Tempe Mendoan', 'description' => 'Tempe mendoan bumbu kunyit', 'price' => 10000, 'category' => 'Snack'],
            ];

            foreach ($items as $item) {
                DB::table('catalog_items')->insert([
                    'business_id' => $bizId,
                    'name' => $item['name'],
                    'description' => $item['description'],
                    'price' => $item['price'],
                    'is_available' => true,
                    'category_id' => null,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
            $this->info('Sample catalog seeded: ' . count($items) . ' items');
        } else {
            $this->info("Catalog already has $catalogCount items");
        }

        // 5. Seed sample ingredients/inventory jika kosong
        $ingredientCount = DB::table('ingredients')->where('business_id', $bizId)->count();
        if ($ingredientCount === 0) {
            $ingredients = [
                ['name' => 'Beras', 'unit' => 'kg', 'stock' => 50, 'min_stock' => 10, 'unit_cost' => 12000],
                ['name' => 'Minyak Goreng', 'unit' => 'liter', 'stock' => 10, 'min_stock' => 3, 'unit_cost' => 15000],
                ['name' => 'Ayam Potong', 'unit' => 'kg', 'stock' => 15, 'min_stock' => 5, 'unit_cost' => 35000],
                ['name' => 'Telur Ayam', 'unit' => 'butir', 'stock' => 100, 'min_stock' => 20, 'unit_cost' => 2000],
                ['name' => 'Tepung Terigu', 'unit' => 'kg', 'stock' => 20, 'min_stock' => 5, 'unit_cost' => 8000],
                ['name' => 'Gula Pasir', 'unit' => 'kg', 'stock' => 10, 'min_stock' => 2, 'unit_cost' => 14000],
                ['name' => 'Teh Celup', 'unit' => 'kotak', 'stock' => 5, 'min_stock' => 1, 'unit_cost' => 15000],
                ['name' => 'Pisang Ambon', 'unit' => 'sisir', 'stock' => 8, 'min_stock' => 2, 'unit_cost' => 25000],
            ];

            foreach ($ingredients as $ing) {
                DB::table('ingredients')->insert([
                    'business_id' => $bizId,
                    'name' => $ing['name'],
                    'unit' => $ing['unit'],
                    'stock' => $ing['stock'],
                    'min_stock' => $ing['min_stock'],
                    'unit_cost' => $ing['unit_cost'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
            $this->info('Sample inventory seeded: ' . count($ingredients) . ' ingredients');
        } else {
            $this->info("Inventory already has $ingredientCount ingredients");
        }

        // 6. Seed sample customers (for CRM)
        $customerCount = DB::table('customers')->where('business_id', $bizId)->count();
        if ($customerCount === 0) {
            DB::table('customers')->insert([
                ['business_id' => $bizId, 'name' => 'Budi Santoso', 'phone' => '08123456789', 'total_visits' => 12, 'total_spent' => 350000, 'loyalty_points' => 350, 'created_at' => now(), 'updated_at' => now()],
                ['business_id' => $bizId, 'name' => 'Siti Rahayu', 'phone' => '08234567890', 'total_visits' => 5, 'total_spent' => 145000, 'loyalty_points' => 145, 'created_at' => now(), 'updated_at' => now()],
                ['business_id' => $bizId, 'name' => 'Ahmad Fauzi', 'phone' => '08345678901', 'total_visits' => 20, 'total_spent' => 620000, 'loyalty_points' => 620, 'created_at' => now(), 'updated_at' => now()],
            ]);
            $this->info('Sample customers seeded: 3 customers');
        } else {
            $this->info("CRM already has $customerCount customers");
        }

        $this->line('');
        $this->info('=== SETUP COMPLETE ===');
        $this->info("Business ID: $bizId");
        $this->info('Login: admin@antiribet.com / password123');
        $this->line('');
    }
}
