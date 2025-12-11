# onepack_funaging_v10.ps1
# FUNAGING.CLUB SYSTEM RESTORE & AUTO-RUN PACK (v10)
# Target repo: sanook-master-v2-main (SAS v1 Master Baseline)

param(
    [switch]$SkipDocker
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  ONEPACK v10 - FUNAGING.CLUB SYSTEM RESTORE & AUTO-RUN" -ForegroundColor Cyan
Write-Host "  Repo: sanook-master-v2-main (SAS v1 Master Baseline)" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

function Test-Command($name) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    return $cmd -ne $null
}

# -------------------------------------------------------------------
# R0: ENVIRONMENT CHECK
# -------------------------------------------------------------------
Write-Host "[R0] Checking core tooling (Python / Node / Docker)..." -ForegroundColor Yellow

if (Test-Command "python") {
    $pyVer = python --version 2>&1
    Write-Host "  Python : $pyVer"
} else {
    Write-Warning "  Python not found in PATH. Please install Python 3.11+ and re-run."
}

if (Test-Command "node") {
    $nodeVer = node -v 2>&1
    $npmVer  = npm -v 2>&1
    Write-Host "  Node.js: $nodeVer"
    Write-Host "  npm    : $npmVer"
} else {
    Write-Warning "  Node.js not found in PATH."
}

if (Test-Command "docker") {
    $dockerVer = docker --version 2>&1
    Write-Host "  Docker : $dockerVer"
} else {
    Write-Warning "  Docker not found in PATH."
}

if (Test-Command "docker-compose") {
    $dcVer = docker-compose --version 2>&1
    Write-Host "  docker-compose: $dcVer"
} elseif (Test-Command "docker") {
    $dcVer2 = docker compose version 2>&1
    Write-Host "  docker compose : $dcVer2"
}

Write-Host ""

# -------------------------------------------------------------------
# R1: REPO SANITY CHECK (FUNAGING.CLUB ONLY)
# -------------------------------------------------------------------
Write-Host "[R1] Verifying FUNAGING.CLUB repo structure..." -ForegroundColor Yellow

$expectedItems = @("backend", "frontend", "docker-compose.sas.yml")
$missing = @()

foreach ($item in $expectedItems) {
    if (-not (Test-Path $item)) {
        $missing += $item
    }
}

if ($missing.Count -gt 0) {
    Write-Warning "  Missing expected items in current directory:"
    $missing | ForEach-Object { Write-Warning "    - $_" }
    Write-Warning "  Make sure you run this script from the ROOT of sanook-master-v2-main."
} else {
    Write-Host "  Repo structure OK. (backend/, frontend/, docker-compose.sas.yml found)"
}

# ป้องกันไม่ให้ไปยุ่ง Media OS โดยไม่ได้ตั้งใจ
try {
    $currentName = (Get-Item -LiteralPath ".").Name
    if ((Test-Path "funaging-media-os") -or ($currentName -match "media-os")) {
        Write-Warning "  Detected something that looks like Media OS in this path."
        Write-Warning "  This ONEPACK is for FunAging.club only and will NOT touch Media OS."
    }
} catch { }

Write-Host ""

# -------------------------------------------------------------------
# R1.1: BACKEND STRUCTURE CHECK (SAS v1 PATTERN)
# -------------------------------------------------------------------
Write-Host "[R1.1] Checking backend structure (SAS v1 pattern)..." -ForegroundColor Yellow

$backendRoot = Join-Path (Get-Location) "backend"
$backendChecks = @(
    "app\main.py",
    "app\new_main.py",
    "app\routes\trip.py",
    "app\routes\office.py",
    "app\routes\media.py"
)

foreach ($rel in $backendChecks) {
    $p = Join-Path $backendRoot $rel
    if (Test-Path $p) {
        Write-Host "  [OK] $rel"
    } else {
        Write-Warning "  [MISS] $rel  ← compare with SAS v1 Master Baseline in GitHub"
    }
}

Write-Host ""

# -------------------------------------------------------------------
# R1.2: BACKEND VENV + DEPENDENCIES
# -------------------------------------------------------------------
Write-Host "[R1.2] Backend virtual environment & dependencies..." -ForegroundColor Yellow

if (-not (Test-Path $backendRoot)) {
    Write-Warning "  backend folder not found. Skipping backend env setup."
} else {
    Push-Location $backendRoot

    $venvPath = Join-Path (Get-Location) ".venv"
    if (-not (Test-Path $venvPath)) {
        Write-Host "  Creating backend virtual environment (.venv) ..."
        python -m venv .venv
    } else {
        Write-Host "  Backend virtual environment already exists."
    }

    $activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
    if (Test-Path $activateScript) {
        Write-Host "  Activating backend virtual environment..."
        . $activateScript

        $reqFile = "requirements.txt"
        if (Test-Path $reqFile) {
            Write-Host "  Installing / updating Python packages from requirements.txt ..."
            pip install --upgrade pip
            pip install -r requirements.txt
        } else {
            Write-Warning "  backend/requirements.txt not found. Sync with SAS v1 baseline if needed."
        }
    } else {
        Write-Warning "  Cannot find .venv\Scripts\Activate.ps1 – venv creation may have failed."
    }

    Pop-Location
}

Write-Host ""

# -------------------------------------------------------------------
# R2: SUPABASE FIX TEMPLATE (ADMIN / STAFF UUID)
# -------------------------------------------------------------------
Write-Host "[R2] Generating Supabase fix template for Admin/Staff UUID..." -ForegroundColor Yellow

$sqlFolder = Join-Path (Get-Location) "supabase_fix"
if (-not (Test-Path $sqlFolder)) {
    New-Item -ItemType Directory -Path $sqlFolder | Out-Null
}

$sqlFile = Join-Path $sqlFolder "fix_admin_staff_uuid_v10.sql"

$sqlTemplate = @"
-- ==========================================================
-- FUNAGING.CLUB - SUPABASE AUTH / PROFILE FIX (v10 TEMPLATE)
-- ปรับอีเมลและ UUID ตามของจริงก่อนรัน
-- ==========================================================

-- ตรวจสอบ user ปัจจุบัน (Admin / Staff)
-- ปรับ email ให้ตรงกับระบบจริงก่อนรัน SELECT นี้
-- SELECT id, email FROM auth.users
--   WHERE email IN ('sanookagingstudio@gmail.com','akemontree@gmail.com');

-- ถ้า Staff ใช้ UUID เดียวกับ Admin:
--   1) สร้าง Staff user ใหม่จากหน้า Auth ของ Supabase (แนะนำใช้ Dashboard)
--   2) เอา UUID ใหม่ของ Staff มาแทน 'NEW-STAFF-UUID-HERE' ด้านล่าง

-- ตัวอย่างการผูก profiles กับ UUID ใหม่ (เปลี่ยนชื่อ table/column ให้ตรงโปรเจกต์จริง):

-- UPDATE profiles
--   SET user_id = 'NEW-STAFF-UUID-HERE', role = 'STAFF'
--   WHERE email = 'akemontree@gmail.com';

-- UPDATE profiles
--   SET role = 'ADMIN'
--   WHERE email = 'sanookagingstudio@gmail.com';

-- ตรวจอีกครั้ง
-- SELECT user_id, email, role FROM profiles
--   WHERE email IN ('sanookagingstudio@gmail.com','akemontree@gmail.com');

-- NOTE:
--   • ให้ copy ทีละคำสั่งไปวางใน Supabase SQL Editor แล้วรันด้วยความระมัดระวัง
--   • ONE PACK ไม่เก็บ SERVICE ROLE KEY เพื่อความปลอดภัยของระบบ
"@

$sqlTemplate | Out-File -FilePath $sqlFile -Encoding UTF8 -Force

Write-Host "  Supabase fix template created:"
Write-Host "    $sqlFile"
Write-Host ""

# -------------------------------------------------------------------
# R3: DOCKER BACKEND BUILD & HEALTH CHECK
# -------------------------------------------------------------------
Write-Host "[R3] Docker stack (sas_db + sas_backend)..." -ForegroundColor Yellow

if ($SkipDocker) {
    Write-Host "  SkipDocker switch is ON. Skipping Docker operations."
} else {
    if (-not (Test-Path "docker-compose.sas.yml")) {
        Write-Warning "  docker-compose.sas.yml not found in current directory. Cannot start Docker stack."
    } else {
        try {
            Write-Host "  Bringing up database container (sas_db)..."
            docker compose -f docker-compose.sas.yml up -d sas_db

            Write-Host "  Waiting 10 seconds for DB to initialize..."
            Start-Sleep -Seconds 10

            Write-Host "  Bringing up backend container (sas_backend)..."
            docker compose -f docker-compose.sas.yml up -d sas_backend
        }
        catch {
            Write-Warning "  Docker compose up failed: $($_.Exception.Message)"
        }
    }
}

Write-Host ""

# Health check
Write-Host "[R3.1] Backend HTTP health check (ports 8000 / 9000)..." -ForegroundColor Yellow

$healthy = $false
$portsToCheck = @(8000, 9000)
$pathsToTry  = @("/health", "/")

foreach ($p in $portsToCheck) {
    foreach ($path in $pathsToTry) {
        $url = "http://localhost:$p$path"
        try {
            Write-Host "  Trying $url ..."
            $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5
            Write-Host "    StatusCode: $($resp.StatusCode)"
            if ($resp.StatusCode -eq 200) {
                Write-Host "    Backend appears healthy on $url" -ForegroundColor Green
                $healthy = $true
                break
            }
        } catch {
            Write-Warning "    Failed on $url : $($_.Exception.Message)"
        }
    }
    if ($healthy) { break }
}

if (-not $healthy) {
    Write-Warning "  Backend health check did not return HTTP 200 on known ports/path."
    Write-Warning "  Check docker logs for sas_backend / sas_db if something is wrong."
}

Write-Host ""

# -------------------------------------------------------------------
# R4: FRONTEND QUICK CHECK
# -------------------------------------------------------------------
Write-Host "[R4] Frontend quick sanity check (Next.js app)..." -ForegroundColor Yellow

$frontendRoot = Join-Path (Get-Location) "frontend"

if (-not (Test-Path $frontendRoot)) {
    Write-Warning "  frontend folder not found."
} else {
    $envLocal = Join-Path $frontendRoot ".env.local"
    if (Test-Path $envLocal) {
        Write-Host "  Found frontend/.env.local → verify:"
        Write-Host "    SUPABASE_URL / SUPABASE_ANON_KEY / BACKEND_URL"
    } else {
        Write-Warning "  frontend/.env.local not found."
        Write-Host  "  Create it based on your Vercel/Supabase environment variables."
    }

    Write-Host ""
    Write-Host "  To run frontend in dev mode (manual step):" -ForegroundColor Cyan
    Write-Host "    cd frontend"
    Write-Host "    npm install"
    Write-Host "    npm run dev"
    Write-Host ""
}

# -------------------------------------------------------------------
# DONE
# -------------------------------------------------------------------
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  ONEPACK v10 DONE  → Environment checked, backend prepared," -ForegroundColor Cyan
Write-Host "                     Supabase fix SQL generated, Docker run," -ForegroundColor Cyan
Write-Host "                     frontend sanity info printed." -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next manual actions (minimal):" -ForegroundColor Cyan
Write-Host "  1) เปิดไฟล์ supabase_fix\fix_admin_staff_uuid_v10.sql แล้ว copy คำสั่งไปรันใน Supabase."
Write-Host "  2) ถ้า health check ไม่ 200 ให้ดู docker logs (sas_backend / sas_db)."
Write-Host "  3) ตั้งค่า frontend/.env.local แล้วรัน frontend dev หรือ deploy Vercel." 
Write-Host ""

