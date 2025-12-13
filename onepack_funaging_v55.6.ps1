# =====================================================
# ONEPACK v55.6 — INSTALL @supabase/supabase-js
# =====================================================

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== ONEPACK v55.6 — INSTALL SUPABASE DEP ===" -ForegroundColor Cyan
Write-Host ""

# -------- PHASE 1: GO TO FRONTEND --------
Write-Host "[1/4] ENTER frontend directory" -ForegroundColor Yellow

$frontendDir = Join-Path $scriptDir "frontend"
if (-not (Test-Path $frontendDir)) {
    Write-Host "  ✖ frontend directory not found" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "$frontendDir\package.json")) {
    Write-Host "  ✖ frontend/package.json not found" -ForegroundColor Red
    exit 1
}

Push-Location $frontendDir
Write-Host "  ✔ Changed to frontend directory" -ForegroundColor Green
Write-Host ""

# -------- PHASE 2: INSTALL DEPENDENCY --------
Write-Host "[2/4] INSTALL @supabase/supabase-js" -ForegroundColor Yellow

Write-Host "  Checking if @supabase/supabase-js is already installed..." -ForegroundColor Gray
$packageJson = Get-Content "package.json" -Raw | ConvertFrom-Json

if ($packageJson.dependencies.'@supabase/supabase-js' -or $packageJson.devDependencies.'@supabase/supabase-js') {
    Write-Host "  ⚠ @supabase/supabase-js already in package.json" -ForegroundColor Yellow
    Write-Host "    Reinstalling to ensure latest version..." -ForegroundColor Gray
}

try {
    Write-Host "  Running npm install @supabase/supabase-js..." -ForegroundColor Gray
    npm install @supabase/supabase-js 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✔ @supabase/supabase-js installed successfully" -ForegroundColor Green
        
        # Verify installation
        if (Test-Path "node_modules\@supabase\supabase-js") {
            Write-Host "  ✔ Verified: package exists in node_modules" -ForegroundColor Green
        }
    } else {
        Write-Host "  ✖ npm install failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
        Pop-Location
        exit 1
    }
} catch {
    Write-Host "  ✖ npm install failed: $($_.Exception.Message)" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host ""

# -------- PHASE 3: CLEAR NEXT CACHE --------
Write-Host "[3/4] CLEAR .next CACHE" -ForegroundColor Yellow

$nextCacheDir = Join-Path $frontendDir ".next"
if (Test-Path $nextCacheDir) {
    Write-Host "  Removing .next cache directory..." -ForegroundColor Gray
    try {
        Remove-Item -Recurse -Force $nextCacheDir -ErrorAction Stop
        Write-Host "  ✔ .next cache cleared" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ Could not fully remove .next cache: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "    Some files may be locked. Try closing the dev server first." -ForegroundColor Cyan
    }
} else {
    Write-Host "  ✓ .next cache directory not found (nothing to clear)" -ForegroundColor Gray
}
Write-Host ""

# -------- PHASE 4: RESTART FRONTEND --------
Write-Host "[4/4] RESTART FRONTEND" -ForegroundColor Yellow

Write-Host "  Stopping existing Node processes..." -ForegroundColor Gray
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
}

Write-Host "  Starting frontend dev server..." -ForegroundColor Gray
Write-Host "  Note: Dev server will run in this window. Press Ctrl+C to stop." -ForegroundColor Cyan
Write-Host ""

# Run dev server (blocking)
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
    Pop-Location
    exit 1
}

# This won't be reached if dev server runs successfully (it blocks)
Pop-Location

Write-Host ""
Write-Host "=== ONEPACK v55.6 COMPLETE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Supabase dependency installed:" -ForegroundColor White
Write-Host "  • @supabase/supabase-js installed" -ForegroundColor Gray
Write-Host "  • .next cache cleared" -ForegroundColor Gray
Write-Host "  • Frontend dev server running" -ForegroundColor Gray
Write-Host ""
Write-Host "Usage:" -ForegroundColor White
Write-Host "  • import { createClient } from '@supabase/supabase-js'" -ForegroundColor Gray
Write-Host "  • import { supabase } from '@/config/supabase'" -ForegroundColor Gray
Write-Host ""
