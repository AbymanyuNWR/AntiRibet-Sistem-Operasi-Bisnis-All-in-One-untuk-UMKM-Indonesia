<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\StaffService;

class StaffController extends Controller
{
    protected StaffService $staffService;

    public function __construct(StaffService $staffService)
    {
        $this->staffService = $staffService;
    }

    public function index(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'merchant_owner') {
            return response()->json(['success' => false, 'message' => 'Unauthorized. Hanya Owner yang bisa mengakses staff.'], 403);
        }

        $staff = $this->staffService->getStaffByBusiness($user->business_id);

        return response()->json([
            'success' => true,
            'data' => $staff
        ]);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'merchant_owner') {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'name' => 'required',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:6',
        ]);

        $staff = $this->staffService->createStaff($user->business_id, $request->all());

        return response()->json([
            'success' => true,
            'message' => 'Staff berhasil ditambahkan.',
            'data' => $staff
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $user = $request->user();
        if ($user->role !== 'merchant_owner') {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $deleted = $this->staffService->deleteStaff($user->business_id, $id);
        
        if ($deleted) {
            return response()->json(['success' => true, 'message' => 'Staff berhasil dihapus.']);
        }

        return response()->json(['success' => false, 'message' => 'Staff tidak ditemukan.'], 404);
    }
}
