$html = Invoke-WebRequest -Uri "https://windows.php.net/downloads/releases/" -UseBasicParsing
$links = $html.Links | Where-Object { $_.href -match 'php-8.3.\d+-nts-Win32-vs16-x64.zip' }
if ($links -and $links.Count -gt 0) {
    $target = $links[0].href
    if ($target -notmatch "^http") {
        $target = "https://windows.php.net" + $target
    }
    Write-Host "Downloading from: $target"
    Invoke-WebRequest -Uri $target -OutFile "D:\php\php.zip"
    Write-Host "Download complete."
} else {
    Write-Host "Error: Could not find PHP 8.3 zip."
}
