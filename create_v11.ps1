$ErrorActionPreference = "Stop"

$scriptPath = "mega_onepack_AZ_v11.ps1"

$scriptContent = @'
$ErrorActionPreference = "Stop"

Write-Host "========== MEGA ONEPACK AZ v11 — FRONTEND REPAIR =========="
Write-Host ""

function Write-Step {
    param([string]$Message)
    Write-Host "[STEP] $Message"
}

function Write-Ok {
    param([string]$Message)
    Write-Host "[ OK ] $Message"
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message"
}

function Write-Err {
    param([string]$Message)
    Write-Host "[FAIL] $Message"
}

Write-Step "Detect repository root"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir
$repoRoot = Get-Location
Write-Ok "Repo root = $repoRoot"

$frontendPath = Join-Path $repoRoot "frontend"
if (-not (Test-Path $frontendPath)) {
    Write-Err "frontend folder not found at $frontendPath"
    exit 1
}
Write-Ok "Found frontend folder: $frontendPath"

$packageJson = Join-Path $frontendPath "package.json"
if (-not (Test-Path $packageJson)) {
    Write-Err "package.json not found in frontend. Cannot start dev server."
    exit 1
}
Write-Ok "package.json found"

Write-Step "Check existing node / npm processes"
try {
    $nodeProcs = Get-Process node -ErrorAction SilentlyContinue
    if ($nodeProcs) {
        Write-Warn ("Existing node processes detected: " + ($nodeProcs.Id -join ", "))
    } else {
        Write-Ok "No existing node processes detected (or not accessible)"
    }
} catch {
    Write-Warn "Unable to query node processes (non-critical)."
}

Write-Step "Locate npm command"
$npmCmd = $null

try {
    $cmd = Get-Command npm -ErrorAction SilentlyContinue
    if ($cmd) {
        $npmCmd = $cmd.Source
        Write-Ok "Found npm via Get-Command: $npmCmd"
    } else {
        Write-Warn "npm not found via Get-Command. Trying common paths..."
    }
} catch {
    Write-Warn "Get-Command npm failed. Trying common paths..."
}

if (-not $npmCmd) {
    $commonPaths = @(
        "$env:ProgramFiles\nodejs\npm.cmd",
        "$env:ProgramFiles\nodejs\npm.exe",
        "$env:ProgramFiles(x86)\nodejs\npm.cmd",
        "$env:ProgramFiles(x86)\nodejs\npm.exe",
        "$env:LOCALAPPDATA\Programs\nodejs\npm.cmd",
        "$env:LOCALAPPDATA\Programs\nodejs\npm.exe"
    )

    foreach ($p in $commonPaths) {
        if (Test-Path $p) {
            $npmCmd = $p
            Write-Ok "Found npm at common path: $npmCmd"
            break
        }
    }
}

if (-not $npmCmd) {
    $localNpmCli = Join-Path $frontendPath "node_modules\npm\bin\npm-cli.js"
    if (Test-Path $localNpmCli) {
        $npmCmd = "node `"$localNpmCli`""
        Write-Ok "Using local npm-cli via node: $npmCmd"
    }
}

if (-not $npmCmd) {
    Write-Err "Unable to locate npm. Please ensure Node.js/npm is installed and in PATH."
    exit 1
}

Write-Step "Start frontend dev server via pwsh wrapper"
$frontendCommand = "cd `"$frontendPath`"; & `"$npmCmd`" run dev"

try {
    $pwshCmd = (Get-Command pwsh -ErrorAction SilentlyContinue)
    if ($pwshCmd) {
        Write-Ok "Using pwsh to start dev server"
        Start-Process -FilePath $pwshCmd.Source -ArgumentList "-NoExit", "-Command", $frontendCommand | Out-Null
    } else {
        Write-Warn "pwsh not found. Falling back to powershell."
        Start-Process -FilePath "powershell.exe" -ArgumentList "-NoExit", "-Command", $frontendCommand | Out-Null
    }
    Write-Ok "Frontend dev server start command dispatched."
} catch {
    Write-Err ("Failed to start frontend dev server: " + $_.Exception.Message)
    exit 1
}

Write-Step "Final summary"
Write-Ok "Backend was not modified by this script."
Write-Ok "Frontend dev server should be starting in a new terminal window."
Write-Ok "Open http://localhost:3000 to verify the site."
Write-Host ""
Write-Host "========== MEGA ONEPACK AZ v11 — DONE =========="
'@

Set-Content -Path $scriptPath -Value $scriptContent -Encoding UTF8

Write-Host "Created $scriptPath"
Write-Host "Running $scriptPath ..."
Write-Host ""

pwsh -File $scriptPath









