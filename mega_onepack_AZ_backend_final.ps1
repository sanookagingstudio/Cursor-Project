# mega_onepack_AZ_backend_final.ps1  (V3 FIXED)
# BACKEND ONLY – 100% RUNNABLE

$ErrorActionPreference = "Stop"

#====================
# CONFIG (Fix Host variable)
#====================
$LOG      = "mega_onepack_backend.log"
$SUMMARY  = "mega_onepack_backend_summary.txt"

$PORT     = 8000
$SAS_HOST = "127.0.0.1"   # <-- FIXED (ไม่ชน $Host ของ PowerShell)
$HEALTH   = "http://${SAS_HOST}:${PORT}/health"

#====================
# UTILS
#====================
function Write-Log {
    param([string]$phase,[string]$msg)
    $line = "[{0}] [{1}] {2}" -f (Get-Date).ToString("s"),$phase,$msg
    Add-Content -Path $LOG -Value $line
}

function Try-Http {
    param([string]$url,[string]$phase)
    try {
        $r = Invoke-WebRequest -Uri $url -TimeoutSec 5 -Method GET
        Write-Log $phase ("HTTP {0} : {1}" -f $r.StatusCode, $url)
        return $true
    } catch {
        Write-Log $phase ("HTTP ERR : {0} :: {1}" -f $url, $_.Exception.Message)
        return $false
    }
}

#====================
# START
#====================
Remove-Item $LOG -ErrorAction SilentlyContinue
Remove-Item $SUMMARY -ErrorAction SilentlyContinue

$root    = (Get-Location).Path
$backend = Join-Path $root "backend"
$appDir  = Join-Path $backend "app"
$routers = Join-Path $appDir "routers"

#====================
# PHASE A — ตรวจโครงสร้าง backend
#====================
$phase = "PHASE-A"
Write-Log $phase "START"

if (!(Test-Path $backend)) { throw "Backend folder not found: $backend" }
if (!(Test-Path $appDir))  { New-Item -ItemType Directory -Path $appDir | Out-Null }
if (!(Test-Path $routers)) { New-Item -ItemType Directory -Path $routers | Out-Null }

Write-Log $phase "Backend/app/routers OK"
Write-Log $phase "PASS"

#====================
# PHASE B — main.py (stable)
#====================
$phase = "PHASE-B"
Write-Log $phase "START"

$mainPy = Join-Path $appDir "main.py"

$mainContent = @'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import health, trip, office, media

app = FastAPI(title="FunAging SAS Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(trip.router)
app.include_router(office.router)
app.include_router(media.router)

@app.get("/")
async def root():
    return {"status": "ok", "service": "FunAging SAS Backend"}
'@

Set-Content -Path $mainPy -Value $mainContent -Encoding UTF8
Write-Log $phase "Wrote main.py"
Write-Log $phase "PASS"

#====================
# PHASE C — routers
#====================
$phase = "PHASE-C"
Write-Log $phase "START"

Set-Content -Path (Join-Path $routers "__init__.py") -Value @'
from . import health, trip, office, media
'@ -Encoding UTF8

Set-Content -Path (Join-Path $routers "health.py") -Value @'
from fastapi import APIRouter

router = APIRouter(prefix="", tags=["health"])

@router.get("/health")
async def health_check():
    return {"status": "ok"}
'@ -Encoding UTF8

Set-Content -Path (Join-Path $routers "trip.py") -Value @'
from fastapi import APIRouter

router = APIRouter(prefix="/trip", tags=["trip"])

@router.get("/ping")
async def trip_ping():
    return {"module": "trip", "status": "ok"}
'@ -Encoding UTF8

Set-Content -Path (Join-Path $routers "office.py") -Value @'
from fastapi import APIRouter

router = APIRouter(prefix="/office", tags=["office"])

@router.get("/ping")
async def office_ping():
    return {"module": "office", "status": "ok"}
'@ -Encoding UTF8

Set-Content -Path (Join-Path $routers "media.py") -Value @'
from fastapi import APIRouter

router = APIRouter(prefix="/media", tags=["media"])

@router.get("/ping")
async def media_ping():
    return {"module": "media", "status": "ok"}
'@ -Encoding UTF8

Write-Log $phase "Routers ready"
Write-Log $phase "PASS"

#====================
# PHASE D — Start Uvicorn
#====================
$phase = "PHASE-D"
Write-Log $phase "START"

$pythonCmd  = "python"
$uvicornArgs = "-m uvicorn app.main:app --host 0.0.0.0 --port $PORT --reload"

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $pythonCmd
$psi.Arguments = $uvicornArgs
$psi.WorkingDirectory = $backend
$psi.CreateNoWindow = $true
$psi.UseShellExecute = $false
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError  = $true

$proc = New-Object System.Diagnostics.Process
$proc.StartInfo = $psi

if ($proc.Start()) {
    Write-Log $phase "uvicorn started (PID=$($proc.Id))"
} else {
    Write-Log $phase "FAILED to start uvicorn"
}

Write-Log $phase "PASS"

#====================
# PHASE E — Healthcheck
#====================
$phase = "PHASE-E"
Write-Log $phase "START"

$ok = $false
for ($i=1; $i -le 12; $i++) {
    Start-Sleep 3
    if (Try-Http -url $HEALTH -phase $phase) {
        $ok = $true
        break
    }
}

Write-Log $phase ("Healthcheck result = {0}" -f $ok)

#====================
# SUMMARY
#====================
$lines = @()
$lines += "BACKEND ONEPACK FINAL REPORT"
$lines += "Time: " + (Get-Date -f s)
$lines += "Health URL: $HEALTH"
$lines += "Health OK : $ok"
$lines += ""
$lines += "Log tail:"
$lines += (Get-Content $LOG -Tail 40)

Set-Content -Path $SUMMARY -Value $lines -Encoding UTF8

Write-Host "DONE. Health OK = $ok"
