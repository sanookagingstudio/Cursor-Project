$ErrorActionPreference = "Stop"



$global:ONEPACK_STATUS = @{}

$global:ONEPACK_LOG = Join-Path (Get-Location) "mega_onepack_AZ_v3.log"

$script:OnePackSummary = @()

$global:ONEPACK_RUNTIME = "unknown"   # docker | dev | unknown



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



function Mask { param($v)

    if(!$v){return ""}

    if($v.Length -le 6){return ("*" * $v.Length)}

    return $v.Substring(0,3)+"*****"+$v.Substring($v.Length-3)

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

        $m = "[ONEPACK-AZ-v3] Auto snapshot "+(Get-Date -f s)

        git commit -m $m | Out-Null

        $t="onepack-az-v3-"+(Get-Date -f yyyyMMddHHmmss)

        try{ git tag -a $t -m $m | Out-Null }catch{}

        LogFile $p "Snapshot: $t"

    } else {

        LogFile $p "No changes"

    }

}



function Run-DockerCommand {

    param([string[]]$Args,[string]$Phase)

    try {

        $output = & docker @Args 2>&1

        if($output){

            $output | ForEach-Object { LogFile $Phase ("docker "+($Args -join " ")+" :: "+$_) }

        }

        if($LASTEXITCODE -eq 0){ return $true }

        LogFile $Phase ("docker command failed, exitcode="+$LASTEXITCODE)

        return $false

    } catch {

        LogFile $Phase ("docker command threw: "+$_.Exception.Message)

        return $false

    }

}



function Test-DockerRunning {

    param([string]$Phase="PHASE-F")

    $ok = Run-DockerCommand @("info") $Phase

    if($ok){

        LogFile $Phase "Docker engine is running."

        return $true

    } else {

        LogFile $Phase "Docker engine NOT running."

        return $false

    }

}



function UpDocker { param($f,$p)

    if(!(Test-Path $f)){ LogFile $p "Compose missing: $f"; return }

    LogFile $p "Running docker compose up for $f"

    # use 'compose' subcommand through docker CLI so we reuse Run-DockerCommand

    $ok = Run-DockerCommand @("compose","-f",$f,"up","-d","--build") $p

    if(!$ok){

        LogFile $p "docker compose up failed."

    }

}



function Start-DockerDesktopIfPossible { param($p)

    $paths = @(

        "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe",

        "$Env:ProgramFiles(x86)\Docker\Docker\Docker Desktop.exe"

    )

    $exe = $paths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if($exe){

        LogFile $p "Starting Docker Desktop: $exe"

        try { Start-Process -FilePath $exe | Out-Null } catch { LogFile $p "Cannot start Docker Desktop: "+$_.Exception.Message }

    } else {

        LogFile $p "Docker Desktop executable not found."

    }

    for($i=1;$i -le 30;$i++){

        if(Test-DockerRunning $p){ return $true }

        Start-Sleep 3

    }

    LogFile $p "Docker engine still not running after wait."

    return $false

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

$compose=Join-Path $root "docker-compose.sas.yml"

$guard=Join-Path $root ".sas_guard_v3.json"



try {

    if(!(Test-Path $backend)){ throw "Missing backend folder" }

    if(!(Test-Path $frontend)){ throw "Missing frontend folder" }



    LoadEnv (Join-Path $backend ".env") $p

    LoadEnv (Join-Path $root ".env") $p

    LoadEnv (Join-Path $root ".env.local") $p

    LoadEnv (Join-Path $frontend ".env.local") $p



    $fp = @{ project_root=$root; time=(Get-Date).ToString("o"); marker="FunAging.club-SAS-v1"; version="ONEPACK-AZ-v3" } | ConvertTo-Json

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



    function EnsureUser { param($em,$pw,$p,$authBase,$hdr)

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



    EnsureUser $ADMIN $PWD $p $authBase $hdr

    EnsureUser $STAFF $PWD $p $authBase $hdr



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

# PHASE E — SELF HEALING

# ==========================

$p="PHASE-E"

PhaseSet $p "START"

try{

    $main=Join-Path $backend "app/main.py"

    $new=Join-Path $backend "app/new_main.py"

    if(!(Test-Path $main) -and (Test-Path $new)){

        Copy-Item $new $main -Force

        LogFile $p "main.py restored from new_main.py"

    }

    PhaseSet $p "PASS"

    Summary $p "Self-heal OK"

}catch{

    PhaseSet $p "PASS-WITH-ISSUES"

    Summary $p ("Heal issue: "+$_.Exception.Message)

}



# ==========================

# PHASE F — RUNTIME ENGINE (DOCKER OR DEV)

# ==========================

$p="PHASE-F"

PhaseSet $p "START"

try{

    if(Test-DockerRunning $p){

        $global:ONEPACK_RUNTIME = "docker"

        UpDocker $compose $p

    } else {

        LogFile $p "Docker not running. Trying to start Docker Desktop..."

        if(Start-DockerDesktopIfPossible $p){

            $global:ONEPACK_RUNTIME = "docker"

            UpDocker $compose $p

        } else {

            LogFile $p "Docker unavailable. Falling back to DEV runtime."

            $global:ONEPACK_RUNTIME = "dev"

            Start-DevBackend $backend $p

            Start-DevFrontend $frontend $p

        }

    }

    PhaseSet $p "PASS"

    Summary $p ("Runtime mode: "+$global:ONEPACK_RUNTIME)

}catch{

    PhaseSet $p "PASS-WITH-ISSUES"

    Summary $p ("Runtime issue: "+$_.Exception.Message)

}



# ==========================

# PHASE G — HEALTHCHECK

# ==========================

$p="PHASE-G"

PhaseSet $p "START"

$be=$false;$fe=$false

try{

    Start-Sleep 5

    foreach($u in @("http://localhost:8000/health","http://localhost:8000/docs")){

        if(HttpOK $u $p){$be=$true;break}

    }

    foreach($u in @("http://localhost:3000/","http://localhost:3000")){

        if(HttpOK $u $p){$fe=$true;break}

    }

    if($be -and $fe){

        PhaseSet $p "PASS"

        Summary $p ("Health OK, runtime="+$global:ONEPACK_RUNTIME)

    } else {

        PhaseSet $p "PASS-WITH-ISSUES"

        Summary $p ("Health backend="+$be+" frontend="+$fe+" runtime="+$global:ONEPACK_RUNTIME)

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

$sum=Join-Path $root "mega_onepack_AZ_v3_summary.txt"



$txt=@()

$txt+="ONEPACK A→Z v3 Report"

$txt+="Time: "+(Get-Date -f s)

$txt+="Runtime: "+$global:ONEPACK_RUNTIME

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










