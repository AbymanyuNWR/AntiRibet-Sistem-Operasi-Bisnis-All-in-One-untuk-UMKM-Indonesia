<?php

namespace App\Services;

use App\Models\User;
use App\Models\Business;
use App\Models\MerchantWallet;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Exception;
use Illuminate\Support\Str;

class AuthService
{
    public function registerMerchant(array $data)
    {
        try {
            DB::beginTransaction();

            $business = Business::create([
                'name' => $data['business_name'],
                'slug' => Str::slug($data['business_name']) . '-' . rand(100, 999),
            ]);

            MerchantWallet::create([
                'business_id' => $business->id,
                'balance' => 0
            ]);

            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
                'business_id' => $business->id
            ]);

            $token = $user->createToken('merchant-token')->plainTextToken;

            DB::commit();
            
            return [
                'user' => $user,
                'business' => $business,
                'token' => $token
            ];

        } catch (Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }
}
