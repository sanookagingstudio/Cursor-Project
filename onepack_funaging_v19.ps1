# ONEPACK FUNAGING v19 — LOCAL RUNNER (BACKEND + FRONTEND)

$ErrorActionPreference = "Stop"

# ใช้ path ของไฟล์สคริปต์เป็นฐาน
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== FUNAGING.SAS v19 LOCAL RUNNER START ===" -ForegroundColor Cyan
Write-Host ""

# ---- STEP 1: VERSION CHECK (Python / Node / npm) ----
Write-Host "[1/4] Checking Python / Node / npm versions..." -ForegroundColor Yellow

try {
    $pyVer = python --version 2>&1
    Write-Host "  Python: $pyVer" -ForegroundColor Green
} catch {
    Write-Host "  ✖ Python not found in PATH" -ForegroundColor Red
}

try {
    $nodeVer = node -v 2>&1
    $npmVer = npm -v 2>&1
    Write-Host "  Node.js: $nodeVer" -ForegroundColor Green
    Write-Host "  npm: $npmVer" -ForegroundColor Green
} catch {
    Write-Host "  ✖ Node.js / npm not found in PATH" -ForegroundColor Red
}
Write-Host ""

# ---- STEP 2: START BACKEND (FASTAPI/UVICORN) ----
Write-Host "[2/4] Checking backend health on http://127.0.0.1:8000/health ..." -ForegroundColor Yellow

$backendHealthy = $false
try {
    $resp = Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -UseBasicParsing -TimeoutSec 3
    if ($resp.StatusCode -eq 200) {
        $backendHealthy = $true
        Write-Host "  ✔ Backend already running" -ForegroundColor Green
        Write-Host "    Response: $($resp.Content)" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ℹ Backend not running, starting new uvicorn process..." -ForegroundColor Cyan
}

if (-not $backendHealthy) {
    if (-not (Test-Path "backend")) {
        Write-Host "  ✖ backend/ directory not found" -ForegroundColor Red
    } elseif (-not (Test-Path "backend/app/main.py")) {
        Write-Host "  ✖ backend/app/main.py not found" -ForegroundColor Red
    } else {
        Write-Host "  Starting backend in new window..." -ForegroundColor Gray
        $backendCmd = "-NoExit -Command `"cd '$scriptDir\backend'; if (Test-Path '.venv\Scripts\Activate.ps1') { . .venv\Scripts\Activate.ps1 }; uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`""
        
        try {
            Start-Process powershell -ArgumentList $backendCmd -WindowStyle Normal
            Write-Host "  Waiting for backend to start..." -ForegroundColor Gray
            Start-Sleep -Seconds 8

            $maxRetries = 5
            $retryCount = 0
            while ($retryCount -lt $maxRetries) {
                try {
                    $resp = Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -UseBasicParsing -TimeoutSec 5
                    if ($resp.StatusCode -eq 200) {
                        Write-Host "  ✔ Backend started successfully" -ForegroundColor Green
                        Write-Host "    Response: $($resp.Content)" -ForegroundColor Gray
                        $backendHealthy = $true
                        break
                    }
                } catch {
                    $retryCount++
                    if ($retryCount -lt $maxRetries) {
                        Start-Sleep -Seconds 2
                    }
                }
            }

            if (-not $backendHealthy) {
                Write-Host "  ⚠ Backend may still be starting. Check the backend window for errors." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "  ✖ Failed to start backend: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host ""

# ---- STEP 3: START FRONTEND (NEXT.JS DEV) ----
Write-Host "[3/4] Checking frontend on http://localhost:3000 ..." -ForegroundColor Yellow

$frontendHealthy = $false
try {
    $resp2 = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 3
    if ($resp2.StatusCode -eq 200) {
        $frontendHealthy = $true
        Write-Host "  ✔ Frontend already running" -ForegroundColor Green
    }
} catch {
    Write-Host "  ℹ Frontend not running, starting Next.js dev server..." -ForegroundColor Cyan
}

if (-not $frontendHealthy) {
    if (-not (Test-Path "frontend")) {
        Write-Host "  ✖ frontend/ directory not found" -ForegroundColor Red
    } elseif (-not (Test-Path "frontend/package.json")) {
        Write-Host "  ✖ frontend/package.json not found" -ForegroundColor Red
    } else {
        Write-Host "  Starting frontend in new window..." -ForegroundColor Gray
        $frontendCmd = "-NoExit -Command `"cd '$scriptDir\frontend'; npm run dev`""
        
        try {
            Start-Process powershell -ArgumentList $frontendCmd -WindowStyle Normal
            Write-Host "  Waiting for frontend to start..." -ForegroundColor Gray
            Start-Sleep -Seconds 10

            $maxRetries = 5
            $retryCount = 0
            while ($retryCount -lt $maxRetries) {
                try {
                    $resp2 = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
                    if ($resp2.StatusCode -eq 200) {
                        Write-Host "  ✔ Frontend started successfully" -ForegroundColor Green
                        $frontendHealthy = $true
                        break
                    }
                } catch {
                    $retryCount++
                    if ($retryCount -lt $maxRetries) {
                        Start-Sleep -Seconds 3
                    }
                }
            }

            if (-not $frontendHealthy) {
                Write-Host "  ⚠ Frontend may still be starting. Check the frontend window for errors." -ForegroundColor Yellow
                Write-Host "    Next.js typically takes 10-30 seconds to compile on first run." -ForegroundColor Gray
            }
        } catch {
            Write-Host "  ✖ Failed to start frontend: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host ""

# ---- STEP 4: SUMMARY ----
Write-Host "[4/4] DONE." -ForegroundColor Green
Write-Host ""
Write-Host "=== FUNAGING.SAS v19 LOCAL RUNNER READY ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend  : http://127.0.0.1:8000/docs" -ForegroundColor White
Write-Host "Health   : http://127.0.0.1:8000/health" -ForegroundColor White
Write-Host "Frontend : http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "Note: Backend and Frontend are running in separate PowerShell windows." -ForegroundColor Gray
Write-Host "      Close those windows to stop the servers." -ForegroundColor Gray
Write-Host ""






