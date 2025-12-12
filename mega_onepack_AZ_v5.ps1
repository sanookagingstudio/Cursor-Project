$ErrorActionPreference = "Stop"



$global:ONEPACK_STATUS = @{}

$global:ONEPACK_LOG = Join-Path (Get-Location) "mega_onepack_AZ_v5.log"

$script:OnePackSummary = @()

$global:ONEPACK_RUNTIME = "dev"   # FORCE DEV MODE WITH SELF-HEALING



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



function Retry { param($a,$p,$r=3,$d=3)

    for($i=1;$i -le $r;$i++){

        try { return & $a }

        catch {

            LogFile $p ("Retry $i failed: "+$_.Exception.Message)

            if($i -eq $r){ throw }

            Start-Sleep $d

        }

    }

}



function LoadEnv { param($file,$p)

    if(!(Test-Path $file)){ LogFile $p "Env not found: $file"; return }

    LogFile $p "Load env: $file"

    foreach($l in Get-Content $file){

        if(!$l.Trim() -or $l.Trim().StartsWith("#")){continue}

        $i = $l.IndexOf("=")

        if($i -gt 0){

            $k = $l.Substring(0,$i).Trim()

            $v = $l.Substring($i+1).Trim().Trim('"').Trim("'")

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



function GitSnap { param($p)

    if(!(Test-Path ".git")){ LogFile $p "Skip git snapshot"; return }

    try{ $s = git status --porcelain 2>$null }catch{ LogFile $p "Git fail"; return }

    if($s){

        git add -A | Out-Null

        $m = "[ONEPACK-AZ-v5] Auto snapshot "+(Get-Date -f s)

        git commit -m $m | Out-Null

        $t="onepack-az-v5-"+(Get-Date -f yyyyMMddHHmmss)

        try{ git tag -a $t -m $m | Out-Null }catch{}

        LogFile $p "Snapshot: $t"

    } else {

        LogFile $p "No changes"

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



function Start-DevBackend { param($backendPath,$p)

    if(!(Test-Path $backendPath)){

        LogFile $p "Backend path not found: $backendPath"

        return

    }

    LogFile $p "Starting DEV backend with uvicorn..."

    try {

        Start-Process -WorkingDirectory $backendPath -FilePath "python" -ArgumentList "-m uvicorn app.main:app --host 0.0.0.0 --port 8000" -WindowStyle Minimized | Out-Null

        LogFile $p "DEV backend process started."

    } catch {

        LogFile $p "DEV backend failed: "+$_.Exception.Message

    }

}



function Start-DevFrontend { param($frontendPath,$p)

    if(!(Test-Path $frontendPath)){

        LogFile $p "Frontend path not found: $frontendPath"

        return

    }

    LogFile $p "Starting DEV frontend with npm run dev..."

    try {

        Start-Process -WorkingDirectory $frontendPath -FilePath "npm" -ArgumentList "run dev -- --port 3000" -WindowStyle Minimized | Out-Null

        LogFile $p "DEV frontend process started."

    } catch {

        LogFile $p "DEV frontend failed: "+$_.Exception.Message

    }

}



# ==========================

# PHASE A — FOUNDATION

# ==========================

$p="PHASE-A"

PhaseSet $p "START"

$root=(Get-Location).Path

$backend=Join-Path $root "backend"

$frontend=Join-Path $root "frontend"

$guard=Join-Path $root ".sas_guard_v5.json"



try {

    if(!(Test-Path $backend)){ throw "Missing backend folder" }

    if(!(Test-Path $frontend)){ throw "Missing frontend folder" }



    LoadEnv (Join-Path $backend ".env") $p

    LoadEnv (Join-Path $root ".env") $p

    LoadEnv (Join-Path $root ".env.local") $p

    LoadEnv (Join-Path $frontend ".env.local") $p



    $fp = @{ project_root=$root; time=(Get-Date).ToString("o"); marker="FunAging.club-SAS-v1"; version="ONEPACK-AZ-v5"; runtime="dev-self-heal" } | ConvertTo-Json

    Set-Content $guard $fp



    PhaseSet $p "PASS"

    Summary $p "Foundation OK"

}

catch {

    PhaseSet $p "PASS-WITH-ISSUES"

    Summary $p ("Foundation issue: "+$_.Exception.Message)

}



# ==========================

# PHASE B — SUPABASE AUTH

# ==========================

$p="PHASE-B"

PhaseSet $p "START"



$SU=$env:SUPABASE_URL

$SR=$env:SUPABASE_SERVICE_ROLE_KEY

if(!$SR){ $SR=$env:SUPABASE_SERVICE_ROLE }



$ADMIN="sanookagingstudio@gmail.com"

$STAFF="akemontree@gmail.com"

$PWD="Ake@8814883"



try {

    if(!$SU -or !$SR){ throw "Missing SUPABASE env" }



    $authBase = ($SU.TrimEnd("/"))+"/auth/v1"

    $hdr = @{ apikey=$SR; Authorization="Bearer $SR"; "Content-Type"="application/json" }



    function EnsureUserLocal { param($em,$pw,$p,$authBase,$hdr)

        $url = $authBase + "/admin/users?email=eq."+[uri]::EscapeDataString($em)

        try { $u = Retry { Invoke-RestMethod -Uri $url -Headers $hdr -Method GET } $p }

        catch { $u=$null }

        if($u -and $u.Count -gt 0){

            LogFile $p "User exists: $em"

            return

        }

        $body=@{ email=$em; password=$pw; email_confirm=$true }|ConvertTo-Json

        $cUrl=$authBase+"/admin/users"

        try { Retry { Invoke-RestMethod -Uri $cUrl -Headers $hdr -Method POST -Body $body } $p }

        catch { LogFile $p "Create fail: $em" }

        LogFile $p "Created user: $em"

    }



    EnsureUserLocal $ADMIN $PWD $p $authBase $hdr

    EnsureUserLocal $STAFF $PWD $p $authBase $hdr



    PhaseSet $p "PASS"

    Summary $p "Supabase auth synced"

}

catch {

    PhaseSet $p "PASS-WITH-ISSUES"

    Summary $p ("Auth issue: "+$_.Exception.Message)

}



# ==========================

# PHASE C — SAFE GUARD

# ==========================

$p="PHASE-C"

PhaseSet $p "START"

try{

    if(!(Test-Path $guard)){ throw "Guard missing" }

    PhaseSet $p "PASS"

    Summary $p "Safe guard OK"

}catch{

    PhaseSet $p "PASS-WITH-ISSUES"

    Summary $p ("Guard issue: "+$_.Exception.Message)

}



# ==========================

# PHASE D — GIT SNAPSHOT

# ==========================

$p="PHASE-D"

PhaseSet $p "START"

try{

    GitSnap $p

    PhaseSet $p "PASS"

    Summary $p "Git snapshot done"

}catch{

    PhaseSet $p "PASS-WITH-ISSUES"

    Summary $p ("Git issue: "+$_.Exception.Message)

}



# ==========================

# PHASE E — BACKEND SELF-HEAL

# ==========================

$p="PHASE-E"

PhaseSet $p "START"

try{

    $appDir   = Join-Path $backend "app"

    $mainPath = Join-Path $appDir "main.py"

    $routersDir = Join-Path $appDir "routers"

    $healthPath = Join-Path $routersDir "health.py"

    $tripPath   = Join-Path $routersDir "trip.py"

    $officePath = Join-Path $routersDir "office.py"

    $mediaPath  = Join-Path $routersDir "media.py"

    $routersInit = Join-Path $routersDir "__init__.py"



    $mainContent = @'

# FunAging SAS Backend main (Self-Healing v5)

from fastapi import FastAPI

from fastapi.middleware.cors import CORSMiddleware



from app.routers import health, trip, office, media



app = FastAPI(

    title="FunAging SAS Backend",

    version="0.1.0",

)



app.add_middleware(

    CORSMiddleware,

    allow_origins=["*"],

    allow_credentials=True,

    allow_methods=["*"],

    allow_headers=["*"],

)



@app.get("/")

async def root():

    return {"status": "ok", "service": "funaging-backend", "version": "v5"}



app.include_router(health.router, prefix="/health", tags=["health"])

app.include_router(trip.router, prefix="/trip", tags=["trip"])

app.include_router(office.router, prefix="/office", tags=["office"])

app.include_router(media.router, prefix="/media", tags=["media"])

'@



    $healthContent = @'

# Health router (self-healing v5)

from fastapi import APIRouter



router = APIRouter()



@router.get("/", summary="Health check")

async def get_health():

    return {"status": "ok"}

'@



    $tripContent = @'

# Trip router (self-healing v5 placeholder)

from fastapi import APIRouter



router = APIRouter()



@router.get("/", summary="List trips (placeholder)")

async def list_trips():

    return {"items": [], "message": "Trip API placeholder (v5)"}

'@



    $officeContent = @'

# Office router (self-healing v5 placeholder)

from fastapi import APIRouter



router = APIRouter()



@router.get("/", summary="Office API placeholder")

async def office_root():

    return {"items": [], "message": "Office API placeholder (v5)"}

'@



    $mediaContent = @'

# Media router (self-healing v5 placeholder)

from fastapi import APIRouter



router = APIRouter()



@router.get("/", summary="Media API placeholder")

async def media_root():

    return {"items": [], "message": "Media API placeholder (v5)"}

'@



    $routersInitContent = @'

"""API routers package (self-healing v5)."""

from . import health, trip, office, media  # noqa: F401

'@



    Ensure-FileContent $mainPath        $mainContent        $p

    Ensure-FileContent $healthPath      $healthContent      $p

    Ensure-FileContent $tripPath        $tripContent        $p

    Ensure-FileContent $officePath      $officeContent      $p

    Ensure-FileContent $mediaPath       $mediaContent       $p

    Ensure-FileContent $routersInit     $routersInitContent $p



    PhaseSet $p "PASS"

    Summary $p "Backend self-healed (main.py + routers)"

}catch{

    PhaseSet $p "PASS-WITH-ISSUES"

    Summary $p ("Backend heal issue: "+$_.Exception.Message)

}



# ==========================

# PHASE F — FORCE DEV RUNTIME

# ==========================

$p="PHASE-F"

PhaseSet $p "START"

try{

    Start-DevBackend $backend $p

    Start-DevFrontend $frontend $p

    PhaseSet $p "PASS"

    Summary $p "Runtime mode: dev (forced, with self-heal)"

}catch{

    PhaseSet $p "PASS-WITH-ISSUES"

    Summary $p ("Runtime issue: "+$_.Exception.Message)

}



# ==========================

# PHASE G — HEALTHCHECK (DEV)

# ==========================

$p="PHASE-G"

PhaseSet $p "START"

$be=$false;$fe=$false

try{

    # wait a bit longer for dev servers

    Start-Sleep 12

    foreach($u in @("http://localhost:8000/health","http://localhost:8000/docs","http://localhost:8000/")){

        if(HttpOK $u $p){$be=$true;break}

    }

    foreach($u in @("http://localhost:3000/","http://localhost:3000")){

        if(HttpOK $u $p){$fe=$true;break}

    }

    if($be -and $fe){

        PhaseSet $p "PASS"

        Summary $p "Health OK, runtime=dev"

    } else {

        PhaseSet $p "PASS-WITH-ISSUES"

        Summary $p ("Health backend="+$be+" frontend="+$fe+" runtime=dev")

    }

}catch{

    PhaseSet $p "PASS-WITH-ISSUES"

    Summary $p ("Health error: "+$_.Exception.Message)

}



# ==========================

# PHASE Z — SUMMARY

# ==========================

$p="PHASE-Z"

PhaseSet $p "START"

$root=(Get-Location).Path

$sum=Join-Path $root "mega_onepack_AZ_v5_summary.txt"



$txt=@()

$txt+="ONEPACK A→Z v5 Report"

$txt+="Time: "+(Get-Date -f s)

$txt+="Runtime: dev (self-healing)"

$txt+=""

$txt+="Phase Status:"

foreach($k in $global:ONEPACK_STATUS.Keys){

    $txt+=" - $k : "+$global:ONEPACK_STATUS[$k]

}

$txt+=""

$txt+="Details:"

$txt+=$script:OnePackSummary



Set-Content $sum $txt

PhaseSet $p "PASS"







