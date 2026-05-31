<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Attendance;
use App\Models\Payroll;
use App\Models\User;
use App\Models\Account;
use App\Models\JournalEntry;
use App\Models\JournalLine;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class HrmController extends Controller
{
    public function getStaff(Request $request)
    {
        $staff = User::where('business_id', $request->user()->business_id)
            ->where('role', 'merchant_staff')
            ->get();
        return response()->json(['success' => true, 'data' => $staff]);
    }

    public function clockIn(Request $request)
    {
        $user = $request->user();
        
        $active = Attendance::where('user_id', $user->id)->whereNull('clock_out')->first();
        if ($active) {
            return response()->json(['success' => false, 'message' => 'Anda belum clock-out dari sesi sebelumnya.'], 400);
        }

        $att = Attendance::create([
            'user_id' => $user->id,
            'clock_in' => now()
        ]);

        return response()->json(['success' => true, 'message' => 'Clock-In berhasil', 'data' => $att]);
    }

    public function clockOut(Request $request)
    {
        $user = $request->user();
        
        $active = Attendance::where('user_id', $user->id)->whereNull('clock_out')->first();
        if (!$active) {
            return response()->json(['success' => false, 'message' => 'Tidak ada sesi aktif.'], 400);
        }

        $active->clock_out = now();
        $in = Carbon::parse($active->clock_in);
        $out = Carbon::parse($active->clock_out);
        $active->total_hours = $in->floatDiffInHours($out);
        $active->save();

        return response()->json(['success' => true, 'message' => 'Clock-Out berhasil', 'data' => $active]);
    }

    public function generatePayroll(Request $request)
    {
        $request->validate(['user_id' => 'required|exists:users,id']);
        $businessId = $request->user()->business_id;

        $targetUser = User::where('business_id', $businessId)->findOrFail($request->user_id);
        
        // Cek absensi bulan ini (simplifikasi)
        $start = now()->startOfMonth();
        $end = now()->endOfMonth();

        $totalHours = Attendance::where('user_id', $targetUser->id)
            ->whereBetween('clock_in', [$start, $end])
            ->sum('total_hours');

        $totalAmount = $totalHours * $targetUser->hourly_rate;

        $payroll = Payroll::create([
            'business_id' => $businessId,
            'user_id' => $targetUser->id,
            'period_start' => $start,
            'period_end' => $end,
            'total_amount' => $totalAmount,
            'status' => 'pending'
        ]);

        return response()->json(['success' => true, 'data' => $payroll]);
    }

    public function getPayrolls(Request $request)
    {
        $payrolls = Payroll::with('user')
            ->where('business_id', $request->user()->business_id)
            ->get();
        return response()->json(['success' => true, 'data' => $payrolls]);
    }

    public function payPayroll(Request $request, $id)
    {
        return DB::transaction(function () use ($request, $id) {
            $businessId = $request->user()->business_id;
            
            $payroll = Payroll::where('business_id', $businessId)
                ->where('id', $id)
                ->lockForUpdate()
                ->firstOrFail();

            if ($payroll->status === 'paid') {
                return response()->json(['success' => false, 'message' => 'Gaji sudah dibayar sebelumnya.'], 400);
            }

            // SUPER LOGIC: Journaling
            $accKas = Account::where('business_id', $businessId)->where('account_code', '1001')->first();
            $accBebanGaji = Account::firstOrCreate([
                'business_id' => $businessId,
                'account_code' => '5002',
            ], [
                'name' => 'Beban Gaji Karyawan',
                'type' => 'expense'
            ]);

            if ($accKas && $accBebanGaji) {
                $journal = JournalEntry::create([
                    'business_id' => $businessId,
                    'reference_type' => 'Payroll',
                    'reference_id' => $payroll->id,
                    'description' => 'Pembayaran Gaji Karyawan',
                    'entry_date' => now(),
                ]);

                // Debit Beban Gaji
                JournalLine::create(['journal_entry_id' => $journal->id, 'account_id' => $accBebanGaji->id, 'debit' => $payroll->total_amount, 'credit' => 0]);
                // Kredit Kas
                JournalLine::create(['journal_entry_id' => $journal->id, 'account_id' => $accKas->id, 'debit' => 0, 'credit' => $payroll->total_amount]);
            }

            $payroll->status = 'paid';
            $payroll->save();

            return response()->json(['success' => true, 'message' => 'Gaji berhasil dibayar & tercatat di Akuntansi!']);
        });
    }
}
