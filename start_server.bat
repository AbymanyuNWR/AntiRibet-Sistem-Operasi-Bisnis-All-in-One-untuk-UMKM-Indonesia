@echo off
echo ==============================================================
echo ANTIRIBET - SERVER BACKEND API (LARAVEL ENGINE)
echo ==============================================================

echo [1/4] Mendeteksi Mesin PHP Lokal di D:\php...
if not exist "D:\php\php.exe" (
    echo [ERROR] PHP Engine tidak ditemukan di D:\php.
    echo Harap tunggu instalasi robot AI selesai atau periksa koneksi.
    pause
    exit /b 1
)
set PHP_BIN=D:\php\php.exe
set COMPOSER_BIN=D:\php\composer.phar

echo [2/4] Mengunduh Dependensi Backend (Composer)...
cd backend
if not exist "vendor" (
    %PHP_BIN% %COMPOSER_BIN% install
    %PHP_BIN% artisan key:generate --force
)

echo [3/4] Menyiapkan Database SQLite Sementara...
if not exist "database\database.sqlite" (
    type nul > database\database.sqlite
    %PHP_BIN% artisan migrate --seed --force
)

echo [4/4] Menyalakan Server API Backend (Port 8000)...
echo Silakan biarkan jendela hitam ini tetap terbuka!
%PHP_BIN% artisan serve --host=127.0.0.1 --port=8000
