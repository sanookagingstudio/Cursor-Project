# =====================================================
# ONEPACK v56 — FIX SUPABASE ENV (FINAL)
# =====================================================

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== ONEPACK v56 — FIX SUPABASE ENV ===" -ForegroundColor Cyan
Write-Host ""

$frontendDir = Join-Path $scriptDir "frontend"
if (-not (Test-Path $frontendDir)) {
    Write-Host "  ✖ frontend directory not found" -ForegroundColor Red
    exit 1
}

# -------- PHASE 1: WRITE .env.local --------
Write-Host "[1/4] WRITE frontend/.env.local" -ForegroundColor Yellow

$envFile = Join-Path $frontendDir ".env.local"
if (Test-Path $envFile) {
    Write-Host "  ⚠ .env.local already exists, backing up..." -ForegroundColor Yellow
    Copy-Item $envFile "$envFile.backup" -Force
}

$envContent = @"
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
"@

$envContent | Set-Content -Path $envFile -Encoding UTF8
Write-Host "  ✔ .env.local written" -ForegroundColor Green
Write-Host "    ⚠ IMPORTANT: Update with your actual Supabase credentials!" -ForegroundColor Yellow
Write-Host "      1. Replace YOUR_PROJECT_ID with your Supabase project ID" -ForegroundColor Cyan
Write-Host "      2. Replace YOUR_PUBLIC_ANON_KEY with your Supabase anon key" -ForegroundColor Cyan
Write-Host ""

# -------- PHASE 2: CLEAR CACHE --------
Write-Host "[2/4] CLEAR .next cache" -ForegroundColor Yellow

$nextCacheDir = Join-Path $frontendDir ".next"
if (Test-Path $nextCacheDir) {
    Write-Host "  Removing .next cache directory..." -ForegroundColor Gray
    try {
        Remove-Item -Recurse -Force $nextCacheDir -ErrorAction Stop
        Write-Host "  ✔ cache cleared" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ Could not fully remove .next cache: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "    Some files may be locked. Try closing the dev server first." -ForegroundColor Cyan
    }
} else {
    Write-Host "  ✓ .next cache directory not found (nothing to clear)" -ForegroundColor Gray
}
Write-Host ""

# -------- PHASE 3: RESTART FRONTEND --------
Write-Host "[3/4] RESTART frontend" -ForegroundColor Yellow

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
        Write-Host "    Next.js typically takes 10-30 seconds to compile." -ForegroundColor Gray
    }
} catch {
    Write-Host "  ✖ Failed to start frontend: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "    Start manually with: cd frontend && npm run dev" -ForegroundColor Cyan
}

Write-Host ""

# -------- PHASE 4: DONE --------
Write-Host "[4/4] DONE" -ForegroundColor Yellow

Write-Host ""
Write-Host "=== ONEPACK v56 COMPLETE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Supabase ENV fixed:" -ForegroundColor White
Write-Host "  • frontend/.env.local created with template values" -ForegroundColor Gray
Write-Host "  • .next cache cleared" -ForegroundColor Gray
Write-Host "  • Frontend restarted" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Edit frontend/.env.local" -ForegroundColor Gray
Write-Host "  2. Replace YOUR_PROJECT_ID with your Supabase project ID" -ForegroundColor Gray
Write-Host "  3. Replace YOUR_PUBLIC_ANON_KEY with your Supabase anon key" -ForegroundColor Gray
Write-Host "  4. Restart frontend if needed" -ForegroundColor Gray
Write-Host ""
Write-Host "Access:" -ForegroundColor White
Write-Host "  • Login: http://localhost:3000/auth/login" -ForegroundColor Gray
Write-Host ""















