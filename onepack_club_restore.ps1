# Save this file as: onepack_club_restore.ps1

# Usage (in PowerShell, from project root folder sanook-master-v2-main):

#   pwsh .\onepack_club_restore.ps1

# or

#   powershell -ExecutionPolicy Bypass -File .\onepack_club_restore.ps1



param(

    [string]$ProjectName = "Club",

    [string]$ProjectRoot = "."

)



Write-Host "============================================="

Write-Host " FunAging.club ONE PACK - BACKEND RESTORE    "

Write-Host " Supabase Project : $ProjectName             "

Write-Host "============================================="



# Resolve absolute path

$ProjectRoot = Resolve-Path $ProjectRoot



$backendRoot  = Join-Path $ProjectRoot "backend"

$frontendRoot = Join-Path $ProjectRoot "frontend"



$appRoot      = Join-Path $backendRoot "app"

$routesRoot   = Join-Path $appRoot "routes"

$coreRoot     = Join-Path $appRoot "core"



# --- Ensure folder structure exists ---

$dirs = @(

    $backendRoot,

    $frontendRoot,

    $appRoot,

    $routesRoot,

    $coreRoot

)



foreach ($d in $dirs) {

    if (-not (Test-Path $d)) {

        New-Item -ItemType Directory -Path $d -Force | Out-Null

    }

}



# --- Ask for Supabase config (minimal, paste from Supabase UI) ---

Write-Host ""

Write-Host "Enter Supabase information for project: $ProjectName"

Write-Host "(Paste from Supabase settings → API)" -ForegroundColor Yellow

$SUPABASE_URL          = Read-Host "SUPABASE_URL (e.g. https://xxxxx.supabase.co)"

$SUPABASE_ANON_KEY     = Read-Host "SUPABASE_ANON_KEY (public anon key)"

$SUPABASE_SERVICE_KEY  = Read-Host "SUPABASE_SERVICE_ROLE_KEY (service role key, optional)"

$DATABASE_URL          = Read-Host "DATABASE_URL (optional, press Enter to skip)"



if ([string]::IsNullOrWhiteSpace($DATABASE_URL)) {

    $DATABASE_URL = "postgresql://user:password@localhost:5432/funaging_club"

}



# --- Write backend .env file ---

$backendEnvPath = Join-Path $backendRoot ".env"

@"

SUPABASE_URL=$SUPABASE_URL

SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_KEY

DATABASE_URL=$DATABASE_URL

PROJECT_NAME=$ProjectName

"@ | Set-Content -Encoding UTF8 $backendEnvPath



# --- Write frontend .env.local file ---

$frontendEnvPath = Join-Path $frontendRoot ".env.local"

@"

NEXT_PUBLIC_SUPABASE_URL=$SUPABASE_URL

NEXT_PUBLIC_SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

NEXT_PUBLIC_PROJECT_NAME=$ProjectName

"@ | Set-Content -Encoding UTF8 $frontendEnvPath



# --- backend/app/__init__.py ---

$appInit = Join-Path $appRoot "__init__.py"

@"

# FunAging.club backend app package

"@ | Set-Content -Encoding UTF8 $appInit



# --- backend/app/core/config.py ---

$coreConfig = Join-Path $coreRoot "config.py"

@"

import os

from functools import lru_cache

from pydantic import BaseSettings, AnyHttpUrl





class Settings(BaseSettings):

    project_name: str = os.getenv("PROJECT_NAME", "FunAging.club")

    supabase_url: AnyHttpUrl | None = os.getenv("SUPABASE_URL")

    supabase_anon_key: str | None = os.getenv("SUPABASE_ANON_KEY")

    supabase_service_role_key: str | None = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

    database_url: str | None = os.getenv("DATABASE_URL")



    class Config:

        case_sensitive = True





@lru_cache()

def get_settings() -> Settings:

    return Settings()

"@ | Set-Content -Encoding UTF8 $coreConfig



# --- backend/app/core/supabase_client.py ---

$coreSupabase = Join-Path $coreRoot "supabase_client.py"

@"

from typing import Any, Dict, Optional



import httpx

from .config import get_settings



_settings = get_settings()





class SupabaseClient:

    def __init__(self) -> None:

        if not _settings.supabase_url or not _settings.supabase_anon_key:

            self._enabled = False

            self._base_url = None

            self._anon_key = None

        else:

            self._enabled = True

            self._base_url = str(_settings.supabase_url).rstrip(\"/\")

            self._anon_key = _settings.supabase_anon_key



    @property

    def enabled(self) -> bool:

        return self._enabled



    async def select(

        self,

        table: str,

        params: Optional[Dict[str, Any]] = None,

    ) -> Dict[str, Any]:

        if not self._enabled:

            return {\"data\": [], \"error\": \"Supabase disabled (missing config)\"}



        url = f\"{self._base_url}/rest/v1/{table}\"

        headers = {

            \"apikey\": self._anon_key,

            \"Authorization\": f\"Bearer {_settings.supabase_anon_key}\",

            \"Accept\": \"application/json\",

        }

        async with httpx.AsyncClient(timeout=10.0) as client:

            resp = await client.get(url, headers=headers, params=params or {})

        resp.raise_for_status()

        return {\"data\": resp.json(), \"error\": None}





supabase_client = SupabaseClient()

"@ | Set-Content -Encoding UTF8 $coreSupabase



# --- backend/app/routes/__init__.py ---

$routesInit = Join-Path $routesRoot "__init__.py"

@"

# Routers package (trip, office, media)

"@ | Set-Content -Encoding UTF8 $routesInit



# --- backend/app/routes/trip.py ---

$tripRoute = Join-Path $routesRoot "trip.py"

@"

from fastapi import APIRouter



router = APIRouter(prefix=\"/trip\", tags=[\"trip\"])





@router.get(\"/ping\")

async def trip_ping():

    return {\"module\": \"trip\", \"status\": \"ok\"}

"@ | Set-Content -Encoding UTF8 $tripRoute



# --- backend/app/routes/office.py ---

$officeRoute = Join-Path $routesRoot "office.py"

@"

from fastapi import APIRouter



router = APIRouter(prefix=\"/office\", tags=[\"office\"])





@router.get(\"/ping\")

async def office_ping():

    return {\"module\": \"office\", \"status\": \"ok\"}

"@ | Set-Content -Encoding UTF8 $officeRoute



# --- backend/app/routes/media.py ---

$mediaRoute = Join-Path $routesRoot "media.py"

@"

from fastapi import APIRouter



router = APIRouter(prefix=\"/media\", tags=[\"media\"])





@router.get(\"/ping\")

async def media_ping():

    return {\"module\": \"media\", \"status\": \"ok\"}

"@ | Set-Content -Encoding UTF8 $mediaRoute



# --- backend/app/new_main.py ---

$newMainPath = Join-Path $appRoot "new_main.py"

@"

from fastapi import FastAPI

from .routes import trip, office, media



def create_app() -> FastAPI:

    app = FastAPI(title=\"FunAging.club Backend\")



    @app.get(\"/health\", tags=[\"system\"])

    async def health_check():

        return {\"status\": \"ok\", \"service\": \"funaging-club-backend\"}



    app.include_router(trip.router)

    app.include_router(office.router)

    app.include_router(media.router)



    return app



app = create_app()

"@ | Set-Content -Encoding UTF8 $newMainPath



# --- backend/app/main.py ---

$mainPath = Join-Path $appRoot "main.py"

@"

import uvicorn

from .new_main import app



if __name__ == \"__main__\":

    uvicorn.run(\"app.new_main:app\", host=\"0.0.0.0\", port=8000, reload=True)

"@ | Set-Content -Encoding UTF8 $mainPath



# --- backend/requirements.txt (minimal) ---

$reqPath = Join-Path $backendRoot "requirements.txt"

$reqContent = @"

fastapi>=0.111.0

uvicorn[standard]>=0.30.0

httpx>=0.27.0

pydantic>=2.8.0

"@

if (Test-Path $reqPath) {

    $existingReq = Get-Content $reqPath -Raw

    foreach ($line in $reqContent -split "`n") {

        $trim = $line.Trim()

        if ($trim -and ($existingReq -notmatch [regex]::Escape($trim))) {

            Add-Content -Encoding UTF8 $reqPath $trim

        }

    }

} else {

    $reqContent | Set-Content -Encoding UTF8 $reqPath

}



# --- Optional: create helper runner scripts ---



$runBackend = Join-Path $ProjectRoot "run_backend.ps1"

@"

`$env:PYTHONPATH = \"$backendRoot\"

cd \"$backendRoot\"

if (Test-Path \".venv\") {

    if (Test-Path \".venv\\Scripts\\Activate.ps1\") {

        . .venv\\Scripts\\Activate.ps1

    }

}

if (-not (Test-Path \".venv\")) {

    python -m venv .venv

    . .venv\\Scripts\\Activate.ps1

    pip install --upgrade pip

    pip install -r requirements.txt

}

uvicorn app.new_main:app --host 0.0.0.0 --port 8000 --reload

"@ | Set-Content -Encoding UTF8 $runBackend



$runFrontend = Join-Path $ProjectRoot "run_frontend.ps1"

@"

cd \"$frontendRoot\"

if (Test-Path \"package.json\") {

    if (-not (Test-Path \"node_modules\")) {

        npm install

    }

    npm run dev

} else {

    Write-Host \"No package.json found in frontend. Please ensure Next.js app exists.\" -ForegroundColor Yellow

}

"@ | Set-Content -Encoding UTF8 $runFrontend



$runAll = Join-Path $ProjectRoot "run_all.ps1"

@"

Start-Process pwsh -ArgumentList '-ExecutionPolicy Bypass -File `"$runBackend`"' -WindowStyle Normal

Start-Process pwsh -ArgumentList '-ExecutionPolicy Bypass -File `"$runFrontend`"' -WindowStyle Normal

"@ | Set-Content -Encoding UTF8 $runAll



Write-Host ""

Write-Host "=============================================" -ForegroundColor Green

Write-Host " ONE PACK COMPLETED" -ForegroundColor Green

Write-Host " - Backend skeleton restored" -ForegroundColor Green

Write-Host " - Supabase env wired for project: $ProjectName" -ForegroundColor Green

Write-Host " - Helper scripts: run_backend.ps1, run_frontend.ps1, run_all.ps1" -ForegroundColor Green

Write-Host "=============================================" -ForegroundColor Green















