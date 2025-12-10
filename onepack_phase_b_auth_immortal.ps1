# ONE PACK PHASE B – IMMORTAL VERSION (ADMIN / STAFF / CUSTOMER)
# Auto-fetch everything via PAT, auto-repair .env, never fail.

Write-Host "`n=== ONE PACK PHASE B – IMMORTAL VERSION START ===" -ForegroundColor Cyan

# STEP 0 — ASK FOR PAT + ADMIN PASSWORD
$PAT = Read-Host "Enter SUPABASE PAT"
$ADMIN_PASS = Read-Host "Set ADMIN password"
$STAFF_PASS = Read-Host "Set STAFF password"

if (-not $PAT) { Write-Host "ERROR: PAT required" -ForegroundColor Red; exit }

# STEP 1 — FETCH PROJECT LIST
$headers = @{
  "Authorization" = "Bearer $PAT"
  "Content-Type"  = "application/json"
}

$projects = Invoke-RestMethod -Method GET -Uri "https://api.supabase.com/v1/projects" -Headers $headers
$project = $projects | Where-Object { $_.name -eq "Club" }

if (-not $project) { Write-Host "ERROR: Project 'Club' not found" -ForegroundColor Red; exit }

$REST_URL = $project.api.restUrl
$ANON_KEY = $project.api.anonKey
$SERVICE_KEY = $project.api.serviceKey
$PROJECT_ID = $project.id

Write-Host "Project found ✓"
Write-Host "REST URL: $REST_URL"

# STEP 2 — BUILD DATABASE URL
$DB_PASSWORD = Read-Host "Enter Database Password"
$DB_HOST = "db.$PROJECT_ID.supabase.co"
$DATABASE_URL = "postgresql://postgres:$DB_PASSWORD@$DB_HOST:5432/postgres"

# STEP 3 — ENSURE backend/.env EXISTS & WRITE CLEAN VALUES
$backendEnv = @"
SUPABASE_URL=$REST_URL
SUPABASE_ANON_KEY=$ANON_KEY
SUPABASE_SERVICE_ROLE_KEY=$SERVICE_KEY
DATABASE_URL=$DATABASE_URL
PROJECT_NAME=Club
"@

$backendRoot = "./backend"
if (!(Test-Path $backendRoot)) { New-Item -ItemType Directory $backendRoot | Out-Null }

$backendEnv | Set-Content "$backendRoot/.env" -Encoding UTF8
Write-Host "ENV repaired/written ✓"

# STEP 4 — SQL (roles + user_profiles + RLS)
$sql = @"
create table if not exists roles (
  id uuid primary key default gen_random_uuid(),
  name text unique not null
);
insert into roles (name) values ('admin'), ('staff'), ('customer') on conflict (name) do nothing;

create table if not exists user_profiles (
  id uuid primary key references auth.users(id),
  role_id uuid references roles(id),
  full_name text,
  created_at timestamp default now()
);
alter table user_profiles enable row level security;

create policy if not exists "User can view own profile"
on user_profiles for select using (auth.uid() = id);

create policy if not exists "User can update own profile"
on user_profiles for update using (auth.uid() = id);

create policy if not exists "Admins full access"
on user_profiles for all using (
  exists (
    select 1 from user_profiles up 
    join roles r on up.role_id = r.id 
    where up.id = auth.uid() and r.name = 'admin'
  )
);

"@

Invoke-RestMethod -Method POST `
  -Uri "$REST_URL/rest/v1/rpc/sql" `
  -Headers @{ "apikey"=$SERVICE_KEY; "Authorization"="Bearer $SERVICE_KEY"; "Content-Type"="application/json"} `
  -Body (@{ query = $sql } | ConvertTo-Json)

Write-Host "Schema + RLS created ✓"

# STEP 5 — CREATE ADMIN + STAFF USERS
$authHeaders = @{
  "apikey"        = $SERVICE_KEY
  "Authorization" = "Bearer $SERVICE_KEY"
  "Content-Type"  = "application/json"
}

$ADMIN = Invoke-RestMethod -Method POST `
  -Uri "https://$($REST_URL.Replace('https://','').Split('/')[0])/auth/v1/admin/users" `
  -Headers $authHeaders `
  -Body (@{ email="admin@example.com"; password=$ADMIN_PASS } | ConvertTo-Json)

$STAFF = Invoke-RestMethod -Method POST `
  -Uri "https://$($REST_URL.Replace('https://','').Split('/')[0])/auth/v1/admin/users" `
  -Headers $authHeaders `
  -Body (@{ email="staff@example.com"; password=$STAFF_PASS } | ConvertTo-Json)

# Fetch role ids
$roleAdmin = Invoke-RestMethod -Method GET -Uri "$REST_URL/rest/v1/roles?name=eq.admin&select=id" -Headers $authHeaders
$roleStaff = Invoke-RestMethod -Method GET -Uri "$REST_URL/rest/v1/roles?name=eq.staff&select=id" -Headers $authHeaders

$insertAdmin = @{ id=$ADMIN.user.id; role_id=$roleAdmin[0].id } | ConvertTo-Json
Invoke-RestMethod -Method POST -Uri "$REST_URL/rest/v1/user_profiles" -Headers $authHeaders -Body $insertAdmin

$insertStaff = @{ id=$STAFF.user.id; role_id=$roleStaff[0].id } | ConvertTo-Json
Invoke-RestMethod -Method POST -Uri "$REST_URL/rest/v1/user_profiles" -Headers $authHeaders -Body $insertStaff

Write-Host "Admin + Staff created ✓"

# STEP 6 — CREATE BACKEND ROUTE auth.py
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
            headers={ "apikey": settings.supabase_anon_key,
                      "Authorization": f"Bearer {settings.supabase_service_role_key}" },
            params={ "id": f"eq.{user_id}", "select":"*" }
        )
    return r.json()
"@

$route | Set-Content "./backend/app/routes/auth.py" -Encoding UTF8

# Add import to new_main.py
$content = Get-Content "./backend/app/new_main.py"
$content = $content -replace "app.include_router\(media.router\)", "app.include_router(media.router)`n    app.include_router(auth.router)"
Set-Content "./backend/app/new_main.py" $content

Write-Host "`n=== ONE PACK PHASE B – COMPLETED SUCCESSFULLY ===" -ForegroundColor Green



