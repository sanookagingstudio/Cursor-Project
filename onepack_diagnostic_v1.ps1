# onepack_diagnostic_v1.ps1
# FULL SYSTEM DIAGNOSTIC for FunAging.club project
# Detects all missing/misplaced backend files, compose issues,
# invalid Dockerfile paths, and broken baseline problems.

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "   ONEPACK DIAGNOSTIC v1 — FunAging.club (SAS v1 Baseline)" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

$root = Get-Location
$backend = Join-Path $root "backend"
$compose = Join-Path $root "docker-compose.sas.yml"
$diag_fail = $false

# -------------------------------------------------------------
# 1) CHECK: backend folder exists
# -------------------------------------------------------------
Write-Host "[1] Checking backend folder..." -ForegroundColor Yellow

if (-not (Test-Path $backend)) {
    Write-Host "❌ backend/ folder NOT FOUND" -ForegroundColor Red
    $diag_fail = $true
} else {
    Write-Host "✔ backend/ folder exists" -ForegroundColor Green
}

# -------------------------------------------------------------
# 2) CHECK: critical backend files
# -------------------------------------------------------------
Write-Host "`n[2] Checking backend critical files..." -ForegroundColor Yellow

$critical = @(
    "app",
    "app\main.py",
    "app\new_main.py",
    "requirements.txt",
    "Dockerfile.backend"
)

foreach ($item in $critical) {
    $path = Join-Path $backend $item
    if (Test-Path $path) {
        Write-Host "✔ $item" -ForegroundColor Green
    } else {
        Write-Host "❌ MISSING: backend\$item" -ForegroundColor Red
        $diag_fail = $true
    }
}

# -------------------------------------------------------------
# 3) CHECK: examine backend/app structure
# -------------------------------------------------------------
Write-Host "`n[3] Inspecting backend/app structure..." -ForegroundColor Yellow

$app = Join-Path $backend "app"

if (Test-Path $app) {
    Write-Host "✔ app/ exists" -ForegroundColor Green

    if (Test-Path "$app\routes") {
        Write-Host "  ✔ routes/ exists" -ForegroundColor Green

        $routes = @("trip.py","office.py","media.py")
        foreach ($r in $routes) {
            if (Test-Path "$app\routes\$r") {
                Write-Host "    ✔ routes/$r" -ForegroundColor Green
            } else {
                Write-Host "    ❌ routes/$r missing" -ForegroundColor Red
                $diag_fail = $true
            }
        }
    } else {
        Write-Host "❌ app/routes/ missing" -ForegroundColor Red
        $diag_fail = $true
    }
} else {
    Write-Host "❌ backend/app folder is missing entirely" -ForegroundColor Red
    $diag_fail = $true
}

# -------------------------------------------------------------
# 4) CHECK: Dockerfile.backend location
# -------------------------------------------------------------
Write-Host "`n[4] Checking Dockerfile.backend location..." -ForegroundColor Yellow

$dockerfile1 = Join-Path $backend "Dockerfile.backend"
$dockerfile2 = Join-Path $root "Dockerfile.backend"

if (Test-Path $dockerfile1) {
    Write-Host "✔ Dockerfile.backend is in CORRECT location (backend/)" -ForegroundColor Green
} elseif (Test-Path $dockerfile2) {
    Write-Host "❌ Dockerfile.backend found in WRONG location (root)" -ForegroundColor Red
    Write-Host "   → Should be moved to backend/Dockerfile.backend" -ForegroundColor Yellow
    $diag_fail = $true
} else {
    Write-Host "❌ Dockerfile.backend missing entirely" -ForegroundColor Red
    $diag_fail = $true
}

# -------------------------------------------------------------
# 5) CHECK: docker-compose.sas.yml exists
# -------------------------------------------------------------
Write-Host "`n[5] Checking docker-compose.sas.yml..." -ForegroundColor Yellow

if (-not (Test-Path $compose)) {
    Write-Host "❌ docker-compose.sas.yml missing" -ForegroundColor Red
    $diag_fail = $true
} else {
    Write-Host "✔ docker-compose.sas.yml found" -ForegroundColor Green

    # Basic check inside compose
    $compose_text = Get-Content $compose | Out-String

    if ($compose_text -notmatch "sas_db") {
        Write-Host "❌ compose missing 'sas_db' service" -ForegroundColor Red
        $diag_fail = $true
    } else {
        Write-Host "✔ sas_db service exists" -ForegroundColor Green
    }

    if ($compose_text -notmatch "sas_backend") {
        Write-Host "❌ compose missing 'sas_backend' service" -ForegroundColor Red
        $diag_fail = $true
    } else {
        Write-Host "✔ sas_backend service exists" -ForegroundColor Green
    }
}

# -------------------------------------------------------------
# FINAL RESULT
# -------------------------------------------------------------
Write-Host "`n==============================================================" -ForegroundColor Cyan

if ($diag_fail -eq $false) {
    Write-Host "  ✅ DIAGNOSTIC PASSED — Project structure is correct" -ForegroundColor Green
    Write-Host "==============================================================" -ForegroundColor Cyan
} else {
    Write-Host "  ❌ DIAGNOSTIC FAILED — Missing or misplaced files detected" -ForegroundColor Red
    Write-Host "  → Fix files as reported above OR run ONEPACK_RESTORE (v11)" -ForegroundColor Yellow
    Write-Host "==============================================================" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Done."
Write-Host ""


