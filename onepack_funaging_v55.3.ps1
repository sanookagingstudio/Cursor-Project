# =====================================================
# ONEPACK v55.3 — FIX @ PATH ALIAS
# =====================================================

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== ONEPACK v55.3 — FIX PATH ALIAS ===" -ForegroundColor Cyan
Write-Host ""

# -------- PHASE 1: FIX tsconfig.json --------
Write-Host "[1/4] FIX tsconfig.json" -ForegroundColor Yellow

$frontendDir = Join-Path $scriptDir "frontend"
if (-not (Test-Path $frontendDir)) {
    Write-Host "  ✖ frontend directory not found" -ForegroundColor Red
    exit 1
}

$tsconfig = Join-Path $frontendDir "tsconfig.json"
if (-not (Test-Path $tsconfig)) {
    Write-Host "  ✖ tsconfig.json not found" -ForegroundColor Red
    exit 1
}

Write-Host "  Reading tsconfig.json..." -ForegroundColor Gray
$tsContent = Get-Content $tsconfig -Raw
$modified = $false

# Check if paths already exists
if ($tsContent -notmatch '"paths"') {
    Write-Host "  Adding baseUrl and paths configuration..." -ForegroundColor Gray
    
    # Try to parse as JSON and add paths
    try {
        $tsJson = $tsContent | ConvertFrom-Json
        
        if (-not $tsJson.compilerOptions) {
            $tsJson | Add-Member -MemberType NoteProperty -Name "compilerOptions" -Value @{} -Force
        }
        
        if (-not $tsJson.compilerOptions.baseUrl) {
            $tsJson.compilerOptions | Add-Member -MemberType NoteProperty -Name "baseUrl" -Value "." -Force
            $modified = $true
        }
        
        if (-not $tsJson.compilerOptions.paths) {
            $tsJson.compilerOptions | Add-Member -MemberType NoteProperty -Name "paths" -Value @{
                "@/*" = @("./src/*")
            } -Force
            $modified = $true
        } else {
            # Update paths if it exists but doesn't have @/*
            if (-not $tsJson.compilerOptions.paths.'@/*') {
                $tsJson.compilerOptions.paths | Add-Member -MemberType NoteProperty -Name "@/*" -Value @("./src/*") -Force
                $modified = $true
            }
        }
        
        if ($modified) {
            $tsContent = $tsJson | ConvertTo-Json -Depth 10
            Set-Content -Path $tsconfig -Value $tsContent -Encoding UTF8
            Write-Host "  ✔ Added baseUrl + paths to tsconfig.json" -ForegroundColor Green
        } else {
            Write-Host "  ✓ baseUrl and paths already configured correctly" -ForegroundColor Gray
        }
    } catch {
        # Fallback: manual string replacement
        Write-Host "  ⚠ JSON parsing failed, using string replacement..." -ForegroundColor Yellow
        
        if ($tsContent -notmatch '"baseUrl"') {
            $tsContent = $tsContent -replace '("compilerOptions"\s*:\s*\{)', '$1`n    "baseUrl": ".",'
            $modified = $true
        }
        
        if ($tsContent -notmatch '"paths"') {
            $tsContent = $tsContent -replace '("compilerOptions"\s*:\s*\{)', '$1`n    "paths": { "@/*": ["./src/*"] },'
            $modified = $true
        }
        
        if ($modified) {
            Set-Content -Path $tsconfig -Value $tsContent -Encoding UTF8
            Write-Host "  ✔ Added baseUrl + paths to tsconfig.json" -ForegroundColor Green
        }
    }
} else {
    Write-Host "  ✓ paths already exists in tsconfig.json" -ForegroundColor Gray
    
    # Verify @/* is configured correctly
    if ($tsContent -match '"paths"\s*:\s*\{[^}]*"@/\*"\s*:\s*\["([^"]+)"\]') {
        $currentPath = $matches[1]
        if ($currentPath -ne "./src/*") {
            Write-Host "  ⚠ @/* path is set to '$currentPath', should be './src/*'" -ForegroundColor Yellow
            Write-Host "    Consider updating manually if this is intentional." -ForegroundColor Cyan
        } else {
            Write-Host "  ✓ @/* path alias correctly configured" -ForegroundColor Green
        }
    }
}

Write-Host ""

# -------- PHASE 2: ENSURE useRoleGuard LOCATION --------
Write-Host "[2/4] VERIFY hooks location" -ForegroundColor Yellow

$hookFile = Join-Path $frontendDir "hooks\useRoleGuard.ts"
if (-not (Test-Path $hookFile)) {
    Write-Host "  ✖ useRoleGuard.ts not found at frontend/hooks" -ForegroundColor Red
    Write-Host "    Expected: $hookFile" -ForegroundColor Gray
    Write-Host "    Run ONEPACK v53 to create the hook." -ForegroundColor Yellow
    exit 1
}
Write-Host "  ✔ useRoleGuard.ts found: $hookFile" -ForegroundColor Green
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
Write-Host "=== ONEPACK v55.3 COMPLETE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Path alias fixed:" -ForegroundColor White
Write-Host "  • @/* → ./src/*" -ForegroundColor Gray
Write-Host "  • baseUrl: ." -ForegroundColor Gray
Write-Host "  • .next cache cleared" -ForegroundColor Gray
Write-Host "  • Frontend restarted" -ForegroundColor Gray
Write-Host ""
Write-Host "Usage:" -ForegroundColor White
Write-Host "  • import { useRoleGuard } from '@/hooks/useRoleGuard'" -ForegroundColor Gray
Write-Host "  • import { supabase } from '@/config/supabase'" -ForegroundColor Gray
Write-Host ""
Write-Host "Note: Frontend dev server is running in a separate PowerShell window." -ForegroundColor Yellow
Write-Host "      Close that window to stop the server." -ForegroundColor Yellow
Write-Host ""
