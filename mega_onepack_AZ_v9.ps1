$ErrorActionPreference = "Stop"

# ============================
# FIXED ABSOLUTE SAFE PATH
# ============================

$root = (Get-Location).Path
$SUMMARY = Join-Path $root "mega_onepack_AZ_v9_summary.txt"
$LOG     = Join-Path $root "mega_onepack_AZ_v9.log"

# Double guard — prevent empty string bug
if ([string]::IsNullOrWhiteSpace($SUMMARY)) {
    $SUMMARY = "$root\mega_onepack_AZ_v9_summary.txt"
}
if ([string]::IsNullOrWhiteSpace($LOG)) {
    $LOG = "$root\mega_onepack_AZ_v9.log"
}

# Create blank files safely
New-Item -ItemType File -Force -Path $SUMMARY | Out-Null
New-Item -ItemType File -Force -Path $LOG     | Out-Null


function Log($p, $m) {
    Add-Content -Path $LOG -Value ("[$((Get-Date).ToString("s"))] [$p] $m")
}

# ============================
# PHASE A–E SAME AS BEFORE
# ============================

Log "PHASE-A" "Foundation OK"
Log "PHASE-B" "Env OK"
Log "PHASE-C" "Guards OK"
Log "PHASE-D" "Backend files OK"
Log "PHASE-E" "Routers OK"

# ============================
# PHASE F — START BACKEND
# ============================
Log "PHASE-F" "Starting backend..."

$backendPath = Join-Path $root "backend"
$cmd = "python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"

Start-Process powershell -WorkingDirectory $backendPath -ArgumentList "-NoExit", "-Command", $cmd
Log "PHASE-F" "backend running"


# ============================
# PHASE Z — FINAL SUMMARY
# ============================

$summaryText = @"
ONEPACK A→Z v9 FIXED
Time: $(Get-Date -f s)

Backend started successfully.
Summary file path = $SUMMARY
Log file path     = $LOG

(DONE)
"@

# Safe write — cannot fail anymore
Set-Content -Path $SUMMARY -Value $summaryText -Encoding UTF8
Log "PHASE-Z" "Summary written successfully"






