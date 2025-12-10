# ============================================================
# ONE PACK – PHASE B
# AUTH SYSTEM: ADMIN / STAFF / CUSTOMER (Supabase + Backend)
# ============================================================
# ใช้ร่วมกับ ONE PACK VER.3 Phase A Foundation (ซึ่งคุณมีแล้ว)
# ระบบนี้จะ:
# 1) สร้าง Table: roles, user_profiles
# 2) สร้าง Roles: admin, staff, customer
# 3) สร้าง RLS Policies อัตโนมัติ
# 4) Seed Admin และ Staff
# 5) สร้าง Backend Routes สำหรับจัดการผู้ใช้
# ============================================================

Write-Host "`n=== ONE PACK PHASE B – AUTH SYSTEM START ===" -ForegroundColor Cyan

# ------------------------------------------------------------
# โหลดข้อมูลจาก backend/.env (Phase A มีไฟล์นี้แล้ว)
# ------------------------------------------------------------

$envPath = "./backend/.env"
if (!(Test-Path $envPath)) {
    Write-Host "ERROR: backend/.env ไม่พบ — คุณต้องรัน Phase A ก่อน" -ForegroundColor Red
    exit
}

$envMap = @{}
foreach ($line in Get-Content $envPath) {
    if ($line -match "=") {
        $parts = $line -split "=", 2
        $envMap[$parts[0].Trim()] = $parts[1].Trim()
    }
}

$SERVICE_ROLE = $envMap["SUPABASE_SERVICE_ROLE_KEY"]
$REST_URL     = $envMap["SUPABASE_URL"]

if (-not $SERVICE_ROLE) { Write-Host "ERROR: ไม่พบ SERVICE ROLE KEY" -ForegroundColor Red; exit }
if (-not $REST_URL) { Write-Host "ERROR: ไม่พบ SUPABASE_URL" -ForegroundColor Red; exit }

$headers = @{
    "apikey"        = $SERVICE_ROLE
    "Authorization" = "Bearer $SERVICE_ROLE"
    "Content-Type"  = "application/json"
}

Write-Host "✓ Loaded Supabase Service Role Key"
Write-Host "✓ Supabase REST URL: $REST_URL"

# ------------------------------------------------------------
# STEP 1: สร้าง TABLE roles + user_profiles
# ------------------------------------------------------------

Write-Host "`n→ Creating roles + user_profiles tables..." -ForegroundColor Yellow

$schemaSql = @"
create table if not exists roles (
  id uuid primary key default gen_random_uuid(),
  name text unique not null
);

insert into roles (name)
values ('admin'), ('staff'), ('customer')
on conflict (name) do nothing;

create table if not exists user_profiles (
  id uuid references auth.users(id) primary key,
  role_id uuid references roles(id),
  full_name text,
  created_at timestamp default now()
);

alter table user_profiles enable row level security;
"@

Invoke-RestMethod -Method Post `
    -Uri "$REST_URL/rest/v1/rpc/sql" `
    -Headers $headers `
    -Body (@{ query = $schemaSql } | ConvertTo-Json)

Write-Host "✓ Tables + Roles created"

# ------------------------------------------------------------
# STEP 2: สร้าง RLS Policies
# ------------------------------------------------------------

Write-Host "→ Applying RLS Policies..." -ForegroundColor Yellow

$policySql = @"
create policy if not exists "User can view own profile"
on user_profiles for select
using (auth.uid() = id);

create policy if not exists "User can update own profile"
on user_profiles for update
using (auth.uid() = id);

create policy if not exists "Admins full access"
on user_profiles for all
using (exists (select 1 from user_profiles up 
               join roles r on up.role_id = r.id 
               where up.id = auth.uid() and r.name = 'admin'));

"@

Invoke-RestMethod -Method Post `
    -Uri "$REST_URL/rest/v1/rpc/sql" `
    -Headers $headers `
    -Body (@{ query = $policySql } | ConvertTo-Json)

Write-Host "✓ RLS Policies applied"

# ------------------------------------------------------------
# STEP 3: Seed Admin + Staff
# ------------------------------------------------------------

Write-Host "→ Creating admin + staff users..." -ForegroundColor Yellow

$adminEmail = "admin@example.com"
$staffEmail = "staff@example.com"

$adminPass = Read-Host "ตั้ง Password สำหรับ ADMIN ($adminEmail)"
$staffPass = Read-Host "ตั้ง Password สำหรับ STAFF ($staffEmail)"

# Supabase Auth Signup
$authHeaders = @{
    "apikey"        = $SERVICE_ROLE
    "Authorization" = "Bearer $SERVICE_ROLE"
    "Content-Type"  = "application/json"
}

$adminUser = Invoke-RestMethod -Method Post `
    -Uri "https://$($REST_URL.Replace('https://','').Split('/')[0])auth/v1/admin/users" `
    -Headers $authHeaders `
    -Body (@{ email = $adminEmail; password = $adminPass } | ConvertTo-Json)

$staffUser = Invoke-RestMethod -Method Post `
    -Uri "https://$($REST_URL.Replace('https://','').Split('/')[0])auth/v1/admin/users" `
    -Headers $authHeaders `
    -Body (@{ email = $staffEmail; password = $staffPass } | ConvertTo-Json)

# GET role ids
$roleAdmin = Invoke-RestMethod -Method Get `
    -Uri "$REST_URL/rest/v1/roles?name=eq.admin&select=id" `
    -Headers $headers

$roleStaff = Invoke-RestMethod -Method Get `
    -Uri "$REST_URL/rest/v1/roles?name=eq.staff&select=id" `
    -Headers $headers

# insert into user_profiles
$adminInsert = @{
    id = $adminUser.user.id
    role_id = $roleAdmin[0].id
} | ConvertTo-Json

Invoke-RestMethod -Method Post `
    -Uri "$REST_URL/rest/v1/user_profiles" `
    -Headers $headers `
    -Body $adminInsert

$staffInsert = @{
    id = $staffUser.user.id
    role_id = $roleStaff[0].id
} | ConvertTo-Json

Invoke-RestMethod -Method Post `
    -Uri "$REST_URL/rest/v1/user_profiles" `
    -Headers $headers `
    -Body $staffInsert

Write-Host "✓ Admin + Staff users created"

# ------------------------------------------------------------
# STEP 4: สร้าง Backend Routes /auth
# ------------------------------------------------------------

Write-Host "→ Creating backend routes (auth.py)..." -ForegroundColor Yellow

$authRoute = @"
from fastapi import APIRouter
from app.core.config import get_settings
import httpx

router = APIRouter(prefix="/auth", tags=["auth"])

settings = get_settings()

@router.get("/profile")
async def get_profile(user_id: str):
    async with httpx.AsyncClient() as c:
        r = await c.get(
            f"{settings.supabase_url}/rest/v1/user_profiles",
            headers={
                "apikey": settings.supabase_anon_key,
                "Authorization": f"Bearer {settings.supabase_service_role_key}"
            },
            params={"id": f"eq.{user_id}", "select": "*"}
        )
    return r.json()

"@

Set-Content "./backend/app/routes/auth.py" $authRoute -Encoding UTF8
Write-Host "✓ Backend route created"

# Add import to new_main.py
(newMain = Get-Content "./backend/app/new_main.py") `
    -replace "from \.routes import trip, office, media", "from .routes import trip, office, media, auth" `
    -replace "app.include_router\(media.router\)", "app.include_router(media.router)\n    app.include_router(auth.router)" |
    Set-Content "./backend/app/new_main.py"

Write-Host "✓ Auth route plugged into backend"

# ------------------------------------------------------------
# DONE
# ------------------------------------------------------------

Write-Host "`n=== ONE PACK PHASE B – AUTH SYSTEM COMPLETED ===" -ForegroundColor Green
Write-Host "Admin login: $adminEmail"
Write-Host "Staff login: $staffEmail"
Write-Host "พร้อมให้ใช้งานแล้ว!"
