# onepack_funaging_v9.ps1
# FUNAGING.CLUB SYSTEM RECAP & RESTORE PLAN v9
# Target repo: D:\SanookAgingStudio\shadow project\sanook-master-v2-main

param(
    [switch]$SkipDockerBuild
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  ONEPACK v9 - FUNAGING.CLUB SYSTEM RESTORE & AUTO-CHECK" -ForegroundColor Cyan
Write-Host "  Repo: sanook-master-v2-main (SAS v1 Master Baseline)" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

# -------------------------------------------------------------------
# PHASE R0: ENVIRONMENT CHECK
# -------------------------------------------------------------------
Write-Host "[R0] Checking core tooling (Python / Node / Docker)..." -ForegroundColor Yellow

function Test-Command($name) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    return $cmd -ne $null
}

if (Test-Command "python") {
    $pyVer = python --version 2>&1
    Write-Host "  Python: $pyVer"
} else {
    Write-Warning "  Python not found in PATH. Please install Python 3.11+ and re-run."
}

if (Test-Command "node") {
    $nodeVer = node -v 2>&1
    $npmVer = npm -v 2>&1
    Write-Host "  Node.js: $nodeVer"
    Write-Host "  npm: $npmVer"
} else {
    Write-Warning "  Node.js not found in PATH."
}

if (Test-Command "docker") {
    $dockerVer = docker --version 2>&1
    Write-Host "  Docker: $dockerVer"
} else {
    Write-Warning "  Docker not found in PATH."
}

if (Test-Command "docker-compose") {
    $dcVer = docker-compose --version 2>&1
    Write-Host "  docker-compose: $dcVer"
} elseif (Test-Command "docker") {
    $dcVer2 = docker compose version 2>&1
    Write-Host "  docker compose: $dcVer2"
}

Write-Host ""

# -------------------------------------------------------------------
# PHASE R1: REPO SANITY CHECK (FUNAGING.CLUB ONLY)
# -------------------------------------------------------------------
Write-Host "[R1] Verifying that we are in FUNAGING.CLUB repo (sanook-master-v2-main)..." -ForegroundColor Yellow

$expectedItems = @(
    "backend",
    "frontend",
    "docker-compose.sas.yml"
)

$missing = @()
foreach ($item in $expectedItems) {
    if (-not (Test-Path $item)) {
        $missing += $item
    }
}

if ($missing.Count -gt 0) {
    Write-Warning "  Some expected items are missing in current directory:"
    $missing | ForEach-Object { Write-Warning "    - $_" }
    Write-Warning "  Make sure you run this script from the ROOT of sanook-master-v2-main."
} else {
    Write-Host "  Repo structure OK. (backend/, frontend/, docker-compose.sas.yml found)"
}

# Guard to avoid accidentally touching other projects (e.g. Media OS)
if (Test-Path "funaging-media-os" -or (Get-Item .).Name -match "media-os") {
    Write-Warning "  Detected paths that look like Media OS in this directory."
    Write-Warning "  This ONEPACK is for FunAging.club only and will not touch Media OS."
}

Write-Host ""

# -------------------------------------------------------------------
# PHASE R1.1: BACKEND STRUCTURE CHECK AGAINST SAS v1 PATTERN
# -------------------------------------------------------------------
Write-Host "[R1.1] Checking backend structure against SAS v1 pattern..." -ForegroundColor Yellow

$backendRoot = Join-Path (Get-Location) "backend"
$routesDir   = Join-Path $backendRoot "app\routes"

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
        Write-Warning "  [MISS] $rel (check against SAS v1 Master Baseline in GitHub)"
    }
}

Write-Host ""

# -------------------------------------------------------------------
# PHASE R1.2: BACKEND PYTHON ENV + DEPENDENCIES
# -------------------------------------------------------------------
Write-Host "[R1.2] Preparing backend virtual environment & installing dependencies..." -ForegroundColor Yellow

$venvPath = Join-Path $backendRoot ".venv"

if (-not (Test-Path $backendRoot)) {
    Write-Warning "  backend folder not found. Skipping backend env setup."
} else {
    Set-Location $backendRoot

    if (-not (Test-Path $venvPath)) {
        Write-Host "  Creating virtual environment at backend\.venv ..."
        python -m venv .venv
    } else {
        Write-Host "  Virtual environment already exists."
    }

    $activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
    if (Test-Path $activateScript) {
        Write-Host "  Activating virtual environment..."
        . $activateScript

        $reqFile = "requirements.txt"
        if (Test-Path $reqFile) {
            Write-Host "  Installing / updating Python dependencies from requirements.txt ..."
            pip install --upgrade pip
            pip install -r requirements.txt
        } else {
            Write-Warning "  requirements.txt not found in backend/. Please sync with SAS v1 baseline."
        }
    } else {
        Write-Warning "  Cannot find backend\.venv\Scripts\Activate.ps1 – venv creation may have failed."
    }

    Set-Location (Get-Location).Parent
    Write-Host ""
}

# -------------------------------------------------------------------
# PHASE R2: SUPABASE FIX PREP (ADMIN / STAFF UUID ISSUE)
# -------------------------------------------------------------------
Write-Host "[R2] Preparing Supabase fix instructions (Admin/Staff UUID issue)..." -ForegroundColor Yellow

$sqlFolder = Join-Path (Get-Location) "supabase_fix"
if (-not (Test-Path $sqlFolder)) {
    New-Item -ItemType Directory -Path $sqlFolder | Out-Null
}

$sqlFile = Join-Path $sqlFolder "fix_admin_staff_uuid_v9.sql"

# NOTE:
# เนื่องจาก ONEPACK ไม่สามารถ login เข้า Supabase ได้โดยตรง (ต้องใช้ service role / GUI)
# เราจึงสร้างไฟล์ SQL แนะนำให้คุณ copy ไปวางใน Supabase SQL Editor แล้วรันด้วยตัวเอง
# ให้ปรับ EMAIL และ UUID ให้ตรงกับค่าจริงถ้าจำเป็น

$sqlTemplate = @"
-- ==========================================================
-- FUNAGING.CLUB - SUPABASE AUTH / PROFILE FIX (v9 TEMPLATE)
-- ปรับอีเมลและ UUID ตามของจริงก่อนรัน
-- ==========================================================

-- ตัวอย่าง: แยก Admin / Staff ให้คนละ UUID ชัดเจน
-- สมมติ:
--   Admin email  : sanookagingstudio@gmail.com
--   Staff email  : akemontree@gmail.com

-- 1) ตรวจสอบ user ปัจจุบัน
-- SELECT id, email FROM auth.users
--   WHERE email IN ('sanookagingstudio@gmail.com','akemontree@gmail.com');

-- 2) ถ้า Staff ใช้ UUID เดียวกับ Admin จริง ให้สร้าง Staff user ใหม่
--    (ให้ใช้คำสั่งจากหน้า Auth UI หรือคำสั่ง SQL ด้านล่างเป็นแนวทาง)

-- ตัวอย่างสร้าง Staff user ใหม่ (ใช้ Supabase Dashboard สร้างจะง่ายกว่า):
-- INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at)
-- VALUES ('NEW-STAFF-UUID-HERE', 'akemontree@gmail.com', '<<PASSWORD_HASH>>', now());

-- 3) ปรับ profiles / roles ให้ผูกกับ UUID ใหม่ที่ถูกต้อง
-- ตัวอย่าง (เปลี่ยนชื่อ table/column ให้ตรงโปรเจกต์จริง):

-- UPDATE profiles
--   SET user_id = 'NEW-STAFF-UUID-HERE', role = 'STAFF'
--   WHERE email = 'akemontree@gmail.com';

-- UPDATE profiles
--   SET role = 'ADMIN'
--   WHERE email = 'sanookagingstudio@gmail.com';

-- 4) ตรวจสอบผลลัพธ์อีกครั้ง
-- SELECT * FROM profiles
--   WHERE email IN ('sanookagingstudio@gmail.com','akemontree@gmail.com');

-- หมายเหตุ:
-- รันไฟล์นี้ทีละคำสั่งด้วยความระมัดระวังใน Supabase SQL Editor
-- เพื่อให้แน่ใจว่า Admin และ Staff มี UUID คนละตัวกันจริง ๆ
"@

$sqlTemplate | Out-File -FilePath $sqlFile -Encoding UTF8 -Force

Write-Host "  Created Supabase fix template:"
Write-Host "    $sqlFile"
Write-Host "  → เปิดไฟล์นี้ แล้ว copy เนื้อหาไปวางใน Supabase SQL Editor เพื่อจัดการ UUID ตามขั้นตอน." -ForegroundColor DarkYellow
Write-Host ""

# -------------------------------------------------------------------
# PHASE R3: DOCKER BACKEND BUILD & HEALTH CHECK
# -------------------------------------------------------------------
Write-Host "[R3] Docker build & backend health check..." -ForegroundColor Yellow

if ($SkipDockerBuild) {
    Write-Host "  SkipDockerBuild switch is ON. Skipping Docker compose build/up."
} else {
    if (-not (Test-Path "docker-compose.sas.yml")) {
        Write-Warning "  docker-compose.sas.yml not found in current directory. Cannot start Docker stack."
    } else {
        Write-Host "  Starting Docker stack (sas_db + sas_backend) using docker-compose.sas.yml ..."
        try {
            docker compose -f docker-compose.sas.yml up -d sas_db
            Write-Host "  Waiting 10 seconds for DB to be ready..."
            Start-Sleep -Seconds 10

            docker compose -f docker-compose.sas.yml up -d sas_backend
        }
        catch {
            Write-Warning "  Docker compose up failed: $($_.Exception.Message)"
        }
    }
}

Write-Host ""

# Basic health check (HTTP) – adjust port/path if needed
Write-Host "[R3.1] Backend HTTP health check (localhost:8000 or 9000)..." -ForegroundColor Yellow

$portsToCheck = @(8000, 9000)
foreach ($p in $portsToCheck) {
    try {
        $url = "http://localhost:$p/health"
        Write-Host "  Trying $url ..."
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5
        Write-Host "    StatusCode: $($resp.StatusCode)"
        if ($resp.StatusCode -eq 200) {
            Write-Host "    Backend appears healthy on port $p." -ForegroundColor Green
            break
        }
    }
    catch {
        Write-Warning "    Health check on port $p failed: $($_.Exception.Message)"
    }
}

Write-Host ""

# -------------------------------------------------------------------
# PHASE R4: FRONTEND QUICK CHECK (NO BUILD, JUST GUIDANCE)
# -------------------------------------------------------------------
Write-Host "[R4] Frontend quick sanity check (Next.js)..." -ForegroundColor Yellow

$frontendRoot = Join-Path (Get-Location) "frontend"
if (-not (Test-Path $frontendRoot)) {
    Write-Warning "  frontend folder not found."
} else {
    $envLocal = Join-Path $frontendRoot ".env.local"
    if (Test-Path $envLocal) {
        Write-Host "  Found frontend .env.local → Verify SUPABASE_URL / SUPABASE_ANON_KEY / BACKEND_URL inside."
    } else {
        Write-Warning "  frontend/.env.local not found. Create one and sync with Vercel env vars."
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
Write-Host "  ONEPACK v9 COMPLETE (AUTO-CHECK + PREPARED RESTORE STEPS)" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next manual steps summary:" -ForegroundColor Cyan
Write-Host "  1) เปิดไฟล์ supabase_fix\fix_admin_staff_uuid_v9.sql → copy ไปปรับ/รันใน Supabase SQL Editor."
Write-Host "  2) ตรวจว่า Docker backend ขึ้นแล้ว (sas_backend / sas_db) และ health endpoint ตอบ 200."
Write-Host "  3) ตั้งค่า frontend/.env.local ให้ตรงกับ Supabase/Vercel แล้วรัน frontend dev/prod."
Write-Host ""




