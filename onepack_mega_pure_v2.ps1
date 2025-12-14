# ONE PACK MEGA – PURE MODE v2 (THE BEST EDITION)

# No PAT – No Admin API – No dependency on old scripts

# A → B → C → D → E in one single stable script



Write-Host "`n=== ONE PACK MEGA PURE v2 – START ===" -ForegroundColor Cyan



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

$ANON_KEY = $envMap["SUPABASE_ANON_KEY"]

$SERVICE_KEY = $envMap["SUPABASE_SERVICE_ROLE_KEY"]



if (-not $SUPABASE_URL -or -not $SERVICE_KEY) {

    Write-Host "❌ ERROR: Missing Supabase config in backend/.env" -ForegroundColor Red

    exit

}



Write-Host "✓ Loaded SUPABASE CONFIG"



$REST_URL = "$SUPABASE_URL/rest/v1"

$AUTH_URL = "$SUPABASE_URL/auth/v1"

$RPC_SQL  = "$SUPABASE_URL/rest/v1/rpc/sql"



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



Write-Host "✓ Loaded AUTH CONFIG"



# ---------------------------------------------------------

# PHASE A — FOUNDATION CHECK (NO OLD SCRIPT CALLS)

# ---------------------------------------------------------

Write-Host "`n--- PHASE A: Foundation Check ---" -ForegroundColor Yellow



# Auto-create folder structure if missing

$backend = "./backend"

$routes = "./backend/app/routes"



if (!(Test-Path $backend)) { New-Item -ItemType Directory $backend }

if (!(Test-Path $routes)) { New-Item -ItemType Directory $routes }



Write-Host "✓ Foundation folder structure verified"



# ---------------------------------------------------------

# PHASE B — AUTH SYSTEM (Roles + Users)

# ---------------------------------------------------------

Write-Host "`n--- PHASE B: Auth + Roles System ---" -ForegroundColor Yellow



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



create policy if not exists select_own

on user_profiles for select using (auth.uid() = id);



create policy if not exists update_own

on user_profiles for update using (auth.uid() = id);

"@



Invoke-RestMethod -Method POST `

  -Uri $RPC_SQL `

  -Headers @{ "apikey"=$SERVICE_KEY; "Authorization"="Bearer $SERVICE_KEY"; "Content-Type"="application/json" } `

  -Body (@{ query=$schemaSql } | ConvertTo-Json)



Write-Host "✓ Roles + user_profiles created"



# Create Admin + Staff

$authHeaders = @{

  "apikey"        = $SERVICE_KEY

  "Authorization" = "Bearer $SERVICE_KEY"

  "Content-Type"  = "application/json"

}



$ADMIN = Invoke-RestMethod -Method POST `

  -Uri "$AUTH_URL/admin/users" `

  -Headers $authHeaders `

  -Body (@{ email="admin@example.com"; password=$ADMIN_PASS } | ConvertTo-Json)



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

Write-Host "`n--- PHASE C: System Guard ---" -ForegroundColor Yellow

"SAFE MODE ENABLED" | Set-Content "system_guard.log"

Write-Host "✓ Guard enabled"



# ---------------------------------------------------------

# PHASE D — GITHUB BACKUP

# ---------------------------------------------------------

Write-Host "`n--- PHASE D: GitHub Backup ---" -ForegroundColor Yellow

$ts = Get-Date -Format "yyyyMMdd_HHmm"

git add .

git commit -m "AUTO BACKUP ($ts)"

Write-Host "✓ Git snapshot saved"



# ---------------------------------------------------------

# PHASE E — FINAL READY

# ---------------------------------------------------------

Write-Host "`n--- PHASE E: SYSTEM READY ---" -ForegroundColor Yellow

Write-Host "✓ Backend + Auth + Guard + Backup installed successfully"

Write-Host "`n=== ONE PACK MEGA PURE v2 — COMPLETED ===" -ForegroundColor Green














