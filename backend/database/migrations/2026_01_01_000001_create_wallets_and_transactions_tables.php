<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('merchant_wallets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('business_id')->constrained('businesses')->onDelete('cascade');
            $table->decimal('balance', 15, 2)->default(0);
            $table->timestamps();
        });

        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('business_id')->constrained('businesses')->onDelete('cascade');
            $table->string('transaction_number')->unique();
            $table->decimal('total_amount', 15, 2);
            $table->string('status')->default('pending'); // pending, paid, void
            $table->string('payment_method')->nullable();
            $table->timestamps();
        });

        Schema::create('platform_fees', function (Blueprint $table) {
            $table->id();
            $table->foreignId('business_id')->constrained('businesses')->onDelete('cascade');
            $table->foreignId('transaction_id')->constrained('transactions')->onDelete('cascade');
            $table->decimal('amount', 15, 2)->default(500); // Fixed fee Rp 500
            $table->timestamps();
        });
        
        Schema::create('wallet_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('merchant_wallet_id')->constrained('merchant_wallets')->onDelete('cascade');
            $table->string('type'); // credit (topup), debit (fee)
            $table->decimal('amount', 15, 2);
            $table->string('reference_id')->nullable(); // ID trx atau topup
            $table->text('description')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wallet_transactions');
        Schema::dropIfExists('platform_fees');
        Schema::dropIfExists('transactions');
        Schema::dropIfExists('merchant_wallets');
    }
};
