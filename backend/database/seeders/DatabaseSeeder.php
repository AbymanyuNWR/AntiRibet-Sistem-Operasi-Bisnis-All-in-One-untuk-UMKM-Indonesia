<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $now = Carbon::now();

        // 1. Buat Super Admin
        DB::table('users')->insert([
            'name' => 'Admin Antiribet',
            'email' => 'admin@antiribet.com',
            'password' => Hash::make('password123'),
            'role' => 'superadmin',
            'created_at' => $now,
            'updated_at' => $now,
        ]);

        // 2. Buat Merchant / Business Dummy
        $businessId = DB::table('businesses')->insertGetId([
            'name' => 'Kopi Senja',
            'slug' => 'kopi-senja',
            'description' => 'Kedai kopi aesthetic terbaik di kota.',
            'created_at' => $now,
            'updated_at' => $now,
        ]);

        // 3. Buat Wallet Merchant dengan Saldo Awal Rp 50.000
        $walletId = DB::table('merchant_wallets')->insertGetId([
            'business_id' => $businessId,
            'balance' => 50000,
            'created_at' => $now,
            'updated_at' => $now,
        ]);
        DB::table('wallet_transactions')->insert([
            'merchant_wallet_id' => $walletId,
            'type' => 'credit',
            'amount' => 50000,
            'description' => 'Saldo awal dari Antiribet',
            'created_at' => $now,
            'updated_at' => $now,
        ]);

        // 4. Buat Akun Owner Merchant
        DB::table('users')->insert([
            'business_id' => $businessId,
            'name' => 'Budi Owner',
            'email' => 'owner@kopisenja.com',
            'password' => Hash::make('password123'),
            'role' => 'merchant_owner',
            'created_at' => $now,
            'updated_at' => $now,
        ]);

        // 5. Buat Katalog Menu (Kategori & Item)
        $categoryId = DB::table('catalog_categories')->insertGetId([
            'business_id' => $businessId,
            'name' => 'Minuman Favorit',
            'created_at' => $now,
            'updated_at' => $now,
        ]);

        DB::table('catalog_items')->insert([
            [
                'business_id' => $businessId,
                'category_id' => $categoryId,
                'name' => 'Kopi Susu Senja',
                'description' => 'Kopi susu gula aren khas racikan Kopi Senja.',
                'price' => 25000,
                'image_url' => null,
                'is_available' => true,
                'created_at' => $now,
                'updated_at' => $now,
            ],
            [
                'business_id' => $businessId,
                'category_id' => $categoryId,
                'name' => 'Americano',
                'description' => 'Espresso dengan tambahan air panas.',
                'price' => 20000,
                'image_url' => null,
                'is_available' => true,
                'created_at' => $now,
                'updated_at' => $now,
            ],
        ]);
    }
}
