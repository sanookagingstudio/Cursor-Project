# ONEPACK FUNAGING v20 — FULL AUTOMATION (RESTORE + ENV + RUNNER)

$ErrorActionPreference = "Stop"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== FUNAGING.SAS ONEPACK v20 — START ===" -ForegroundColor Cyan
Write-Host ""

# STEP 1: VERSION CHECK
Write-Host "[1/6] VERSION CHECK" -ForegroundColor Yellow

try {
    $pyVer = python --version 2>&1
    Write-Host "  Python: $pyVer" -ForegroundColor Green
} catch {
    Write-Host "  ✖ Python not found" -ForegroundColor Red
}

try {
    $nodeVer = node -v 2>&1
    Write-Host "  Node.js: $nodeVer" -ForegroundColor Green
} catch {
    Write-Host "  ✖ Node.js not found" -ForegroundColor Red
}

try {
    $npmVer = npm -v 2>&1
    Write-Host "  npm: $npmVer" -ForegroundColor Green
} catch {
    Write-Host "  ✖ npm not found" -ForegroundColor Red
}
Write-Host ""

# STEP 2: BASELINE RESTORE (v18)
Write-Host "[2/6] BASELINE RESTORE" -ForegroundColor Yellow

if (Test-Path ".\onepack_funaging_v18.ps1") {
    Write-Host "  Running onepack_funaging_v18.ps1 ..." -ForegroundColor Gray
    try {
        & ".\onepack_funaging_v18.ps1" 2>&1 | Out-Null
        Write-Host "  ✔ Baseline restore completed" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ Baseline restore encountered errors: $($_.Exception.Message)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  onepack_funaging_v18.ps1 not found, minimal backend check..." -ForegroundColor Yellow

    $backendMain = Join-Path $scriptDir "backend\app\main.py"
    $backendNewMain = Join-Path $scriptDir "backend\app\new_main.py"

    if (Test-Path $backendNewMain) {
        Copy-Item $backendNewMain $backendMain -Force
        Write-Host "  ✔ main.py restored from new_main.py" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ new_main.py not found, skipping restore" -ForegroundColor Yellow
    }
}
Write-Host ""

# STEP 3: ENV FILE SYNC
Write-Host "[3/6] ENV SYNC" -ForegroundColor Yellow

$rootEnv = Join-Path $scriptDir ".env"
$rootEnvExample = Join-Path $scriptDir ".env.example"
$frontEnv = Join-Path $scriptDir "frontend\.env.local"
$frontEnvExample = Join-Path $scriptDir "frontend\.env.local.example"

$envRestored = 0

if (-not (Test-Path $rootEnv) -and (Test-Path $rootEnvExample)) {
    Copy-Item $rootEnvExample $rootEnv -Force
    Write-Host "  ✔ Root .env created from .env.example" -ForegroundColor Green
    $envRestored++
} elseif (Test-Path $rootEnv) {
    Write-Host "  ✓ Root .env already exists" -ForegroundColor Gray
} else {
    Write-Host "  ⚠ No .env or .env.example found at root" -ForegroundColor Yellow
}

if (-not (Test-Path $frontEnv) -and (Test-Path $frontEnvExample)) {
    if (-not (Test-Path "frontend")) {
        New-Item -ItemType Directory -Path "frontend" | Out-Null
    }
    Copy-Item $frontEnvExample $frontEnv -Force
    Write-Host "  ✔ frontend/.env.local created from .env.local.example" -ForegroundColor Green
    $envRestored++
} elseif (Test-Path $frontEnv) {
    Write-Host "  ✓ frontend/.env.local already exists" -ForegroundColor Gray
} else {
    Write-Host "  ⚠ No frontend/.env.local or .env.local.example found" -ForegroundColor Yellow
}

# Check required environment variables
$requiredEnv = @(
    "SUPABASE_URL",
    "SUPABASE_ANON_KEY",
    "SUPABASE_SERVICE_ROLE_KEY"
)

$missingEnv = @()
foreach ($name in $requiredEnv) {
    $envValue = (Get-Item "env:$name" -ErrorAction SilentlyContinue).Value
    if (-not $envValue) {
        $missingEnv += $name
    }
}

if ($missingEnv.Count -gt 0) {
    Write-Host "  ⚠ ENV WARNING: Missing environment variables:" -ForegroundColor Yellow
    $missingEnv | ForEach-Object { Write-Host "      - $_" -ForegroundColor Yellow }
    Write-Host "     Set these in your shell or .env file before running backend." -ForegroundColor Cyan
} else {
    Write-Host "  ✔ All required environment variables are set" -ForegroundColor Green
}

if ($envRestored -gt 0) {
    Write-Host "  ✔ ENV files restored ($envRestored files)" -ForegroundColor Green
} else {
    Write-Host "  ✔ ENV files check complete" -ForegroundColor Green
}
Write-Host ""

# STEP 4: BACKEND RUNNER
Write-Host "[4/6] BACKEND RUNNER" -ForegroundColor Yellow

$backendHealthy = $false
try {
    $resp = Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -UseBasicParsing -TimeoutSec 3
    if ($resp.StatusCode -eq 200) {
        $backendHealthy = $true
        Write-Host "  ✔ Backend already running" -ForegroundColor Green
        Write-Host "    Response: $($resp.Content)" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ℹ Backend not running" -ForegroundColor Cyan
}

if (-not $backendHealthy) {
    if (-not (Test-Path "backend")) {
        Write-Host "  ✖ backend/ directory not found" -ForegroundColor Red
    } elseif (-not (Test-Path "backend/app/main.py")) {
        Write-Host "  ✖ backend/app/main.py not found" -ForegroundColor Red
    } else {
        Write-Host "  Starting backend (uvicorn)..." -ForegroundColor Gray
        $backendCmd = "-NoExit -Command `"cd '$scriptDir\backend'; if (Test-Path '.venv\Scripts\Activate.ps1') { . .venv\Scripts\Activate.ps1 }; uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`""
        
        try {
            Start-Process powershell -ArgumentList $backendCmd -WindowStyle Normal
            Write-Host "  Waiting for backend to start..." -ForegroundColor Gray
            Start-Sleep -Seconds 6

            $maxRetries = 5
            $retryCount = 0
            while ($retryCount -lt $maxRetries) {
                try {
                    $resp = Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -UseBasicParsing -TimeoutSec 5
                    if ($resp.StatusCode -eq 200) {
                        Write-Host "  ✔ Backend started OK" -ForegroundColor Green
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

# STEP 5: FRONTEND RUNNER
Write-Host "[5/6] FRONTEND RUNNER" -ForegroundColor Yellow

$frontendHealthy = $false
try {
    $resp2 = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 3
    if ($resp2.StatusCode -eq 200) {
        $frontendHealthy = $true
        Write-Host "  ✔ Frontend already running" -ForegroundColor Green
    }
} catch {
    Write-Host "  ℹ Frontend not running" -ForegroundColor Cyan
}

if (-not $frontendHealthy) {
    if (-not (Test-Path "frontend")) {
        Write-Host "  ✖ frontend/ directory not found" -ForegroundColor Red
    } elseif (-not (Test-Path "frontend/package.json")) {
        Write-Host "  ✖ frontend/package.json not found" -ForegroundColor Red
    } else {
        Write-Host "  Starting frontend (Next.js dev)..." -ForegroundColor Gray
        $frontendCmd = "-NoExit -Command `"cd '$scriptDir\frontend'; npm run dev`""
        
        try {
            Start-Process powershell -ArgumentList $frontendCmd -WindowStyle Normal
            Write-Host "  Waiting for frontend to start..." -ForegroundColor Gray
            Start-Sleep -Seconds 8

            $maxRetries = 5
            $retryCount = 0
            while ($retryCount -lt $maxRetries) {
                try {
                    $resp2 = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
                    if ($resp2.StatusCode -eq 200) {
                        Write-Host "  ✔ Frontend started OK" -ForegroundColor Green
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

# STEP 6: SUMMARY
Write-Host "[6/6] SUMMARY" -ForegroundColor Green
Write-Host ""
Write-Host "=== FUNAGING.SAS ONEPACK v20 — DONE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend  : http://127.0.0.1:8000/docs" -ForegroundColor White
Write-Host "Health   : http://127.0.0.1:8000/health" -ForegroundColor White
Write-Host "Frontend : http://localhost:3000" -ForegroundColor White
Write-Host ""
if ($backendHealthy -and $frontendHealthy) {
    Write-Host "✅ Both backend and frontend are running!" -ForegroundColor Green
} elseif ($backendHealthy) {
    Write-Host "✅ Backend is running" -ForegroundColor Green
    Write-Host "⚠ Frontend may still be starting" -ForegroundColor Yellow
} elseif ($frontendHealthy) {
    Write-Host "⚠ Backend may still be starting" -ForegroundColor Yellow
    Write-Host "✅ Frontend is running" -ForegroundColor Green
} else {
    Write-Host "⚠ Services may still be starting. Check the PowerShell windows for status." -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Note: Services are running in separate PowerShell windows." -ForegroundColor Gray
Write-Host "      Close those windows to stop the servers." -ForegroundColor Gray
Write-Host ""


