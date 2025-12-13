# =====================================================
# ONEPACK v55.8 — ALIGN SRC + FIX SUPABASE (FINAL)
# =====================================================

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== ONEPACK v55.8 — FINAL SUPABASE FIX ===" -ForegroundColor Cyan
Write-Host ""

# -------- PHASE 1: ENSURE SRC STRUCTURE --------
Write-Host "[1/6] ENSURE src/ STRUCTURE" -ForegroundColor Yellow

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

# Move config directory if it exists at root level
$oldConfig = Join-Path $frontendDir "config"
$newConfig = Join-Path $srcDir "config"
if (Test-Path $oldConfig) {
    if (Test-Path $newConfig) {
        Write-Host "  ⚠ src/config already exists, merging files..." -ForegroundColor Yellow
        # Copy files from old to new
        Get-ChildItem -Path $oldConfig -File | ForEach-Object {
            $dest = Join-Path $newConfig $_.Name
            if (-not (Test-Path $dest)) {
                Copy-Item $_.FullName $dest -Force
                Write-Host "    • Copied $($_.Name) to src/config" -ForegroundColor Gray
            }
        }
        Remove-Item -Recurse -Force $oldConfig -ErrorAction SilentlyContinue
    } else {
        Move-Item $oldConfig $newConfig -Force -ErrorAction Stop
        Write-Host "  ✔ Moved config → src/config" -ForegroundColor Green
    }
} else {
    Write-Host "  ✓ config directory not found at root (already in src or doesn't exist)" -ForegroundColor Gray
}

# Move hooks directory if it exists at root level
$oldHooks = Join-Path $frontendDir "hooks"
$newHooks = Join-Path $srcDir "hooks"
if (Test-Path $oldHooks) {
    if (Test-Path $newHooks) {
        Write-Host "  ⚠ src/hooks already exists, merging files..." -ForegroundColor Yellow
        # Copy files from old to new
        Get-ChildItem -Path $oldHooks -File | ForEach-Object {
            $dest = Join-Path $newHooks $_.Name
            if (-not (Test-Path $dest)) {
                Copy-Item $_.FullName $dest -Force
                Write-Host "    • Copied $($_.Name) to src/hooks" -ForegroundColor Gray
            }
        }
        Remove-Item -Recurse -Force $oldHooks -ErrorAction SilentlyContinue
    } else {
        Move-Item $oldHooks $newHooks -Force -ErrorAction Stop
        Write-Host "  ✔ Moved hooks → src/hooks" -ForegroundColor Green
    }
} else {
    Write-Host "  ✓ hooks directory not found at root (already in src or doesn't exist)" -ForegroundColor Gray
}
Write-Host ""

# -------- PHASE 2: WRITE ENV --------
Write-Host "[2/6] WRITE .env.local" -ForegroundColor Yellow

$envFile = Join-Path $frontendDir ".env.local"
$envContent = @"
NEXT_PUBLIC_SUPABASE_URL=https://hbjocppvllpcbmhkiode.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=PUT_YOUR_REAL_ANON_KEY_HERE
"@

if (Test-Path $envFile) {
    Write-Host "  ⚠ .env.local already exists, backing up..." -ForegroundColor Yellow
    Copy-Item $envFile "$envFile.backup" -Force
}

# Check if we should preserve existing values
$existingContent = ""
if (Test-Path $envFile) {
    $existingContent = Get-Content $envFile -Raw
}

# Only write if file doesn't exist or doesn't have the required keys
$shouldWrite = $false
if (-not (Test-Path $envFile)) {
    $shouldWrite = $true
} elseif ($existingContent -notmatch "NEXT_PUBLIC_SUPABASE_URL" -or $existingContent -notmatch "NEXT_PUBLIC_SUPABASE_ANON_KEY") {
    $shouldWrite = $true
    Write-Host "  ⚠ Missing required keys, updating .env.local..." -ForegroundColor Yellow
}

if ($shouldWrite) {
    $envContent | Set-Content -Path $envFile -Encoding UTF8
    Write-Host "  ✔ ENV written to frontend/.env.local" -ForegroundColor Green
    Write-Host "    ⚠ IMPORTANT: Update NEXT_PUBLIC_SUPABASE_ANON_KEY with your real key!" -ForegroundColor Yellow
} else {
    Write-Host "  ✓ .env.local already has required keys" -ForegroundColor Gray
    Write-Host "    Current SUPABASE_URL: $((Get-Content $envFile | Select-String 'NEXT_PUBLIC_SUPABASE_URL').ToString().Split('=')[1])" -ForegroundColor DarkGray
}
Write-Host ""

# -------- PHASE 3: VERIFY FILES --------
Write-Host "[3/6] VERIFY FILES" -ForegroundColor Yellow

$supabaseConfig = Join-Path $srcDir "config\supabase.ts"
$useRoleGuard = Join-Path $srcDir "hooks\useRoleGuard.ts"

$allFilesExist = $true

if (Test-Path $supabaseConfig) {
    Write-Host "  ✔ frontend/src/config/supabase.ts exists" -ForegroundColor Green
} else {
    Write-Host "  ✖ frontend/src/config/supabase.ts NOT FOUND" -ForegroundColor Red
    $allFilesExist = $false
}

if (Test-Path $useRoleGuard) {
    Write-Host "  ✔ frontend/src/hooks/useRoleGuard.ts exists" -ForegroundColor Green
} else {
    Write-Host "  ✖ frontend/src/hooks/useRoleGuard.ts NOT FOUND" -ForegroundColor Red
    $allFilesExist = $false
}

if (-not $allFilesExist) {
    Write-Host ""
    Write-Host "  ⚠ Some required files are missing. Run ONEPACK v50-v55.5 to create them." -ForegroundColor Yellow
}
Write-Host ""

# -------- PHASE 4: CLEAR CACHE --------
Write-Host "[4/6] CLEAR CACHE" -ForegroundColor Yellow

$nextCacheDir = Join-Path $frontendDir ".next"
if (Test-Path $nextCacheDir) {
    Write-Host "  Removing .next cache directory..." -ForegroundColor Gray
    try {
        Remove-Item -Recurse -Force $nextCacheDir -ErrorAction Stop
        Write-Host "  ✔ Cache cleared" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ Could not fully remove .next cache: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "    Some files may be locked. Try closing the dev server first." -ForegroundColor Cyan
    }
} else {
    Write-Host "  ✓ .next cache directory not found (nothing to clear)" -ForegroundColor Gray
}
Write-Host ""

# -------- PHASE 5: RESTART FRONTEND --------
Write-Host "[5/6] RESTART FRONTEND" -ForegroundColor Yellow

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

Push-Location $frontendDir
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

# -------- PHASE 6: DONE --------
Write-Host ""
Write-Host "[6/6] DONE" -ForegroundColor Yellow

Write-Host ""
Write-Host "=== ONEPACK v55.8 COMPLETE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Structure aligned:" -ForegroundColor White
Write-Host "  • frontend/src/config/ (Supabase config)" -ForegroundColor Gray
Write-Host "  • frontend/src/hooks/ (useRoleGuard)" -ForegroundColor Gray
Write-Host "  • frontend/.env.local (Supabase credentials)" -ForegroundColor Gray
Write-Host ""
Write-Host "Access:" -ForegroundColor White
Write-Host "  • Admin Panel: http://localhost:3000/admin/users" -ForegroundColor Gray
Write-Host "  • Dashboard:   http://localhost:3000/dashboard" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠ IMPORTANT: Update NEXT_PUBLIC_SUPABASE_ANON_KEY in frontend/.env.local" -ForegroundColor Yellow
Write-Host ""

