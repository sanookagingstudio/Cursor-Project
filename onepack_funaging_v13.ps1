param(
    [switch]$SkipFrontend
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "      ONEPACK v13 — FunAging.club" -ForegroundColor Cyan
Write-Host "  Auto-Build • Auto-Health • Auto-Backup" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# ---------- PATH ----------
$ProjectRoot = "D:\SanookAgingStudio\shadow project\sanook-master-v2-main"

if (-not (Test-Path $ProjectRoot)) {
    Write-Warning "Project root not found: $ProjectRoot"
    Write-Host "Using current directory instead..." -ForegroundColor Yellow
    $ProjectRoot = Get-Location
}

Set-Location $ProjectRoot
Write-Host "Project root: $ProjectRoot" -ForegroundColor Gray

# ---------- GIT SAFE CHECK ----------
Write-Host "`n[Git] Checking repository status..." -ForegroundColor Yellow

try {
    $isGitRepo = git rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Not a git repository. Skipping git operations."
        $NeedBackup = $false
    } else {
        Write-Host "  Git repository detected" -ForegroundColor Green
        
        $GitChanges = git status --porcelain 2>$null
        $NeedBackup = $false

        if ($GitChanges) {
            Write-Host "  Uncommitted changes detected" -ForegroundColor Yellow
            
            $FilesChanged = $GitChanges | ForEach-Object {
                if ($_.Length -gt 3) {
                    $_.Substring(3)
                }
            }

            foreach ($f in $FilesChanged) {
                if ($f -match "^backend/" -or
                    $f -match "^docker-compose" -or
                    $f -match "^backend/Dockerfile.backend" -or
                    $f -match "^requirements" -or
                    $f -match "^onepack" -or
                    $f -match "^frontend/.env.local") {
                        $NeedBackup = $true
                        Write-Host "    → $f (will be backed up)" -ForegroundColor Gray
                }
            }
        } else {
            Write-Host "  No uncommitted changes" -ForegroundColor Green
        }
    }
} catch {
    Write-Warning "Git check failed: $($_.Exception.Message)"
    $NeedBackup = $false
}

# ---------- RESTORE GUIDE ----------
Write-Host "`n[Restore Guide] Creating RESTORE.md..." -ForegroundColor Yellow

$restore = @'
# RESTORE GUIDE — FunAging.club (ONEPACK v13)

## Quick Restore Steps

1. Fetch all branches and tags:
   git fetch --all
   git fetch --tags

2. Checkout main branch:
   git checkout main
   git pull

3. List available stable tags:
   git tag -l "stable-v13-*"

4. Restore to a specific stable tag:
   git checkout tags/<TAG> -b restore-<TAG>

## Example
git checkout tags/stable-v13-20251212-000330 -b restore-20251212

## View All Tags
git tag -l

## View Tag Details
git show <TAG>
'@

$restore | Out-File "$ProjectRoot\RESTORE.md" -Encoding UTF8 -Force
Write-Host "  ✔ RESTORE.md created" -ForegroundColor Green

# ---------- AUTO FIX DOCKERFILE ----------
Write-Host "`n[Dockerfile] Auto-fixing Dockerfile.backend..." -ForegroundColor Yellow

$Dockerfile = "$ProjectRoot\backend\Dockerfile.backend"
if (Test-Path $Dockerfile) {
    $raw = Get-Content $Dockerfile -Raw
    $fixed = $raw -replace "COPY backend/requirements.txt","COPY requirements.txt"
    $fixed = $fixed -replace "COPY backend/app","COPY app"
    
    if ($raw -ne $fixed) {
        $fixed | Set-Content $Dockerfile -NoNewline
        Write-Host "  ✔ Dockerfile.backend fixed" -ForegroundColor Green
    } else {
        Write-Host "  ✔ Dockerfile.backend already correct" -ForegroundColor Green
    }
} else {
    Write-Warning "  Dockerfile.backend not found"
}

# ---------- DIAGNOSTIC ----------
Write-Host "`n[Diagnostic] Checking project structure..." -ForegroundColor Yellow

$diagFail = $false

if (!(Test-Path "$ProjectRoot\backend\app\main.py")) {
    Write-Host "  ❌ Missing backend/app/main.py" -ForegroundColor Red
    $diagFail = $true
} else {
    Write-Host "  ✔ backend/app/main.py exists" -ForegroundColor Green
}

if (!(Test-Path "$ProjectRoot\docker-compose.sas.yml")) {
    Write-Host "  ❌ Missing docker-compose.sas.yml" -ForegroundColor Red
    $diagFail = $true
} else {
    Write-Host "  ✔ docker-compose.sas.yml exists" -ForegroundColor Green
}

if ($diagFail) {
    Write-Warning "Diagnostic failed. Please fix missing files before continuing."
    exit 1
}

Write-Host "  ✔ Diagnostic OK" -ForegroundColor Green

# ---------- DOCKER BUILD & RUN ----------
Write-Host "`n[Docker] Building and starting containers..." -ForegroundColor Yellow

try {
    Write-Host "  Stopping existing containers..." -ForegroundColor Gray
    docker compose -f docker-compose.sas.yml down 2>&1 | Out-Null
    
    Write-Host "  Building backend image..." -ForegroundColor Gray
    docker compose -f docker-compose.sas.yml build sas_backend
    
    Write-Host "  Starting containers..." -ForegroundColor Gray
    docker compose -f docker-compose.sas.yml up -d
    
    Write-Host "  ✔ Docker stack started" -ForegroundColor Green
} catch {
    Write-Warning "Docker operations failed: $($_.Exception.Message)"
    exit 1
}

Write-Host "  Waiting for services to initialize..." -ForegroundColor Gray
Start-Sleep -Seconds 5

# ---------- HEALTHCHECK ----------
Write-Host "`n[Healthcheck] Testing backend health..." -ForegroundColor Yellow

function Test-Health {
    try {
        $r = Invoke-WebRequest "http://localhost:8000/health" -UseBasicParsing -TimeoutSec 5
        if ($r.StatusCode -eq 200) {
            return $true
        }
    } catch {
        return $false
    }
    return $false
}

$ok = $false
for ($i=1; $i -le 10; $i++) {
    Write-Host "  Attempt $i/10..." -ForegroundColor Gray
    if (Test-Health) {
        $ok = $true
        break
    }
    Start-Sleep -Seconds 2
}

if ($ok) {
    Write-Host "  ✔ Backend HEALTH OK" -ForegroundColor Green
    
    try {
        $healthResponse = Invoke-WebRequest "http://localhost:8000/health" -UseBasicParsing
        Write-Host "    Response: $($healthResponse.Content)" -ForegroundColor Gray
    } catch {}
} else {
    Write-Host "  ❌ Backend FAILED healthcheck" -ForegroundColor Red
    Write-Host "    Check logs: docker logs sas_backend" -ForegroundColor Yellow
}

# ---------- AUTO BACKUP (Mode 1) ----------
if ($ok -and $NeedBackup) {
    Write-Host "`n[Auto-Backup] Creating git backup..." -ForegroundColor Yellow
    
    try {
        Write-Host "  Staging changes..." -ForegroundColor Gray
        git add . 2>&1 | Out-Null
        
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $msg = "AUTO-BACKUP: v13 snapshot $timestamp"
        
        Write-Host "  Committing changes..." -ForegroundColor Gray
        git commit -m "$msg" 2>&1 | Out-Null
        
        $tag = "stable-v13-$timestamp"
        Write-Host "  Creating tag: $tag" -ForegroundColor Gray
        git tag -a $tag -m "$msg" 2>&1 | Out-Null
        
        Write-Host "  Pushing to remote..." -ForegroundColor Gray
        git push 2>&1 | Out-Null
        git push origin $tag 2>&1 | Out-Null
        
        Write-Host "  ✔ AUTO BACKUP COMPLETE → $tag" -ForegroundColor Green
        Write-Host "    Restore with: git checkout tags/$tag -b restore-$timestamp" -ForegroundColor Cyan
    } catch {
        Write-Warning "Git backup failed: $($_.Exception.Message)"
        Write-Host "  You may need to configure git remote or commit manually." -ForegroundColor Yellow
    }
} elseif ($ok -and -not $NeedBackup) {
    Write-Host "`n[Auto-Backup] Skipped (no changes to backup)" -ForegroundColor Gray
} elseif (-not $ok) {
    Write-Host "`n[Auto-Backup] Skipped (backend health check failed)" -ForegroundColor Yellow
}

# ---------- FRONTEND ----------
if (-not $SkipFrontend) {
    Write-Host "`n[Frontend] Setting up frontend environment..." -ForegroundColor Yellow
    
    $envFile = "$ProjectRoot\frontend\.env.local"
    if (!(Test-Path $envFile)) {
        $envContent = @"
# Auto-generated by ONEPACK v13
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
NEXT_PUBLIC_API_URL=http://localhost:8000
"@
        $envContent | Out-File $envFile -Encoding UTF8 -Force
        Write-Host "  ✔ Created frontend/.env.local" -ForegroundColor Green
    } else {
        Write-Host "  ✔ frontend/.env.local already exists" -ForegroundColor Green
    }

    Write-Host "`n  Frontend setup complete." -ForegroundColor Green
    Write-Host "  To start frontend:" -ForegroundColor Cyan
    Write-Host "    cd frontend" -ForegroundColor White
    Write-Host "    npm install" -ForegroundColor White
    Write-Host "    npm run dev" -ForegroundColor White
} else {
    Write-Host "`n[Frontend] Skipped (SkipFrontend flag set)" -ForegroundColor Gray
}

# ---------- SUMMARY ----------
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "         ONEPACK v13 — COMPLETE" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

if ($ok) {
    Write-Host "✅ Backend: http://localhost:8000/health" -ForegroundColor Green
} else {
    Write-Host "❌ Backend: Health check failed" -ForegroundColor Red
}

if (-not $SkipFrontend) {
    Write-Host "📦 Frontend: Ready (run 'cd frontend && npm run dev')" -ForegroundColor Cyan
}

if ($NeedBackup -and $ok) {
    Write-Host "💾 Backup: Created stable tag" -ForegroundColor Green
}

Write-Host ""
Write-Host "View logs:" -ForegroundColor Cyan
Write-Host "  docker logs sas_backend" -ForegroundColor White
Write-Host "  docker logs sas_db" -ForegroundColor White
Write-Host ""

