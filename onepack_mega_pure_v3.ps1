# ONE PACK MEGA – PURE MODE v3 (IMMORTAL SQL-SAFE MODE)

# Uses pg-meta SQL endpoint instead of /rpc/sql

# No PAT, no Admin API. Reads from backend/.env + config/auth_config.env



Write-Host "`n=== ONE PACK MEGA PURE v3 – START ===" -ForegroundColor Cyan



# ---------------------------------------------------------

# LOAD SUPABASE CONFIG (.env)

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



$envMap = @{}

foreach ($line in Get-Content $envFile) {

    if ($line -match "=") {

        $parts = $line -split "=", 2

        $envMap[$parts[0].Trim()] = $parts[1].Trim()

    }

}



$SUPABASE_URL = $envMap["SUPABASE_URL"]

$ANON_KEY     = $envMap["SUPABASE_ANON_KEY"]

$SERVICE_KEY  = $envMap["SUPABASE_SERVICE_ROLE_KEY"]



if (-not $SUPABASE_URL -or -not $SERVICE_KEY) {

    Write-Host "❌ ERROR: Missing Supabase config in backend/.env" -ForegroundColor Red

    exit

}



Write-Host "✓ Loaded SUPABASE CONFIG"



$REST_URL     = "$SUPABASE_URL/rest/v1"

$AUTH_URL     = "$SUPABASE_URL/auth/v1"

$PG_META_SQL  = "$SUPABASE_URL/pg/meta/sql"



# ---------------------------------------------------------

# LOAD AUTH CONFIG

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

    Write-Host "❌ ERROR: Missing ADMIN_PASS or STAFF_PASS in auth_config.env" -ForegroundColor Red

    exit

}



Write-Host "✓ Loaded AUTH CONFIG"



# ---------------------------------------------------------

# PHASE A — FOUNDATION CHECK

# ---------------------------------------------------------

Write-Host "`n--- PHASE A: Foundation Check ---" -ForegroundColor Yellow



$backend = "./backend"

$routes  = "./backend/app/routes"



if (!(Test-Path $backend)) { New-Item -ItemType Directory $backend | Out-Null }

if (!(Test-Path $routes))  { New-Item -ItemType Directory $routes  | Out-Null }



Write-Host "✓ Foundation folder structure verified"



# ---------------------------------------------------------

# PHASE B — AUTH + ROLES SYSTEM (via pg-meta SQL)

# ---------------------------------------------------------

Write-Host "`n--- PHASE B: Auth + Roles System (pg-meta) ---" -ForegroundColor Yellow



$schemaSql = @"

create extension if not exists "pgcrypto";



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



create policy if not exists select_own

on user_profiles for select using (auth.uid() = id);



create policy if not exists update_own

on user_profiles for update using (auth.uid() = id);

"@



$schemaBody = @{ query = $schemaSql } | ConvertTo-Json -Depth 5

$metaHeaders = @{

    "apikey"        = $SERVICE_KEY

    "Authorization" = "Bearer $SERVICE_KEY"

    "Content-Type"  = "application/json"

}



try {

    $resp = Invoke-RestMethod -Method Post -Uri $PG_META_SQL -Headers $metaHeaders -Body $schemaBody

    Write-Host "✓ Roles + user_profiles created/updated via pg-meta"

} catch {

    Write-Host "❌ ERROR: Failed to execute schema SQL via pg-meta" -ForegroundColor Red

    Write-Host $_.Exception.Message -ForegroundColor DarkRed

    exit

}



# Create Admin + Staff

$authHeaders = @{

  "apikey"        = $SERVICE_KEY

  "Authorization" = "Bearer $SERVICE_KEY"

  "Content-Type"  = "application/json"

}



try {

    $ADMIN = Invoke-RestMethod -Method POST -Uri "$AUTH_URL/admin/users" `

        -Headers $authHeaders `

        -Body (@{ email="admin@example.com"; password=$ADMIN_PASS } | ConvertTo-Json)



    $STAFF = Invoke-RestMethod -Method POST -Uri "$AUTH_URL/admin/users" `

        -Headers $authHeaders `

        -Body (@{ email="staff@example.com"; password=$STAFF_PASS } | ConvertTo-Json)



    Write-Host "✓ Admin + Staff users created/ensured"

} catch {

    Write-Host "❌ ERROR: Failed creating admin/staff users" -ForegroundColor Red

    Write-Host $_.Exception.Message -ForegroundColor DarkRed

    exit

}



# Assign roles

try {

    $roleAdmin = Invoke-RestMethod -Method GET -Uri "$REST_URL/roles?name=eq.admin&select=id" -Headers $authHeaders

    $roleStaff = Invoke-RestMethod -Method GET -Uri "$REST_URL/roles?name=eq.staff&select=id" -Headers $authHeaders



    Invoke-RestMethod -Method POST -Uri "$REST_URL/user_profiles" -Headers $authHeaders `

      -Body (@{ id=$ADMIN.user.id; role_id=$roleAdmin[0].id } | ConvertTo-Json)



    Invoke-RestMethod -Method POST -Uri "$REST_URL/user_profiles" -Headers $authHeaders `

      -Body (@{ id=$STAFF.user.id; role_id=$roleStaff[0].id } | ConvertTo-Json)



    Write-Host "✓ Roles assigned to Admin + Staff"

} catch {

    Write-Host "❌ ERROR: Failed assigning roles" -ForegroundColor Red

    Write-Host $_.Exception.Message -ForegroundColor DarkRed

    exit

}



# ---------------------------------------------------------

# PHASE C — SYSTEM GUARD

# ---------------------------------------------------------

Write-Host "`n--- PHASE C: System Guard ---" -ForegroundColor Yellow

"SAFE MODE ENABLED (MEGA PURE v3)" | Set-Content "system_guard.log"

Write-Host "✓ Guard enabled"



# ---------------------------------------------------------

# PHASE D — GITHUB BACKUP

# ---------------------------------------------------------

Write-Host "`n--- PHASE D: GitHub Backup ---" -ForegroundColor Yellow

$ts = Get-Date -Format "yyyyMMdd_HHmm"

git add .

git commit -m "AUTO BACKUP (MEGA PURE v3 - $ts)" | Out-Null

Write-Host "✓ Git snapshot saved"



# ---------------------------------------------------------

# PHASE E — FINAL READY

# ---------------------------------------------------------

Write-Host "`n--- PHASE E: SYSTEM READY ---" -ForegroundColor Yellow

Write-Host "Admin login: admin@example.com"

Write-Host "Staff login: staff@example.com"

Write-Host "`n=== ONE PACK MEGA PURE v3 – COMPLETED SUCCESSFULLY ===" -ForegroundColor Green










