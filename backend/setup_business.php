<?php
// Script: Setup business untuk admin@antiribet.com
require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
$app->boot();

use Illuminate\Support\Facades\DB;

try {
    // Cek apakah sudah ada business
    $existing = DB::table('businesses')->first();
    if ($existing) {
        // Link user ke business yang sudah ada
        DB::table('users')->where('id', 1)->update(['business_id' => $existing->id]);
        echo "Linked user to existing business ID: " . $existing->id . " (" . $existing->name . ")\n";
        
        // Juga tambahkan wallet jika belum ada
        $wallet = DB::table('merchant_wallets')->where('business_id', $existing->id)->first();
        if (!$wallet) {
            DB::table('merchant_wallets')->insert([
                'business_id' => $existing->id,
                'balance' => 500000,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            echo "Created wallet with Rp 500.000\n";
        } else {
            echo "Wallet already exists: Rp " . $wallet->balance . "\n";
        }
    } else {
        // Buat business baru
        $bizId = DB::table('businesses')->insertGetId([
            'name' => 'AntiRibet Demo Cafe',
            'slug' => 'antiribet-demo',
            'owner_id' => 1,
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
        
        // Link user ke business
        DB::table('users')->where('id', 1)->update(['business_id' => $bizId]);
        
        // Buat wallet
        DB::table('merchant_wallets')->insert([
            'business_id' => $bizId,
            'balance' => 500000,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
        
        echo "Created new business ID: $bizId\n";
        echo "Linked user and created wallet with Rp 500.000\n";
    }
    
    // Verifikasi
    $user = DB::table('users')->where('id', 1)->first();
    echo "User business_id is now: " . $user->business_id . "\n";
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
