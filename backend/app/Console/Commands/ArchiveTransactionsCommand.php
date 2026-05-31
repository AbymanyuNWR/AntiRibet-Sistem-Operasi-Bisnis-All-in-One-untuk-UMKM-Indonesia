<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class ArchiveTransactionsCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'antiribet:archive-transactions {--days=90 : Number of days to keep active}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Archive transactions older than X days to cold storage table';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $days = $this->option('days');
        $cutoffDate = now()->subDays($days);
        
        $this->info("Archiving transactions older than {$cutoffDate}...");

        $oldTransactions = \Illuminate\Support\Facades\DB::table('transactions')
            ->where('created_at', '<', $cutoffDate)
            ->get();

        if ($oldTransactions->isEmpty()) {
            $this->info("No transactions to archive.");
            return;
        }

        \Illuminate\Support\Facades\DB::beginTransaction();
        try {
            foreach ($oldTransactions as $tx) {
                $transactionNumber = 'INV-' . $tx->id;
                
                \Illuminate\Support\Facades\DB::table('archived_transactions')->insert([
                    'business_id' => $tx->business_id,
                    'transaction_number' => $transactionNumber,
                    'type' => $tx->type,
                    'total_amount' => $tx->total_amount,
                    'status' => $tx->status,
                    'payment_method' => $tx->payment_method ?? 'cash',
                    'idempotency_key' => $tx->idempotency_key,
                    'archived_at' => now(),
                    'created_at' => $tx->created_at,
                    'updated_at' => $tx->updated_at,
                ]);
            }
            
            // Delete from active table
            $deleted = \Illuminate\Support\Facades\DB::table('transactions')
                ->where('created_at', '<', $cutoffDate)
                ->delete();

            \Illuminate\Support\Facades\DB::commit();
            $this->info("Successfully archived {$deleted} transactions.");
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\DB::rollBack();
            $this->error("Failed to archive transactions: " . $e->getMessage());
        }
    }
}
