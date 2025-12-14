# =========================================================
# ONEPACK v55.1 — AUTO ENV + ADMIN PANEL APPLY (FINAL)
# =========================================================

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== ONEPACK v55.1 — AUTO ENV + ADMIN PANEL ===" -ForegroundColor Cyan
Write-Host ""

# -------- PHASE 1: LOAD ENV FROM frontend/.env.local --------
Write-Host "[1/6] LOAD ENV FROM frontend/.env.local" -ForegroundColor Yellow

$envFile = Join-Path $scriptDir "frontend\.env.local"
if (-not (Test-Path $envFile)) {
    Write-Host "  ✖ frontend/.env.local NOT FOUND" -ForegroundColor Red
    Write-Host "    Create frontend/.env.local with required Supabase variables." -ForegroundColor Yellow
    Write-Host "    Example:" -ForegroundColor Cyan
    Write-Host "      NEXT_PUBLIC_SUPABASE_URL=your-url" -ForegroundColor Gray
    Write-Host "      NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key" -ForegroundColor Gray
    Write-Host "      SUPABASE_SERVICE_ROLE_KEY=your-service-key" -ForegroundColor Gray
    exit 1
}

Write-Host "  Reading environment variables from $envFile..." -ForegroundColor Gray

$envLoaded = 0
Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    # Skip comments and empty lines
    if ($line -match "^\s*#" -or $line -match "^\s*$") { return }
    
    # Parse KEY=VALUE
    if ($line -match "^([^=]+)=(.*)$") {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        
        # Remove quotes if present
        if ($value -match "^['""](.*)['""]$") {
            $value = $matches[1]
        }
        
        # Set environment variable
        Set-Item -Path "env:$name" -Value $value -ErrorAction SilentlyContinue
        $envLoaded++
    }
}

Write-Host "  ✔ Loaded $envLoaded environment variables" -ForegroundColor Green

# Verify required variables
$required = @(
    "NEXT_PUBLIC_SUPABASE_URL",
    "NEXT_PUBLIC_SUPABASE_ANON_KEY",
    "SUPABASE_SERVICE_ROLE_KEY"
)

$missingEnv = @()
foreach ($k in $required) {
    $envValue = (Get-Item "env:$k" -ErrorAction SilentlyContinue).Value
    if (-not $envValue) {
        Write-Host "  ✖ ENV $k MISSING" -ForegroundColor Red
        $missingEnv += $k
    } else {
        Write-Host "  ✔ ENV $k LOADED" -ForegroundColor Green
    }
}

if ($missingEnv.Count -gt 0) {
    Write-Host ""
    Write-Host "  ⚠ Missing required environment variables:" -ForegroundColor Yellow
    $missingEnv | ForEach-Object { Write-Host "      - $_" -ForegroundColor Yellow }
    Write-Host "    Please add them to frontend/.env.local" -ForegroundColor Cyan
    exit 1
}

Write-Host ""

# -------- PHASE 2: RUN ONEPACK v55 --------
Write-Host "[2/6] RUN ONEPACK v55" -ForegroundColor Yellow

$onepack55 = Join-Path $scriptDir "onepack_funaging_v55.ps1"
if (-not (Test-Path $onepack55)) {
    Write-Host "  ✖ onepack_funaging_v55.ps1 NOT FOUND" -ForegroundColor Red
    Write-Host "    Please ensure onepack_funaging_v55.ps1 exists in the project root." -ForegroundColor Yellow
    exit 1
}

Write-Host "  Running onepack_funaging_v55.ps1..." -ForegroundColor Gray
try {
    & $onepack55
    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne $null) {
        Write-Host "  ⚠ ONEPACK v55 exited with code: $LASTEXITCODE" -ForegroundColor Yellow
    } else {
        Write-Host "  ✔ ONEPACK v55 completed" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✖ ONEPACK v55 failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "    Continuing anyway..." -ForegroundColor Yellow
}
Write-Host ""

# -------- PHASE 3: RESTART FRONTEND --------
Write-Host "[3/6] RESTART FRONTEND" -ForegroundColor Yellow

$frontendDir = Join-Path $scriptDir "frontend"
if (-not (Test-Path $frontendDir)) {
    Write-Host "  ✖ frontend directory not found" -ForegroundColor Red
    exit 1
}

# Stop existing Node processes (Next.js dev server)
Write-Host "  Stopping existing frontend processes..." -ForegroundColor Gray
try {
    $nodeProcesses = Get-Process node -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -like "*node.exe*"
    }
    if ($nodeProcesses) {
        $nodeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Host "  ✔ Stopped existing Node processes" -ForegroundColor Green
    } else {
        Write-Host "  ✓ No existing Node processes found" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ⚠ Could not stop existing processes: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Start frontend dev server
Write-Host "  Starting frontend dev server..." -ForegroundColor Gray
$frontendCmd = "-NoExit -Command `"cd '$frontendDir'; npm run dev`""
try {
    Start-Process powershell -ArgumentList $frontendCmd -WindowStyle Normal
    Write-Host "  Waiting for frontend to start..." -ForegroundColor Gray
    Start-Sleep -Seconds 8
    
    # Verify frontend is starting
    $maxRetries = 5
    $retryCount = 0
    $frontendReady = $false
    
    while ($retryCount -lt $maxRetries) {
        try {
            $resp = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 3
            if ($resp.StatusCode -eq 200) {
                $frontendReady = $true
                break
            }
        } catch {
            $retryCount++
            if ($retryCount -lt $maxRetries) {
                Start-Sleep -Seconds 3
            }
        }
    }
    
    if ($frontendReady) {
        Write-Host "  ✔ Frontend restarted and ready" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Frontend may still be starting (check the PowerShell window)" -ForegroundColor Yellow
        Write-Host "    Next.js typically takes 10-30 seconds to compile on first run." -ForegroundColor Gray
    }
} catch {
    Write-Host "  ✖ Failed to start frontend: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "    Start manually with: cd frontend && npm run dev" -ForegroundColor Cyan
}
Write-Host ""

# -------- PHASE 4: HEALTH CHECK --------
Write-Host "[4/6] HEALTH CHECK" -ForegroundColor Yellow

$urls = @(
    @{ url = "http://localhost:3000"; name = "Frontend Root" },
    @{ url = "http://localhost:3000/admin/users"; name = "Admin Panel" },
    @{ url = "http://localhost:3000/dashboard"; name = "Dashboard" }
)

$healthyUrls = 0
foreach ($u in $urls) {
    try {
        $resp = Invoke-WebRequest -Uri $u.url -UseBasicParsing -TimeoutSec 5
        if ($resp.StatusCode -eq 200) {
            Write-Host "  ✔ $($u.name) ($($u.url)) OK" -ForegroundColor Green
            $healthyUrls++
        } else {
            Write-Host "  ⚠ $($u.name) ($($u.url)) returned status $($resp.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq 401 -or $statusCode -eq 403) {
            Write-Host "  ⚠ $($u.name) ($($u.url)) requires authentication (expected)" -ForegroundColor Cyan
        } else {
            Write-Host "  ⚠ $($u.name) ($($u.url)) NOT READY (may still be starting)" -ForegroundColor Yellow
        }
    }
}

if ($healthyUrls -eq 0) {
    Write-Host "  ⚠ No URLs responded (frontend may still be compiling)" -ForegroundColor Yellow
    Write-Host "    Wait a few seconds and check http://localhost:3000 manually" -ForegroundColor Cyan
}
Write-Host ""

# -------- PHASE 5: FINAL STATUS --------
Write-Host "[5/6] FINAL STATUS" -ForegroundColor Yellow

Write-Host ""
Write-Host "Admin Panel Setup Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Access URLs:" -ForegroundColor White
Write-Host "  • Admin Panel: http://localhost:3000/admin/users" -ForegroundColor Gray
Write-Host "  • Dashboard:   http://localhost:3000/dashboard" -ForegroundColor Gray
Write-Host "  • Frontend:    http://localhost:3000" -ForegroundColor Gray
Write-Host ""
Write-Host "Authentication:" -ForegroundColor White
Write-Host "  • Login as admin: sanookagingstudio@gmail.com" -ForegroundColor Gray
Write-Host "  • Admin panel requires admin role" -ForegroundColor Gray
Write-Host "  • Create /auth/login page if it doesn't exist" -ForegroundColor Yellow
Write-Host ""
Write-Host "Features:" -ForegroundColor White
Write-Host "  • View all users with roles" -ForegroundColor Gray
Write-Host "  • Change user roles (admin, staff, user)" -ForegroundColor Gray
Write-Host "  • Protected with role guard" -ForegroundColor Gray
Write-Host ""

# -------- PHASE 6: DONE --------
Write-Host "[6/6] DONE" -ForegroundColor Yellow

Write-Host ""
Write-Host "=== ONEPACK v55.1 COMPLETE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Ensure frontend dev server is running" -ForegroundColor Gray
Write-Host "  2. Navigate to http://localhost:3000/admin/users" -ForegroundColor Gray
Write-Host "  3. Login with admin credentials" -ForegroundColor Gray
Write-Host "  4. Manage user roles from the admin panel" -ForegroundColor Gray
Write-Host ""
Write-Host "Note: Frontend is running in a separate PowerShell window." -ForegroundColor Yellow
Write-Host "      Close that window to stop the dev server." -ForegroundColor Yellow
Write-Host ""





