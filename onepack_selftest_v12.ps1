# =======================
# ONEPACK SELFTEST v12
# =======================

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "=== FunAging.club SELF-TEST v12 ===" -ForegroundColor Cyan
Write-Host ""

# ------------------[ A ] ตรวจสอบโครงสร้างโปรเจกต์ ------------------
Write-Host "[A] Checking project structure..." -ForegroundColor Yellow

$backendOk = (Test-Path "backend/app/main.py") -and (Test-Path "backend/requirements.txt")
$frontendOk = Test-Path "frontend"
$composeOk = Test-Path "docker-compose.sas.yml"
$dockerfileOk = Test-Path "backend/Dockerfile.backend"

if ($backendOk) {
    Write-Host " - backend folder: OK" -ForegroundColor Green
} else {
    Write-Host " - backend folder: MISSING" -ForegroundColor Red
}

if ($frontendOk) {
    Write-Host " - frontend folder: OK" -ForegroundColor Green
} else {
    Write-Host " - frontend folder: MISSING" -ForegroundColor Red
}

if ($composeOk) {
    Write-Host " - compose file: OK" -ForegroundColor Green
} else {
    Write-Host " - compose file: MISSING" -ForegroundColor Red
}

if ($dockerfileOk) {
    Write-Host " - backend Dockerfile: OK" -ForegroundColor Green
} else {
    Write-Host " - backend Dockerfile: MISSING" -ForegroundColor Red
}

# ------------------[ B ] ตรวจสอบ Docker Engine ------------------
Write-Host "`n[B] Checking Docker Engine..." -ForegroundColor Yellow

try {
    $null = docker info 2>&1
    Write-Host " - Docker Engine: OK" -ForegroundColor Green
} catch {
    Write-Host " - Docker Engine NOT RUNNING" -ForegroundColor Red
    Write-Host "   Please start Docker Desktop and try again." -ForegroundColor Yellow
    exit 1
}

# ------------------[ C ] รัน docker compose ------------------
Write-Host "`n[C] Starting containers..." -ForegroundColor Yellow

try {
    Write-Host "  Stopping existing containers..." -ForegroundColor Gray
    docker compose -f docker-compose.sas.yml down 2>&1 | Out-Null
    
    Write-Host "  Building and starting containers..." -ForegroundColor Gray
    docker compose -f docker-compose.sas.yml up -d --build
    
    Write-Host " - Containers started" -ForegroundColor Green
} catch {
    Write-Host " - Failed to start containers: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "  Waiting for services to initialize..." -ForegroundColor Gray
Start-Sleep -Seconds 6

# ------------------[ D ] ตรวจสอบ container status ------------------
Write-Host "`n[D] Checking containers..." -ForegroundColor Yellow

try {
    $ps = docker ps --format "{{.Names}} | {{.Status}}"
    if ($ps) {
        Write-Host $ps
        Write-Host " - Container status: OK" -ForegroundColor Green
    } else {
        Write-Host " - No containers running" -ForegroundColor Red
    }
} catch {
    Write-Host " - Failed to check container status" -ForegroundColor Red
}

# Check specific containers
$sasBackendRunning = docker ps --format "{{.Names}}" | Select-String -Pattern "sas_backend"
$sasDbRunning = docker ps --format "{{.Names}}" | Select-String -Pattern "sas_db"

if ($sasBackendRunning) {
    Write-Host " - sas_backend: Running" -ForegroundColor Green
} else {
    Write-Host " - sas_backend: NOT RUNNING" -ForegroundColor Red
}

if ($sasDbRunning) {
    Write-Host " - sas_db: Running" -ForegroundColor Green
} else {
    Write-Host " - sas_db: NOT RUNNING" -ForegroundColor Red
}

# ------------------[ E ] Backend Healthcheck ------------------
Write-Host "`n[E] Backend Healthcheck..." -ForegroundColor Yellow

$backendHealthy = $false

# Check /health endpoint
try {
    $health = Invoke-WebRequest "http://localhost:8000/health" -UseBasicParsing -TimeoutSec 5
    if ($health.StatusCode -eq 200) {
        Write-Host " - Backend /health: OK" -ForegroundColor Green
        Write-Host "   Response: $($health.Content)" -ForegroundColor Gray
        $backendHealthy = $true
    }
} catch {
    Write-Host " - Backend /health: NOT RESPONDING" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
}

# Check root endpoint
try {
    $root = Invoke-WebRequest "http://localhost:8000/" -UseBasicParsing -TimeoutSec 5
    if ($root.StatusCode -eq 200) {
        Write-Host "`n - Backend / : OK" -ForegroundColor Green
        Write-Host "   Response: $($root.Content)" -ForegroundColor Gray
    }
} catch {
    Write-Host "`n - Backend / : NOT RESPONDING" -ForegroundColor Red
}

if (-not $backendHealthy) {
    Write-Host "`n⚠ Backend health check failed. Check logs below." -ForegroundColor Yellow
}

# ------------------[ F ] Backend Logs ------------------
Write-Host "`n[F] Backend logs (last 20 lines)..." -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

try {
    $backendLogs = docker logs sas_backend --tail 20 2>&1
    Write-Host $backendLogs
} catch {
    Write-Host "Failed to retrieve backend logs: $($_.Exception.Message)" -ForegroundColor Red
}

# ------------------[ G ] Database Logs ------------------
Write-Host "`n[G] Database logs (last 20 lines)..." -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

try {
    $dbLogs = docker logs sas_db --tail 20 2>&1
    Write-Host $dbLogs
} catch {
    Write-Host "Failed to retrieve database logs: $($_.Exception.Message)" -ForegroundColor Red
}

# ------------------[ H ] Frontend Test ------------------
Write-Host "`n[H] Frontend sanity check..." -ForegroundColor Yellow

if (Test-Path "frontend/.env.local") {
    Write-Host " - .env.local exists" -ForegroundColor Green
    
    $envContent = Get-Content "frontend/.env.local" -Raw
    if ($envContent -match "NEXT_PUBLIC_API_URL") {
        Write-Host " - NEXT_PUBLIC_API_URL configured" -ForegroundColor Green
    } else {
        Write-Host " - NEXT_PUBLIC_API_URL missing" -ForegroundColor Yellow
    }
} else {
    Write-Host " - .env.local missing" -ForegroundColor Yellow
    Write-Host "   → Run frontend/setup-env.ps1 to create it" -ForegroundColor Cyan
}

if (Test-Path "frontend/package.json") {
    Write-Host " - package.json exists" -ForegroundColor Green
} else {
    Write-Host " - package.json missing" -ForegroundColor Red
}

# Check if frontend dev server is running
try {
    $frontendCheck = Invoke-WebRequest "http://localhost:3000" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
    if ($frontendCheck.StatusCode -eq 200) {
        Write-Host " - Frontend dev server: Running on port 3000" -ForegroundColor Green
    }
} catch {
    Write-Host " - Frontend dev server: Not running" -ForegroundColor Gray
    Write-Host "   → Start with: cd frontend && npm run dev" -ForegroundColor Cyan
}

# ------------------[ SUMMARY ] ------------------
Write-Host ""
Write-Host "=== SELF-TEST COMPLETE ===" -ForegroundColor Cyan
Write-Host ""

# Summary
$allChecks = @(
    @{Name="Project Structure"; Pass=$backendOk -and $frontendOk -and $composeOk -and $dockerfileOk},
    @{Name="Docker Engine"; Pass=$true},
    @{Name="Containers Running"; Pass=$sasBackendRunning -and $sasDbRunning},
    @{Name="Backend Health"; Pass=$backendHealthy}
)

$passed = ($allChecks | Where-Object { $_.Pass }).Count
$total = $allChecks.Count

Write-Host "Summary: $passed/$total checks passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
Write-Host ""
Write-Host "Backend URL:  http://localhost:8000/health" -ForegroundColor White
Write-Host "Frontend URL: http://localhost:3000" -ForegroundColor White
Write-Host ""
