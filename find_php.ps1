$html = Invoke-WebRequest -Uri "https://windows.php.net/downloads/releases/" -UseBasicParsing
$html.Content -match 'php-8.3.\d+-nts-Win32-vs16-x64.zip' | Out-Null
Write-Host $matches[0]
