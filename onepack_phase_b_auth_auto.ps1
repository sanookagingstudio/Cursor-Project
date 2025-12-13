# ONE PACK PHASE B – AUTO MODE (NO INPUT)
# Reads PAT + passwords from config files. Fully automated.

Write-Host "`n=== ONE PACK PHASE B – AUTO MODE START ===" -ForegroundColor Cyan

# ---------------------------------------------------------
# LOAD CONFIG FILES
# ---------------------------------------------------------
$patFile = "./config/pat.secret"
$authConfigFile = "./config/auth_config.env"

if (!(Test-Path $patFile)) {
    Write-Host "❌ ERROR: Missing PAT file at config/pat.secret" -ForegroundColor Red
    exit
}
if (!(Test-Path $authConfigFile)) {
    Write-Host "❌ ERROR: Missing auth_config.env file" -ForegroundColor Red
    exit
}

$PAT = Get-Content $patFile -Raw

# Parse auth_config.env
$authMap = @{}
foreach ($line in Get-Content $authConfigFile) {
    if ($line -match "=") {
        $parts = $line -split "=", 2
        $authMap[$parts[0].Trim()] = $parts[1].Trim()
    }
}

$ADMIN_PASS = $authMap["ADMIN_PASS"]
$STAFF_PASS = $authMap["STAFF_PASS"]
$DB_PASSWORD = $authMap["DB_PASSWORD"]

if (-not $ADMIN_PASS -or -not $STAFF_PASS -or -not $DB_PASSWORD) {
    Write-Host "❌ ERROR: auth_config.env missing required fields" -ForegroundColor Red
    exit
}

Write-Host "✓ Config loaded"

# ---------------------------------------------------------
# FETCH PROJECT VIA PAT
# ---------------------------------------------------------
$headers = @{
    "Authorization" = "Bearer $PAT"
    "Content-Type"  = "application/json"
}

try {
    $projects = Invoke-RestMethod -Method GET -Uri "https://api.supabase.com/v1/projects" -Headers $headers
} catch {
    Write-Host "❌ ERROR: Cannot fetch project list. PAT invalid." -ForegroundColor Red
    exit
}

$project = $projects | Where-Object { $_.name -eq "Club" }

if (-not $project) {
    Write-Host "❌ Project 'Club' not found" -ForegroundColor Red
    exit
}

$PROJECT_ID = $project.id
$ANON_KEY = $project.api.anonKey
$SERVICE_KEY = $project.api.serviceKey

$HOST = "$PROJECT_ID.supabase.co"
$REST_URL = "https://$HOST/rest/v1"
$AUTH_URL = "https://$HOST/auth/v1"
$RPC_SQL  = "$REST_URL/rpc/sql"

Write-Host "✓ Project located"
Write-Host "  → $REST_URL"

# ---------------------------------------------------------
# WRITE ENV
# ---------------------------------------------------------
$DATABASE_URL = "postgresql://postgres:$DB_PASSWORD@db.$PROJECT_ID.supabase.co:5432/postgres"

@"
SUPABASE_URL=https://$HOST
SUPABASE_ANON_KEY=$ANON_KEY
SUPABASE_SERVICE_ROLE_KEY=$SERVICE_KEY
DATABASE_URL=$DATABASE_URL
PROJECT_NAME=Club
"@ | Set-Content "./backend/.env"

Write-Host "✓ ENV written"

# ---------------------------------------------------------
# SCHEMA + RLS
# ---------------------------------------------------------
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

create policy if not exists "User can update own profile"
on user_profiles for update using (auth.uid() = id);
"@

Invoke-RestMethod -Method POST -Uri $RPC_SQL `
    -Headers @{ apikey=$SERVICE_KEY; Authorization="Bearer $SERVICE_KEY"; "Content-Type"="application/json" } `
    -Body (@{ query=$schema_sql } | ConvertTo-Json)

Write-Host "✓ Schema + RLS installed"

# ---------------------------------------------------------
# CREATE USERS
# ---------------------------------------------------------
$authHeaders = @{
  "apikey"        = $SERVICE_KEY
  "Authorization" = "Bearer $SERVICE_KEY"
  "Content-Type"  = "application/json"
}

$ADMIN = Invoke-RestMethod -Method POST -Uri "$AUTH_URL/admin/users" -Headers $authHeaders `
    -Body (@{ email="admin@example.com"; password=$ADMIN_PASS } | ConvertTo-Json)

$STAFF = Invoke-RestMethod -Method POST -Uri "$AUTH_URL/admin/users" -Headers $authHeaders `
    -Body (@{ email="staff@example.com"; password=$STAFF_PASS } | ConvertTo-Json)

Write-Host "✓ Users created"

# ---------------------------------------------------------
# ASSIGN ROLES
# ---------------------------------------------------------
$roleAdmin = Invoke-RestMethod -Method GET -Uri "$REST_URL/roles?name=eq.admin&select=id" -Headers $authHeaders
$roleStaff = Invoke-RestMethod -Method GET -Uri "$REST_URL/roles?name=eq.staff&select=id" -Headers $authHeaders

Invoke-RestMethod -Method POST -Uri "$REST_URL/user_profiles" -Headers $authHeaders `
    -Body (@{ id=$ADMIN.user.id; role_id=$roleAdmin[0].id } | ConvertTo-Json)

Invoke-RestMethod -Method POST -Uri "$REST_URL/user_profiles" -Headers $authHeaders `
    -Body (@{ id=$STAFF.user.id; role_id=$roleStaff[0].id } | ConvertTo-Json)

Write-Host "✓ Roles assigned"

# ---------------------------------------------------------
# ROUTE INSTALL
# ---------------------------------------------------------
$route = @"
from fastapi import APIRouter
from app.core.config import get_settings
import httpx

router = APIRouter(prefix='/auth', tags=['auth'])
settings = get_settings()
"@

$route | Set-Content "./backend/app/routes/auth.py"

Write-Host "`n=== COMPLETE — AUTO AUTH SYSTEM INSTALLED ===" -ForegroundColor Green












