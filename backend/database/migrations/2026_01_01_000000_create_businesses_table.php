<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('businesses', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->string('logo_url')->nullable();
            $table->timestamps();
        });

        // Modifikasi tabel users default Laravel jika ini adalah real project,
        // tapi kita asumsikan struktur dasar untuk relasi:
        Schema::table('users', function (Blueprint $table) {
            $table->foreignId('business_id')->nullable()->constrained('businesses')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['business_id']);
            $table->dropColumn('business_id');
        });
        Schema::dropIfExists('businesses');
    }
};
