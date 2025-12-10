# ONE PACK VER.3 – Full Automate (PAT + Auto Fetch + Manual DB Password)
# ไม่ต้องมีไฟล์ config แยก ONE PACK ตัวเดียวจบ

Write-Host "`n=== ONE PACK VER.3 – FULL AUTOMATE ===" -ForegroundColor Cyan

# -----------------------------------------------------------
# INPUT: PAT + DB PASSWORD
# -----------------------------------------------------------

$PAT = Read-Host "ใส่ SUPABASE PAT (Personal Access Token)"
$DB_PASSWORD = Read-Host "ใส่ Database Password ใหม่ของคุณ"

$PROJECT_NAME = "Club"

if (-not $PAT) { Write-Host "ERROR: ต้องใส่ PAT" -ForegroundColor Red; exit }
if (-not $DB_PASSWORD) { Write-Host "ERROR: ต้องใส่ DB_PASSWORD" -ForegroundColor Red; exit }

Write-Host "PAT Loaded ✓" -ForegroundColor Green

# -----------------------------------------------------------
# CALL ADMIN API
# -----------------------------------------------------------

$headers = @{
    "Authorization" = "Bearer $PAT"
    "Content-Type"  = "application/json"
}

# ดึงโปรเจกต์ทั้งหมด
try {
    $projects = Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects" -Method GET -Headers $headers
} catch {
    Write-Host "ERROR: ไม่สามารถดึงโปรเจกต์ได้ (PAT ผิดหรือหมดอายุ)" -ForegroundColor Red
    exit
}

$project = $projects | Where-Object { $_.name -eq $PROJECT_NAME }

if (-not $project) {
    Write-Host "ERROR: ไม่พบโปรเจกต์ชื่อ '$PROJECT_NAME'" -ForegroundColor Red
    exit
}

$PROJECT_ID = $project.id
$REST_URL = $project.api.restUrl
$ANON_KEY = $project.api.anonKey
$SERVICE_KEY = $project.api.serviceKey

Write-Host "PROJECT FOUND ✓" -ForegroundColor Green
Write-Host "REST URL: $REST_URL"

# -----------------------------------------------------------
# BUILD DATABASE URL (Method 2)
# -----------------------------------------------------------

$DB_HOST = "db.$PROJECT_ID.supabase.co"
$DATABASE_URL = "postgresql://postgres:$DB_PASSWORD@$DB_HOST:5432/postgres"

Write-Host "DATABASE_URL Built ✓" -ForegroundColor Green

# -----------------------------------------------------------
# Paths
# -----------------------------------------------------------

$ProjectRoot = Resolve-Path "."
$backendRoot  = Join-Path $ProjectRoot "backend"
$frontendRoot = Join-Path $ProjectRoot "frontend"
$appRoot      = Join-Path $backendRoot "app"
$routesRoot   = Join-Path $appRoot "routes"
$coreRoot     = Join-Path $appRoot "core"

foreach ($d in @($backendRoot,$frontendRoot,$appRoot,$routesRoot,$coreRoot)) {
    if (!(Test-Path $d)) { New-Item -ItemType Directory -Path $d | Out-Null }
}

# -----------------------------------------------------------
# WRITE ENV FILES
# -----------------------------------------------------------

@"
SUPABASE_URL=$REST_URL
SUPABASE_ANON_KEY=$ANON_KEY
SUPABASE_SERVICE_ROLE_KEY=$SERVICE_KEY
DATABASE_URL=$DATABASE_URL
PROJECT_NAME=$PROJECT_NAME
"@ | Set-Content -Encoding UTF8 (Join-Path $backendRoot ".env")

@"
NEXT_PUBLIC_SUPABASE_URL=$REST_URL
NEXT_PUBLIC_SUPABASE_ANON_KEY=$ANON_KEY
NEXT_PUBLIC_PROJECT_NAME=$PROJECT_NAME
"@ | Set-Content -Encoding UTF8 (Join-Path $frontendRoot ".env.local")

Write-Host "ENV FILES CREATED ✓" -ForegroundColor Green

# -----------------------------------------------------------
# BASELINE BACKEND FILES
# -----------------------------------------------------------

@"
# FunAging Backend App
"@ | Set-Content (Join-Path $appRoot "__init__.py")

@"
import os
from functools import lru_cache
from pydantic import BaseSettings

class Settings(BaseSettings):
    project_name: str = os.getenv("PROJECT_NAME")
    supabase_url: str = os.getenv("SUPABASE_URL")
    supabase_anon_key: str = os.getenv("SUPABASE_ANON_KEY")
    supabase_service_role_key: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
    database_url: str = os.getenv("DATABASE_URL")

@lru_cache()
def get_settings():
    return Settings()
"@ | Set-Content (Join-Path $coreRoot "config.py")

@"
import httpx
from .config import get_settings

_settings = get_settings()

class SupabaseClient:
    def __init__(self):
        self.enabled = bool(_settings.supabase_url and _settings.supabase_anon_key)
        self.url = _settings.supabase_url.rstrip('/') if self.enabled else None
        self.key = _settings.supabase_anon_key

    async def select(self, table: str, params=None):
        if not self.enabled:
            return {"data": [], "error": "Supabase disabled"}
        headers = {"apikey": self.key, "Authorization": f"Bearer {self.key}"}
        async with httpx.AsyncClient() as c:
            r = await c.get(f"{self.url}/rest/v1/{table}", headers=headers, params=params or {})
        r.raise_for_status()
        return {"data": r.json(), "error": None}

supabase_client = SupabaseClient()
"@ | Set-Content (Join-Path $coreRoot "supabase_client.py")

@"
from fastapi import APIRouter
router = APIRouter(prefix='/trip', tags=['trip'])

@router.get('/ping')
async def ping(): return {'module': 'trip', 'status': 'ok'}
"@ | Set-Content (Join-Path $routesRoot "trip.py")

@"
from fastapi import APIRouter
router = APIRouter(prefix='/office', tags=['office'])

@router.get('/ping')
async def ping(): return {'module': 'office', 'status': 'ok'}
"@ | Set-Content (Join-Path $routesRoot "office.py")

@"
from fastapi import APIRouter
router = APIRouter(prefix='/media', tags=['media'])

@router.get('/ping')
async def ping(): return {'module': 'media', 'status': 'ok'}
"@ | Set-Content (Join-Path $routesRoot "media.py")

@"
from fastapi import FastAPI
from .routes import trip, office, media

def create_app():
    app = FastAPI(title='FunAging.club Backend')

    @app.get('/health')
    async def health(): return {'status': 'ok'}

    app.include_router(trip.router)
    app.include_router(office.router)
    app.include_router(media.router)
    return app

app = create_app()
"@ | Set-Content (Join-Path $appRoot "new_main.py")

@"
import uvicorn
if __name__ == '__main__':
    uvicorn.run('app.new_main:app', host='0.0.0.0', port=8000, reload=True)
"@ | Set-Content (Join-Path $appRoot "main.py")

@"
fastapi
uvicorn[standard]
httpx
pydantic
"@ | Set-Content (Join-Path $backendRoot "requirements.txt")

# -----------------------------------------------------------
# RUNNER SCRIPTS
# -----------------------------------------------------------

@"
cd '$backendRoot'
python -m venv .venv
. .\.venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install -r requirements.txt
uvicorn app.new_main:app --reload
"@ | Set-Content "run_backend.ps1"

@"
cd '$frontendRoot'
npm install
npm run dev
"@ | Set-Content "run_frontend.ps1"

@"
Start-Process pwsh -ArgumentList '-File run_backend.ps1'
Start-Process pwsh -ArgumentList '-File run_frontend.ps1'
"@ | Set-Content "run_all.ps1"

Write-Host "`n=== ONE PACK VER.3 COMPLETED ===" -ForegroundColor Green
Write-Host "Backend + Frontend restored successfully"
Write-Host "Environment auto-configured"
Write-Host "Ready to run: pwsh .\run_all.ps1"
