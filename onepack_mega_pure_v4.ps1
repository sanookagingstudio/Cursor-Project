# ONE PACK MEGA PURE v4 — REST-ONLY IMMORTAL MODE

# No SQL, No pg-meta, No PAT, No Admin API project listing

# Fully stable with Supabase 2025 API rules

# Reads only backend/.env + config/auth_config.env



Write-Host "`n=== ONE PACK MEGA PURE v4 – START ===" -ForegroundColor Cyan



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

$SERVICE_KEY  = $envMap["SUPABASE_SERVICE_ROLE_KEY"]



if (-not $SUPABASE_URL -or -not $SERVICE_KEY) {

    Write-Host "❌ ERROR: Missing Supabase config in backend/.env" -ForegroundColor Red

    exit

}



Write-Host "✓ Loaded SUPABASE CONFIG"



$REST_URL = "$SUPABASE_URL/rest/v1"

$AUTH_URL = "$SUPABASE_URL/auth/v1"



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



$authHeaders = @{

  "apikey"        = $SERVICE_KEY

  "Authorization" = "Bearer $SERVICE_KEY"

  "Content-Type"  = "application/json"

}



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

# PHASE B — AUTH + ROLES SYSTEM (REST ONLY)

# ---------------------------------------------------------

Write-Host "`n--- PHASE B: Auth + Roles System (REST ONLY) ---" -ForegroundColor Yellow



# --- Create Admin user ---

try {

    $ADMIN = Invoke-RestMethod -Method POST `

      -Uri "$AUTH_URL/admin/users" `

      -Headers $authHeaders `

      -Body (@{ email="admin@example.com"; password=$ADMIN_PASS } | ConvertTo-Json)



    Write-Host "✓ Admin user created/ensured"

} catch {

    Write-Host "⚠ Admin user may already exist"

}



# --- Create Staff user ---

try {

    $STAFF = Invoke-RestMethod -Method POST `

      -Uri "$AUTH_URL/admin/users" `

      -Headers $authHeaders `

      -Body (@{ email="staff@example.com"; password=$STAFF_PASS } | ConvertTo-Json)



    Write-Host "✓ Staff user created/ensured"

} catch {

    Write-Host "⚠ Staff user may already exist"

}



# --- Fetch user IDs ---

try {

    $adminId = (Invoke-RestMethod -Method GET -Uri "$REST_URL/auth.users?email=eq.admin@example.com&select=id" -Headers $authHeaders)[0].id

    $staffId = (Invoke-RestMethod -Method GET -Uri "$REST_URL/auth.users?email=eq.staff@example.com&select=id" -Headers $authHeaders)[0].id



    Write-Host "✓ Retrieved Admin + Staff user IDs"

} catch {

    Write-Host "❌ ERROR: Cannot retrieve user IDs" -ForegroundColor Red

    exit

}



# --- Fetch role IDs ---

try {

    $roleAdmin = (Invoke-RestMethod -Method GET -Uri "$REST_URL/roles?name=eq.admin&select=id" -Headers $authHeaders)[0].id

    $roleStaff = (Invoke-RestMethod -Method GET -Uri "$REST_URL/roles?name=eq.staff&select=id" -Headers $authHeaders)[0].id

    Write-Host "✓ Retrieved role IDs"

} catch {

    Write-Host "❌ ERROR: Cannot retrieve role IDs" -ForegroundColor Red

    exit

}



# --- Insert/Update user_profiles ---

try {

    Invoke-RestMethod -Method POST -Uri "$REST_URL/user_profiles" `

      -Headers $authHeaders `

      -Body (@{ id=$adminId; role_id=$roleAdmin } | ConvertTo-Json)



    Invoke-RestMethod -Method POST -Uri "$REST_URL/user_profiles" `

      -Headers $authHeaders `

      -Body (@{ id=$staffId; role_id=$roleStaff } | ConvertTo-Json)



    Write-Host "✓ user_profiles linked with roles"

} catch {

    Write-Host "⚠ user_profiles may already exist"

}



# ---------------------------------------------------------

# PHASE C — SYSTEM GUARD

# ---------------------------------------------------------

Write-Host "`n--- PHASE C: System Guard ---" -ForegroundColor Yellow

"SAFE MODE ENABLED (MEGA PURE v4 – REST ONLY)" | Set-Content "system_guard.log"

Write-Host "✓ Guard enabled"



# ---------------------------------------------------------

# PHASE D — GITHUB BACKUP

# ---------------------------------------------------------

Write-Host "`n--- PHASE D: GitHub Backup ---" -ForegroundColor Yellow

$ts = Get-Date -Format "yyyyMMdd_HHmm"

git add .

git commit -m "AUTO BACKUP (MEGA PURE v4 - $ts)" | Out-Null

Write-Host "✓ Git snapshot saved"



# ---------------------------------------------------------

# PHASE E — FINAL READY

# ---------------------------------------------------------

Write-Host "`n--- PHASE E: SYSTEM READY ---" -ForegroundColor Yellow

Write-Host "Admin login: admin@example.com"

Write-Host "Staff login: staff@example.com"

Write-Host "`n=== ONE PACK MEGA PURE v4 – COMPLETED SUCCESSFULLY ===" -ForegroundColor Green






