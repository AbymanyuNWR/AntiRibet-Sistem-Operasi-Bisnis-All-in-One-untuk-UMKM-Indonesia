<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect('http://127.0.0.1:8080'); // Redirect backend root to Website Landing Page
});

Route::get('/login', function () {
    return view('auth.login');
})->name('login');

Route::get('/register', function () {
    return view('auth.register');
})->name('register');
