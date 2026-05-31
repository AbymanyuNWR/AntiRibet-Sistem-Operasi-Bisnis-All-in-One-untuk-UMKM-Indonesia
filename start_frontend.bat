@echo off
echo ==============================================================
echo ANTIRIBET - KASIR ^& MANAJEMEN BISNIS SUPER (FLUTTER ENGINE)
echo ==============================================================

echo [1/3] Mendeteksi Flutter SDK di Drive D:\...
if not exist "D:\flutter\bin\flutter.bat" (
    echo [ERROR] Flutter SDK tidak ditemukan di D:\flutter.
    echo Harap tunggu robot AI menyelesaikan proses instalasinya.
    pause
    exit /b 1
)

echo [2/3] Mengunduh dependensi (packages)...
cd app
call D:\flutter\bin\flutter.bat pub get
if %errorlevel% neq 0 (
    echo [ERROR] Gagal mengunduh dependensi.
    pause
    exit /b %errorlevel%
)

echo [3/3] Meluncurkan aplikasi Kasir Antiribet di Chrome...
call D:\flutter\bin\flutter.bat run -d chrome
if %errorlevel% neq 0 (
    echo [ERROR] Aplikasi berhenti atau gagal diluncurkan.
    pause
    exit /b %errorlevel%
)
