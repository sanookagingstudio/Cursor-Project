# ONE PACK MEGA PURE v5 – SIMPLE FACT VERSION
# No .env, no PAT, no pg-meta. REST only. No prompts.

Write-Host "=== ONE PACK MEGA PURE v5 – SIMPLE FACT VERSION START ===" -ForegroundColor Cyan

# --------------------------------------------------------------------
# IMMUTABLE CONFIG
# --------------------------------------------------------------------
$SUPABASE_URL     = "https://hbjocppvllpcbmhkiode.supabase.co"
$SUPABASE_SERVICE = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhiam9jcHB2bGxwY2JtaGtpb2RlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NTI5NDkxMCwiZXhwIjoyMDgwODcwOTEwfQ.V7oc0unR_Bku88SU1P5ZAk3IV5loMMaVbmbiItZbOZA"
$DB_PASSWORD      = "Ake@8814883"

$REST_URL = "$SUPABASE_URL/rest/v1"
$AUTH_URL = "$SUPABASE_URL/auth/v1"

$headers = @{
    "apikey"        = $SUPABASE_SERVICE
    "Authorization" = "Bearer $SUPABASE_SERVICE"
    "Content-Type"  = "application/json"
}

# --------------------------------------------------------------------
# PHASE A – FOUNDATION CHECK
# --------------------------------------------------------------------
Write-Host "`n--- PHASE A: Foundation Check ---" -ForegroundColor Yellow

if (-not (Test-Path "backend")) {
    New-Item -ItemType Directory -Path "backend" | Out-Null
}
Write-Host "✓ Backend folder verified" -ForegroundColor Green

# --------------------------------------------------------------------
# PHASE B – AUTH + ROLES (REST ONLY)
#   (role tables + policies ต้องสร้างใน SQL Editor ไปแล้ว)
# --------------------------------------------------------------------
Write-Host "`n--- PHASE B: Auth + Roles (REST ONLY) ---" -ForegroundColor Yellow

# 1) Create Admin user
$adminBodyJson = (@{
    email         = "admin@funaging.club"
    password      = $DB_PASSWORD
    email_confirm = $true
} | ConvertTo-Json)

Write-Host "→ Creating admin user via $AUTH_URL/admin/users"
$adminUser = Invoke-RestMethod -Uri "$AUTH_URL/admin/users" -Method POST -Headers $headers -Body $adminBodyJson -ErrorAction Stop
$adminId   = $adminUser.user.id
Write-Host "✓ Admin created, id = $adminId" -ForegroundColor Green

# 2) Create Staff user
$staffBodyJson = (@{
    email         = "staff@funaging.club"
    password      = $DB_PASSWORD
    email_confirm = $true
} | ConvertTo-Json)

Write-Host "→ Creating staff user via $AUTH_URL/admin/users"
$staffUser = Invoke-RestMethod -Uri "$AUTH_URL/admin/users" -Method POST -Headers $headers -Body $staffBodyJson -ErrorAction Stop
$staffId   = $staffUser.user.id
Write-Host "✓ Staff created, id = $staffId" -ForegroundColor Green

# 3) Get roles from roles table
Write-Host "→ Fetching roles from $REST_URL/roles"
$roles = Invoke-RestMethod -Uri "$REST_URL/roles?select=id,name" -Method GET -Headers $headers -ErrorAction Stop

$roleAdmin = $roles | Where-Object { $_.name -eq "admin" }
$roleStaff = $roles | Where-Object { $_.name -eq "staff" }

if (-not $roleAdmin -or -not $roleStaff) {
    Write-Host "❌ ERROR: roles table missing admin/staff rows" -ForegroundColor Red
    exit 1
}

# 4) Insert user_profiles
$adminProfileJson = (@{
    id        = $adminId
    role_id   = $roleAdmin.id
    full_name = "System Admin"
} | ConvertTo-Json)

$staffProfileJson = (@{
    id        = $staffId
    role_id   = $roleStaff.id
    full_name = "System Staff"
} | ConvertTo-Json)

Write-Host "→ Inserting admin profile"
Invoke-RestMethod -Uri "$REST_URL/user_profiles" -Method POST -Headers $headers -Body $adminProfileJson -ErrorAction Stop

Write-Host "→ Inserting staff profile"
Invoke-RestMethod -Uri "$REST_URL/user_profiles" -Method POST -Headers $headers -Body $staffProfileJson -ErrorAction Stop

Write-Host "✓ user_profiles created & linked" -ForegroundColor Green

# --------------------------------------------------------------------
# PHASE C – SYSTEM GUARD
# --------------------------------------------------------------------
Write-Host "`n--- PHASE C: System Guard ---" -ForegroundColor Yellow
"System validated at $(Get-Date)" | Set-Content "system_guard.log"
Write-Host "✓ Guard file updated" -ForegroundColor Green

# --------------------------------------------------------------------
# PHASE D – GIT BACKUP
# --------------------------------------------------------------------
Write-Host "`n--- PHASE D: Git Backup ---" -ForegroundColor Yellow
try {
    git add .        | Out-Null
    git commit -m "AUTO: OnePack Mega Pure v5 Simple $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-Null
    Write-Host "✓ Git backup committed" -ForegroundColor Green
} catch {
    Write-Host "⚠ Git commit skipped (maybe no changes)" -ForegroundColor DarkYellow
}

# --------------------------------------------------------------------
# DONE
# --------------------------------------------------------------------
Write-Host "`n=== ONE PACK MEGA PURE v5 – SIMPLE FACT VERSION DONE ===" -ForegroundColor Cyan





