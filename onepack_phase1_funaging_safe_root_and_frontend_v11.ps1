$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FUNAGING PHASE 1 - SAFE ROOT & FRONTEND" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Initialize report variables
$report = @{
    ROOT_HAS_PACKAGE_JSON = $false
    ROOT_HAS_NODE_MODULES = $false
    ROOT_HAS_VITE_CONFIG = $false
    ROOT_HAS_NPM_GUARD_FILES = @()
    FRONTEND_HAS_PACKAGE_JSON = $false
    ROOT_PACKAGE_JSON_BACKED_UP = $false
    ROOT_NODE_MODULES_RENAMED = $false
    ROOT_VITE_FILES_QUARANTINED = @()
    NPM_GUARD_INSTALLED = $false
    FRONTEND_DEV_SCRIPT_LOOKS_VALID = $false
    NEXT_CONFIG_STATUS = "unknown"
    DEV_SERVER_STARTED = $false
    DEV_SERVER_ERRORS = ""
}

# Function helpers
function Write-Step { param([string]$Message) Write-Host "[STEP] $Message" -ForegroundColor Yellow }
function Write-Ok { param([string]$Message) Write-Host "[ OK ] $Message" -ForegroundColor Green }
function Write-Warn { param([string]$Message) Write-Host "[WARN] $Message" -ForegroundColor Magenta }
function Write-Err { param([string]$Message) Write-Host "[FAIL] $Message" -ForegroundColor Red }

# Ensure we're at repo root
Write-Step "Detect repository root"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir
$repoRoot = Get-Location
Write-Ok "Repo root = $repoRoot"

# ========================================
# PHASE A — SAFETY & ENVIRONMENT CHECK
# ========================================
Write-Host ""
Write-Host "=== PHASE A: SAFETY & ENVIRONMENT CHECK ===" -ForegroundColor Cyan

# Check root package.json
if (Test-Path "package.json") {
    $report.ROOT_HAS_PACKAGE_JSON = $true
    Write-Warn "Found root package.json"
} else {
    Write-Ok "No root package.json found"
}

# Check root node_modules
if (Test-Path "node_modules") {
    $report.ROOT_HAS_NODE_MODULES = $true
    Write-Warn "Found root node_modules"
} else {
    Write-Ok "No root node_modules found"
}

# Check vite.config.*
$viteConfigs = @(Get-ChildItem -Path "." -Filter "vite.config.*" -ErrorAction SilentlyContinue)
if ($viteConfigs.Count -gt 0) {
    $report.ROOT_HAS_VITE_CONFIG = $true
    Write-Warn "Found Vite config files: $($viteConfigs.Name -join ', ')"
} else {
    Write-Ok "No Vite config files found"
}

# Check index.html
if (Test-Path "index.html") {
    Write-Warn "Found root index.html"
} else {
    Write-Ok "No root index.html found"
}

# Check npm guard files
$npmGuards = @()
if (Test-Path "npm") { $npmGuards += "npm" }
if (Test-Path "npm.cmd") { $npmGuards += "npm.cmd" }
$report.ROOT_HAS_NPM_GUARD_FILES = $npmGuards
if ($npmGuards.Count -gt 0) {
    Write-Ok "Found npm guard files: $($npmGuards -join ', ')"
} else {
    Write-Warn "No npm guard files found"
}

# Check frontend package.json
$frontendPackageJson = Join-Path "frontend" "package.json"
if (Test-Path $frontendPackageJson) {
    $report.FRONTEND_HAS_PACKAGE_JSON = $true
    Write-Ok "Found frontend/package.json"
} else {
    Write-Err "frontend/package.json NOT FOUND"
}

# Print SCAN SUMMARY
Write-Host ""
Write-Host "=== SCAN SUMMARY ===" -ForegroundColor Cyan
Write-Host "ROOT_HAS_PACKAGE_JSON: $($report.ROOT_HAS_PACKAGE_JSON)"
Write-Host "ROOT_HAS_NODE_MODULES: $($report.ROOT_HAS_NODE_MODULES)"
Write-Host "ROOT_HAS_VITE_CONFIG: $($report.ROOT_HAS_VITE_CONFIG)"
Write-Host "ROOT_HAS_NPM_GUARD_FILES: $($report.ROOT_HAS_NPM_GUARD_FILES -join ', ')"
Write-Host "FRONTEND_HAS_PACKAGE_JSON: $($report.FRONTEND_HAS_PACKAGE_JSON)"
Write-Host ""

# ========================================
# PHASE B — CLEAN ROOT (NON-DESTRUCTIVE)
# ========================================
Write-Host "=== PHASE B: CLEAN ROOT ===" -ForegroundColor Cyan

# Backup and remove root package.json if exists
if ($report.ROOT_HAS_PACKAGE_JSON) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupName = "package.json.bak_$timestamp"
    if (-not (Test-Path $backupName)) {
        Copy-Item "package.json" $backupName
        Remove-Item "package.json"
        $report.ROOT_PACKAGE_JSON_BACKED_UP = $true
        Write-Ok "Backed up and removed root package.json -> $backupName"
    } else {
        Write-Warn "Backup already exists: $backupName"
        $report.ROOT_PACKAGE_JSON_BACKED_UP = $true
    }
}

# Rename root node_modules if exists
if ($report.ROOT_HAS_NODE_MODULES) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupName = "node_modules_BACKUP_$timestamp"
    if (-not (Test-Path $backupName)) {
        Rename-Item "node_modules" $backupName
        $report.ROOT_NODE_MODULES_RENAMED = $true
        Write-Ok "Renamed root node_modules -> $backupName"
    } else {
        Write-Warn "Backup folder already exists: $backupName"
        $report.ROOT_NODE_MODULES_RENAMED = $true
    }
}

# Backup Vite config files
$viteFiles = @(Get-ChildItem -Path "." -Filter "vite.config.*" -ErrorAction SilentlyContinue)
foreach ($file in $viteFiles) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupName = "$($file.Name).bak_$timestamp"
    if (-not (Test-Path $backupName)) {
        Copy-Item $file.FullName $backupName
        Remove-Item $file.FullName
        $report.ROOT_VITE_FILES_QUARANTINED += $file.Name
        Write-Ok "Backed up and removed $($file.Name) -> $backupName"
    } else {
        Write-Warn "Backup already exists: $backupName"
        $report.ROOT_VITE_FILES_QUARANTINED += $file.Name
    }
}

# Backup root index.html if it looks like Vite template
if (Test-Path "index.html") {
    $indexContent = Get-Content "index.html" -Raw
    if ($indexContent -match "vite|/src/main\.tsx|/src/main\.jsx") {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupName = "index.html.bak_$timestamp"
        if (-not (Test-Path $backupName)) {
            Copy-Item "index.html" $backupName
            Remove-Item "index.html"
            $report.ROOT_VITE_FILES_QUARANTINED += "index.html"
            Write-Ok "Backed up and removed root index.html -> $backupName"
        } else {
            Write-Warn "Backup already exists: $backupName"
            $report.ROOT_VITE_FILES_QUARANTINED += "index.html"
        }
    } else {
        Write-Ok "Root index.html doesn't look like Vite template, keeping it"
    }
}

# Create/enforce NPM GUARD
$npmGuardContent = @'
echo "⛔ ERROR: Do NOT run npm here. Use: cd frontend && npm run dev"
exit 1
'@

if (-not (Test-Path "npm") -or (Get-Content "npm" -Raw) -ne $npmGuardContent) {
    Set-Content -Path "npm" -Value $npmGuardContent -Encoding UTF8
    Write-Ok "Created/updated npm guard file"
}

if (-not (Test-Path "npm.cmd") -or (Get-Content "npm.cmd" -Raw) -ne $npmGuardContent) {
    Set-Content -Path "npm.cmd" -Value $npmGuardContent -Encoding UTF8
    Write-Ok "Created/updated npm.cmd guard file"
}

$report.NPM_GUARD_INSTALLED = $true

# Print ROOT_CLEANUP_SUMMARY
Write-Host ""
Write-Host "=== ROOT_CLEANUP_SUMMARY ===" -ForegroundColor Cyan
Write-Host "ROOT_PACKAGE_JSON_BACKED_UP: $($report.ROOT_PACKAGE_JSON_BACKED_UP)"
Write-Host "ROOT_NODE_MODULES_RENAMED: $($report.ROOT_NODE_MODULES_RENAMED)"
Write-Host "ROOT_VITE_FILES_QUARANTINED: $($report.ROOT_VITE_FILES_QUARANTINED -join ', ')"
Write-Host "NPM_GUARD_INSTALLED: $($report.NPM_GUARD_INSTALLED)"
Write-Host ""

# ========================================
# PHASE C — FRONTEND NEXT.JS VALIDATION
# ========================================
Write-Host "=== PHASE C: FRONTEND VALIDATION ===" -ForegroundColor Cyan

if (-not $report.FRONTEND_HAS_PACKAGE_JSON) {
    Write-Err "Cannot proceed: frontend/package.json is missing"
    $report.FRONTEND_DEV_SCRIPT_LOOKS_VALID = $false
    $report.NEXT_CONFIG_STATUS = "error_missing_package_json"
} else {
    # Inspect frontend package.json
    $frontendPkg = Get-Content $frontendPackageJson | ConvertFrom-Json
    if ($frontendPkg.scripts -and $frontendPkg.scripts.dev) {
        $devScript = $frontendPkg.scripts.dev
        if ($devScript -match "next dev") {
            $report.FRONTEND_DEV_SCRIPT_LOOKS_VALID = $true
            Write-Ok "Frontend dev script looks valid: $devScript"
        } else {
            Write-Warn "Frontend dev script may be invalid: $devScript"
            $report.FRONTEND_DEV_SCRIPT_LOOKS_VALID = $false
        }
    } else {
        Write-Warn "Frontend package.json missing 'dev' script"
        $report.FRONTEND_DEV_SCRIPT_LOOKS_VALID = $false
    }

    # Check next.config.js
    $nextConfigPath = Join-Path "frontend" "next.config.js"
    if (Test-Path $nextConfigPath) {
        $nextConfigContent = Get-Content $nextConfigPath -Raw
        # Check for deprecated experimental flags
        if ($nextConfigContent -match "experimental\.(serverActions|turbo)\s*=\s*true") {
            Write-Warn "next.config.js contains deprecated experimental flags"
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backupName = "next.config.js.bak_$timestamp"
            Copy-Item $nextConfigPath $backupName
            $cleanConfig = @'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: false,
  swcMinify: true,
  images: {
    domains: [
      "localhost",
      "127.0.0.1",
      "lh3.googleusercontent.com",
      "images.unsplash.com",
      "cdn.jsdelivr.net"
    ]
  }
};

module.exports = nextConfig;
'@
            Set-Content -Path $nextConfigPath -Value $cleanConfig -Encoding UTF8
            $report.NEXT_CONFIG_STATUS = "backed_up_and_rewritten"
            Write-Ok "Cleaned next.config.js (backup: $backupName)"
        } elseif ($nextConfigContent -match "reactStrictMode|swcMinify|images") {
            $report.NEXT_CONFIG_STATUS = "ok"
            Write-Ok "next.config.js looks valid"
        } else {
            $report.NEXT_CONFIG_STATUS = "suspicious_but_kept"
            Write-Warn "next.config.js exists but content is unusual (kept as-is)"
        }
    } else {
        Write-Warn "next.config.js not found in frontend"
        $report.NEXT_CONFIG_STATUS = "missing"
    }

    # Run npm install in frontend
    Write-Step "Running npm install in frontend"
    Push-Location "frontend"
    try {
        $installOutput = & npm install 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "npm install completed successfully"
        } else {
            Write-Warn "npm install had warnings (exit code: $LASTEXITCODE)"
        }
    } catch {
        Write-Err "npm install failed: $($_.Exception.Message)"
        $report.DEV_SERVER_ERRORS = "npm install failed: $($_.Exception.Message)"
    }
    Pop-Location

    # Start dev server (non-blocking)
    Write-Step "Starting frontend dev server"
    Push-Location "frontend"
    try {
        # Start dev server in background
        $devProcess = Start-Process -FilePath "pwsh" -ArgumentList "-NoExit", "-Command", "npm run dev" -PassThru -WindowStyle Hidden
        Write-Ok "Dev server process started (PID: $($devProcess.Id))"
        
        # Wait a bit for server to start
        Start-Sleep -Seconds 8
        
        # Check if process is still running
        $stillRunning = Get-Process -Id $devProcess.Id -ErrorAction SilentlyContinue
        if ($stillRunning) {
            # Try to check if port 3000 is listening
            $portCheck = Test-NetConnection -ComputerName localhost -Port 3000 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
            if ($portCheck.TcpTestSucceeded) {
                $report.DEV_SERVER_STARTED = $true
                Write-Ok "Dev server appears to be running on port 3000"
            } else {
                Write-Warn "Dev server process running but port 3000 not yet accessible"
            }
        } else {
            Write-Warn "Dev server process may have exited"
        }
    } catch {
        Write-Err "Failed to start dev server: $($_.Exception.Message)"
        $report.DEV_SERVER_ERRORS = "Failed to start: $($_.Exception.Message)"
    }
    Pop-Location
}

# ========================================
# PHASE D — FINAL STATUS REPORT
# ========================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "=== FUNAGING PHASE 1 STATUS REPORT ===" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "ROOT_STATUS:" -ForegroundColor Yellow
Write-Host "- ROOT_HAS_PACKAGE_JSON_AFTER_CLEAN: $(-not (Test-Path 'package.json'))"
Write-Host "- ROOT_HAS_NODE_MODULES_AFTER_CLEAN: $(-not (Test-Path 'node_modules'))"
Write-Host "- ROOT_VITE_FILES_QUARANTINED: $(if ($report.ROOT_VITE_FILES_QUARANTINED.Count -gt 0) { $report.ROOT_VITE_FILES_QUARANTINED -join ', ' } else { 'none' })"
Write-Host "- NPM_GUARD_INSTALLED: $($report.NPM_GUARD_INSTALLED)"
Write-Host ""

Write-Host "FRONTEND_STATUS:" -ForegroundColor Yellow
Write-Host "- FRONTEND_PACKAGE_JSON_EXISTS: $($report.FRONTEND_HAS_PACKAGE_JSON)"
Write-Host "- FRONTEND_DEV_SCRIPT_LOOKS_VALID: $($report.FRONTEND_DEV_SCRIPT_LOOKS_VALID)"
Write-Host "- NEXT_CONFIG_STATUS: $($report.NEXT_CONFIG_STATUS)"
Write-Host ""

Write-Host "DEV_SERVER_STATUS:" -ForegroundColor Yellow
Write-Host "- DEV_SERVER_STARTED: $($report.DEV_SERVER_STARTED)"
Write-Host "- EXPECTED_URL: http://localhost:3000"
Write-Host "- ERROR_SUMMARY: $(if ($report.DEV_SERVER_ERRORS) { $report.DEV_SERVER_ERRORS } else { 'none' })"
Write-Host ""

# Determine READY_FOR_V11
$readyForV11 = $true
$blockingIssues = @()

if (-not $report.FRONTEND_HAS_PACKAGE_JSON) {
    $readyForV11 = $false
    $blockingIssues += "frontend/package.json is missing"
}

if (-not $report.FRONTEND_DEV_SCRIPT_LOOKS_VALID) {
    $readyForV11 = $false
    $blockingIssues += "frontend dev script is invalid or missing"
}

if ($report.DEV_SERVER_ERRORS -and -not $report.DEV_SERVER_STARTED) {
    $readyForV11 = $false
    $blockingIssues += "dev server failed to start: $($report.DEV_SERVER_ERRORS)"
}

Write-Host "READY_FOR_V11:" -ForegroundColor $(if ($readyForV11) { "Green" } else { "Red" })
Write-Host "- $readyForV11"
if (-not $readyForV11) {
    Write-Host "- Blocking issues:" -ForegroundColor Red
    foreach ($issue in $blockingIssues) {
        Write-Host "  • $issue" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "END_OF_REPORT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan



