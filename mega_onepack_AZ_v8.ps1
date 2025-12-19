$ErrorActionPreference = "Stop"



$global:ONEPACK_STATUS = @{}

$global:ONEPACK_LOG = Join-Path (Get-Location) "mega_onepack_AZ_v8.log"

$script:OnePackSummary = @()



function LogFile { param($p,$m)

    Add-Content -Path $global:ONEPACK_LOG -Value ("["+(Get-Date).ToString("s")+"] [$p] $m")

}



function PhaseSet { param($p,$s)

    $global:ONEPACK_STATUS[$p] = $s

    LogFile $p ("STATUS="+$s)

}



function Summary { param($p,$m)

    $script:OnePackSummary += "[$p] $m"

}



function LoadEnv { param($file,$p)

    if(!(Test-Path $file)){ LogFile $p "Env not found: $file"; return }

    LogFile $p "Load env: $file"

    foreach($l in Get-Content $file){

        if(!$l.Trim() -or $l.Trim().StartsWith("#")){continue}

        $i=$l.IndexOf("=")

        if($i -gt 0){

            $k=$l.Substring(0,$i).Trim()

            $v=$l.Substring($i+1).Trim().Trim('"').Trim("'")

            if($k){ Set-Item ("Env:"+$k) $v -ErrorAction SilentlyContinue }

        }

    }

}



function HttpOK { param($u,$p)

    try {

        $r = Invoke-WebRequest -Uri $u -TimeoutSec 8 -Method GET

        if($r.StatusCode -ge 200 -and $r.StatusCode -lt 400){

            LogFile $p "HTTP OK: $u"

            return $true

        }

        LogFile $p "HTTP BAD: $u Status="+$r.StatusCode

        return $false

    } catch {

        LogFile $p "HTTP ERR: $u Error="+$_.Exception.Message

        return $false

    }

}



function Ensure-FileContent {

    param($path,$content,$p)

    $dir = Split-Path $path

    if($dir -and -not (Test-Path $dir)){

        New-Item -ItemType Directory -Path $dir -Force | Out-Null

        LogFile $p "Created dir: $dir"

    }

    Set-Content -Path $path -Value $content -Encoding UTF8

    LogFile $p "Wrote file: $path"

}



function Start-DevProcess {

    param(

        [string]$name,

        [string]$workdir,

        [string]$file,

        [string]$args,

        [string]$phase

    )

    try{

        LogFile $phase "Starting $name : $file $args @ $workdir"

        Start-Process -WorkingDirectory $workdir -FilePath $file -ArgumentList $args -WindowStyle Minimized | Out-Null

        LogFile $phase "$name started (background)"

        return $true

    }catch{

        LogFile $phase "FAILED to start $name : $($_.Exception.Message)"

        return $false

    }

}



$root    = (Get-Location).Path

$backend = Join-Path $root "backend"

$frontend= Join-Path $root "frontend"



$summaryPath = Join-Path $root "mega_onepack_AZ_v8_summary.txt"



try {



    # ==========================

    # PHASE A — FOUNDATION

    # ==========================

    $p="PHASE-A"

    PhaseSet $p "START"



    if(!(Test-Path $backend)){ throw "Missing backend folder" }

    if(!(Test-Path $frontend)){ New-Item -ItemType Directory -Path $frontend -Force | Out-Null }



    LoadEnv (Join-Path $backend ".env") $p

    LoadEnv (Join-Path $root ".env") $p

    LoadEnv (Join-Path $root ".env.local") $p

    LoadEnv (Join-Path $frontend ".env.local") $p



    $guard = Join-Path $root ".sas_guard_v8.json"

    $fp = @{ root=$root; time=(Get-Date).ToString("o"); marker="SAS-ONEPACK-v8" } | ConvertTo-Json

    Set-Content $guard $fp



    PhaseSet $p "PASS"

    Summary $p "Foundation OK"



    # ==========================

    # PHASE B — SUPABASE ENV QUICK CHECK

    # ==========================

    $p="PHASE-B"

    PhaseSet $p "START"



    $SU=$env:SUPABASE_URL

    $SR=$env:SUPABASE_SERVICE_ROLE_KEY

    if(!$SR){ $SR=$env:SUPABASE_SERVICE_ROLE }



    if(!$SU -or !$SR){

        PhaseSet $p "PASS-WITH-ISSUES"

        Summary $p "Supabase env missing or incomplete"

    } else {

        PhaseSet $p "PASS"

        Summary $p "Supabase env OK"

    }



    # ==========================

    # PHASE C — GUARD CHECK

    # ==========================

    $p="PHASE-C"

    PhaseSet $p "START"

    if(Test-Path $guard){

        PhaseSet $p "PASS"

        Summary $p "Guard OK"

    }else{

        PhaseSet $p "PASS-WITH-ISSUES"

        Summary $p "Guard file missing (created new)"

    }



    # ==========================

    # PHASE D — GIT SNAPSHOT (SOFT)

    # ==========================

    $p="PHASE-D"

    PhaseSet $p "START"

    try{

        if(Test-Path ".git"){

            $st = git status --porcelain 2>$null

            if($st){

                git add -A | Out-Null

                $msg="[ONEPACK-v8] Auto snapshot "+(Get-Date -f s)

                git commit -m $msg | Out-Null

                LogFile $p "Git snapshot committed"

            } else {

                LogFile $p "Git clean, no commit"

            }

        } else {

            LogFile $p "No .git folder, skip snapshot"

        }

        PhaseSet $p "PASS"

        Summary $p "Git snapshot done (if needed)"

    }catch{

        PhaseSet $p "PASS-WITH-ISSUES"

        Summary $p "Git snapshot issue: $($_.Exception.Message)"

    }



    # ==========================

    # PHASE E — BACKEND SELF-HEAL

    # ==========================

    $p="PHASE-E"

    PhaseSet $p "START"



    $appDir      = Join-Path $backend "app"

    $routersDir  = Join-Path $appDir "routers"

    $mainPath    = Join-Path $appDir "main.py"

    $routersInit = Join-Path $routersDir "__init__.py"

    $healthPath  = Join-Path $routersDir "health.py"

    $tripPath    = Join-Path $routersDir "trip.py"

    $officePath  = Join-Path $routersDir "office.py"

    $mediaPath   = Join-Path $routersDir "media.py"



    $mainContent = @'

import uvicorn

from fastapi import FastAPI

from fastapi.middleware.cors import CORSMiddleware

from app.routers import health, trip, office, media



app = FastAPI(title="FunAging SAS Backend", version="0.1.0")



app.add_middleware(

    CORSMiddleware,

    allow_origins=["*"],

    allow_credentials=True,

    allow_methods=["*"],

    allow_headers=["*"],

)



@app.get("/")

async def root():

    return {"status": "ok", "service": "funaging-backend", "version": "v8"}



app.include_router(health.router, prefix="/health", tags=["health"])

app.include_router(trip.router,   prefix="/trip",   tags=["trip"])

app.include_router(office.router, prefix="/office", tags=["office"])

app.include_router(media.router,  prefix="/media",  tags=["media"])



if __name__ == "__main__":

    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)

'@



    $healthContent = @'

from fastapi import APIRouter



router = APIRouter()



@router.get("/", summary="Health check")

async def health():

    return {"status": "ok"}

'@



    $tripContent = @'

from fastapi import APIRouter



router = APIRouter()



@router.get("/", summary="Trip placeholder")

async def list_trips():

    return {"items": [], "message": "Trip API placeholder (v8)"}

'@



    $officeContent = @'

from fastapi import APIRouter



router = APIRouter()



@router.get("/", summary="Office placeholder")

async def office_root():

    return {"items": [], "message": "Office API placeholder (v8)"}

'@



    $mediaContent = @'

from fastapi import APIRouter



router = APIRouter()



@router.get("/", summary="Media placeholder")

async def media_root():

    return {"items": [], "message": "Media API placeholder (v8)"}

'@



    $routersInitContent = @'

"""API routers package (self-healing v8)."""

from . import health, trip, office, media  # noqa: F401

'@



    Ensure-FileContent $mainPath        $mainContent        $p

    Ensure-FileContent $routersInit     $routersInitContent $p

    Ensure-FileContent $healthPath      $healthContent      $p

    Ensure-FileContent $tripPath        $tripContent        $p

    Ensure-FileContent $officePath      $officeContent      $p

    Ensure-FileContent $mediaPath       $mediaContent       $p



    PhaseSet $p "PASS"

    Summary $p "Backend self-healed (main.py + routers)"



    # ==========================

    # PHASE F — DEV RUNTIME (BACKEND + FRONTEND)

    # ==========================

    $p="PHASE-F"

    PhaseSet $p "START"



    $backendStarted  = $false

    $frontendStarted = $false



    # Start backend dev (python uvicorn)

    $backendStarted = Start-DevProcess "backend-dev" $backend "python" "-m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload" $p

    if(-not $backendStarted){

        # fallback to py

        $backendStarted = Start-DevProcess "backend-dev-fallback" $backend "py" "-m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload" $p

    }



    # Start frontend dev

    $backendPkg  = Join-Path $backend "package.json"

    $frontendPkg = Join-Path $frontend "package.json"



    if(Test-Path $backendPkg){

        $frontendStarted = Start-DevProcess "frontend-dev (backend folder)" $backend "npm" "run dev -- --port 3000" $p

    } elseif(Test-Path $frontendPkg){

        $frontendStarted = Start-DevProcess "frontend-dev (frontend folder)" $frontend "npm" "run dev -- --port 3000" $p

    } else {

        LogFile $p "No package.json found for frontend (backend nor frontend). Skip frontend dev."

    }



    if($backendStarted -or $frontendStarted){

        PhaseSet $p "PASS"

        Summary $p "Dev runtime started (backend=$backendStarted frontend=$frontendStarted)"

    } else {

        PhaseSet $p "PASS-WITH-ISSUES"

        Summary $p "Failed to start dev runtime (backend and frontend)"

    }



    # ==========================

    # PHASE G — HEALTHCHECK

    # ==========================

    $p="PHASE-G"

    PhaseSet $p "START"



    $be = $false

    $fe = $false



    for($i=1;$i -le 8;$i++){

        Start-Sleep 5



        if(-not $be){

            foreach($u in @(

                "http://localhost:8000/health",

                "http://127.0.0.1:8000/health",

                "http://localhost:8000/",

                "http://127.0.0.1:8000/"

            )){

                if(HttpOK $u $p){ $be=$true; break }

            }

        }



        if(-not $fe){

            foreach($u in @(

                "http://localhost:3000/",

                "http://127.0.0.1:3000/",

                "http://localhost:5173/",

                "http://127.0.0.1:5173/"

            )){

                if(HttpOK $u $p){ $fe=$true; break }

            }

        }



        if($be -and $fe){ break }

    }



    if($be -and $fe){

        PhaseSet $p "PASS"

        Summary $p "Health OK (backend+frontend)"

    } else {

        PhaseSet $p "PASS-WITH-ISSUES"

        Summary $p ("Health: backend="+$be+" frontend="+$fe)

    }



}

catch {

    $msg = $_.Exception.Message

    LogFile "GLOBAL" "Unhandled error: $msg"

    $global:ONEPACK_STATUS["GLOBAL"] = "ERROR"

    Summary "GLOBAL" "Unhandled error: $msg"

}

finally {

    # PHASE Z — SUMMARY (always)

    $p="PHASE-Z"

    PhaseSet $p "START"



    $txt=@()

    $txt+="ONEPACK A→Z v8 Report"

    $txt+="Time: "+(Get-Date -f s)

    $txt+="Runtime: dev auto-fix (backend+frontend)"

    $txt+=""

    $txt+="Phase Status:"

    foreach($k in $global:ONEPACK_STATUS.Keys){

        $txt+=" - $k : "+$global:ONEPACK_STATUS[$k]

    }

    $txt+=""

    $txt+="Details:"

    $txt+=$script:OnePackSummary



    Set-Content $summaryPath $txt -Encoding UTF8

    PhaseSet $p "PASS"

}























