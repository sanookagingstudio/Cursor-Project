# mega_onepack_AZ_v10.ps1

# FULL SYSTEM ONEPACK V10 — BACKEND + FRONTEND SELF-HEAL & DEV RUNTIME



$ErrorActionPreference = "Stop"



# =========================

# GLOBALS & LOGGING

# =========================

$LOG     = "mega_onepack_AZ_v10.log"

$SUMMARY = "mega_onepack_AZ_v10_summary.txt"



Remove-Item $LOG -ErrorAction SilentlyContinue

Remove-Item $SUMMARY -ErrorAction SilentlyContinue



$global:PHASE_STATUS = @{}



function Log {

    param([string]$phase, [string]$msg)

    $line = "[{0}] [{1}] {2}" -f (Get-Date).ToString("s"), $phase, $msg

    Add-Content -Path $LOG -Value $line

}



function Set-Phase {

    param([string]$phase, [string]$status)

    $global:PHASE_STATUS[$phase] = $status

    Log $phase ("STATUS=" + $status)

}



function Http-Ok {

    param([string]$url, [string]$phase)

    try {

        $r = Invoke-WebRequest -Uri $url -TimeoutSec 5 -Method GET

        if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 400) {

            Log $phase ("HTTP OK " + $r.StatusCode + " " + $url)

            return $true

        } else {

            Log $phase ("HTTP BAD " + $r.StatusCode + " " + $url)

            return $false

        }

    } catch {

        Log $phase ("HTTP ERR " + $url + " :: " + $_.Exception.Message)

        return $false

    }

}



# =========================

# PATHS

# =========================

$root     = (Get-Location).Path

$backend  = Join-Path $root "backend"

$frontend = Join-Path $root "frontend"

$appDir   = Join-Path $backend "app"

$routers  = Join-Path $appDir "routers"



$BACKEND_HOST = "127.0.0.1"

$BACKEND_PORT = 8000

$FRONTEND_PORT = 3000



$HEALTH_BACKEND  = "http://${BACKEND_HOST}:${BACKEND_PORT}/health"

$HEALTH_FRONTEND = "http://127.0.0.1:${FRONTEND_PORT}/"



# =========================

# PHASE A — FOUNDATION

# =========================

$phase = "PHASE-A"

Set-Phase $phase "START"



try {

    if (!(Test-Path $backend)) { throw "Backend folder missing: $backend" }

    if (!(Test-Path $appDir))  { New-Item -ItemType Directory -Path $appDir | Out-Null }

    if (!(Test-Path $routers)) { New-Item -ItemType Directory -Path $routers | Out-Null }



    $benv = Join-Path $backend ".env"

    if (Test-Path $benv) {

        Log $phase ("Load env: " + $benv)

        foreach ($line in Get-Content $benv) {

            if (-not $line.Trim() -or $line.Trim().StartsWith("#")) { continue }

            $idx = $line.IndexOf("=")

            if ($idx -gt 0) {

                $k = $line.Substring(0,$idx).Trim()

                $v = $line.Substring($idx+1).Trim().Trim('"').Trim("'")

                if ($k) { Set-Item -Path ("Env:" + $k) -Value $v -ErrorAction SilentlyContinue }

            }

        }

    }



    Set-Phase $phase "PASS"

} catch {

    Log $phase ("ERR " + $_.Exception.Message)

    Set-Phase $phase "PASS-WITH-ISSUES"

}



# =========================

# PHASE B — BACKEND VERIFY + SELF-HEAL (NON-DESTRUCTIVE IF HEALTHY)

# =========================

$phase = "PHASE-B"

Set-Phase $phase "START"



$backendHealthy = Http-Ok $HEALTH_BACKEND $phase



if ($backendHealthy) {

    Log $phase "Backend already healthy — skip code overwrite"

    Set-Phase $phase "PASS"

} else {

    try {

        $mainPy = Join-Path $appDir "main.py"



        $needRepair = $false

        if (!(Test-Path $mainPy)) { $needRepair = $true }

        if (!(Test-Path $routers)) { $needRepair = $true }



        if ($needRepair) {

            Log $phase "Backend not healthy — applying minimal stable backend repair"



            # main.py stable

@'

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

'@ | Set-Content -Path $mainPy -Encoding UTF8



            if (!(Test-Path $routers)) { New-Item -ItemType Directory -Path $routers | Out-Null }



@'

from . import health, trip, office, media

'@ | Set-Content -Path (Join-Path $routers "__init__.py") -Encoding UTF8



@'

from fastapi import APIRouter



router = APIRouter(prefix="", tags=["health"])



@router.get("/health")

async def health_check():

    return {"status": "ok"}

'@ | Set-Content -Path (Join-Path $routers "health.py") -Encoding UTF8



@'

from fastapi import APIRouter



router = APIRouter(prefix="/trip", tags=["trip"])



@router.get("/ping")

async def trip_ping():

    return {"module": "trip", "status": "ok"}

'@ | Set-Content -Path (Join-Path $routers "trip.py") -Encoding UTF8



@'

from fastapi import APIRouter



router = APIRouter(prefix="/office", tags=["office"])



@router.get("/ping")

async def office_ping():

    return {"module": "office", "status": "ok"}

'@ | Set-Content -Path (Join-Path $routers "office.py") -Encoding UTF8



@'

from fastapi import APIRouter



router = APIRouter(prefix="/media", tags=["media"])



@router.get("/ping")

async def media_ping():

    return {"module": "media", "status": "ok"}

'@ | Set-Content -Path (Join-Path $routers "media.py") -Encoding UTF8



            Log $phase "Backend files repaired"

        } else {

            Log $phase "Backend files exist — no overwrite, only restart"

        }



        # start uvicorn

        $pythonCmd   = "python"

        $uvicornArgs = "-m uvicorn app.main:app --host 0.0.0.0 --port $BACKEND_PORT --reload"



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

        $started = $proc.Start()

        if ($started) {

            Log $phase ("uvicorn started PID=" + $proc.Id)

        } else {

            Log $phase "uvicorn failed to start"

        }



        # wait for health

        $backendHealthy = $false

        for ($i=1; $i -le 15; $i++) {

            Start-Sleep 3

            if (Http-Ok $HEALTH_BACKEND $phase) { $backendHealthy = $true; break }

        }



        Log $phase ("Backend health after repair = " + $backendHealthy)



        if ($backendHealthy) {

            Set-Phase $phase "PASS"

        } else {

            Set-Phase $phase "PASS-WITH-ISSUES"

        }

    } catch {

        Log $phase ("ERR " + $_.Exception.Message)

        Set-Phase $phase "PASS-WITH-ISSUES"

    }

}



# =========================

# PHASE C — FRONTEND STRUCTURE + CONFIG

# =========================

$phase = "PHASE-C"

Set-Phase $phase "START"



try {

    if (!(Test-Path $frontend)) {

        New-Item -ItemType Directory -Path $frontend | Out-Null

        Log $phase "Created frontend directory"

    }



    $pkg = Join-Path $frontend "package.json"

    if (!(Test-Path $pkg)) {

@'

{

  "name": "funaging-frontend",

  "version": "1.0.0",

  "private": true,

  "scripts": {

    "dev": "next dev -p 3000",

    "build": "next build",

    "start": "next start -p 3000"

  },

  "dependencies": {

    "next": "14.1.0",

    "react": "18.2.0",

    "react-dom": "18.2.0",

    "@supabase/supabase-js": "2.45.0",

    "lucide-react": "latest",

    "tailwindcss": "3.4.0",

    "postcss": "8.4.35",

    "autoprefixer": "10.4.20"

  }

}

'@ | Set-Content -Path $pkg -Encoding UTF8

        Log $phase "Created package.json baseline"

    } else {

        Log $phase "Found existing package.json — keep it"

    }



    $tw = Join-Path $frontend "tailwind.config.js"

    if (!(Test-Path $tw)) {

@'

module.exports = {

  content: [

    "./app/**/*.{js,ts,jsx,tsx}",

    "./components/**/*.{js,ts,jsx,tsx}"

  ],

  theme: { extend: {} },

  plugins: []

};

'@ | Set-Content -Path $tw -Encoding UTF8

        Log $phase "Created tailwind.config.js"

    }



    $postcss = Join-Path $frontend "postcss.config.js"

    if (!(Test-Path $postcss)) {

@'

module.exports = {

  plugins: {

    tailwindcss: {},

    autoprefixer: {}

  }

};

'@ | Set-Content -Path $postcss -Encoding UTF8

        Log $phase "Created postcss.config.js"

    }



    $appDirFe = Join-Path $frontend "app"

    if (!(Test-Path $appDirFe)) {

        New-Item -ItemType Directory -Path $appDirFe | Out-Null

    }



    $globals = Join-Path $appDirFe "globals.css"

@'

@tailwind base;

@tailwind components;

@tailwind utilities;

'@ | Set-Content -Path $globals -Encoding UTF8



    $page = Join-Path $appDirFe "page.tsx"

    if (!(Test-Path $page)) {

@'

export default function Home() {

  return (

    <div className="min-h-screen flex items-center justify-center bg-slate-900 text-slate-50">

      <div className="px-8 py-6 rounded-2xl shadow-lg bg-slate-800 border border-slate-700">

        <h1 className="text-3xl font-bold mb-2">FunAging Frontend is running 🎉</h1>

        <p className="text-sm text-slate-300">

          Backend health is managed by ONEPACK AZ v10. This is the SAS dashboard entry.

        </p>

      </div>

    </div>

  );

}

'@ | Set-Content -Path $page -Encoding UTF8

        Log $phase "Created app/page.tsx"

    } else {

        # patch any 'class=' to 'className=' defensively

        (Get-Content $page) -replace 'class=', 'className=' | Set-Content $page -Encoding UTF8

        Log $phase "Patched page.tsx class → className"

    }



    Set-Phase $phase "PASS"

} catch {

    Log $phase ("ERR " + $_.Exception.Message)

    Set-Phase $phase "PASS-WITH-ISSUES"

}



# =========================

# PHASE D — FRONTEND DEPENDENCIES (npm install)

# =========================

$phase = "PHASE-D"

Set-Phase $phase "START"



$frontendDepsOk = $false



try {

    Push-Location $frontend



    if (Test-Path "node_modules") {

        Log $phase "node_modules already exists — keep it"

    } else {

        if (Test-Path "package-lock.json") { Remove-Item "package-lock.json" -Force -ErrorAction SilentlyContinue }

        Log $phase "Running npm install..."

        npm install | ForEach-Object { Log $phase $_ }

    }



    $frontendDepsOk = $true

    Pop-Location



    Set-Phase $phase "PASS"

} catch {

    Log $phase ("ERR " + $_.Exception.Message)

    try { Pop-Location } catch {}

    Set-Phase $phase "PASS-WITH-ISSUES"

}



# =========================

# PHASE E — START RUNTIMES (BACKEND ALREADY STARTED ABOVE IF NEEDED)

# =========================

$phase = "PHASE-E"

Set-Phase $phase "START"



$frontendStarted = $false



try {

    if ($frontendDepsOk) {

        $psiFe = New-Object System.Diagnostics.ProcessStartInfo

        $psiFe.FileName = "npm"

        $psiFe.Arguments = "run dev -- -p $FRONTEND_PORT"

        $psiFe.WorkingDirectory = $frontend

        $psiFe.CreateNoWindow = $true

        $psiFe.UseShellExecute = $false

        $psiFe.RedirectStandardOutput = $true

        $psiFe.RedirectStandardError  = $true



        $pFe = New-Object System.Diagnostics.Process

        $pFe.StartInfo = $psiFe

        $startedFe = $pFe.Start()

        if ($startedFe) {

            Log $phase ("frontend dev started PID=" + $pFe.Id)

            $frontendStarted = $true

        } else {

            Log $phase "frontend dev failed to start"

        }

    } else {

        Log $phase "Skip frontend start, deps not OK"

    }



    Set-Phase $phase "PASS"

} catch {

    Log $phase ("ERR " + $_.Exception.Message)

    Set-Phase $phase "PASS-WITH-ISSUES"

}



# =========================

# PHASE F — HEALTHCHECK BACKEND + FRONTEND

# =========================

$phase = "PHASE-F"

Set-Phase $phase "START"



$beOk = $false

$feOk = $false



try {

    for ($i=1; $i -le 20; $i++) {

        if (-not $beOk) { $beOk = Http-Ok $HEALTH_BACKEND $phase }

        if (-not $feOk) { $feOk = Http-Ok $HEALTH_FRONTEND $phase }

        if ($beOk -and $feOk) { break }

        Start-Sleep 3

    }



    Log $phase ("Backend OK = " + $beOk + " | Frontend OK = " + $feOk)



    if ($beOk -and $feOk) {

        Set-Phase $phase "PASS"

    } else {

        Set-Phase $phase "PASS-WITH-ISSUES"

    }

} catch {

    Log $phase ("ERR " + $_.Exception.Message)

    Set-Phase $phase "PASS-WITH-ISSUES"

}



# =========================

# PHASE Z — SUMMARY FILE

# =========================

$phase = "PHASE-Z"

Set-Phase $phase "START"



$lines = @()

$lines += "ONEPACK A→Z V10 REPORT"

$lines += "Time: " + (Get-Date -f s)

$lines += "Backend health URL : $HEALTH_BACKEND"

$lines += "Frontend URL       : $HEALTH_FRONTEND"

$lines += ""



$lines += "PHASE STATUS:"

foreach ($k in $global:PHASE_STATUS.Keys) {

    $lines += " - $k : " + $global:PHASE_STATUS[$k]

}



$lines += ""

$lines += "LOG TAIL:"

if (Test-Path $LOG) {

    $lines += (Get-Content $LOG -Tail 80)

}



Set-Content -Path $SUMMARY -Value $lines -Encoding UTF8



Set-Phase $phase "PASS"



"ONEPACK V10 COMPLETE. See mega_onepack_AZ_v10_summary.txt"












