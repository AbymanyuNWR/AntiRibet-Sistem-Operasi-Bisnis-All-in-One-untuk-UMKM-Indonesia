<?php

use Illuminate\Support\Facades\Broadcast;

/*
|--------------------------------------------------------------------------
| Broadcast Channels
|--------------------------------------------------------------------------
|
| Di sini tempat mendaftarkan izin (authorization) bagi aplikasi Flutter
| untuk "berlangganan" mendengarkan notifikasi realtime lewat WebSocket.
|
*/

Broadcast::channel('business.{businessId}.orders', function ($user, $businessId) {
    return (int) $user->business_id === (int) $businessId;
});
