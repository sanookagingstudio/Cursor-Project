# ================================
# ONE PACK v18 — SAS SYSTEM RESTORE
# ================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== SAS ONE PACK v18 — START SYSTEM RESTORE ===" -ForegroundColor Cyan
Write-Host ""

# ---------- PHASE 1: CLEAN & PREPARE BACKEND ----------
Write-Host "[1/8] RESTORING BACKEND BASELINE..." -ForegroundColor Yellow

$backendPath = "backend"
$restorePath = "backend/app"

# ลบ main.py ที่เสีย + คืน baseline
if (Test-Path "$restorePath/main.py") {
    Remove-Item "$restorePath/main.py" -Force -ErrorAction SilentlyContinue
    Write-Host "  Removed existing main.py" -ForegroundColor Gray
}

if (Test-Path "backend/app/new_main.py") {
    Copy-Item "backend/app/new_main.py" "$restorePath/main.py" -Force
    Write-Host "  ✔ Copied new_main.py → main.py" -ForegroundColor Green
} else {
    Write-Host "  ⚠ new_main.py not found — skipping main.py restore" -ForegroundColor Yellow
}

# Restore routes folder structure
if (-not (Test-Path "$restorePath/routes")) {
    New-Item -ItemType Directory -Force "$restorePath/routes" | Out-Null
    Write-Host "  Created routes/ directory" -ForegroundColor Gray
}

if (Test-Path "backend/app/routes_backup") {
    Copy-Item "backend/app/routes_backup/*" "$restorePath/routes" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  ✔ Restored routes from routes_backup/" -ForegroundColor Green
} else {
    Write-Host "  ⚠ routes_backup/ not found — skipping route restore" -ForegroundColor Yellow
}

Write-Host "✔ Backend baseline restored" -ForegroundColor Green
Write-Host ""

# ---------- PHASE 2: REPAIR ROUTING ----------
Write-Host "[2/8] FIXING ROUTING..." -ForegroundColor Yellow

$routes = @("trip.py", "office.py", "media.py")
$routesRestored = 0

foreach ($r in $routes) {
    if (-not (Test-Path "$restorePath/routes/$r")) {
        if (Test-Path "backend/app/routes_backup/$r") {
            Copy-Item "backend/app/routes_backup/$r" "$restorePath/routes/$r" -Force
            Write-Host "  ✔ Restored routes/$r" -ForegroundColor Green
            $routesRestored++
        } else {
            Write-Host "  ⚠ routes_backup/$r not found — skipping" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ✓ routes/$r already exists" -ForegroundColor Gray
    }
}

if ($routesRestored -gt 0) {
    Write-Host "✔ Routing repaired ($routesRestored files restored)" -ForegroundColor Green
} else {
    Write-Host "✔ Routing check complete" -ForegroundColor Green
}
Write-Host ""

# ---------- PHASE 3: SUPABASE ROLE & PROFILE FIX ----------
Write-Host "[3/8] SUPABASE ROLE SYNC..." -ForegroundColor Yellow

$sbUrl = $env:SUPABASE_URL
$sbKey = $env:SUPABASE_SERVICE_ROLE_KEY

if (-not $sbUrl -or -not $sbKey) {
    Write-Host "  ⚠ SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY not set in environment" -ForegroundColor Yellow
    Write-Host "  Skipping Supabase role sync (manual step required)" -ForegroundColor Yellow
} else {
    $headers = @{
        "apikey" = $sbKey
        "Authorization" = "Bearer $sbKey"
        "Content-Type" = "application/json"
    }

    # Force admin/staff separation
    $adminEmail = "sanookagingstudio@gmail.com"
    $staffEmail = "akemontree@gmail.com"

    try {
        $body = @{
            admin_email = $adminEmail
            staff_email = $staffEmail
        } | ConvertTo-Json

        Invoke-RestMethod -Method Post -Uri "$sbUrl/rest/v1/rpc/fix_user_roles" -Headers $headers -Body $body -ErrorAction SilentlyContinue
        Write-Host "  ✔ Supabase role sync attempted" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ Supabase role sync failed (may need manual fix): $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "  → Use Supabase SQL Editor to fix admin/staff UUID manually" -ForegroundColor Cyan
    }
}

Write-Host "✔ Supabase roles check complete" -ForegroundColor Green
Write-Host ""

# ---------- PHASE 4: RESTORE ENV FILES ----------
Write-Host "[4/8] RESTORING ENV FILES..." -ForegroundColor Yellow

$envRestored = 0

if (Test-Path ".env.example") {
    Copy-Item ".env.example" ".env" -Force -ErrorAction SilentlyContinue
    Write-Host "  ✔ Restored .env from .env.example" -ForegroundColor Green
    $envRestored++
} else {
    Write-Host "  ⚠ .env.example not found — skipping .env restore" -ForegroundColor Yellow
}

if (Test-Path "frontend/.env.local.example") {
    if (-not (Test-Path "frontend")) {
        New-Item -ItemType Directory -Path "frontend" | Out-Null
    }
    Copy-Item "frontend/.env.local.example" "frontend/.env.local" -Force -ErrorAction SilentlyContinue
    Write-Host "  ✔ Restored frontend/.env.local from .env.local.example" -ForegroundColor Green
    $envRestored++
} else {
    Write-Host "  ⚠ frontend/.env.local.example not found — skipping frontend env restore" -ForegroundColor Yellow
}

if ($envRestored -gt 0) {
    Write-Host "✔ ENV files restored ($envRestored files)" -ForegroundColor Green
} else {
    Write-Host "✔ ENV files check complete (no examples found)" -ForegroundColor Green
}
Write-Host ""

# ---------- PHASE 5: BACKEND DEPENDENCIES ----------
Write-Host "[5/8] INSTALLING BACKEND DEPENDENCIES..." -ForegroundColor Yellow

if (-not (Test-Path "backend/requirements.txt")) {
    Write-Host "  ⚠ backend/requirements.txt not found — skipping backend dependencies" -ForegroundColor Yellow
} else {
    try {
        Push-Location backend
        python -m pip install --upgrade pip 2>&1 | Out-Null
        pip install -r requirements.txt 2>&1 | Out-Null
        Write-Host "  ✔ Backend dependencies installed" -ForegroundColor Green
        Pop-Location
    } catch {
        Write-Host "  ⚠ Backend dependency installation failed: $($_.Exception.Message)" -ForegroundColor Yellow
        Pop-Location
    }
}

Write-Host "✔ Backend dependencies check complete" -ForegroundColor Green
Write-Host ""

# ---------- PHASE 6: FRONTEND DEPENDENCIES ----------
Write-Host "[6/8] INSTALLING FRONTEND DEPENDENCIES..." -ForegroundColor Yellow

if (-not (Test-Path "frontend/package.json")) {
    Write-Host "  ⚠ frontend/package.json not found — skipping frontend dependencies" -ForegroundColor Yellow
} else {
    try {
        Push-Location frontend
        npm install --force 2>&1 | Out-Null
        Write-Host "  ✔ Frontend dependencies installed" -ForegroundColor Green
        Pop-Location
    } catch {
        Write-Host "  ⚠ Frontend dependency installation failed: $($_.Exception.Message)" -ForegroundColor Yellow
        Pop-Location
    }
}

Write-Host "✔ Frontend dependencies check complete" -ForegroundColor Green
Write-Host ""

# ---------- PHASE 7: HEALTH CHECK ----------
Write-Host "[7/8] RUNNING HEALTH CHECK..." -ForegroundColor Yellow

# Check if backend is already running
$backendRunning = $false
try {
    $check = Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
    if ($check.StatusCode -eq 200) {
        $backendRunning = $true
        Write-Host "  ✔ Backend already running and healthy" -ForegroundColor Green
    }
} catch {
    # Backend not running, that's OK
}

if (-not $backendRunning) {
    Write-Host "  ℹ Backend not running — start manually with:" -ForegroundColor Cyan
    Write-Host "    cd backend && uvicorn app.main:app --reload" -ForegroundColor White
    Write-Host "  Or use Docker:" -ForegroundColor Cyan
    Write-Host "    docker compose -f docker-compose.sas.yml up -d" -ForegroundColor White
}

Write-Host "✔ Health check complete" -ForegroundColor Green
Write-Host ""

# ---------- PHASE 8: DONE ----------
Write-Host "=== SAS ONE PACK v18 COMPLETED ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Start backend:" -ForegroundColor White
Write-Host "     cd backend" -ForegroundColor Gray
Write-Host "     uvicorn app.main:app --reload" -ForegroundColor Gray
Write-Host ""
Write-Host "     OR use Docker:" -ForegroundColor White
Write-Host "     docker compose -f docker-compose.sas.yml up -d" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Start frontend:" -ForegroundColor White
Write-Host "     cd frontend" -ForegroundColor Gray
Write-Host "     npm run dev" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Verify system:" -ForegroundColor White
Write-Host "     pwsh .\onepack_verifier_v13.ps1" -ForegroundColor Gray
Write-Host ""






