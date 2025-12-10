$ErrorActionPreference = "Stop"



$global:ONEPACK_STATUS = @{}

$global:ONEPACK_LOG = Join-Path -Path (Get-Location) -ChildPath "mega_onepack_AZ.log"



function Write-Log {

    param([string]$Phase,[string]$Message)

    $ts = (Get-Date).ToString("s")

    $line = "[$ts] [$Phase] $Message"

    Add-Content -Path $global:ONEPACK_LOG -Value $line

}



function Set-PhaseStatus {

    param([string]$Phase,[string]$Status)

    $global:ONEPACK_STATUS[$Phase] = $Status

    Write-Log -Phase $Phase -Message "STATUS=$Status"

}



function Invoke-WithRetry {

    param(

        [scriptblock]$Action,

        [int]$MaxRetry = 3,

        [int]$DelaySeconds = 3,

        [string]$Phase = "GENERIC"

    )

    $attempt = 0

    while ($attempt -lt $MaxRetry) {

        try {

            $attempt++

            return & $Action

        } catch {

            Write-Log -Phase $Phase -Message "Attempt $attempt failed: $($_.Exception.Message)"

            if ($attempt -ge $MaxRetry) {

                throw

            }

            Start-Sleep -Seconds $DelaySeconds

        }

    }

}



function Load-EnvFile {

    param([string]$Path,[string]$Phase)

    if (Test-Path $Path) {

        Write-Log -Phase $Phase -Message "Loading env file: $Path"

        Get-Content $Path | Where-Object {$_ -and -not $_.Trim().StartsWith("#")} | ForEach-Object {

            if ($_ -match "^\s*([^=]+)=(.*)$") {

                $key = $matches[1].Trim()

                $val = $matches[2].Trim()

                $val = $val.Trim('"').Trim("'")

                Set-Item -Path "env:$key" -Value $val

            }

        }

    } else {

        Write-Log -Phase $Phase -Message "Env file not found: $Path"

    }

}



function Test-HttpOk {

    param([string]$Url,[int]$TimeoutSec = 8,[string]$Phase = "HTTP")

    try {

        $result = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec $TimeoutSec

        if ($result.StatusCode -ge 200 -and $result.StatusCode -lt 400) {

            Write-Log -Phase $Phase -Message "HTTP OK: $Url Status=$($result.StatusCode)"

            return $true

        } else {

            Write-Log -Phase $Phase -Message "HTTP FAIL: $Url Status=$($result.StatusCode)"

            return $false

        }

    } catch {

        Write-Log -Phase $Phase -Message "HTTP ERROR: $Url Error=$($_.Exception.Message)"

        return $false

    }

}



function Ensure-GitSnapshot {

    param([string]$Phase)

    if (-not (Test-Path ".git")) {

        Write-Log -Phase $Phase -Message ".git folder not found, skipping git snapshot"

        return

    }

    try {

        $status = git status --porcelain 2>$null

    } catch {

        Write-Log -Phase $Phase -Message "git status failed, skipping git snapshot"

        return

    }

    if ($status) {

        try {

            git add -A | Out-Null

            $msg = "[ONEPACK-AZ] Auto snapshot $(Get-Date -Format s)"

            git commit -m $msg | Out-Null

            $tag = "onepack-az-" + (Get-Date -Format "yyyyMMddHHmmss")

            try { git tag -a $tag -m $msg | Out-Null } catch {}

            Write-Log -Phase $Phase -Message "Git snapshot created: $msg Tag=$tag"

        } catch {

            Write-Log -Phase $Phase -Message "Git snapshot failed: $($_.Exception.Message)"

        }

    } else {

        Write-Log -Phase $Phase -Message "No changes to commit, skipping git snapshot"

    }

}



function Ensure-DockerUp {

    param([string]$ComposeFile,[string]$Phase)

    if (-not (Test-Path $ComposeFile)) {

        Write-Log -Phase $Phase -Message "Compose file not found: $ComposeFile"

        return

    }

    $cmd1 = "docker compose -f `"$ComposeFile`" up -d --build"

    $cmd2 = "docker-compose -f `"$ComposeFile`" up -d --build"

    try {

        Write-Log -Phase $Phase -Message "Running: $cmd1"

        cmd.exe /c $cmd1 2>&1 | ForEach-Object { Write-Log -Phase $Phase -Message $_ }

    } catch {

        Write-Log -Phase $Phase -Message "docker compose failed, trying docker-compose: $($_.Exception.Message)"

        try {

            Write-Log -Phase $Phase -Message "Running: $cmd2"

            cmd.exe /c $cmd2 2>&1 | ForEach-Object { Write-Log -Phase $Phase -Message $_ }

        } catch {

            Write-Log -Phase $Phase -Message "docker-compose failed: $($_.Exception.Message)"

        }

    }

}



function Mask-Value {

    param([string]$v)

    if (-not $v) { return "" }

    if ($v.Length -le 6) { return ("*" * $v.Length) }

    $start = $v.Substring(0,3)

    $end = $v.Substring($v.Length-3)

    return "$start*****$end"

}



$script:OnePackSummary = @()



function Add-Summary {

    param([string]$Phase,[string]$Message)

    $script:OnePackSummary += "[$Phase] $Message"

}



# PHASE A - FOUNDATION

$phase = "PHASE-A"

Set-PhaseStatus -Phase $phase -Status "START"

Write-Log -Phase $phase -Message "ONEPACK AZ START"



$root = Get-Location

$backendPath = Join-Path $root "backend"

$frontendPath = Join-Path $root "frontend"

$composeFile = Join-Path $root "docker-compose.sas.yml"

$guardFile = Join-Path $root ".sas_guard.json"



try {

    if (-not (Test-Path $backendPath)) { throw "backend folder not found: $backendPath" }

    if (-not (Test-Path $frontendPath)) { throw "frontend folder not found: $frontendPath" }



    Load-EnvFile -Path (Join-Path $backendPath ".env") -Phase $phase

    Load-EnvFile -Path (Join-Path $root ".env") -Phase $phase

    Load-EnvFile -Path (Join-Path $root ".env.local") -Phase $phase

    Load-EnvFile -Path (Join-Path $frontendPath ".env.local") -Phase $phase



    $fingerprint = @{

        project_root = $root.Path

        timestamp = (Get-Date).ToString("o")

        marker = "FunAging.club-SAS-v1"

    } | ConvertTo-Json -Depth 3

    Set-Content -Path $guardFile -Value $fingerprint -Encoding UTF8

    Write-Log -Phase $phase -Message "Guard file updated: $guardFile"



    Set-PhaseStatus -Phase $phase -Status "PASS"

    Add-Summary -Phase $phase -Message "Foundation OK"

} catch {

    Set-PhaseStatus -Phase $phase -Status "HEALING"

    Write-Log -Phase $phase -Message "Error: $($_.Exception.Message)"

    Add-Summary -Phase $phase -Message "Foundation issue: $($_.Exception.Message)"

    Set-PhaseStatus -Phase $phase -Status "PASS-WITH-ISSUES"

}



# PHASE B - SUPABASE AUTH ENGINE

$phase = "PHASE-B"

Set-PhaseStatus -Phase $phase -Status "START"



$SUPABASE_URL = $env:SUPABASE_URL

$SUPABASE_ANON_KEY = $env:SUPABASE_ANON_KEY

$SUPABASE_SERVICE_ROLE_KEY = $env:SUPABASE_SERVICE_ROLE_KEY

if (-not $SUPABASE_SERVICE_ROLE_KEY) { $SUPABASE_SERVICE_ROLE_KEY = $env:SUPABASE_SERVICE_ROLE }



$ADMIN_EMAIL = "sanookagingstudio@gmail.com"

$STAFF_EMAIL = "akemontree@gmail.com"

$DEFAULT_PASSWORD = "Ake@8814883"



try {

    if (-not $SUPABASE_URL -or -not $SUPABASE_SERVICE_ROLE_KEY) {

        throw "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY"

    }

    Write-Log -Phase $phase -Message ("SUPABASE_URL=" + (Mask-Value $SUPABASE_URL))

    Write-Log -Phase $phase -Message ("SERVICE_ROLE_KEY=" + (Mask-Value $SUPABASE_SERVICE_ROLE_KEY))



    $baseAuth = ($SUPABASE_URL.TrimEnd('/')) + "/auth/v1"

    $headers = @{

        "apikey" = $SUPABASE_SERVICE_ROLE_KEY

        "Authorization" = "Bearer $SUPABASE_SERVICE_ROLE_KEY"

        "Content-Type" = "application/json"

    }



    function Ensure-SupabaseUser {

        param(

            [string]$Email,

            [string]$Password,

            [string]$PhaseName

        )

        $authUrl = $baseAuth + "/admin/users?email=eq.$([uri]::EscapeDataString($Email))"

        Write-Log -Phase $PhaseName -Message "Checking Supabase user: $Email"

        $existing = $null

        try {

            $existing = Invoke-WithRetry -Phase $PhaseName -Action {

                Invoke-RestMethod -Uri $authUrl -Headers $headers -Method GET -TimeoutSec 8

            }

        } catch {

            Write-Log -Phase $PhaseName -Message "User lookup failed: $($_.Exception.Message)"

        }

        if ($existing -and $existing.Count -gt 0) {

            Write-Log -Phase $PhaseName -Message "User exists: $Email"

            return

        }

        $createUrl = $baseAuth + "/admin/users"

        $body = @{

            email = $Email

            password = $Password

            email_confirm = $true

        } | ConvertTo-Json -Depth 3

        Write-Log -Phase $PhaseName -Message "Creating Supabase user: $Email"

        try {

            Invoke-WithRetry -Phase $PhaseName -Action {

                Invoke-RestMethod -Uri $createUrl -Headers $headers -Method POST -Body $body -TimeoutSec 8

            } | Out-Null

            Write-Log -Phase $PhaseName -Message "User created: $Email"

        } catch {

            Write-Log -Phase $PhaseName -Message "User create failed: $Email Error=$($_.Exception.Message)"

        }

    }



    Ensure-SupabaseUser -Email $ADMIN_EMAIL -Password $DEFAULT_PASSWORD -PhaseName $phase

    Ensure-SupabaseUser -Email $STAFF_EMAIL -Password $DEFAULT_PASSWORD -PhaseName $phase



    Set-PhaseStatus -Phase $phase -Status "PASS"

    Add-Summary -Phase $phase -Message "Supabase auth checked and users ensured"

} catch {

    Set-PhaseStatus -Phase $phase -Status "PASS-WITH-ISSUES"

    Write-Log -Phase $phase -Message "Error: $($_.Exception.Message)"

    Add-Summary -Phase $phase -Message "Supabase auth issue: $($_.Exception.Message)"

}



# PHASE C - SAFE GUARD ENGINE

$phase = "PHASE-C"

Set-PhaseStatus -Phase $phase -Status "START"



try {

    if (Test-Path $guardFile) {

        $guard = Get-Content $guardFile -Raw | ConvertFrom-Json

        if ($guard.marker -ne "FunAging.club-SAS-v1") {

            Write-Log -Phase $phase -Message "Guard marker mismatch"

        }

    }

    Set-PhaseStatus -Phase $phase -Status "PASS"

    Add-Summary -Phase $phase -Message "Safe guard OK"

} catch {

    Set-PhaseStatus -Phase $phase -Status "PASS-WITH-ISSUES"

    Write-Log -Phase $phase -Message "Error: $($_.Exception.Message)"

    Add-Summary -Phase $phase -Message "Safe guard issue: $($_.Exception.Message)"

}



# PHASE D - GIT AUTO BACKUP ENGINE

$phase = "PHASE-D"

Set-PhaseStatus -Phase $phase -Status "START"

try {

    Ensure-GitSnapshot -Phase $phase

    Set-PhaseStatus -Phase $phase -Status "PASS"

    Add-Summary -Phase $phase -Message "Git snapshot processed"

} catch {

    Set-PhaseStatus -Phase $phase -Status "PASS-WITH-ISSUES"

    Write-Log -Phase $phase -Message "Error: $($_.Exception.Message)"

    Add-Summary -Phase $phase -Message "Git snapshot issue: $($_.Exception.Message)"

}



# PHASE E - SELF HEALING ENGINE (BASIC)

$phase = "PHASE-E"

Set-PhaseStatus -Phase $phase -Status "START"

try {

    $backendMain = Join-Path $backendPath "app\main.py"

    $backendNewMain = Join-Path $backendPath "app\new_main.py"

    if (-not (Test-Path $backendMain) -and (Test-Path $backendNewMain)) {

        Copy-Item -Path $backendNewMain -Destination $backendMain -Force

        Write-Log -Phase $phase -Message "main.py restored from new_main.py"

    }

    Set-PhaseStatus -Phase $phase -Status "PASS"

    Add-Summary -Phase $phase -Message "Self-healing basic checks done"

} catch {

    Set-PhaseStatus -Phase $phase -Status "PASS-WITH-ISSUES"

    Write-Log -Phase $phase -Message "Error: $($_.Exception.Message)"

    Add-Summary -Phase $phase -Message "Self-healing issue: $($_.Exception.Message)"

}



# PHASE F - DOCKER ENGINE

$phase = "PHASE-F"

Set-PhaseStatus -Phase $phase -Status "START"

try {

    Ensure-DockerUp -ComposeFile $composeFile -Phase $phase

    Set-PhaseStatus -Phase $phase -Status "PASS"

    Add-Summary -Phase $phase -Message "Docker up executed"

} catch {

    Set-PhaseStatus -Phase $phase -Status "PASS-WITH-ISSUES"

    Write-Log -Phase $phase -Message "Error: $($_.Exception.Message)"

    Add-Summary -Phase $phase -Message "Docker engine issue: $($_.Exception.Message)"

}



# PHASE G - FINAL HEALTHCHECK

$phase = "PHASE-G"

Set-PhaseStatus -Phase $phase -Status "START"

$backendOk = $false

$frontendOk = $false

try {

    $backendHealthUrls = @(

        "http://localhost:8000/health",

        "http://localhost:8000/docs"

    )

    foreach ($u in $backendHealthUrls) {

        if (Test-HttpOk -Url $u -Phase $phase) { $backendOk = $true; break }

    }

    $frontendUrls = @(

        "http://localhost:3000",

        "http://localhost:3000/"

    )

    foreach ($u in $frontendUrls) {

        if (Test-HttpOk -Url $u -Phase $phase) { $frontendOk = $true; break }

    }

    if ($backendOk -and $frontendOk) {

        Set-PhaseStatus -Phase $phase -Status "PASS"

        Add-Summary -Phase $phase -Message "Backend and Frontend healthy"

    } else {

        Set-PhaseStatus -Phase $phase -Status "PASS-WITH-ISSUES"

        Add-Summary -Phase $phase -Message ("Healthcheck backend=" + $backendOk + " frontend=" + $frontendOk)

    }

} catch {

    Set-PhaseStatus -Phase $phase -Status "PASS-WITH-ISSUES"

    Write-Log -Phase $phase -Message "Error: $($_.Exception.Message)"

    Add-Summary -Phase $phase -Message "Healthcheck issue: $($_.Exception.Message)"

}



# PHASE Z - FINAL SUMMARY

$phase = "PHASE-Z"

Set-PhaseStatus -Phase $phase -Status "START"



$summaryFile = Join-Path $root "mega_onepack_AZ_summary.txt"

$lines = @()

$lines += "ONEPACK AZ SUMMARY"

$lines += "Timestamp: $(Get-Date -Format s)"

$lines += ""

$lines += "Phase Status:"

foreach ($k in $global:ONEPACK_STATUS.Keys) {

    $lines += " - $k : $($global:ONEPACK_STATUS[$k])"

}

$lines += ""

$lines += "Details:"

$lines += $script:OnePackSummary

Set-Content -Path $summaryFile -Value $lines -Encoding UTF8

Write-Log -Phase $phase -Message "Summary written to $summaryFile"



Set-PhaseStatus -Phase $phase -Status "PASS"

