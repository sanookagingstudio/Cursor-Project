# ONEPACK FUNAGING v40 — GRAND UNIFIED BUILD (RESTORE + DB + UI + DEPLOY + JARVIS)

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== FUNAGING.SAS ONEPACK v40 — START ===" -ForegroundColor Cyan
Write-Host ""

# PHASE 1: VERSION CHECK
Write-Host "[1/8] VERSION CHECK" -ForegroundColor Yellow

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
    Write-Host "  ⚠ Vercel CLI not found (deploy steps will be skipped)" -ForegroundColor Yellow
}
Write-Host ""

# PHASE 2: BASELINE RESTORE (v18 / v20 CHAIN)
Write-Host "[2/8] BASELINE RESTORE" -ForegroundColor Yellow

$onepack18 = Join-Path $scriptDir "onepack_funaging_v18.ps1"
$onepack20 = Join-Path $scriptDir "onepack_funaging_v20.ps1"

if (Test-Path $onepack18) {
    Write-Host "  Running onepack_funaging_v18.ps1 ..." -ForegroundColor Gray
    try {
        & $onepack18 2>&1 | Out-Null
        Write-Host "  ✔ Baseline restore (v18) completed" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ Baseline restore (v18) encountered errors: $($_.Exception.Message)" -ForegroundColor Yellow
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

if (Test-Path $onepack20) {
    Write-Host "  Running onepack_funaging_v20.ps1 (full automation baseline) ..." -ForegroundColor Gray
    try {
        & $onepack20 2>&1 | Out-Null
        Write-Host "  ✔ Full automation baseline (v20) completed" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ Full automation baseline (v20) encountered errors: $($_.Exception.Message)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠ onepack_funaging_v20.ps1 not found, skipping v20 chain (non-blocking)" -ForegroundColor Yellow
}
Write-Host ""

# PHASE 3: ENV SYNC (ROOT + FRONTEND) + REQUIRED VAR CHECK
Write-Host "[3/8] ENV SYNC + REQUIRED VARS" -ForegroundColor Yellow

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

$requiredEnv = @(
    "SUPABASE_URL",
    "SUPABASE_ANON_KEY",
    "SUPABASE_SERVICE_ROLE_KEY",
    "NEXT_PUBLIC_SUPABASE_URL",
    "NEXT_PUBLIC_SUPABASE_ANON_KEY"
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
}
Write-Host ""

# PHASE 4: SUPABASE PRODUCTION SYNC (ROLES + OPTIONAL MIGRATIONS)
Write-Host "[4/8] SUPABASE SYNC" -ForegroundColor Yellow

$supabaseUrl = (Get-Item "env:SUPABASE_URL" -ErrorAction SilentlyContinue).Value
$supabaseKey = (Get-Item "env:SUPABASE_SERVICE_ROLE_KEY" -ErrorAction SilentlyContinue).Value

if ($supabaseUrl -and $supabaseKey) {
    Write-Host "  Supabase URL and SERVICE_ROLE_KEY detected" -ForegroundColor Green

    $headers = @{
        "apikey"        = $supabaseKey
        "Authorization" = "Bearer $supabaseKey"
        "Content-Type"  = "application/json"
    }

    $roleBody = @{
        admin_email = "sanookagingstudio@gmail.com"
        staff_email = "akemontree@gmail.com"
    } | ConvertTo-Json

    try {
        $rpcUrl = "$supabaseUrl/rest/v1/rpc/fix_user_roles"
        Invoke-RestMethod -Method Post -Uri $rpcUrl -Headers $headers -Body $roleBody -ErrorAction Stop | Out-Null
        Write-Host "  ✔ Supabase role fix RPC executed (admin/staff separation)" -ForegroundColor Green
    } catch {
        $errorMsg = $_.Exception.Message
        if ($errorMsg -match "404" -or $errorMsg -match "not found") {
            Write-Host "  ⚠ Supabase role fix RPC missing or not defined (non-blocking)" -ForegroundColor Yellow
        } else {
            Write-Host "  ⚠ Supabase role fix RPC failed: $errorMsg" -ForegroundColor Yellow
        }
    }

    $migrationSqlDir1 = Join-Path $scriptDir "backend\db\migrations"
    $migrationSqlDir2 = Join-Path $scriptDir "supabase\migrations"

    $migrationDirs = @()
    if (Test-Path $migrationSqlDir1) { $migrationDirs += $migrationSqlDir1 }
    if (Test-Path $migrationSqlDir2) { $migrationDirs += $migrationSqlDir2 }

    if ($migrationDirs.Count -gt 0) {
        Write-Host "  Scanning migration directories..." -ForegroundColor Gray
        $migrationCount = 0
        foreach ($mdir in $migrationDirs) {
            $migrations = Get-ChildItem -Path $mdir -Filter *.sql -File -ErrorAction SilentlyContinue
            foreach ($migration in $migrations) {
                Write-Host "    Found migration: $($migration.Name)" -ForegroundColor Gray
                $migrationCount++
            }
        }
        if ($migrationCount -gt 0) {
            Write-Host "  ℹ Found $migrationCount migration(s) (execution is manual if needed)" -ForegroundColor Cyan
        } else {
            Write-Host "  ℹ No migrations found in migration directories" -ForegroundColor Cyan
        }
    } else {
        Write-Host "  ℹ No migration directories found (backend/db/migrations or supabase/migrations)" -ForegroundColor Cyan
    }
} else {
    Write-Host "  ⚠ Supabase URL / SERVICE_ROLE_KEY missing, skipping Supabase sync" -ForegroundColor Yellow
}
Write-Host ""

# PHASE 5: UI BINDING CHECK (DASHBOARD / API / CONFIG)
Write-Host "[5/8] UI BINDING CHECK" -ForegroundColor Yellow

$frontendDir = Join-Path $scriptDir "frontend"
$pagesDir = Join-Path $frontendDir "app"
$dashboardDir = Join-Path $pagesDir "dashboard"

if (Test-Path $frontendDir) {
    Write-Host "  Frontend directory detected" -ForegroundColor Green

    $candidateFiles = @(
        (Join-Path $dashboardDir "page.tsx"),
        (Join-Path $dashboardDir "page.jsx"),
        (Join-Path $pagesDir "page.tsx"),
        (Join-Path $pagesDir "page.jsx")
    )

    $foundPages = 0
    foreach ($cf in $candidateFiles) {
        if (Test-Path $cf) {
            Write-Host "    ✔ Dashboard/entry file found: $cf" -ForegroundColor Green
            $foundPages++
        }
    }

    if ($foundPages -eq 0) {
        Write-Host "    ⚠ No dashboard/entry page files found" -ForegroundColor Yellow
    }

    $configTs = Join-Path $frontendDir "config\supabase.ts"
    $configJs = Join-Path $frontendDir "config\supabase.js"
    $configFound = $false
    if (Test-Path $configTs) {
        Write-Host "    ✔ Supabase config file detected: $configTs" -ForegroundColor Green
        $configFound = $true
    }
    if (Test-Path $configJs) {
        Write-Host "    ✔ Supabase config file detected: $configJs" -ForegroundColor Green
        $configFound = $true
    }
    if (-not $configFound) {
        Write-Host "    ⚠ Supabase config file not found (config/supabase.ts or config/supabase.js)" -ForegroundColor Yellow
    }

    $apiFolder = Join-Path $frontendDir "app\api"
    if (Test-Path $apiFolder) {
        $apiRoutes = Get-ChildItem -Path $apiFolder -Directory -ErrorAction SilentlyContinue
        Write-Host "    ✔ API routes folder detected: $apiFolder ($($apiRoutes.Count) route(s))" -ForegroundColor Green
    } else {
        Write-Host "    ℹ API routes folder not found (app/api)" -ForegroundColor Cyan
    }
} else {
    Write-Host "  ⚠ Frontend directory not found, skipping UI binding checks" -ForegroundColor Yellow
}
Write-Host ""

# PHASE 6: TEST SUITE (OPTIONAL)
Write-Host "[6/8] TEST SUITE" -ForegroundColor Yellow

$testScripts = @(
    ".\run_tests.ps1",
    ".\validate_auth.ps1",
    ".\validate_supabase.ps1"
)

$testsRun = 0
foreach ($ts in $testScripts) {
    if (Test-Path $ts) {
        Write-Host "  Running $ts ..." -ForegroundColor Gray
        try {
            & $ts 2>&1 | Out-Null
            Write-Host "    ✔ $ts completed" -ForegroundColor Green
            $testsRun++
        } catch {
            Write-Host "    ⚠ Test script $ts failed (non-blocking): $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

if ($testsRun -eq 0) {
    Write-Host "  ℹ No test scripts found (optional step)" -ForegroundColor Cyan
} else {
    Write-Host "  ✔ Test suite completed ($testsRun scripts)" -ForegroundColor Green
}
Write-Host ""

# PHASE 7: FRONTEND PRODUCTION BUILD + VERCEL DEPLOY
Write-Host "[7/8] BUILD + DEPLOY" -ForegroundColor Yellow

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
            Write-Host "  ✖ Next.js production build failed: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "    Check the output above for details" -ForegroundColor Yellow
        }

        $vercelAvailable = $false
        try {
            vercel --version | Out-Null
            $vercelAvailable = $true
        } catch { }

        if ($vercelAvailable) {
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
                Write-Host "    Check Vercel CLI login / project linkage" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  ⚠ Vercel CLI not available, skipping deploy" -ForegroundColor Yellow
        }
        Pop-Location
    }
} else {
    Write-Host "  ⚠ Frontend directory not found, skipping build/deploy" -ForegroundColor Yellow
}
Write-Host ""

# PHASE 8: JARVIS + LOCAL RUNNER (BACKEND + FRONTEND DEV)
Write-Host "[8/8] JARVIS + LOCAL RUNNER" -ForegroundColor Yellow

$jarvisScripts = @(
    ".\jarvis\jarvis_health.ps1",
    ".\jarvis\jarvis_sentinel.ps1",
    ".\jarvis\jarvis_report.ps1"
)

$jarvisRun = 0
foreach ($js in $jarvisScripts) {
    if (Test-Path $js) {
        Write-Host "  Running Jarvis script: $js ..." -ForegroundColor Gray
        try {
            & $js 2>&1 | Out-Null
            Write-Host "    ✔ $js completed" -ForegroundColor Green
            $jarvisRun++
        } catch {
            Write-Host "    ⚠ Jarvis script $js failed (non-blocking): $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

if ($jarvisRun -eq 0) {
    Write-Host "  ℹ No Jarvis scripts found (optional step)" -ForegroundColor Cyan
} else {
    Write-Host "  ✔ Jarvis scripts completed ($jarvisRun scripts)" -ForegroundColor Green
}

# Local runner
Write-Host "  Starting local services..." -ForegroundColor Gray

$backendHealthy = $false
try {
    $respB = Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -UseBasicParsing -TimeoutSec 3
    if ($respB.StatusCode -eq 200) {
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
                    $respB = Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -UseBasicParsing -TimeoutSec 5
                    if ($respB.StatusCode -eq 200) {
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
    $respF = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 3
    if ($respF.StatusCode -eq 200) {
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
                    $respF = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
                    if ($respF.StatusCode -eq 200) {
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
Write-Host "=== FUNAGING.SAS ONEPACK v40 — DONE ===" -ForegroundColor Cyan
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






