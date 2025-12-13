# =====================================================
# ONEPACK v55.9 — FINAL SUPABASE RUNTIME FIX
# =====================================================

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== ONEPACK v55.9 — FINAL SUPABASE FIX ===" -ForegroundColor Cyan
Write-Host ""

# -------- PHASE 1: FORCE ENV REWRITE --------
Write-Host "[1/5] FORCE WRITE .env.local" -ForegroundColor Yellow

$frontendDir = Join-Path $scriptDir "frontend"
if (-not (Test-Path $frontendDir)) {
    Write-Host "  ✖ frontend directory not found" -ForegroundColor Red
    exit 1
}

$envFile = Join-Path $frontendDir ".env.local"
if (Test-Path $envFile) {
    Write-Host "  ⚠ .env.local already exists, backing up..." -ForegroundColor Yellow
    Copy-Item $envFile "$envFile.backup" -Force
}

$envContent = @"
NEXT_PUBLIC_SUPABASE_URL=https://hbjocppvllpcbmhkiode.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=PUT_REAL_ANON_KEY_HERE
"@

$envContent | Set-Content -Path $envFile -Encoding UTF8
Write-Host "  ✔ .env.local written" -ForegroundColor Green
Write-Host "    ⚠ IMPORTANT: Update NEXT_PUBLIC_SUPABASE_ANON_KEY with your real key!" -ForegroundColor Yellow
Write-Host ""

# -------- PHASE 2: PATCH supabase.ts (FAIL-SAFE) --------
Write-Host "[2/5] PATCH supabase.ts" -ForegroundColor Yellow

$supabasePath = Join-Path $frontendDir "src\config\supabase.ts"

if (-not (Test-Path $supabasePath)) {
    # Ensure directory exists
    $configDir = Split-Path $supabasePath
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Force -Path $configDir | Out-Null
        Write-Host "  ✔ Created config directory" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠ supabase.ts already exists, backing up..." -ForegroundColor Yellow
    Copy-Item $supabasePath "$supabasePath.backup" -Force
}

$supabaseContent = @'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  console.warn('⚠️ Supabase ENV missing')
}

export const supabase = supabaseUrl && supabaseAnonKey
  ? createClient(supabaseUrl, supabaseAnonKey)
  : null
'@

$supabaseContent | Set-Content -Path $supabasePath -Encoding UTF8
Write-Host "  ✔ supabase.ts patched (fail-safe)" -ForegroundColor Green
Write-Host "    • Handles missing env vars gracefully" -ForegroundColor Gray
Write-Host "    • Returns null if env vars are missing" -ForegroundColor Gray
Write-Host ""

# -------- PHASE 3: CLEAR CACHE --------
Write-Host "[3/5] CLEAR NEXT CACHE" -ForegroundColor Yellow

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

# -------- PHASE 4: HARD RESTART FRONTEND --------
Write-Host "[4/5] HARD RESTART FRONTEND" -ForegroundColor Yellow

Write-Host "  Stopping all Node processes..." -ForegroundColor Gray
try {
    $nodeProcesses = Get-Process node -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -like "*node.exe*"
    }
    
    if ($nodeProcesses) {
        $processCount = $nodeProcesses.Count
        $nodeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3
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
    Write-Host "    4. Ensure @supabase/supabase-js is installed: npm install @supabase/supabase-js" -ForegroundColor Gray
    Write-Host ""
    Pop-Location
    exit 1
}

# This won't be reached if dev server runs successfully (it blocks)
Pop-Location

# -------- PHASE 5: DONE --------
Write-Host ""
Write-Host "[5/5] DONE" -ForegroundColor Yellow

Write-Host ""
Write-Host "=== ONEPACK v55.9 COMPLETE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Supabase runtime fix applied:" -ForegroundColor White
Write-Host "  • .env.local written with Supabase URL" -ForegroundColor Gray
Write-Host "  • supabase.ts patched with fail-safe handling" -ForegroundColor Gray
Write-Host "  • Cache cleared" -ForegroundColor Gray
Write-Host "  • Frontend restarted" -ForegroundColor Gray
Write-Host ""
Write-Host "Access:" -ForegroundColor White
Write-Host "  • Admin Panel: http://localhost:3000/admin/users" -ForegroundColor Gray
Write-Host "  • Dashboard:   http://localhost:3000/dashboard" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠ IMPORTANT: Update NEXT_PUBLIC_SUPABASE_ANON_KEY in frontend/.env.local" -ForegroundColor Yellow
Write-Host ""
