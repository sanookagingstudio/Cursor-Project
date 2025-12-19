# ONE PACK AUTO-FETCH RESTORE – FunAging.club (PAT Version)
# ใช้ Personal Access Token (PAT) ดึงค่าจาก Supabase อัตโนมัติ

param(
    [string]$ProjectRoot = "."
)

Write-Host "`n=== ONE PACK AUTO-FETCH (PAT Version) ===" -ForegroundColor Cyan

# -----------------------------------------------------------
# โหลดค่า PAT + Project Name
# -----------------------------------------------------------

$configPath = Join-Path $ProjectRoot "supabase_config.auto"
if (!(Test-Path $configPath)) {
    Write-Host "ERROR: supabase_config.auto ไม่พบ" -ForegroundColor Red
    exit
}

$PAT = ""
$PROJECT_NAME = ""

foreach ($line in Get-Content $configPath) {
    if ($line -match "=") {
        $parts = $line -split "=", 2
        $key = $parts[0].Trim()
        $val = $parts[1].Trim()
        if ($key -eq "SUPABASE_PAT") { $PAT = $val }
        if ($key -eq "PROJECT_NAME") { $PROJECT_NAME = $val }
    }
}

if (-not $PAT) {
    Write-Host "ERROR: SUPABASE_PAT ไม่พบในไฟล์" -ForegroundColor Red
    exit
}

Write-Host "Loaded PAT ✓" -ForegroundColor Green
Write-Host "Project Name: $PROJECT_NAME"

# -----------------------------------------------------------
# เรียก Supabase Admin API (ใช้ PAT)
# -----------------------------------------------------------

$headers = @{
    "Authorization" = "Bearer $PAT"
    "Content-Type"  = "application/json"
}

# 🎯 ดึงรายการโปรเจกต์ทั้งหมด
try {
    $projects = Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects" -Method GET -Headers $headers
} catch {
    Write-Host "ERROR: ไม่สามารถดึงรายการโปรเจกต์ได้" -ForegroundColor Red
    Write-Host $_
    exit
}

# เลือกโปรเจกต์ตามชื่อ
$project = $projects | Where-Object { $_.name -eq $PROJECT_NAME }

if (-not $project) {
    Write-Host "ERROR: ไม่พบโปรเจกต์ชื่อ '$PROJECT_NAME'" -ForegroundColor Red
    exit
}

$project_id = $project.id
$rest_url   = $project.api.restUrl
$anon_key   = $project.api.anonKey
$service_key = $project.api.serviceKey

Write-Host "PROJECT FOUND ✓" -ForegroundColor Green
Write-Host "Project ID: $project_id"
Write-Host "REST URL:  $rest_url"

# -----------------------------------------------------------
# ดึง DATABASE_URL
# -----------------------------------------------------------

try {
    $dbInfo = Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$project_id/database" -Method GET -Headers $headers
} catch {
    Write-Host "ERROR: ไม่สามารถดึง DATABASE_URL" -ForegroundColor Red
    exit
}

$database_url = $dbInfo.connectionString

if (-not $database_url) {
    Write-Host "ERROR: database.connectionString ว่าง" -ForegroundColor Red
    exit
}

Write-Host "DATABASE_URL fetched ✓" -ForegroundColor Green

# -----------------------------------------------------------
# เตรียมโฟลเดอร์ Backend + Frontend
# -----------------------------------------------------------

$backendRoot  = Join-Path $ProjectRoot "backend"
$frontendRoot = Join-Path $ProjectRoot "frontend"
$appRoot      = Join-Path $backendRoot "app"
$routesRoot   = Join-Path $appRoot "routes"
$coreRoot     = Join-Path $appRoot "core"

foreach ($d in @($backendRoot,$frontendRoot,$appRoot,$routesRoot,$coreRoot)) {
    if (!(Test-Path $d)) { New-Item -ItemType Directory -Path $d | Out-Null }
}

# -----------------------------------------------------------
# เขียน ENV อัตโนมัติ
# -----------------------------------------------------------

@"
SUPABASE_URL=$rest_url
SUPABASE_ANON_KEY=$anon_key
SUPABASE_SERVICE_ROLE_KEY=$service_key
DATABASE_URL=$database_url
PROJECT_NAME=$PROJECT_NAME
"@ | Set-Content -Encoding UTF8 (Join-Path $backendRoot ".env")

@"
NEXT_PUBLIC_SUPABASE_URL=$rest_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=$anon_key
NEXT_PUBLIC_PROJECT_NAME=$PROJECT_NAME
"@ | Set-Content -Encoding UTF8 (Join-Path $frontendRoot ".env.local")

Write-Host "ENV Files Generated ✓" -ForegroundColor Green

# -----------------------------------------------------------
# Backend baseline
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
async def ping(): return {'module':'trip','status':'ok'}
"@ | Set-Content (Join-Path $routesRoot "trip.py")

@"
from fastapi import APIRouter
router = APIRouter(prefix='/office', tags=['office'])

@router.get('/ping')
async def ping(): return {'module':'office','status':'ok'}
"@ | Set-Content (Join-Path $routesRoot "office.py")

@"
from fastapi import APIRouter
router = APIRouter(prefix='/media', tags=['media'])

@router.get('/ping')
async def ping(): return {'module':'media','status':'ok'}
"@ | Set-Content (Join-Path $routesRoot "media.py")

@"
from fastapi import FastAPI
from .routes import trip, office, media

def create_app():
    app = FastAPI(title='FunAging.club Backend')

    @app.get('/health')
    async def health(): return {'status':'ok'}

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
# Runner Scripts
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

Write-Host "`n=== ONE PACK AUTO-FETCH COMPLETED ===" -ForegroundColor Green
Write-Host "Backend + Frontend restored successfully"
Write-Host "Supabase auto-configured using PAT"
























