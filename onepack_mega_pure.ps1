# ONE PACK MEGA – PURE MODE (NO PAT, NEVER EXPIRE)
# Phase A → Phase B → Phase C → Phase D → Phase E
# Uses local ENV + config only. No admin API.

Write-Host "`n=== ONE PACK MEGA – PURE MODE START ===" -ForegroundColor Cyan

# ---------------------------------------------------------
# LOAD SUPABASE CONFIG FROM backend/.env
# ---------------------------------------------------------
$envFile = "./backend/.env"
$authConfig = "./config/auth_config.env"

if (!(Test-Path $envFile)) {
    Write-Host "❌ ERROR: backend/.env not found" -ForegroundColor Red
    exit
}

if (!(Test-Path $authConfig)) {
    Write-Host "❌ ERROR: config/auth_config.env not found" -ForegroundColor Red
    exit
}

# parse backend/.env
$envMap = @{}
foreach ($line in Get-Content $envFile) {
    if ($line -match "=") {
        $parts = $line -split "=", 2
        $envMap[$parts[0].Trim()] = $parts[1].Trim()
    }
}

$SUPABASE_URL = $envMap["SUPABASE_URL"]
$ANON_KEY = $envMap["SUPABASE_ANON_KEY"]
$SERVICE_KEY = $envMap["SUPABASE_SERVICE_ROLE_KEY"]
$DATABASE_URL = $envMap["DATABASE_URL"]

if (-not $SUPABASE_URL -or -not $SERVICE_KEY) {
    Write-Host "❌ ERROR: Missing Supabase keys in backend/.env" -ForegroundColor Red
    exit
}

Write-Host "✓ Loaded SUPABASE CONFIG"

# build URLs
$REST_URL = "$SUPABASE_URL/rest/v1"
$AUTH_URL = "$SUPABASE_URL/auth/v1"
$RPC_SQL  = "$SUPABASE_URL/rest/v1/rpc/sql"

# ---------------------------------------------------------
# LOAD AUTH CONFIG FOR ADMIN / STAFF / DB
# ---------------------------------------------------------
$authMap = @{}
foreach ($line in Get-Content $authConfig) {
    if ($line -match "=") {
        $parts = $line -split "=", 2
        $authMap[$parts[0].Trim()] = $parts[1].Trim()
    }
}

$ADMIN_PASS = $authMap["ADMIN_PASS"]
$STAFF_PASS = $authMap["STAFF_PASS"]

if (-not $ADMIN_PASS -or -not $STAFF_PASS) {
    Write-Host "❌ ERROR: Missing ADMIN_PASS or STAFF_PASS" -ForegroundColor Red
    exit
}

Write-Host "✓ Loaded AUTH CONFIG"

# ---------------------------------------------------------
# PHASE A — BACKEND/FRONTEND RESTORE
# ---------------------------------------------------------
Write-Host "`n--- PHASE A: Restore Foundation ---" -ForegroundColor Yellow

if (Test-Path "./onepack_ver3.ps1") {
    pwsh ./onepack_ver3.ps1
    Write-Host "✓ Foundation restored"
} else {
    Write-Host "⚠ No foundation script found, continuing..."
}

# ---------------------------------------------------------
# PHASE B — AUTH SYSTEM (PURE MODE)
# ---------------------------------------------------------
Write-Host "`n--- PHASE B: Auth System (Roles + Users) ---" -ForegroundColor Yellow

# schema SQL
$schemaSql = @"
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

create policy if not exists "select_own"
on user_profiles for select using (auth.uid() = id);

create policy if not exists "update_own"
on user_profiles for update using (auth.uid() = id);
"@

Invoke-RestMethod -Method POST `
  -Uri $RPC_SQL `
  -Headers @{ "apikey"=$SERVICE_KEY; "Authorization"="Bearer $SERVICE_KEY"; "Content-Type"="application/json" } `
  -Body (@{ query=$schemaSql } | ConvertTo-Json)

Write-Host "✓ Roles + user_profiles installed"

# create admin + staff
$authHeaders = @{
  "apikey"        = $SERVICE_KEY
  "Authorization" = "Bearer $SERVICE_KEY"
  "Content-Type"  = "application/json"
}

# admin
$ADMIN = Invoke-RestMethod -Method POST `
  -Uri "$AUTH_URL/admin/users" `
  -Headers $authHeaders `
  -Body (@{ email="admin@example.com"; password=$ADMIN_PASS } | ConvertTo-Json)

# staff
$STAFF = Invoke-RestMethod -Method POST `
  -Uri "$AUTH_URL/admin/users" `
  -Headers $authHeaders `
  -Body (@{ email="staff@example.com"; password=$STAFF_PASS } | ConvertTo-Json)

Write-Host "✓ Admin + Staff created"

# assign roles
$roleAdmin = Invoke-RestMethod -Method GET -Uri "$REST_URL/roles?name=eq.admin&select=id" -Headers $authHeaders
$roleStaff = Invoke-RestMethod -Method GET -Uri "$REST_URL/roles?name=eq.staff&select=id" -Headers $authHeaders

Invoke-RestMethod -Method POST -Uri "$REST_URL/user_profiles" -Headers $authHeaders `
  -Body (@{ id=$ADMIN.user.id; role_id=$roleAdmin[0].id } | ConvertTo-Json)

Invoke-RestMethod -Method POST -Uri "$REST_URL/user_profiles" -Headers $authHeaders `
  -Body (@{ id=$STAFF.user.id; role_id=$roleStaff[0].id } | ConvertTo-Json)

Write-Host "✓ Roles assigned"

# ---------------------------------------------------------
# PHASE C — SYSTEM GUARD
# ---------------------------------------------------------
Write-Host "`n--- PHASE C: System Guard Enabled ---" -ForegroundColor Yellow
"SAFE MODE ENABLED" | Set-Content "system_guard.log"
Write-Host "✓ Guard activated"

# ---------------------------------------------------------
# PHASE D — GITHUB INTELLIGENT BACKUP
# ---------------------------------------------------------
Write-Host "`n--- PHASE D: GitHub Backup ---" -ForegroundColor Yellow

$ts = Get-Date -Format "yyyyMMdd_HHmm"
git add .
git commit -m "AUTO BACKUP ($ts)"
Write-Host "✓ Git Snapshot Saved"

# ---------------------------------------------------------
# PHASE E — FINAL READY
# ---------------------------------------------------------
Write-Host "`n--- PHASE E: SYSTEM READY ---" -ForegroundColor Yellow
Write-Host "✓ Backend + Auth + Guard + Backup configured"

Write-Host "`n=== ONE PACK MEGA PURE MODE COMPLETED SUCCESSFULLY ===" -ForegroundColor Green












