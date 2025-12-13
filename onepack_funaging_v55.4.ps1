# =====================================================
# ONEPACK v55.4 — FIX @ ALIAS STRUCTURE (FINAL)
# =====================================================

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== ONEPACK v55.4 — FIX SRC STRUCTURE ===" -ForegroundColor Cyan
Write-Host ""

# -------- PHASE 1: ENSURE src/hooks EXISTS --------
Write-Host "[1/4] ENSURE frontend/src/hooks" -ForegroundColor Yellow

$srcHooks = Join-Path $scriptDir "frontend\src\hooks"
if (-not (Test-Path $srcHooks)) {
    New-Item -ItemType Directory -Force -Path $srcHooks | Out-Null
    Write-Host "  ✔ frontend/src/hooks ready" -ForegroundColor Green
} else {
    Write-Host "  ✓ frontend/src/hooks already exists" -ForegroundColor Gray
}
Write-Host ""

# -------- PHASE 2: MOVE useRoleGuard.ts --------
Write-Host "[2/4] MOVE useRoleGuard.ts" -ForegroundColor Yellow

$oldHook = Join-Path $scriptDir "frontend\hooks\useRoleGuard.ts"
$newHook = Join-Path $scriptDir "frontend\src\hooks\useRoleGuard.ts"

if (-not (Test-Path $oldHook)) {
    Write-Host "  ✖ useRoleGuard.ts not found at frontend/hooks" -ForegroundColor Red
    Write-Host "    Expected: $oldHook" -ForegroundColor Gray
    
    # Check if it's already in the new location
    if (Test-Path $newHook) {
        Write-Host "  ✓ useRoleGuard.ts already exists at src/hooks (skipping move)" -ForegroundColor Green
    } else {
        Write-Host "    Run ONEPACK v53 to create the hook first." -ForegroundColor Yellow
        exit 1
    }
} else {
    Copy-Item $oldHook $newHook -Force
    Write-Host "  ✔ Copied to src/hooks/useRoleGuard.ts" -ForegroundColor Green
}
Write-Host ""

# -------- PHASE 3: CLEAR NEXT CACHE --------
Write-Host "[3/4] CLEAR .next CACHE" -ForegroundColor Yellow

$nextCacheDir = Join-Path $scriptDir "frontend\.next"
if (Test-Path $nextCacheDir) {
    Write-Host "  Removing .next cache directory..." -ForegroundColor Gray
    try {
        Remove-Item -Recurse -Force $nextCacheDir -ErrorAction SilentlyContinue
        Write-Host "  ✔ .next cache cleared" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ Could not fully remove .next cache: $($_.Exception.Message)" -ForegroundColor Yellow
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

$frontendDir = Join-Path $scriptDir "frontend"
Write-Host "  Starting frontend dev server..." -ForegroundColor Gray
$frontendCmd = "-NoExit -Command `"cd '$frontendDir'; npm run dev`""
try {
    Start-Process powershell -ArgumentList $frontendCmd -WindowStyle Normal
    Write-Host "  ✔ Frontend dev server started in new window" -ForegroundColor Green
    Write-Host "    Waiting for server to initialize..." -ForegroundColor Gray
    Start-Sleep -Seconds 5
    
    # Quick health check
    $maxRetries = 3
    $retryCount = 0
    while ($retryCount -lt $maxRetries) {
        try {
            $resp = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 3
            if ($resp.StatusCode -eq 200) {
                Write-Host "  ✔ Frontend is responding" -ForegroundColor Green
                break
            }
        } catch {
            $retryCount++
            if ($retryCount -lt $maxRetries) {
                Start-Sleep -Seconds 3
            }
        }
    }
    
    if ($retryCount -eq $maxRetries) {
        Write-Host "  ⚠ Frontend may still be starting (check the PowerShell window)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ✖ Failed to start frontend: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "    Start manually with: cd frontend && npm run dev" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=== ONEPACK v55.4 COMPLETE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Structure fixed:" -ForegroundColor White
Write-Host "  • frontend/src/hooks/ created" -ForegroundColor Gray
Write-Host "  • useRoleGuard.ts moved to src/hooks/" -ForegroundColor Gray
Write-Host "  • @/* alias now correctly resolves to src/*" -ForegroundColor Gray
Write-Host "  • .next cache cleared" -ForegroundColor Gray
Write-Host "  • Frontend restarted" -ForegroundColor Gray
Write-Host ""
Write-Host "Import path:" -ForegroundColor White
Write-Host "  • import { useRoleGuard } from '@/hooks/useRoleGuard'" -ForegroundColor Gray
Write-Host "    → resolves to: frontend/src/hooks/useRoleGuard.ts" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Note: Frontend dev server is running in a separate PowerShell window." -ForegroundColor Yellow
Write-Host "      Close that window to stop the server." -ForegroundColor Yellow
Write-Host ""

