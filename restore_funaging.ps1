# ==========================================
# ONE PACK – ABSOLUTE FINAL RESTORE
# FunAging.club → SAS v1 Master Baseline
# Fully Auto: Restore + Build + Start Server
# ==========================================

Write-Host "=== AUTO-RESTORE FUNAGING.CLUB STARTING ===" -ForegroundColor Cyan

# 1) Ensure Git Repository Exists
if (-not (Test-Path ".git")) {
    Write-Host "❌ ERROR: This folder is not a Git repository. THE BEST MODE requires correct project folder." -ForegroundColor Red
    exit 1
}
Write-Host "✓ Git repository detected" -ForegroundColor Green

# 2) Fetch All Tags From GitHub
Write-Host "Fetching all remote branches and tags..." -ForegroundColor Yellow
git fetch --all --prune

# 3) Detect Restore Point
$restoreTag = "v1"
if (Test-Path "versions/meta.json") {
    $meta = Get-Content "versions/meta.json" | ConvertFrom-Json
    $current = $meta.currentVersion
    $restoreTag = "v$($current-1)"
}
Write-Host "✓ Restore point detected: $restoreTag" -ForegroundColor Green

# 4) Checkout Restore Code
Write-Host "Checking out tag $restoreTag ..." -ForegroundColor Yellow
git checkout $restoreTag -f

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: Cannot checkout restore tag" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Source restored to: $restoreTag" -ForegroundColor Green

# 5) Install Dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ npm install failed" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Dependencies installed" -ForegroundColor Green

# 6) Build Project
Write-Host "Building project..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed. ONE PACK THE BEST MODE requires ChatGPT patching." -ForegroundColor Red
    exit 1
}
Write-Host "✓ Build successful" -ForegroundColor Green

# 7) Auto-Run Server (Forever Mode)
Write-Host "Starting server automatically..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-Command npm run dev" -WindowStyle Hidden
Start-Sleep -Seconds 5

# 8) Verify Server Is Running
try {
    $result = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 5
    Write-Host "✓ SERVER ONLINE — FUNAGING.CLUB IS RESTORED" -ForegroundColor Green
}
catch {
    Write-Host "❌ Server did not respond. Manual check required." -ForegroundColor Red
}

Write-Host "=== RESTORE COMPLETE ===" -ForegroundColor Cyan














