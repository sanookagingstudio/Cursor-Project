# ==========================================
# ONEPACK — FORCE START FRONTEND (3000)
# ==========================================

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== FORCE START FRONTEND ===" -ForegroundColor Cyan
Write-Host ""

# 1) Kill node เดิม (ถ้ามี)
Write-Host "[1/4] Stopping existing Node processes..." -ForegroundColor Yellow

try {
    $nodeProcesses = Get-Process node -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -like "*node.exe*"
    }
    
    if ($nodeProcesses) {
        $processCount = $nodeProcesses.Count
        $nodeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Host "  ✔ Stopped $processCount Node process(es)" -ForegroundColor Green
    } else {
        Write-Host "  ✓ No existing Node processes found" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ⚠ Could not stop processes: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "    Continuing anyway..." -ForegroundColor Gray
}

Write-Host ""

# 2) เข้า frontend
Write-Host "[2/4] Navigating to frontend directory..." -ForegroundColor Yellow

$frontendDir = Join-Path $scriptDir "frontend"
if (-not (Test-Path $frontendDir)) {
    Write-Host "  ✖ frontend directory not found" -ForegroundColor Red
    Write-Host "    Current directory: $scriptDir" -ForegroundColor Gray
    exit 1
}

if (-not (Test-Path "$frontendDir\package.json")) {
    Write-Host "  ✖ frontend/package.json not found" -ForegroundColor Red
    exit 1
}

Set-Location $frontendDir
Write-Host "  ✔ Changed to frontend directory" -ForegroundColor Green
Write-Host ""

# 3) ติดตั้ง deps เผื่อยังไม่ครบ
Write-Host "[3/4] Installing dependencies..." -ForegroundColor Yellow

try {
    Write-Host "  Running npm install..." -ForegroundColor Gray
    npm install 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✔ Dependencies installed" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ npm install had warnings (continuing anyway)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ⚠ npm install failed: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "    Continuing anyway..." -ForegroundColor Gray
}

Write-Host ""

# 4) รัน dev แบบเห็น error จริง
Write-Host "[4/4] Starting Next.js dev server..." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Frontend will start on: http://localhost:3000" -ForegroundColor Cyan
Write-Host "  Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""
Write-Host "  Starting dev server (showing real output)..." -ForegroundColor Gray
Write-Host "  " + ("=" * 60) -ForegroundColor DarkGray
Write-Host ""

# Run dev server (this will block and show output)
try {
    npm run dev
} catch {
    Write-Host ""
    Write-Host "  ✖ Dev server failed to start: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Troubleshooting:" -ForegroundColor Yellow
    Write-Host "    1. Check if port 3000 is already in use" -ForegroundColor Gray
    Write-Host "    2. Verify package.json has 'dev' script" -ForegroundColor Gray
    Write-Host "    3. Check Node.js and npm are installed correctly" -ForegroundColor Gray
    Write-Host ""
    exit 1
}





