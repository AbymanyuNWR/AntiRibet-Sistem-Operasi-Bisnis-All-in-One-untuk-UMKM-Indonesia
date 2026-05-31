$ErrorActionPreference = "Stop"

Write-Host "Creating D:\php directory..."
New-Item -ItemType Directory -Force -Path "D:\php" | Out-Null

$zipUrl = "https://windows.php.net/downloads/releases/php-8.3.31-nts-Win32-vs16-x64.zip"
Write-Host "Downloading PHP 8.3 from $zipUrl..."
Invoke-WebRequest -Uri $zipUrl -OutFile "D:\php\php.zip"

Write-Host "Extracting PHP..."
Expand-Archive -Path "D:\php\php.zip" -DestinationPath "D:\php" -Force
Remove-Item "D:\php\php.zip"

Write-Host "Configuring php.ini..."
Copy-Item "D:\php\php.ini-development" "D:\php\php.ini"
$iniPath = "D:\php\php.ini"
$ini = Get-Content $iniPath

$ini = $ini -replace '^;extension_dir = "ext"', 'extension_dir = "ext"'
$ini = $ini -replace '^;extension=curl', 'extension=curl'
$ini = $ini -replace '^;extension=fileinfo', 'extension=fileinfo'
$ini = $ini -replace '^;extension=mbstring', 'extension=mbstring'
$ini = $ini -replace '^;extension=openssl', 'extension=openssl'
$ini = $ini -replace '^;extension=pdo_sqlite', 'extension=pdo_sqlite'
$ini = $ini -replace '^;extension=sqlite3', 'extension=sqlite3'
$ini = $ini -replace '^;extension=zip', 'extension=zip'

Set-Content -Path $iniPath -Value $ini

Write-Host "Downloading Composer..."
Invoke-WebRequest -Uri "https://getcomposer.org/download/latest-stable/composer.phar" -OutFile "D:\php\composer.phar"

Write-Host "PHP Setup Complete."
