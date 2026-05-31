<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Tabel Roles untuk RBAC (Owner, Kasir, Admin)
        Schema::create('roles', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // owner, cashier, kitchen, superadmin
            $table->string('display_name');
            $table->timestamps();
        });

        Schema::create('role_user', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('role_id')->constrained('roles')->onDelete('cascade');
        });

        // Tabel Booking / Reservasi Meja
        Schema::create('bookings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('business_id')->constrained('businesses')->onDelete('cascade');
            $table->string('customer_name');
            $table->string('customer_phone');
            $table->date('booking_date');
            $table->time('booking_time');
            $table->integer('guest_count');
            $table->string('table_number')->nullable();
            $table->string('status')->default('pending'); // pending, confirmed, completed, cancelled
            $table->timestamps();
        });

        // Tabel Queues (Antrean harian)
        Schema::create('queues', function (Blueprint $table) {
            $table->id();
            $table->foreignId('business_id')->constrained('businesses')->onDelete('cascade');
            $table->foreignId('transaction_id')->constrained('transactions')->onDelete('cascade');
            $table->string('queue_number'); // e.g. A-001
            $table->date('queue_date');
            $table->string('status')->default('waiting'); // waiting, cooking, ready, served
            $table->timestamps();
            
            // Mencegah duplikat nomor antrean di tanggal yang sama untuk satu toko
            $table->unique(['business_id', 'queue_date', 'queue_number']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('queues');
        Schema::dropIfExists('bookings');
        Schema::dropIfExists('role_user');
        Schema::dropIfExists('roles');
    }
};
