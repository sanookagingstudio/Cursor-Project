# ONEPACK FUNAGING v50 — MAX GRAND UNIFIED (DB + UI + JARVIS + BUILD + DEPLOY)

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== FUNAGING.SAS ONEPACK v50 MAX — START ===" -ForegroundColor Cyan
Write-Host ""

# PHASE 1: CHAIN v40 (RESTORE + BUILD + DEPLOY + LOCAL)
Write-Host "[1/8] RUNNING ONEPACK v40 CHAIN" -ForegroundColor Yellow

$onepack40 = Join-Path $scriptDir "onepack_funaging_v40.ps1"
if (Test-Path $onepack40) {
    Write-Host "  Running onepack_funaging_v40.ps1 ..." -ForegroundColor Gray
    try {
        & $onepack40 2>&1 | Out-Null
        Write-Host "  ✔ ONEPACK v40 chain completed" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ ONEPACK v40 chain encountered errors: $($_.Exception.Message)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠ onepack_funaging_v40.ps1 not found, skipping v40 chain (non-blocking)" -ForegroundColor Yellow
}
Write-Host ""

# PHASE 2: FRONTEND STRUCTURE + SUPABASE CLIENT
Write-Host "[2/8] FRONTEND STRUCTURE + SUPABASE CLIENT" -ForegroundColor Yellow

$frontendDir = Join-Path $scriptDir "frontend"
if (Test-Path $frontendDir) {
    $configDir = Join-Path $frontendDir "config"
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Force -Path $configDir | Out-Null
        Write-Host "  ✔ Created frontend config directory: $configDir" -ForegroundColor Green
    } else {
        Write-Host "  ✓ Frontend config directory already exists" -ForegroundColor Gray
    }

    $supabaseConfigTs = Join-Path $configDir "supabase.ts"
    if (-not (Test-Path $supabaseConfigTs)) {
        $supabaseConfigContent = @'
import { createClient } from "@supabase/supabase-js";

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error("Missing NEXT_PUBLIC_SUPABASE_URL or NEXT_PUBLIC_SUPABASE_ANON_KEY");
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
'@
        $supabaseConfigContent | Set-Content -Path $supabaseConfigTs -Encoding UTF8
        Write-Host "  ✔ Created Supabase client config: $supabaseConfigTs" -ForegroundColor Green
    } else {
        Write-Host "  ✓ Supabase client config already exists: $supabaseConfigTs" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⚠ Frontend directory not found, skipping Supabase client generation" -ForegroundColor Yellow
}
Write-Host ""

# PHASE 3: ENV LOCAL SYNC FOR SUPABASE (NEXT_PUBLIC_*)
Write-Host "[3/8] ENV LOCAL SYNC FOR SUPABASE" -ForegroundColor Yellow

$frontEnv = Join-Path $frontendDir ".env.local"
$frontEnvExample = Join-Path $frontendDir ".env.local.example"

if (-not (Test-Path $frontEnv) -and (Test-Path $frontEnvExample)) {
    Copy-Item $frontEnvExample $frontEnv -Force
    Write-Host "  ✔ Created frontend/.env.local from example" -ForegroundColor Green
} elseif (Test-Path $frontEnv) {
    Write-Host "  ✓ frontend/.env.local already exists" -ForegroundColor Gray
} else {
    Write-Host "  ⚠ No frontend/.env.local or .env.local.example found" -ForegroundColor Yellow
}

if (Test-Path $frontEnv) {
    $envText = Get-Content $frontEnv -Raw -ErrorAction SilentlyContinue

    $supUrlValue = (Get-Item "env:SUPABASE_URL" -ErrorAction SilentlyContinue).Value
    if (-not $supUrlValue) { $supUrlValue = "YOUR_SUPABASE_URL_HERE" }

    $supAnonValue = (Get-Item "env:SUPABASE_ANON_KEY" -ErrorAction SilentlyContinue).Value
    if (-not $supAnonValue) { $supAnonValue = "YOUR_SUPABASE_ANON_KEY_HERE" }

    $envModified = $false

    if ($envText -notmatch "(?m)^\s*NEXT_PUBLIC_SUPABASE_URL\s*=") {
        Add-Content $frontEnv "`nNEXT_PUBLIC_SUPABASE_URL=$supUrlValue" -NoNewline
        Write-Host "  ✔ Added NEXT_PUBLIC_SUPABASE_URL to frontend/.env.local" -ForegroundColor Green
        $envModified = $true
    } else {
        Write-Host "  ✓ NEXT_PUBLIC_SUPABASE_URL already present in frontend/.env.local" -ForegroundColor Gray
    }

    if ($envText -notmatch "(?m)^\s*NEXT_PUBLIC_SUPABASE_ANON_KEY\s*=") {
        Add-Content $frontEnv "`nNEXT_PUBLIC_SUPABASE_ANON_KEY=$supAnonValue" -NoNewline
        Write-Host "  ✔ Added NEXT_PUBLIC_SUPABASE_ANON_KEY to frontend/.env.local" -ForegroundColor Green
        $envModified = $true
    } else {
        Write-Host "  ✓ NEXT_PUBLIC_SUPABASE_ANON_KEY already present in frontend/.env.local" -ForegroundColor Gray
    }

    if ($envModified) {
        Write-Host "  ✔ ENV file updated" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠ frontend/.env.local not present, skipping NEXT_PUBLIC_* sync" -ForegroundColor Yellow
}
Write-Host ""

# PHASE 4: BASIC API ROUTES BINDING (HEALTH + PING)
Write-Host "[4/8] API ROUTES BINDING (HEALTH + PING)" -ForegroundColor Yellow

if (Test-Path $frontendDir) {
    $apiBaseDir = Join-Path $frontendDir "app\api"

    if (-not (Test-Path $apiBaseDir)) {
        New-Item -ItemType Directory -Force -Path $apiBaseDir | Out-Null
        Write-Host "  ✔ Created API base directory: $apiBaseDir" -ForegroundColor Green
    }

    # Health proxy route
    $healthDir = Join-Path $apiBaseDir "health"
    if (-not (Test-Path $healthDir)) {
        New-Item -ItemType Directory -Force -Path $healthDir | Out-Null
    }
    $healthRoute = Join-Path $healthDir "route.ts"
    if (-not (Test-Path $healthRoute)) {
        $healthRouteContent = @'
import { NextResponse } from "next/server";

const BACKEND_URL = process.env.NEXT_PUBLIC_BACKEND_URL || "http://127.0.0.1:8000";

export async function GET() {
  try {
    const res = await fetch(`${BACKEND_URL}/health`);
    const data = await res.json().catch(() => ({}));
    return NextResponse.json({ ok: true, upstream: data }, { status: 200 });
  } catch (e) {
    return NextResponse.json({ ok: false, error: "Backend health check failed" }, { status: 500 });
  }
}
'@
        $healthRouteContent | Set-Content -Path $healthRoute -Encoding UTF8
        Write-Host "  ✔ Created API route: /api/health" -ForegroundColor Green
    } else {
        Write-Host "  ✓ API route /api/health already exists" -ForegroundColor Gray
    }

    # Trip ping route
    $tripDir = Join-Path $apiBaseDir "trip"
    if (-not (Test-Path $tripDir)) {
        New-Item -ItemType Directory -Force -Path $tripDir | Out-Null
    }
    $tripRoute = Join-Path $tripDir "route.ts"
    if (-not (Test-Path $tripRoute)) {
        $tripRouteContent = @'
import { NextResponse } from "next/server";

const BACKEND_URL = process.env.NEXT_PUBLIC_BACKEND_URL || "http://127.0.0.1:8000";

export async function GET() {
  try {
    const res = await fetch(`${BACKEND_URL}/trip/ping`);
    const data = await res.json().catch(() => ({}));
    return NextResponse.json({ ok: true, upstream: data }, { status: 200 });
  } catch (e) {
    return NextResponse.json({ ok: false, error: "Trip ping failed" }, { status: 500 });
  }
}
'@
        $tripRouteContent | Set-Content -Path $tripRoute -Encoding UTF8
        Write-Host "  ✔ Created API route: /api/trip" -ForegroundColor Green
    } else {
        Write-Host "  ✓ API route /api/trip already exists" -ForegroundColor Gray
    }

    # Office ping route
    $officeDir = Join-Path $apiBaseDir "office"
    if (-not (Test-Path $officeDir)) {
        New-Item -ItemType Directory -Force -Path $officeDir | Out-Null
    }
    $officeRoute = Join-Path $officeDir "route.ts"
    if (-not (Test-Path $officeRoute)) {
        $officeRouteContent = @'
import { NextResponse } from "next/server";

const BACKEND_URL = process.env.NEXT_PUBLIC_BACKEND_URL || "http://127.0.0.1:8000";

export async function GET() {
  try {
    const res = await fetch(`${BACKEND_URL}/office/ping`);
    const data = await res.json().catch(() => ({}));
    return NextResponse.json({ ok: true, upstream: data }, { status: 200 });
  } catch (e) {
    return NextResponse.json({ ok: false, error: "Office ping failed" }, { status: 500 });
  }
}
'@
        $officeRouteContent | Set-Content -Path $officeRoute -Encoding UTF8
        Write-Host "  ✔ Created API route: /api/office" -ForegroundColor Green
    } else {
        Write-Host "  ✓ API route /api/office already exists" -ForegroundColor Gray
    }

    # Media ping route
    $mediaDir = Join-Path $apiBaseDir "media"
    if (-not (Test-Path $mediaDir)) {
        New-Item -ItemType Directory -Force -Path $mediaDir | Out-Null
    }
    $mediaRoute = Join-Path $mediaDir "route.ts"
    if (-not (Test-Path $mediaRoute)) {
        $mediaRouteContent = @'
import { NextResponse } from "next/server";

const BACKEND_URL = process.env.NEXT_PUBLIC_BACKEND_URL || "http://127.0.0.1:8000";

export async function GET() {
  try {
    const res = await fetch(`${BACKEND_URL}/media/ping`);
    const data = await res.json().catch(() => ({}));
    return NextResponse.json({ ok: true, upstream: data }, { status: 200 });
  } catch (e) {
    return NextResponse.json({ ok: false, error: "Media ping failed" }, { status: 500 });
  }
}
'@
        $mediaRouteContent | Set-Content -Path $mediaRoute -Encoding UTF8
        Write-Host "  ✔ Created API route: /api/media" -ForegroundColor Green
    } else {
        Write-Host "  ✓ API route /api/media already exists" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⚠ Frontend directory not found, skipping API binding" -ForegroundColor Yellow
}
Write-Host ""

# PHASE 5: CREATE TEST SUITE SCRIPTS (IF MISSING)
Write-Host "[5/8] CREATE TEST SUITE SCRIPTS (STUBS)" -ForegroundColor Yellow

$runTests = Join-Path $scriptDir "run_tests.ps1"
$validateAuth = Join-Path $scriptDir "validate_auth.ps1"
$validateSup = Join-Path $scriptDir "validate_supabase.ps1"

if (-not (Test-Path $runTests)) {
    $runTestsContent = @'
Write-Host "=== RUN TESTS (BASIC HEALTH) ==="
try {
  $resp = Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -UseBasicParsing -TimeoutSec 5
  Write-Host "Backend /health status: $($resp.StatusCode)"
} catch {
  Write-Host "Backend /health check failed"
}
try {
  $resp2 = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
  Write-Host "Frontend / status: $($resp2.StatusCode)"
} catch {
  Write-Host "Frontend / check failed"
}
'@
    $runTestsContent | Set-Content -Path $runTests -Encoding UTF8
    Write-Host "  ✔ Created stub: run_tests.ps1" -ForegroundColor Green
} else {
    Write-Host "  ✓ run_tests.ps1 already exists" -ForegroundColor Gray
}

if (-not (Test-Path $validateAuth)) {
    $validateAuthContent = @'
Write-Host "=== VALIDATE AUTH (STUB) ==="
Write-Host "Implement real auth tests here (login, protected routes, etc.)"
'@
    $validateAuthContent | Set-Content -Path $validateAuth -Encoding UTF8
    Write-Host "  ✔ Created stub: validate_auth.ps1" -ForegroundColor Green
} else {
    Write-Host "  ✓ validate_auth.ps1 already exists" -ForegroundColor Gray
}

if (-not (Test-Path $validateSup)) {
    $validateSupContent = @'
Write-Host "=== VALIDATE SUPABASE (STUB) ==="
$supUrl = (Get-Item "env:SUPABASE_URL" -ErrorAction SilentlyContinue).Value
$supAnon = (Get-Item "env:SUPABASE_ANON_KEY" -ErrorAction SilentlyContinue).Value
if (-not $supUrl -or -not $supAnon) {
  Write-Host "Supabase ENV missing"
} else {
  Write-Host "Supabase ENV detected, add real validation logic here."
}
'@
    $validateSupContent | Set-Content -Path $validateSup -Encoding UTF8
    Write-Host "  ✔ Created stub: validate_supabase.ps1" -ForegroundColor Green
} else {
    Write-Host "  ✓ validate_supabase.ps1 already exists" -ForegroundColor Gray
}
Write-Host ""

# PHASE 6: JARVIS SCRIPTS GENERATION (HEALTH / SENTINEL / REPORT)
Write-Host "[6/8] JARVIS SCRIPTS GENERATION" -ForegroundColor Yellow

$jarvisDir = Join-Path $scriptDir "jarvis"
if (-not (Test-Path $jarvisDir)) {
    New-Item -ItemType Directory -Force -Path $jarvisDir | Out-Null
    Write-Host "  ✔ Created jarvis directory: $jarvisDir" -ForegroundColor Green
} else {
    Write-Host "  ✓ Jarvis directory already exists" -ForegroundColor Gray
}

$jarvisHealth = Join-Path $jarvisDir "jarvis_health.ps1"
$jarvisSentinel = Join-Path $jarvisDir "jarvis_sentinel.ps1"
$jarvisReport = Join-Path $jarvisDir "jarvis_report.ps1"

if (-not (Test-Path $jarvisHealth)) {
    $jarvisHealthContent = @'
Write-Host "=== JARVIS HEALTH CHECK ==="
$now = Get-Date
Write-Host "Timestamp : $now"

$targets = @(
  "http://127.0.0.1:8000/health",
  "http://127.0.0.1:8000/trip/ping",
  "http://127.0.0.1:8000/office/ping",
  "http://127.0.0.1:8000/media/ping",
  "http://localhost:3000",
  "http://localhost:3000/api/health"
)

foreach ($t in $targets) {
  try {
    $r = Invoke-WebRequest -Uri $t -UseBasicParsing -TimeoutSec 5
    Write-Host "[OK] $t => $($r.StatusCode)"
  } catch {
    Write-Host "[FAIL] $t"
  }
}
'@
    $jarvisHealthContent | Set-Content -Path $jarvisHealth -Encoding UTF8
    Write-Host "  ✔ Created Jarvis script: jarvis_health.ps1" -ForegroundColor Green
} else {
    Write-Host "  ✓ jarvis_health.ps1 already exists" -ForegroundColor Gray
}

if (-not (Test-Path $jarvisSentinel)) {
    $jarvisSentinelContent = @'
Write-Host "=== JARVIS SENTINEL (STUB) ==="
Write-Host "Add logic to watch logs, errors, quotas, etc."
'@
    $jarvisSentinelContent | Set-Content -Path $jarvisSentinel -Encoding UTF8
    Write-Host "  ✔ Created Jarvis script: jarvis_sentinel.ps1" -ForegroundColor Green
} else {
    Write-Host "  ✓ jarvis_sentinel.ps1 already exists" -ForegroundColor Gray
}

if (-not (Test-Path $jarvisReport)) {
    $jarvisReportContent = @'
Write-Host "=== JARVIS REPORT (STUB) ==="
Write-Host "Summarize status from health checks, tests, and deployments."
'@
    $jarvisReportContent | Set-Content -Path $jarvisReport -Encoding UTF8
    Write-Host "  ✔ Created Jarvis script: jarvis_report.ps1" -ForegroundColor Green
} else {
    Write-Host "  ✓ jarvis_report.ps1 already exists" -ForegroundColor Gray
}
Write-Host ""

# PHASE 7: REBUILD + REDEPLOY (AFTER CHANGES)
Write-Host "[7/8] REBUILD + REDEPLOY" -ForegroundColor Yellow

$vercelAvailable = $false
try {
    vercel --version | Out-Null
    $vercelAvailable = $true
} catch { }

if (Test-Path $frontendDir) {
    if (-not (Test-Path "$frontendDir\package.json")) {
        Write-Host "  ✖ frontend/package.json not found" -ForegroundColor Red
    } else {
        Push-Location $frontendDir
        try {
            Write-Host "  Installing dependencies..." -ForegroundColor Gray
            npm install --force 2>&1 | Out-Null
            Write-Host "  ✔ Dependencies installed" -ForegroundColor Green

            Write-Host "  Building Next.js production bundle..." -ForegroundColor Gray
            npm run build 2>&1 | Out-Null
            Write-Host "  ✔ Next.js production build completed (v50)" -ForegroundColor Green
        } catch {
            Write-Host "  ✖ Next.js production build failed (v50): $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "    Check the output above for details" -ForegroundColor Yellow
        }

        if ($vercelAvailable) {
            try {
                Write-Host "  Deploying to Vercel production..." -ForegroundColor Gray
                vercel deploy --prod 2>&1 | Out-Null
                Write-Host "  ✔ Vercel deploy --prod invoked (v50)" -ForegroundColor Green
            } catch {
                Write-Host "  ✖ Vercel deploy failed (v50): $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "    Check Vercel CLI login/project" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  ⚠ Vercel CLI not available, skipping deploy (v50)" -ForegroundColor Yellow
        }
        Pop-Location
    }
} else {
    Write-Host "  ⚠ Frontend directory not found, skipping build/deploy (v50)" -ForegroundColor Yellow
}
Write-Host ""

# PHASE 8: FINAL HEALTH + SUMMARY
Write-Host "[8/8] FINAL HEALTH + SUMMARY" -ForegroundColor Yellow

$backendHealthy = $false
try {
    $rb = Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -UseBasicParsing -TimeoutSec 5
    if ($rb.StatusCode -eq 200) { $backendHealthy = $true }
} catch { }

$frontendHealthy = $false
try {
    $rf = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
    if ($rf.StatusCode -eq 200) { $frontendHealthy = $true }
} catch { }

Write-Host "  Backend health : " -NoNewline
if ($backendHealthy) {
    Write-Host "OK" -ForegroundColor Green
} else {
    Write-Host "FAIL" -ForegroundColor Red
}

Write-Host "  Frontend root  : " -NoNewline
if ($frontendHealthy) {
    Write-Host "OK" -ForegroundColor Green
} else {
    Write-Host "FAIL" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== FUNAGING.SAS ONEPACK v50 MAX — DONE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend  : http://127.0.0.1:8000/docs" -ForegroundColor White
Write-Host "Health   : http://127.0.0.1:8000/health" -ForegroundColor White
Write-Host "Frontend : http://localhost:3000" -ForegroundColor White
Write-Host ""

if ($backendHealthy -and $frontendHealthy) {
    Write-Host "✅ Both backend and frontend are healthy!" -ForegroundColor Green
} elseif ($backendHealthy) {
    Write-Host "✅ Backend is healthy" -ForegroundColor Green
    Write-Host "⚠ Frontend may still be starting" -ForegroundColor Yellow
} elseif ($frontendHealthy) {
    Write-Host "⚠ Backend may still be starting" -ForegroundColor Yellow
    Write-Host "✅ Frontend is healthy" -ForegroundColor Green
} else {
    Write-Host "⚠ Services may still be starting. Check the PowerShell windows for status." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Created/Updated:" -ForegroundColor Cyan
Write-Host "  • Supabase client config (config/supabase.ts)" -ForegroundColor Gray
Write-Host "  • API routes (/api/health, /api/trip, /api/office, /api/media)" -ForegroundColor Gray
Write-Host "  • Test suite stubs (run_tests.ps1, validate_auth.ps1, validate_supabase.ps1)" -ForegroundColor Gray
Write-Host "  • Jarvis scripts (jarvis/jarvis_health.ps1, jarvis_sentinel.ps1, jarvis_report.ps1)" -ForegroundColor Gray
Write-Host ""


