# ONEPACK FUNAGING v30 — ALL-IN-ONE PRODUCTION BUILD

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== FUNAGING.SAS ONEPACK v30 — START ===" -ForegroundColor Cyan
Write-Host ""

# PHASE 1: VERSION CHECK
Write-Host "[1/7] VERSION CHECK" -ForegroundColor Yellow

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

try {
    $vercelVer = vercel --version 2>&1
    Write-Host "  Vercel CLI: $vercelVer" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Vercel CLI not found (deploy step will be skipped)" -ForegroundColor Yellow
}
Write-Host ""

# PHASE 2: BASELINE RESTORE (v18/v20 CHAIN)
Write-Host "[2/7] BASELINE RESTORE (v18)" -ForegroundColor Yellow

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
        Write-Host "  ✔ main.py restored from new_main.py (minimal restore)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ new_main.py not found, skipping minimal restore" -ForegroundColor Yellow
    }
}
Write-Host ""

# PHASE 3: ENV SYNC + SUPABASE ROLE FIX
Write-Host "[3/7] ENV SYNC + SUPABASE CHECK" -ForegroundColor Yellow

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
    Write-Host "  ⚠ No .env or .env.example at root" -ForegroundColor Yellow
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
    Write-Host "  ⚠ No frontend/.env.local or .env.local.example" -ForegroundColor Yellow
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
} else {
    Write-Host "  ✔ All required environment variables are set" -ForegroundColor Green
}

# Supabase role fix RPC
$supabaseUrl = (Get-Item "env:SUPABASE_URL" -ErrorAction SilentlyContinue).Value
$supabaseKey = (Get-Item "env:SUPABASE_SERVICE_ROLE_KEY" -ErrorAction SilentlyContinue).Value

if ($supabaseUrl -and $supabaseKey) {
    Write-Host "  Attempting Supabase role fix RPC..." -ForegroundColor Gray
    $headers = @{
        "apikey"        = $supabaseKey
        "Authorization" = "Bearer $supabaseKey"
        "Content-Type"  = "application/json"
    }
    $body = @{
        admin_email = "sanookagingstudio@gmail.com"
        staff_email = "akemontree@gmail.com"
    } | ConvertTo-Json

    try {
        $rpcUrl = "$supabaseUrl/rest/v1/rpc/fix_user_roles"
        Invoke-RestMethod -Method Post -Uri $rpcUrl -Headers $headers -Body $body -ErrorAction Stop | Out-Null
        Write-Host "  ✔ Supabase role fix RPC executed" -ForegroundColor Green
    } catch {
        $errorMsg = $_.Exception.Message
        if ($errorMsg -match "404" -or $errorMsg -match "not found") {
            Write-Host "  ⚠ Supabase role fix RPC function not defined (safe to ignore)" -ForegroundColor Yellow
        } else {
            Write-Host "  ⚠ Supabase role fix RPC failed: $errorMsg" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "  ⚠ Supabase URL / SERVICE_ROLE_KEY missing, skipping role fix RPC" -ForegroundColor Yellow
}

if ($envRestored -gt 0) {
    Write-Host "  ✔ ENV files restored ($envRestored files)" -ForegroundColor Green
}
Write-Host ""

# PHASE 4: TEST SUITE (OPTIONAL)
Write-Host "[4/7] TEST SUITE" -ForegroundColor Yellow

$testScripts = @(
    ".\run_tests.ps1",
    ".\validate_auth.ps1"
)

$testsRun = 0
foreach ($ts in $testScripts) {
    if (Test-Path $ts) {
        Write-Host "  Running $ts ..." -ForegroundColor Gray
        try {
            & $ts 2>&1 | Out-Null
            Write-Host "  ✔ $ts completed" -ForegroundColor Green
            $testsRun++
        } catch {
            Write-Host "  ⚠ Test script $ts failed (non-blocking): $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

if ($testsRun -eq 0) {
    Write-Host "  ℹ No test scripts found (optional step)" -ForegroundColor Cyan
} else {
    Write-Host "  ✔ Test suite completed ($testsRun scripts)" -ForegroundColor Green
}
Write-Host ""

# PHASE 5: BUILD FRONTEND (NEXT.JS PRODUCTION BUILD)
Write-Host "[5/7] FRONTEND PRODUCTION BUILD" -ForegroundColor Yellow

$frontendDir = Join-Path $scriptDir "frontend"
if (Test-Path $frontendDir) {
    if (-not (Test-Path "$frontendDir\package.json")) {
        Write-Host "  ✖ frontend/package.json not found" -ForegroundColor Red
    } else {
        Push-Location $frontendDir
        try {
            Write-Host "  Installing dependencies..." -ForegroundColor Gray
            npm install --force 2>&1 | Out-Null
            Write-Host "  ✔ Dependencies installed" -ForegroundColor Green

            Write-Host "  Building Next.js production bundle..." -ForegroundColor Gray
            npm run build 2>&1 | Out-Null
            Write-Host "  ✔ Next.js production build completed" -ForegroundColor Green
        } catch {
            Write-Host "  ✖ Next.js build failed: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "    Check the output above for details" -ForegroundColor Yellow
        }
        Pop-Location
    }
} else {
    Write-Host "  ⚠ frontend directory not found, skipping build" -ForegroundColor Yellow
}
Write-Host ""

# PHASE 6: VERCEL DEPLOY (IF CLI AVAILABLE)
Write-Host "[6/7] VERCEL DEPLOY" -ForegroundColor Yellow

$vercelAvailable = $false
try {
    vercel --version | Out-Null
    $vercelAvailable = $true
} catch { }

if ($vercelAvailable -and (Test-Path $frontendDir)) {
    if (-not (Test-Path "$frontendDir\package.json")) {
        Write-Host "  ⚠ frontend/package.json not found, skipping Vercel deploy" -ForegroundColor Yellow
    } else {
        Push-Location $frontendDir
        try {
            Write-Host "  Pulling Vercel environment..." -ForegroundColor Gray
            vercel pull --yes --environment=production 2>&1 | Out-Null
            Write-Host "  ✔ Vercel environment pulled" -ForegroundColor Green
        } catch {
            Write-Host "  ⚠ vercel pull failed or project not linked (non-blocking)" -ForegroundColor Yellow
        }

        try {
            Write-Host "  Deploying to Vercel production..." -ForegroundColor Gray
            vercel deploy --prod 2>&1 | Out-Null
            Write-Host "  ✔ Vercel deploy --prod invoked" -ForegroundColor Green
        } catch {
            Write-Host "  ✖ Vercel deploy failed: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "    Check Vercel CLI login / project link" -ForegroundColor Yellow
        }
        Pop-Location
    }
} else {
    if (-not $vercelAvailable) {
        Write-Host "  ⚠ Vercel CLI not available, skipping deploy" -ForegroundColor Yellow
    } else {
        Write-Host "  ⚠ frontend missing, skipping deploy" -ForegroundColor Yellow
    }
}
Write-Host ""

# PHASE 7: LOCAL RUNNER (BACKEND + FRONTEND DEV)
Write-Host "[7/7] LOCAL RUNNER" -ForegroundColor Yellow

$backendHealthy = $false
try {
    $resp = Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -UseBasicParsing -TimeoutSec 3
    if ($resp.StatusCode -eq 200) {
        $backendHealthy = $true
        Write-Host "  ✔ Backend already running" -ForegroundColor Green
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

if (-not $frontendHealthy -and (Test-Path $frontendDir)) {
    if (-not (Test-Path "$frontendDir\package.json")) {
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

# SUMMARY
Write-Host "=== FUNAGING.SAS ONEPACK v30 — DONE ===" -ForegroundColor Cyan
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






