# ===============================================================
# ONEPACK v15B — Jarvis Version Manager (Non-Interactive)
# Fully automated, parameter-based, no user input required.
# ===============================================================

param(
    [switch]$ShowInventory,
    [switch]$Backup,
    [switch]$HealthCheck,
    [string]$CloneVersion,
    [string]$RestoreTag
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host " ONEPACK v15B — Jarvis Automated Version Manager" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""

# -------------------------------------------------------------------
# Function: Ensure Git Repo
# -------------------------------------------------------------------
function Ensure-GitRepo {
    try {
        $isGit = git rev-parse --is-inside-work-tree 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $isGit -or $isGit.Trim().ToLower() -ne "true") {
            Write-Host "[ERROR] Not inside a Git repository." -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "[ERROR] Not inside a Git repository." -ForegroundColor Red
        exit 1
    }
}

# -------------------------------------------------------------------
# Function: Health Check Backend
# -------------------------------------------------------------------
function Run-HealthCheck {
    Write-Host "[INFO] Running backend health check..." -ForegroundColor Yellow

    # Check Docker
    try {
        docker info | Out-Null
        Write-Host "[OK]   Docker engine running" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Docker engine not running" -ForegroundColor Red
        return
    }

    # Check containers
    try {
        $running = docker ps --format "{{.Names}}" 2>$null
        if ($running -contains "sas_backend") {
            Write-Host "[OK]   sas_backend container running" -ForegroundColor Green
        } else {
            Write-Host "[WARN] sas_backend container not running" -ForegroundColor Yellow
            return
        }
    } catch {
        Write-Host "[WARN] Could not check containers" -ForegroundColor Yellow
        return
    }

    # Check health endpoint
    try {
        $health = Invoke-WebRequest -Uri "http://localhost:8000/health" -UseBasicParsing -TimeoutSec 5
        Write-Host "[OK]   /health → $($health.StatusCode)" -ForegroundColor Green
        if ($health.Content) {
            Write-Host "       Response: $($health.Content)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "[ERROR] Backend health check failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# -------------------------------------------------------------------
# Function: Show Version Inventory
# -------------------------------------------------------------------
function Show-Inventory {
    Ensure-GitRepo

    Write-Host "============= VERSION INVENTORY =============" -ForegroundColor Cyan
    Write-Host ""

    try {
        $currentBranch = (git rev-parse --abbrev-ref HEAD 2>$null).Trim()
        Write-Host "[Current Branch]" -ForegroundColor Yellow
        Write-Host "  $currentBranch" -ForegroundColor Green
        Write-Host ""

        Write-Host "[Branches]" -ForegroundColor Yellow
        $branches = git branch --format="%(refname:short)" 2>$null
        if ($branches) {
            $branches | ForEach-Object {
                if ($_ -eq $currentBranch) {
                    Write-Host "  * $_ (current)" -ForegroundColor Green
                } else {
                    Write-Host "    $_"
                }
            }
        } else {
            Write-Host "  (no branches found)"
        }
        Write-Host ""

        Write-Host "[Tags]" -ForegroundColor Yellow
        $tags = git tag --sort=-creatordate 2>$null
        if ($tags) {
            $counter = 1
            foreach ($t in $tags) {
                $color = "White"
                if ($t -like "stable-*") { $color = "Green" }
                elseif ($t -like "snapshot-*") { $color = "Yellow" }
                Write-Host ("  {0:00}) " -f $counter) -NoNewline
                Write-Host "$t" -ForegroundColor $color
                $counter++
            }
        } else {
            Write-Host "  (no tags found)"
        }
        Write-Host ""

        Write-Host "[Recent Commits]" -ForegroundColor Yellow
        $commits = git log --oneline -n 15 2>$null
        if ($commits) {
            $commits | ForEach-Object { Write-Host "  $_" }
        } else {
            Write-Host "  (no commits found)"
        }
        Write-Host ""

        Write-Host "=============================================" -ForegroundColor Cyan
    } catch {
        Write-Host "[ERROR] Failed to retrieve inventory: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# -------------------------------------------------------------------
# Function: Auto Backup (Commit + Tag + Push)
# -------------------------------------------------------------------
function Run-Backup {
    Ensure-GitRepo

    $timestamp = (Get-Date -Format "yyyyMMdd-HHmmss")
    $tag = "stable-v15-$timestamp"
    $commitMsg = "[AUTO-BACKUP][v15] Snapshot $timestamp"

    Write-Host "[INFO] Staging all changes..." -ForegroundColor Yellow
    git add . 2>&1 | Out-Null
    Write-Host "[OK]   Changes staged" -ForegroundColor Green

    $changes = git status --porcelain 2>$null
    if ($changes) {
        Write-Host "[INFO] Creating commit..." -ForegroundColor Yellow
        git commit -m $commitMsg 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK]   Commit created: $commitMsg" -ForegroundColor Green
        } else {
            Write-Host "[WARN] Commit may have failed (check git status)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[INFO] No changes to commit, creating tag-only snapshot" -ForegroundColor Yellow
    }

    Write-Host "[INFO] Creating tag: $tag" -ForegroundColor Yellow
    git tag -a $tag -m "Stable snapshot v15 $timestamp" 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK]   Tag created: $tag" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Tag creation may have failed" -ForegroundColor Yellow
    }

    $remote = (git remote 2>$null | Select-Object -First 1)
    if ($remote) {
        Write-Host "[INFO] Pushing branch to $remote..." -ForegroundColor Yellow
        $currentBranch = (git rev-parse --abbrev-ref HEAD 2>$null).Trim()
        git push $remote $currentBranch 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK]   Branch pushed" -ForegroundColor Green
        } else {
            Write-Host "[WARN] Branch push may have failed" -ForegroundColor Yellow
        }

        Write-Host "[INFO] Pushing tag $tag to $remote..." -ForegroundColor Yellow
        git push $remote $tag 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK]   Tag pushed" -ForegroundColor Green
        } else {
            Write-Host "[WARN] Tag push may have failed" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[WARN] No git remote configured. Snapshot is LOCAL ONLY." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "[OK] Backup complete. Tag: $tag" -ForegroundColor Green
}

# -------------------------------------------------------------------
# Function: Clone Version (Create new branch from tag)
# -------------------------------------------------------------------
function Run-CloneVersion($tag) {
    Ensure-GitRepo

    if (-not $tag) {
        Write-Host "[ERROR] Missing tag name." -ForegroundColor Red
        exit 1
    }

    # Verify tag exists
    try {
        git rev-parse "$tag^{tag}" 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[ERROR] Tag '$tag' not found." -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "[ERROR] Tag '$tag' not found." -ForegroundColor Red
        exit 1
    }

    $newBranch = "clone-$tag"

    Write-Host "[INFO] Creating new branch from tag: $tag" -ForegroundColor Yellow
    git checkout -b $newBranch $tag 2>&1 | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Clone created: $newBranch" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Failed to create clone branch" -ForegroundColor Red
        exit 1
    }
}

# -------------------------------------------------------------------
# Function: Restore from Tag
# -------------------------------------------------------------------
function Run-Restore($tag) {
    Ensure-GitRepo

    if (-not $tag) {
        Write-Host "[ERROR] Missing tag name." -ForegroundColor Red
        exit 1
    }

    # Verify tag exists
    try {
        git rev-parse "$tag^{tag}" 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[ERROR] Tag '$tag' not found." -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "[ERROR] Tag '$tag' not found." -ForegroundColor Red
        exit 1
    }

    $branch = "restore-$tag"

    Write-Host "[INFO] Restoring from tag: $tag" -ForegroundColor Yellow
    git checkout -b $branch $tag 2>&1 | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Restore branch ready: $branch" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "  pwsh .\onepack_funaging_v13.ps1" -ForegroundColor White
        Write-Host "  pwsh .\onepack_verifier_v13.ps1" -ForegroundColor White
    } else {
        Write-Host "[ERROR] Failed to restore from tag" -ForegroundColor Red
        exit 1
    }
}

# ===================================================================
# DISPATCH — Run actions based on parameters
# ===================================================================
if ($ShowInventory) {
    Show-Inventory
    exit 0
}

if ($Backup) {
    Run-Backup
    exit 0
}

if ($HealthCheck) {
    Run-HealthCheck
    exit 0
}

if ($CloneVersion) {
    Run-CloneVersion $CloneVersion
    exit 0
}

if ($RestoreTag) {
    Run-Restore $RestoreTag
    exit 0
}

# No command provided - show usage
Write-Host "[ERROR] No command provided. Use one of the following:" -ForegroundColor Red
Write-Host ""
Write-Host "Usage examples:" -ForegroundColor Cyan
Write-Host "  .\onepack_funaging_v15B.ps1 -ShowInventory" -ForegroundColor White
Write-Host "  .\onepack_funaging_v15B.ps1 -Backup" -ForegroundColor White
Write-Host "  .\onepack_funaging_v15B.ps1 -HealthCheck" -ForegroundColor White
Write-Host "  .\onepack_funaging_v15B.ps1 -CloneVersion stable-v14-25681212-072324" -ForegroundColor White
Write-Host "  .\onepack_funaging_v15B.ps1 -RestoreTag stable-v14-25681212-072324" -ForegroundColor White
Write-Host ""
exit 1


