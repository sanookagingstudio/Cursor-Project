Write-Host "=== FUNAGING.CLUB – AUTO ONE PACK V4 ===" -ForegroundColor Cyan

# 1) Base64 Python main.py content (safe from PowerShell parsing)
$pyBase64 = @"
ZnJvbSBmYXN0YXBpIGltcG9ydCBGYXN0QVBJCgoKYXBwID0gRmFzdEFQSSgpCgoKYEBhcHAuZ2V0KCcvaGVhbHRoJylgCmRlZiBoZWFsdGgoKToKICAgIHJldHVybiB7InN0YXR1cyI6ICJvayJ9
"@

# Decode Base64 → Python file content
$pyContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($pyBase64))

# Ensure backend/app exists
if (!(Test-Path "backend/app")) { mkdir backend/app -Force }

# Write main.py
$pyContent | Out-File backend/app/main.py -Encoding utf8

Write-Host "✔ main.py generated safely" -ForegroundColor Green

# 2) Install supabase
Write-Host "[1] Checking Supabase module..." -ForegroundColor Yellow

$exists = pip show supabase 2>&1 | Out-String

if ($exists -match "Name: supabase") {
    Write-Host "✔ Supabase OK" -ForegroundColor Green
} else {
    Write-Host "Installing Supabase..." -ForegroundColor Cyan
    pip install supabase
    Write-Host "✔ Supabase installed" -ForegroundColor Green
}

# 3) Create versions folder if missing
if (!(Test-Path "versions")) { mkdir versions }

if (!(Test-Path "versions/meta.json")) {
@"
{
  `"currentVersion`": `"v1`"
}
"@ | Out-File versions/meta.json -Encoding utf8
}

Write-Host "✔ Version system OK" -ForegroundColor Green

# 4) Start backend
Write-Host "[4] Starting backend..." -ForegroundColor Yellow

Start-Process powershell -ArgumentList "uvicorn backend.app.main:app --reload"
Start-Sleep -Seconds 4

# 5) Health check
Write-Host "[5] Checking health..." -ForegroundColor Yellow

try {
    $res = Invoke-RestMethod "http://127.0.0.1:8000/health"
    Write-Host "✔ Backend OK → $($res.status)" -ForegroundColor Green
} catch {
    Write-Host "✘ Backend FAILED" -ForegroundColor Red
}

Write-Host "=== AUTO ONE PACK V4 COMPLETE ===" -ForegroundColor Cyan













