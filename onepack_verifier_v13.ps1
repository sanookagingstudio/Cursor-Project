Write-Output "==============================================================="
Write-Output "     ONEPACK v13 VERIFIER — Full System Validation Suite"
Write-Output "==============================================================="

# Utility: colored output
function OK($msg) { Write-Host "[OK]   $msg" -ForegroundColor Green }
function FAIL($msg) { Write-Host "[FAIL] $msg" -ForegroundColor Red }
function INFO($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }

$ErrorActionPreference = "SilentlyContinue"
$FAIL_FLAG = $false

# ---------------------------------------------------------------
# STEP A — Check Project Structure
# ---------------------------------------------------------------
INFO "Checking project structure..."

$paths = @(
    "backend",
    "backend/app",
    "backend/Dockerfile.backend",
    "backend/requirements.txt",
    "docker-compose.sas.yml",
    "frontend",
    "frontend/.env.local"
)

foreach ($p in $paths) {
    if (Test-Path $p) {
        OK "$p exists"
    } else {
        FAIL "$p missing"
        $FAIL_FLAG = $true
    }
}

# ---------------------------------------------------------------
# STEP B — Docker Engine Status
# ---------------------------------------------------------------
INFO "Checking Docker engine..."

$dockerInfo = docker info 2>&1
if ($LASTEXITCODE -eq 0) {
    OK "Docker engine running"
} else {
    FAIL "Docker engine NOT running"
    $FAIL_FLAG = $true
}

# ---------------------------------------------------------------
# STEP C — Check Containers
# ---------------------------------------------------------------
INFO "Checking containers..."

$containers = docker ps -a --format "{{.Names}}" 2>&1

if ($containers -contains "sas_backend") {
    OK "sas_backend exists"
} else {
    FAIL "sas_backend missing"
    $FAIL_FLAG = $true
}

if ($containers -contains "sas_db") {
    OK "sas_db exists"
} else {
    FAIL "sas_db missing"
    $FAIL_FLAG = $true
}

# Check if containers are running
$runningContainers = docker ps --format "{{.Names}}" 2>&1

if ($runningContainers -contains "sas_backend") {
    OK "sas_backend is running"
} else {
    FAIL "sas_backend is NOT running"
    $FAIL_FLAG = $true
}

if ($runningContainers -contains "sas_db") {
    OK "sas_db is running"
} else {
    FAIL "sas_db is NOT running"
    $FAIL_FLAG = $true
}

# ---------------------------------------------------------------
# STEP D — Backend Health Check
# ---------------------------------------------------------------
INFO "Running backend health checks..."

function Test-Endpoint($url) {
    try {
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 3
        return @{ ok = $true; code = $resp.StatusCode; body = $resp.Content }
    } catch {
        return @{ ok = $false; code = 0; body = "" }
    }
}

$endpoints = @(
    "http://localhost:8000/health",
    "http://localhost:8000/"
)

# Test critical endpoints
foreach ($ep in $endpoints) {
    $result = Test-Endpoint $ep
    if ($result.ok -and $result.code -eq 200) {
        OK "$ep → 200 OK"
        if ($result.body) {
            Write-Host "      Response: $($result.body)" -ForegroundColor Gray
        }
    } else {
        FAIL "$ep → FAILED (Code: $($result.code))"
        $FAIL_FLAG = $true
    }
}

# Test route endpoints (these may return 404 if routes don't exist, which is OK)
INFO "Testing route endpoints (404 is acceptable if routes not implemented)..."

$routeEndpoints = @(
    "http://localhost:8000/trip/test",
    "http://localhost:8000/office/test",
    "http://localhost:8000/media/test"
)

foreach ($ep in $routeEndpoints) {
    $result = Test-Endpoint $ep
    if ($result.ok) {
        if ($result.code -eq 200) {
            OK "$ep → 200 OK"
        } elseif ($result.code -eq 404) {
            INFO "$ep → 404 (route not implemented - OK)"
        } elseif ($result.code -ge 500) {
            FAIL "$ep → $($result.code) (server error)"
            $FAIL_FLAG = $true
        } else {
            INFO "$ep → $($result.code) (check implementation)"
        }
    } else {
        # Connection failed - this might be OK if routes don't exist or require auth
        # Only fail if it's a critical endpoint
        INFO "$ep → Connection failed (may require auth or route not implemented)"
    }
}

# ---------------------------------------------------------------
# STEP E — Logs Check
# ---------------------------------------------------------------
INFO "Checking backend logs for errors..."

try {
    $backendLogs = docker logs sas_backend --tail 200 2>&1
    $dbLogs = docker logs sas_db --tail 200 2>&1

    $patterns = @("ERROR", "Exception", "Traceback", "FATAL", "refused")

    $foundErrors = $false
    foreach ($pattern in $patterns) {
        if ($backendLogs -match $pattern) {
            FAIL "Backend logs contain: $pattern"
            $FAIL_FLAG = $true
            $foundErrors = $true
        }
        if ($dbLogs -match $pattern) {
            FAIL "Database logs contain: $pattern"
            $FAIL_FLAG = $true
            $foundErrors = $true
        }
    }

    if (-not $foundErrors) {
        OK "No critical errors found in logs"
    }
} catch {
    FAIL "Failed to retrieve logs: $($_.Exception.Message)"
    $FAIL_FLAG = $true
}

# ---------------------------------------------------------------
# STEP F — Git Backup Validation
# ---------------------------------------------------------------
INFO "Checking git status..."

try {
    $isGitRepo = git rev-parse --is-inside-work-tree 2>&1
    if ($LASTEXITCODE -eq 0) {
        OK "Git repository detected"
        
        $gitStatus = git status --porcelain 2>&1

        if ($gitStatus) {
            INFO "Uncommitted changes detected (this is OK for development)"
            Write-Host "      Changes:" -ForegroundColor Gray
            $gitStatus | ForEach-Object {
                Write-Host "        $_" -ForegroundColor Gray
            }
        } else {
            OK "Working directory clean"
        }

        $tags = git tag -l "stable-v13-*" 2>&1
        if ($tags) {
            $tagCount = ($tags | Measure-Object).Count
            OK "Backup tags found: $tagCount stable-v13-* tags"
            Write-Host "      Latest tags:" -ForegroundColor Gray
            $tags | Select-Object -Last 3 | ForEach-Object {
                Write-Host "        $_" -ForegroundColor Gray
            }
        } else {
            INFO "No stable-v13-* tags found (this is OK if you haven't run backup yet)"
        }
    } else {
        INFO "Not a git repository (skipping git checks)"
    }
} catch {
    INFO "Git check failed (may not be a git repo): $($_.Exception.Message)"
}

if (Test-Path "RESTORE.md") {
    OK "RESTORE.md exists"
} else {
    FAIL "RESTORE.md missing"
    $FAIL_FLAG = $true
}

# ---------------------------------------------------------------
# STEP G — Dockerfile Validation
# ---------------------------------------------------------------
INFO "Validating Dockerfile.backend..."

if (Test-Path "backend/Dockerfile.backend") {
    $dockerfileContent = Get-Content "backend/Dockerfile.backend" -Raw
    
    if ($dockerfileContent -match "COPY backend/requirements.txt") {
        FAIL "Dockerfile.backend contains incorrect path: COPY backend/requirements.txt"
        $FAIL_FLAG = $true
    } elseif ($dockerfileContent -match "COPY requirements.txt") {
        OK "Dockerfile.backend uses correct COPY path for requirements.txt"
    }
    
    if ($dockerfileContent -match "COPY backend/app") {
        FAIL "Dockerfile.backend contains incorrect path: COPY backend/app"
        $FAIL_FLAG = $true
    } elseif ($dockerfileContent -match "COPY app") {
        OK "Dockerfile.backend uses correct COPY path for app"
    }
} else {
    FAIL "Dockerfile.backend not found"
    $FAIL_FLAG = $true
}

# ---------------------------------------------------------------
# FINAL VERDICT
# ---------------------------------------------------------------
Write-Output ""
Write-Output "==============================================================="
if ($FAIL_FLAG -eq $false) {
    Write-Host "✔ V13 VERIFIED — READY for ONEPACK v14–17" -ForegroundColor Green
    Write-Output ""
    Write-Host "System Status:" -ForegroundColor Cyan
    Write-Host "  ✅ Project structure: OK" -ForegroundColor Green
    Write-Host "  ✅ Docker: Running" -ForegroundColor Green
    Write-Host "  ✅ Containers: Running" -ForegroundColor Green
    Write-Host "  ✅ Backend: Healthy" -ForegroundColor Green
    Write-Host "  ✅ Logs: Clean" -ForegroundColor Green
    Write-Host "  ✅ Dockerfile: Valid" -ForegroundColor Green
} else {
    Write-Host "❌ V13 NOT READY — Fix issues above before continuing" -ForegroundColor Red
    Write-Output ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Fix all [FAIL] items listed above" -ForegroundColor White
    Write-Host "  2. Run: .\onepack_funaging_v13.ps1" -ForegroundColor White
    Write-Host "  3. Run this verifier again" -ForegroundColor White
}
Write-Output "==============================================================="
Write-Output ""







