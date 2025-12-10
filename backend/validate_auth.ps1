$ErrorActionPreference = "Stop"

Write-Host "== AUTH SELF-TEST (Windows) ==" -ForegroundColor Cyan

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

$tokenPath = Join-Path $root "app\admin_token.txt"
if (Test-Path $tokenPath) {
    $tok = Get-Content $tokenPath -Raw
    Write-Host "✅ admin_token.txt found (first 60 chars): $($tok.Substring(0,60))" -ForegroundColor Green
} else {
    Write-Host "❌ admin_token.txt NOT found" -ForegroundColor Red
}

Write-Host "[*] Checking /health ..." -ForegroundColor Cyan
$health = Invoke-RestMethod "http://localhost:8000/health" -TimeoutSec 5
Write-Host "✔ /health OK: $($health | ConvertTo-Json -Compress)" -ForegroundColor Green

Write-Host "[*] Testing login ..." -ForegroundColor Cyan
$body = @{ email = "admin@example.com"; password = "Admin1234!" } | ConvertTo-Json
$login = Invoke-RestMethod "http://localhost:8000/auth/login" -Method POST -ContentType "application/json" -Body $body -TimeoutSec 5
$access = $login.access_token

Write-Host "✔ Login successful. Token(first 60): $($access.Substring(0,60))" -ForegroundColor Green

Write-Host "[*] Calling /auth/me ..." -ForegroundColor Cyan
$me = Invoke-RestMethod "http://localhost:8000/auth/me" -Headers @{ Authorization = "Bearer $access"} -TimeoutSec 5

Write-Host "✔ /auth/me OK: $($me | ConvertTo-Json -Compress)" -ForegroundColor Green
