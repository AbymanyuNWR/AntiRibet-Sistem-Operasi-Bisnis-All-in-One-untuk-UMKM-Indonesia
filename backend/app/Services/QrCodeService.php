<?php

namespace App\Services;

use App\Models\Business;
use Illuminate\Support\Str;

class QrCodeService
{
    /**
     * Generate URL untuk QR Code di meja tertentu.
     * Menggunakan slug bisnis dan nomor meja.
     */
    public function generateTableQrUrl(Business $business, string $tableNumber): string
    {
        // Contoh URL yang akan dicetak pada stiker QR Code
        // https://app.antiribet.id/b/kopi-senja?table=5
        $baseUrl = config('app.frontend_url', 'https://app.antiribet.id');
        return "{$baseUrl}/b/{$business->slug}?table={$tableNumber}";
    }

    /**
     * (Opsional) Generate dynamic QR payload jika kita menggunakan custom JWT token untuk security.
     */
    public function generateSecureQrPayload(Business $business, string $tableNumber): string
    {
        $payload = base64_encode(json_encode([
            'b' => $business->slug,
            't' => $tableNumber,
            'exp' => time() + 86400 // Expired dalam 24 jam (opsional)
        ]));

        $baseUrl = config('app.frontend_url', 'https://app.antiribet.id');
        return "{$baseUrl}/qr?p={$payload}";
    }
}
