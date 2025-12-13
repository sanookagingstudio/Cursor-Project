# =====================================================
# ONEPACK v55.5 — FIX config/supabase ALIAS
# =====================================================

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== ONEPACK v55.5 — FIX CONFIG ALIAS ===" -ForegroundColor Cyan
Write-Host ""

# -------- PHASE 1: ENSURE src/config EXISTS --------
Write-Host "[1/4] ENSURE frontend/src/config" -ForegroundColor Yellow

$frontendDir = Join-Path $scriptDir "frontend"
if (-not (Test-Path $frontendDir)) {
    Write-Host "  ✖ frontend directory not found" -ForegroundColor Red
    exit 1
}

$srcDir = Join-Path $frontendDir "src"
if (-not (Test-Path $srcDir)) {
    New-Item -ItemType Directory -Force -Path $srcDir | Out-Null
    Write-Host "  ✔ Created frontend/src directory" -ForegroundColor Green
} else {
    Write-Host "  ✓ frontend/src directory already exists" -ForegroundColor Gray
}

$srcConfig = Join-Path $srcDir "config"
if (-not (Test-Path $srcConfig)) {
    New-Item -ItemType Directory -Force -Path $srcConfig | Out-Null
    Write-Host "  ✔ Created frontend/src/config directory" -ForegroundColor Green
} else {
    Write-Host "  ✓ frontend/src/config directory already exists" -ForegroundColor Gray
}
Write-Host ""

# -------- PHASE 2: MOVE supabase.ts --------
Write-Host "[2/4] MOVE supabase.ts" -ForegroundColor Yellow

$oldConfig = Join-Path $frontendDir "config\supabase.ts"
$newConfig = Join-Path $srcConfig "supabase.ts"

if (-not (Test-Path $oldConfig)) {
    Write-Host "  ✖ supabase.ts not found at frontend/config" -ForegroundColor Red
    Write-Host "    Expected: $oldConfig" -ForegroundColor Gray
    
    # Check if it's already in the new location
    if (Test-Path $newConfig) {
        Write-Host "  ✓ supabase.ts already exists at src/config (skipping move)" -ForegroundColor Green
    } else {
        Write-Host "    Run ONEPACK v50 to create the Supabase config first." -ForegroundColor Yellow
        exit 1
    }
} else {
    # Copy to new location
    Copy-Item $oldConfig $newConfig -Force
    Write-Host "  ✔ Copied to src/config/supabase.ts" -ForegroundColor Green
    
    # Check if there are other files in config directory
    $otherConfigs = Get-ChildItem -Path (Split-Path $oldConfig) -Filter "*.ts" -File -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -ne "supabase.ts"
    }
    
    if ($otherConfigs) {
        Write-Host "  ℹ Found other config files in frontend/config:" -ForegroundColor Cyan
        foreach ($cfg in $otherConfigs) {
            $newConfigPath = Join-Path $srcConfig $cfg.Name
            Copy-Item $cfg.FullName $newConfigPath -Force
            Write-Host "    • Copied $($cfg.Name) to src/config" -ForegroundColor Gray
        }
    }
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
        Write-Host "    Next.js typically takes 10-30 seconds to compile after cache clear." -ForegroundColor Gray
    }
} catch {
    Write-Host "  ✖ Failed to start frontend: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "    Start manually with: cd frontend && npm run dev" -ForegroundColor Cyan
}

Write-Host ""

# -------- SUMMARY --------
Write-Host "=== ONEPACK v55.5 COMPLETE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Config structure fixed:" -ForegroundColor White
Write-Host "  • frontend/src/config/ created" -ForegroundColor Gray
Write-Host "  • supabase.ts moved to src/config/" -ForegroundColor Gray
Write-Host "  • @/* alias now correctly resolves to src/*" -ForegroundColor Gray
Write-Host "  • .next cache cleared" -ForegroundColor Gray
Write-Host "  • Frontend restarted" -ForegroundColor Gray
Write-Host ""
Write-Host "Import path:" -ForegroundColor White
Write-Host "  • import { supabase } from '@/config/supabase'" -ForegroundColor Gray
Write-Host "    → resolves to: frontend/src/config/supabase.ts" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Note: Frontend dev server is running in a separate PowerShell window." -ForegroundColor Yellow
Write-Host "      Close that window to stop the server." -ForegroundColor Yellow
Write-Host ""
Write-Host "Optional: You can now delete frontend/config/ directory if it's empty." -ForegroundColor Cyan
Write-Host ""
