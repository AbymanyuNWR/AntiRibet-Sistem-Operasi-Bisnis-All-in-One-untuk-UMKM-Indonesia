<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Account;
use App\Models\JournalEntry;
use App\Models\JournalLine;

class AccountingController extends Controller
{
    public function getProfitAndLoss(Request $request)
    {
        $businessId = $request->user()->business_id;

        // Ensure default accounts exist
        $this->ensureAccountsExist($businessId);

        // Calculate Revenue (Credit - Debit) for Revenue accounts
        $revenue = JournalLine::whereHas('account', function($q) use ($businessId) {
                $q->where('business_id', $businessId)->where('type', 'revenue');
            })
            ->selectRaw('SUM(credit) - SUM(debit) as balance')
            ->value('balance') ?? 0;

        // Calculate COGS/Expense (Debit - Credit) for Expense accounts
        $expense = JournalLine::whereHas('account', function($q) use ($businessId) {
                $q->where('business_id', $businessId)->where('type', 'expense');
            })
            ->selectRaw('SUM(debit) - SUM(credit) as balance')
            ->value('balance') ?? 0;

        $grossProfit = $revenue - $expense;

        // Get journals for display
        $journals = JournalEntry::with('lines.account')
            ->where('business_id', $businessId)
            ->orderBy('entry_date', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'revenue' => (float) $revenue,
                'expense' => (float) $expense,
                'gross_profit' => (float) $grossProfit,
                'journals' => $journals,
            ]
        ]);
    }

    private function ensureAccountsExist($businessId)
    {
        $accounts = [
            ['code' => '1001', 'name' => 'Kas / Bank', 'type' => 'asset'],
            ['code' => '1002', 'name' => 'Persediaan Bahan Baku', 'type' => 'asset'],
            ['code' => '4001', 'name' => 'Pendapatan Penjualan', 'type' => 'revenue'],
            ['code' => '5001', 'name' => 'Harga Pokok Penjualan (HPP)', 'type' => 'expense'],
        ];

        foreach ($accounts as $acc) {
            Account::firstOrCreate([
                'business_id' => $businessId,
                'account_code' => $acc['code'],
            ], [
                'name' => $acc['name'],
                'type' => $acc['type']
            ]);
        }
    }
}
