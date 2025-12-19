# =====================================================
# ONEPACK v56.1 — AUTO DISCOVER SUPABASE CONFIG
# =====================================================

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== ONEPACK v56.1 — AUTO SUPABASE DISCOVERY ===" -ForegroundColor Cyan
Write-Host ""

$SUPABASE_URL = $null
$SUPABASE_ANON = $null

$frontendDir = Join-Path $scriptDir "frontend"
if (-not (Test-Path $frontendDir)) {
    Write-Host "  ✖ frontend directory not found" -ForegroundColor Red
    exit 1
}

# -----------------------------------------------------
# STEP 1: TRY TO READ FROM frontend/.env.local
# -----------------------------------------------------
$envFile = Join-Path $frontendDir ".env.local"
if (Test-Path $envFile) {
    Write-Host "🔍 Checking frontend/.env.local" -ForegroundColor Yellow

    $content = Get-Content $envFile
    foreach ($line in $content) {
        if ($line -match "^NEXT_PUBLIC_SUPABASE_URL\s*=\s*(.+)$") {
            $SUPABASE_URL = $Matches[1].Trim().Trim('"').Trim("'")
            Write-Host "  ✔ Found NEXT_PUBLIC_SUPABASE_URL" -ForegroundColor Green
        }
        if ($line -match "^NEXT_PUBLIC_SUPABASE_ANON_KEY\s*=\s*(.+)$") {
            $SUPABASE_ANON = $Matches[1].Trim().Trim('"').Trim("'")
            Write-Host "  ✔ Found NEXT_PUBLIC_SUPABASE_ANON_KEY" -ForegroundColor Green
        }
    }
} else {
    Write-Host "  ℹ frontend/.env.local not found" -ForegroundColor Gray
}

# -----------------------------------------------------
# STEP 2: TRY TO READ FROM frontend/config/supabase.ts
# -----------------------------------------------------
$configFile = Join-Path $frontendDir "config\supabase.ts"
$configFileAlt = Join-Path $frontendDir "src\config\supabase.ts"

if ((-not $SUPABASE_URL -or -not $SUPABASE_ANON)) {
    foreach ($cfg in @($configFile, $configFileAlt)) {
        if (Test-Path $cfg) {
            Write-Host "🔍 Checking $cfg" -ForegroundColor Yellow
            $ts = Get-Content $cfg
            foreach ($line in $ts) {
                if ($line -match "NEXT_PUBLIC_SUPABASE_URL") {
                    Write-Host "  ℹ️ URL is expected from env (not hardcoded)" -ForegroundColor Cyan
                }
                # Note: We don't extract hardcoded values as they should come from env
            }
            break
        }
    }
}

# -----------------------------------------------------
# STEP 3: ASK USER ONLY IF STILL MISSING
# -----------------------------------------------------
if (-not $SUPABASE_URL -or $SUPABASE_URL -match "YOUR_PROJECT_ID|PUT.*HERE") {
    Write-Host ""
    Write-Host "❓ SUPABASE URL NOT FOUND OR INVALID" -ForegroundColor Yellow
    Write-Host "Example: https://abcd1234.supabase.co" -ForegroundColor Gray
    Write-Host "Get it from: Supabase Dashboard → Project Settings → API → Project URL" -ForegroundColor Cyan
    $SUPABASE_URL = Read-Host "Paste Supabase Project URL"
    
    if ([string]::IsNullOrWhiteSpace($SUPABASE_URL)) {
        Write-Host "  ✖ No URL provided" -ForegroundColor Red
        exit 1
    }
}

if (-not $SUPABASE_ANON -or $SUPABASE_ANON -match "YOUR.*KEY|PUT.*HERE") {
    Write-Host ""
    Write-Host "❓ SUPABASE ANON KEY NOT FOUND OR INVALID" -ForegroundColor Yellow
    Write-Host "Get it from: Supabase Dashboard → Project Settings → API → anon public key" -ForegroundColor Cyan
    $SUPABASE_ANON = Read-Host "Paste Supabase anon public key"
    
    if ([string]::IsNullOrWhiteSpace($SUPABASE_ANON)) {
        Write-Host "  ✖ No anon key provided" -ForegroundColor Red
        exit 1
    }
}

# -----------------------------------------------------
# STEP 4: VALIDATE
# -----------------------------------------------------
Write-Host ""
Write-Host "Validating Supabase configuration..." -ForegroundColor Yellow

if (-not ($SUPABASE_URL -match "^https:\/\/.+\.supabase\.co$")) {
    Write-Host "  ✖ INVALID SUPABASE URL FORMAT" -ForegroundColor Red
    Write-Host "    Expected format: https://[project-id].supabase.co" -ForegroundColor Yellow
    Write-Host "    Got: $SUPABASE_URL" -ForegroundColor Gray
    pause
    exit 1
}

if ($SUPABASE_ANON.Length -lt 50) {
    Write-Host "  ✖ INVALID SUPABASE ANON KEY" -ForegroundColor Red
    Write-Host "    Anon keys are typically 100+ characters long" -ForegroundColor Yellow
    Write-Host "    Got length: $($SUPABASE_ANON.Length)" -ForegroundColor Gray
    pause
    exit 1
}

Write-Host "  ✔ Supabase config validated" -ForegroundColor Green
Write-Host "    URL: $SUPABASE_URL" -ForegroundColor DarkGray
Write-Host "    Anon Key: $($SUPABASE_ANON.Substring(0, [Math]::Min(20, $SUPABASE_ANON.Length)))..." -ForegroundColor DarkGray

# -----------------------------------------------------
# STEP 5: WRITE .env.local (AUTHORITATIVE)
# -----------------------------------------------------
Write-Host ""
Write-Host "Writing frontend/.env.local..." -ForegroundColor Yellow

if (Test-Path $envFile) {
    Write-Host "  ⚠ Backing up existing .env.local..." -ForegroundColor Yellow
    Copy-Item $envFile "$envFile.backup" -Force
}

$envContent = @"
NEXT_PUBLIC_SUPABASE_URL=$SUPABASE_URL
NEXT_PUBLIC_SUPABASE_ANON_KEY=$SUPABASE_ANON
"@

$envContent | Set-Content -Path $envFile -Encoding UTF8
Write-Host "  ✔ frontend/.env.local updated" -ForegroundColor Green

# -----------------------------------------------------
# STEP 6: CLEAN & START FRONTEND
# -----------------------------------------------------
Write-Host ""
Write-Host "▶ Restarting frontend (visible mode)..." -ForegroundColor Yellow

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
    }
} catch {
    Write-Host "  ⚠ Could not stop processes: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "  Clearing .next cache..." -ForegroundColor Gray
try {
    $nextCacheDir = Join-Path $frontendDir ".next"
    if (Test-Path $nextCacheDir) {
        Remove-Item -Recurse -Force $nextCacheDir -ErrorAction SilentlyContinue
        Write-Host "  ✔ Cache cleared" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠ Could not fully clear cache (some files may be locked)" -ForegroundColor Yellow
}

Push-Location $frontendDir

if (-not (Test-Path "node_modules")) {
    Write-Host "  Installing dependencies..." -ForegroundColor Gray
    npm install 2>&1 | Out-Null
    Write-Host "  ✔ Dependencies installed" -ForegroundColor Green
}

Write-Host ""
Write-Host "🚀 Frontend starting at http://localhost:3000" -ForegroundColor Green
Write-Host "👉 Login page: http://localhost:3000/auth/login" -ForegroundColor Cyan
Write-Host "--------------------------------------------------" -ForegroundColor DarkGray
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















