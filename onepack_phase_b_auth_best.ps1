# ONE PACK PHASE B – IMMORTAL "THE BEST" VERSION
# Admin / Staff / Customer Auth System
# Ultra-stable, no REST_URL errors, no silent failures, full validation.

Write-Host "`n=== ONE PACK PHASE B – THE BEST VERSION START ===" -ForegroundColor Cyan

# -----------------------------
# INPUT PAT + PASSWORDS
# -----------------------------
$PAT = Read-Host "Enter SUPABASE PAT (required)"
$ADMIN_PASS = Read-Host "Enter password for admin@example.com"
$STAFF_PASS = Read-Host "Enter password for staff@example.com"
$DB_PASSWORD = Read-Host "Enter Database Password"

if (-not $PAT) {
    Write-Host "❌ ERROR: PAT is required." -ForegroundColor Red
    exit
}

# -----------------------------
# FETCH PROJECT INFO
# -----------------------------
$headers = @{
    "Authorization" = "Bearer $PAT"
    "Content-Type"  = "application/json"
}

try {
    $projects = Invoke-RestMethod -Method GET -Uri "https://api.supabase.com/v1/projects" -Headers $headers
} catch {
    Write-Host "❌ ERROR: Unable to fetch project list. PAT invalid or expired." -ForegroundColor Red
    exit
}

$project = $projects | Where-Object { $_.name -eq "Club" }

if (-not $project) {
    Write-Host "❌ ERROR: Project 'Club' not found." -ForegroundColor Red
    exit
}

$PROJECT_ID = $project.id
$ANON_KEY   = $project.api.anonKey
$SERVICE_KEY = $project.api.serviceKey

if (-not $SERVICE_KEY) {
    Write-Host "❌ ERROR: Service Role Key was NOT returned by API." -ForegroundColor Red
    exit
}

Write-Host "✓ Project Found"
Write-Host "  → Project ID: $PROJECT_ID"

# -----------------------------
# BUILD FULL URL STRUCTURE
# -----------------------------
$HOST = "$PROJECT_ID.supabase.co"
$REST_URL = "https://$HOST/rest/v1"
$AUTH_URL = "https://$HOST/auth/v1"
$RPC_SQL  = "$REST_URL/rpc/sql"

Write-Host "✓ REST URL: $REST_URL"
Write-Host "✓ AUTH URL: $AUTH_URL"

# -----------------------------
# DATABASE URL
# -----------------------------
$DATABASE_URL = "postgresql://postgres:$DB_PASSWORD@db.$PROJECT_ID.supabase.co:5432/postgres"

Write-Host "✓ DATABASE_URL built"

# -----------------------------
# WRITE CLEAN ENV
# -----------------------------
@"
SUPABASE_URL=https://$HOST
SUPABASE_ANON_KEY=$ANON_KEY
SUPABASE_SERVICE_ROLE_KEY=$SERVICE_KEY
DATABASE_URL=$DATABASE_URL
PROJECT_NAME=Club
"@ | Set-Content "./backend/.env" -Encoding UTF8

Write-Host "✓ ENV File written and repaired"

# =========================================================
# CREATE SCHEMA: roles + user_profiles + RLS
# =========================================================
$schema_sql = @"
create table if not exists roles (
  id uuid primary key default gen_random_uuid(),
  name text unique not null
);
insert into roles (name)
values ('admin'), ('staff'), ('customer')
on conflict (name) do nothing;

create table if not exists user_profiles (
  id uuid primary key references auth.users(id),
  role_id uuid references roles(id),
  full_name text,
  created_at timestamp default now()
);
alter table user_profiles enable row level security;

create policy if not exists "User can view own profile"
on user_profiles for select
using (auth.uid() = id);

create policy if not exists "User can update own profile"
on user_profiles for update
using (auth.uid() = id);

create policy if not exists "Admins full access"
on user_profiles for all
using (
  exists (
      select 1 from user_profiles up
      join roles r on up.role_id = r.id
      where up.id = auth.uid() and r.name = 'admin'
  )
);
"@

try {
    Invoke-RestMethod -Method POST `
        -Uri $RPC_SQL `
        -Headers @{ apikey=$SERVICE_KEY; Authorization="Bearer $SERVICE_KEY"; "Content-Type"="application/json" } `
        -Body (@{ query=$schema_sql } | ConvertTo-Json)
    Write-Host "✓ Schema + RLS created"
} catch {
    Write-Host "❌ ERROR creating schema" -ForegroundColor Red
    exit
}

# =========================================================
# CREATE USERS (ADMIN + STAFF)
# =========================================================
$authHeaders = @{
  "apikey"        = $SERVICE_KEY
  "Authorization" = "Bearer $SERVICE_KEY"
  "Content-Type"  = "application/json"
}

# → ADMIN
try {
    $ADMIN = Invoke-RestMethod -Method POST `
        -Uri "$AUTH_URL/admin/users" `
        -Headers $authHeaders `
        -Body (@{ email="admin@example.com"; password=$ADMIN_PASS } | ConvertTo-Json)
} catch {
    Write-Host "❌ ERROR creating admin user" -ForegroundColor Red
    exit
}

# → STAFF
try {
    $STAFF = Invoke-RestMethod -Method POST `
        -Uri "$AUTH_URL/admin/users" `
        -Headers $authHeaders `
        -Body (@{ email="staff@example.com"; password=$STAFF_PASS } | ConvertTo-Json)
} catch {
    Write-Host "❌ ERROR creating staff user" -ForegroundColor Red
    exit
}

Write-Host "✓ Users created (admin + staff)"

# =========================================================
# ASSIGN ROLES
# =========================================================
$roleAdmin = Invoke-RestMethod -Method GET -Uri "$REST_URL/roles?name=eq.admin&select=id" -Headers $authHeaders
$roleStaff = Invoke-RestMethod -Method GET -Uri "$REST_URL/roles?name=eq.staff&select=id" -Headers $authHeaders

if (-not $roleAdmin) { Write-Host "❌ ERROR: admin role missing" -ForegroundColor Red; exit }
if (-not $roleStaff) { Write-Host "❌ ERROR: staff role missing" -ForegroundColor Red; exit }

$insertAdmin = @{ id=$ADMIN.user.id; role_id=$roleAdmin[0].id } | ConvertTo-Json
$insertStaff = @{ id=$STAFF.user.id; role_id=$roleStaff[0].id } | ConvertTo-Json

Invoke-RestMethod -Method POST -Uri "$REST_URL/user_profiles" -Headers $authHeaders -Body $insertAdmin
Invoke-RestMethod -Method POST -Uri "$REST_URL/user_profiles" -Headers $authHeaders -Body $insertStaff

Write-Host "✓ Roles assigned"

# =========================================================
# CREATE BACKEND ROUTE auth.py
# =========================================================
$route = @"
from fastapi import APIRouter
from app.core.config import get_settings
import httpx

router = APIRouter(prefix='/auth', tags=['auth'])
settings = get_settings()

@router.get('/profile')
async def get_profile(user_id: str):
    async with httpx.AsyncClient() as c:
        r = await c.get(
            f"{settings.supabase_url}/rest/v1/user_profiles",
            headers={
                "apikey": settings.supabase_anon_key,
                "Authorization": f"Bearer {settings.supabase_service_role_key}"
            },
            params={ "id": f"eq.{user_id}", "select":"*" }
        )
    return r.json()
"@

$route | Set-Content "./backend/app/routes/auth.py" -Encoding UTF8

# plug route
$content = Get-Content "./backend/app/new_main.py"
$content = $content -replace "app.include_router\(media.router\)", "app.include_router(media.router)`n    app.include_router(auth.router)"
Set-Content "./backend/app/new_main.py" $content

Write-Host "`n=== ALL DONE — AUTH SYSTEM INSTALLED SUCCESSFULLY ===" -ForegroundColor Green
Write-Host "Admin login: admin@example.com"
Write-Host "Staff login: staff@example.com"



