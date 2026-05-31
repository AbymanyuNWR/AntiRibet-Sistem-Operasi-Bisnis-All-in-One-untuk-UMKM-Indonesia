<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Hash;

class StaffService
{
    public function getStaffByBusiness(int $businessId)
    {
        return User::where('business_id', $businessId)
            ->where('role', 'merchant_staff')
            ->get();
    }

    public function createStaff(int $businessId, array $data)
    {
        return User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'role' => 'merchant_staff',
            'business_id' => $businessId,
        ]);
    }

    public function deleteStaff(int $businessId, int $staffId)
    {
        $staff = User::where('id', $staffId)->where('business_id', $businessId)->first();
        if ($staff) {
            $staff->delete();
            return true;
        }
        return false;
    }
}
