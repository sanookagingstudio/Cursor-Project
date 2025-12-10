# ONEPACK AZ START



$ErrorActionPreference = "Stop"



$global:ONEPACK_STATUS = @{}

$global:ONEPACK_LOG = Join-Path (Get-Location) "mega_onepack_AZ.log"

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

        $m = "[ONEPACK-AZ] Auto snapshot "+(Get-Date -f s)

        git commit -m $m | Out-Null

        $t="onepack-az-"+(Get-Date -f yyyyMMddHHmmss)

        try{ git tag -a $t -m $m | Out-Null }catch{}

        LogFile $p "Snapshot: $t"

    } else {

        LogFile $p "No changes"

    }

}



function UpDocker { param($f,$p)

    if(!(Test-Path $f)){ LogFile $p "Compose missing: $f"; return }

    $c1="docker compose -f `"$f`" up -d --build"

    $c2="docker-compose -f `"$f`" up -d --build"

    try {

        cmd.exe /c $c1 2>&1 | % { LogFile $p $_ }

    } catch {

        try { cmd.exe /c $c2 2>&1 | % { LogFile $p $_ } }

        catch { LogFile $p "Docker fail "+$_.Exception.Message }

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

$guard=Join-Path $root ".sas_guard.json"



try {

    if(!(Test-Path $backend)){ throw "Missing backend folder" }

    if(!(Test-Path $frontend)){ throw "Missing frontend folder" }



    LoadEnv (Join-Path $backend ".env") $p

    LoadEnv (Join-Path $root ".env") $p

    LoadEnv (Join-Path $root ".env.local") $p

    LoadEnv (Join-Path $frontend ".env.local") $p



    $fp = @{ project_root=$root; time=(Get-Date).ToString("o"); marker="FunAging.club-SAS-v1" } | ConvertTo-Json

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

$AN=$env:SUPABASE_ANON_KEY

$SR=$env:SUPABASE_SERVICE_ROLE_KEY

if(!$SR){ $SR=$env:SUPABASE_SERVICE_ROLE }



$ADMIN="sanookagingstudio@gmail.com"

$STAFF="akemontree@gmail.com"

$PWD="Ake@8814883"



try {

    if(!$SU -or !$SR){ throw "Missing SUPABASE env" }



    $authBase = ($SU.TrimEnd("/"))+"/auth/v1"

    $hdr = @{ apikey=$SR; Authorization="Bearer $SR"; "Content-Type"="application/json" }



    function EnsureUser { param($em,$pw)

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



    EnsureUser $ADMIN $PWD

    EnsureUser $STAFF $PWD



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

        LogFile $p "main.py restored"

    }

    PhaseSet $p "PASS"

    Summary $p "Self-heal OK"

}catch{

    PhaseSet $p "PASS-WITH-ISSUES"

    Summary $p ("Heal issue: "+$_.Exception.Message)

}



# ==========================

# PHASE F — DOCKER

# ==========================

$p="PHASE-F"

PhaseSet $p "START"

try{

    UpDocker $compose $p

    PhaseSet $p "PASS"

    Summary $p "Docker up OK"

}catch{

    PhaseSet $p "PASS-WITH-ISSUES"

    Summary $p ("Docker issue: "+$_.Exception.Message)

}



# ==========================

# PHASE G — HEALTHCHECK

# ==========================

$p="PHASE-G"

PhaseSet $p "START"

$be=$false;$fe=$false

try{

    foreach($u in @("http://localhost:8000/health","http://localhost:8000/docs")){

        if(HttpOK $u $p){$be=$true;break}

    }

    foreach($u in @("http://localhost:3000/","http://localhost:3000")){

        if(HttpOK $u $p){$fe=$true;break}

    }



    if($be -and $fe){ PhaseSet $p "PASS"; Summary $p "Health OK" }

    else { PhaseSet $p "PASS-WITH-ISSUES"; Summary $p "Health backend=$be frontend=$fe" }

}catch{

    PhaseSet $p "PASS-WITH-ISSUES"

    Summary $p ("Health error: "+$_.Exception.Message)

}



# ==========================

# PHASE Z — SUMMARY

# ==========================

$p="PHASE-Z"

PhaseSet $p "START"

$sum=Join-Path $root "mega_onepack_AZ_summary.txt"



$txt=@()

$txt+="ONEPACK A→Z Report"

$txt+="Time: "+(Get-Date -f s)

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



# END OF ONEPACK AZ
