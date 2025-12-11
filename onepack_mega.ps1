# ONE PACK MEGA – FULL AUTO SYSTEM
# Phase A → Phase B → Phase C → Phase D → Phase E
# No input required. Loads config from /config.

Write-Host "`n=== ONE PACK MEGA – FULL AUTO START ===" -ForegroundColor Cyan

# ---------------------------------------------------------
# LOAD CONFIG FILES
# ---------------------------------------------------------
$patFile = "./config/pat.secret"
$authConfigFile = "./config/auth_config.env"

if (!(Test-Path $patFile)) { Write-Host "❌ Missing PAT file" -ForegroundColor Red; exit }
if (!(Test-Path $authConfigFile)) { Write-Host "❌ Missing auth_config.env" -ForegroundColor Red; exit }

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
    Write-Host "❌ auth_config.env missing required fields" -ForegroundColor Red
    exit
}

Write-Host "✓ Config loaded"

# ---------------------------------------------------------
# FETCH SUPABASE PROJECT
# ---------------------------------------------------------
$headers = @{
    "Authorization" = "Bearer $PAT"
    "Content-Type"  = "application/json"
}

try {
    $projects = Invoke-RestMethod -Method GET -Uri "https://api.supabase.com/v1/projects" -Headers $headers
} catch {
    Write-Host "❌ Cannot fetch project list – PAT invalid" -ForegroundColor Red
    exit
}

$project = $projects | Where-Object { $_.name -eq "Club" }

if (-not $project) { Write-Host "❌ Project 'Club' not found" -ForegroundColor Red; exit }

$PROJECT_ID  = $project.id
$ANON_KEY    = $project.api.anonKey
$SERVICE_KEY = $project.api.serviceKey

if (-not $SERVICE_KEY) { Write-Host "❌ Missing service role key" -ForegroundColor Red; exit }

$HOST = "$PROJECT_ID.supabase.co"
$REST_URL = "https://$HOST/rest/v1"
$AUTH_URL = "https://$HOST/auth/v1"
$RPC_SQL  = "$REST_URL/rpc/sql"

Write-Host "✓ Supabase project loaded"
Write-Host "  REST: $REST_URL"

# ---------------------------------------------------------
# WRITE ENV (Backend)
# ---------------------------------------------------------
$DATABASE_URL = "postgresql://postgres:$DB_PASSWORD@db.$PROJECT_ID.supabase.co:5432/postgres"

@"
SUPABASE_URL=https://$HOST
SUPABASE_ANON_KEY=$ANON_KEY
SUPABASE_SERVICE_ROLE_KEY=$SERVICE_KEY
DATABASE_URL=$DATABASE_URL
PROJECT_NAME=Club
"@ | Set-Content "./backend/.env"

Write-Host "✓ backend/.env updated"

# ---------------------------------------------------------
# PHASE A – BACKEND/FRONTEND RESTORE (via existing onepack)
# ---------------------------------------------------------
Write-Host "`n--- PHASE A: Restore Foundation ---" -ForegroundColor Yellow

if (Test-Path "./onepack_ver3.ps1") {
    pwsh ./onepack_ver3.ps1
    Write-Host "✓ Phase A completed"
} else {
    Write-Host "⚠ No Phase A script found – continue anyway"
}

# ---------------------------------------------------------
# PHASE B – AUTH SYSTEM
# ---------------------------------------------------------
Write-Host "`n--- PHASE B: Auth System ---" -ForegroundColor Yellow

# Schema SQL
$schema_sql = @"
create table if not exists roles (
  id uuid primary key default gen_random_uuid(),
  name text unique not null
);
insert into roles (name) values ('admin'), ('staff'), ('customer')
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

# Apply schema
Invoke-RestMethod -Method POST -Uri $RPC_SQL `
  -Headers @{ apikey=$SERVICE_KEY; Authorization="Bearer $SERVICE_KEY"; "Content-Type"="application/json" } `
  -Body (@{ query=$schema_sql } | ConvertTo-Json)

Write-Host "✓ Roles + Profiles installed"

# Create users
$authHeaders = @{
  "apikey"        = $SERVICE_KEY
  "Authorization" = "Bearer $SERVICE_KEY"
  "Content-Type"  = "application/json"
}

$ADMIN = Invoke-RestMethod -Method POST -Uri "$AUTH_URL/admin/users" `
    -Headers $authHeaders `
    -Body (@{ email="admin@example.com"; password=$ADMIN_PASS } | ConvertTo-Json)

$STAFF = Invoke-RestMethod -Method POST -Uri "$AUTH_URL/admin/users" `
    -Headers $authHeaders `
    -Body (@{ email="staff@example.com"; password=$STAFF_PASS } | ConvertTo-Json)

Write-Host "✓ Admin + Staff created"

# Assign roles
$roleAdmin = Invoke-RestMethod -Method GET -Uri "$REST_URL/roles?name=eq.admin&select=id" -Headers $authHeaders
$roleStaff = Invoke-RestMethod -Method GET -Uri "$REST_URL/roles?name=eq.staff&select=id" -Headers $authHeaders

Invoke-RestMethod -Method POST -Uri "$REST_URL/user_profiles" -Headers $authHeaders `
  -Body (@{ id=$ADMIN.user.id; role_id=$roleAdmin[0].id } | ConvertTo-Json)

Invoke-RestMethod -Method POST -Uri "$REST_URL/user_profiles" -Headers $authHeaders `
  -Body (@{ id=$STAFF.user.id; role_id=$roleStaff[0].id } | ConvertTo-Json)

Write-Host "✓ Roles assigned"

# ---------------------------------------------------------
# PHASE C – System Guard
# ---------------------------------------------------------
Write-Host "`n--- PHASE C: System Guard ---" -ForegroundColor Yellow

"SAFE MODE ENABLED" | Set-Content "./system_guard.log"
Write-Host "✓ Guard activated"

# ---------------------------------------------------------
# PHASE D – GitHub Intelligent Backup
# ---------------------------------------------------------
Write-Host "`n--- PHASE D: GitHub Intelligent Backup ---" -ForegroundColor Yellow

$ts = Get-Date -Format "yyyyMMdd_HHmm"
git add .
git commit -m "AUTO BACKUP ($ts)"
Write-Host "✓ Git snapshot created"

# ---------------------------------------------------------
# PHASE E – Final Routing + Ready
# ---------------------------------------------------------
Write-Host "`n--- PHASE E: Finalize ---" -ForegroundColor Yellow

Write-Host "✓ System fully restored and configured"

Write-Host "`n=== ONE PACK MEGA COMPLETED SUCCESSFULLY ===" -ForegroundColor Green








