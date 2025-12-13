Write-Output "==============================================================="
Write-Output "   ONEPACK v14 — Hybrid Backup & Restore Master Engine"
Write-Output "   Project: FunAging.club (sanook-master-v2-main)"
Write-Output "==============================================================="

# -----------------------------
# Utility helpers
# -----------------------------
function OK($msg)   { Write-Host "[OK]   $msg"   -ForegroundColor Green }
function WARN($msg) { Write-Host "[WARN] $msg"   -ForegroundColor Yellow }
function FAIL($msg) { Write-Host "[FAIL] $msg"   -ForegroundColor Red }
function INFO($msg) { Write-Host "[INFO] $msg"   -ForegroundColor Cyan }

$ErrorActionPreference = "SilentlyContinue"
$GLOBAL:HAS_ERROR = $false
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# -----------------------------
# STEP 0 — Basic repo sanity
# -----------------------------
INFO "Checking that we are inside a Git repository..."

$insideGit = & git rev-parse --is-inside-work-tree 2>$null

if ($LASTEXITCODE -ne 0 -or -not $insideGit -or $insideGit.Trim().ToLower() -ne "true") {
    FAIL "Not inside a Git repository. Please run this from the FunAging.club repo root."
    exit 1
}
OK "Git repository detected."

$branch = (& git rev-parse --abbrev-ref HEAD).Trim()
if (-not $branch) { $branch = "unknown" }
INFO "Current git branch: $branch"

# -----------------------------
# STEP 1 — Optional v13 verifier
# -----------------------------
if (Test-Path "onepack_verifier_v13.ps1") {
    INFO "Running ONEPACK v13 verifier to ensure system is stable before backup..."
    try {
        pwsh .\onepack_verifier_v13.ps1
        if ($LASTEXITCODE -eq 0) {
            OK "v13 verifier executed (see above for details)."
        } else {
            WARN "v13 verifier returned a non-zero exit code. Backup will still continue, but verify logs carefully."
        }
    } catch {
        WARN "Failed to execute onepack_verifier_v13.ps1. Continuing with backup anyway."
    }
} else {
    WARN "onepack_verifier_v13.ps1 not found. Skipping pre-backup verification."
}

# -----------------------------
# STEP 2 — Detect file changes
# -----------------------------
INFO "Scanning for changed files (git status --porcelain)..."

$gitStatus = & git status --porcelain
$changedFiles = @()

if ($gitStatus) {
    $lines = $gitStatus -split "`n" | Where-Object { $_.Trim() -ne "" }
    foreach ($line in $lines) {
        if ($line.Length -gt 3) {
            $path = $line.Substring(3).Trim()
            if ($path) { $changedFiles += $path }
        }
    }

    if ($changedFiles.Count -gt 0) {
        OK "Detected $($changedFiles.Count) changed file(s):"
        $changedFiles | ForEach-Object { Write-Host "       - $_" -ForegroundColor Gray }
    } else {
        WARN "git status returned output but no files could be parsed."
    }
} else {
    WARN "No uncommitted changes detected (working tree is clean)."
}

# -----------------------------
# STEP 3 — Determine critical changes
# -----------------------------
$criticalPatterns = @(
    "^backend/",
    "^backend/app",
    "^backend/Dockerfile\.backend",
    "^docker-compose\.sas\.yml",
    "^frontend/",
    "^supabase/",
    "^supabase_fix/",
    "^onepack_.*\.ps1",
    "^mega_onepack_.*\.ps1",
    "^env_.*\.ps1",
    "^\.env",
    "^\.env\.local"
)

$criticalFiles = @()

foreach ($file in $changedFiles) {
    foreach ($pattern in $criticalPatterns) {
        if ($file -match $pattern) {
            $criticalFiles += $file
            break
        }
    }
}

if ($criticalFiles.Count -gt 0) {
    INFO "Critical files changed (will strongly trigger full snapshot):"
    $criticalFiles | Select-Object -Unique | ForEach-Object { Write-Host "       * $_" -ForegroundColor Magenta }
} else {
    INFO "No critical files detected in change list."
}

# -----------------------------
# STEP 4 — Decide snapshot mode
# -----------------------------
$doCommit = $false

if ($changedFiles.Count -gt 0) {
    # There are some changes. For "The Best" hybrid mode:
    # - If critical files changed → always commit
    # - Else → commit as well (so you never lose any work)
    $doCommit = $true
}

if ($doCommit) {
    INFO "Preparing AUTO-SNAPSHOT commit for current changes..."

    $commitMsg = "[AUTO-SNAPSHOT][v14] FunAging backup before pipeline v14–17 - $timestamp"

    INFO "Staging all changes (git add .)..."
    & git add .
    if ($LASTEXITCODE -ne 0) {
        WARN "git add . encountered issues. Continuing, but commit may fail."
    }

    INFO "Creating commit: $commitMsg"
    & git commit -m $commitMsg
    if ($LASTEXITCODE -eq 0) {
        OK "Commit created successfully."
    } else {
        WARN "No new commit created (maybe nothing to commit or commit failed)."
    }
} else {
    INFO "Working tree is clean — no commit required. Will create a tag snapshot referencing current HEAD."
}

# -----------------------------
# STEP 5 — Create snapshot tag
# -----------------------------
$tagName = "stable-v14-$timestamp"
INFO "Creating snapshot tag: $tagName"

& git tag -a $tagName -m "Hybrid backup snapshot created by ONEPACK v14 at $timestamp"
if ($LASTEXITCODE -eq 0) {
    OK "Tag created: $tagName"
} else {
    WARN "Failed to create tag (maybe it already exists)."
}

# -----------------------------
# STEP 6 — Push branch and tag
# -----------------------------
INFO "Checking Git remotes..."
$remotes = & git remote

if (-not $remotes) {
    WARN "No git remotes configured. Snapshot is LOCAL ONLY. Configure a remote to push backups to GitHub."
} else {
    $remote = $remotes.Split("`n")[0].Trim()
    if (-not $remote) { $remote = "origin" }

    INFO "Using remote: $remote"

    INFO "Pushing current branch ($branch) to $remote..."
    & git push $remote $branch
    if ($LASTEXITCODE -eq 0) {
        OK "Branch '$branch' pushed to '$remote'."
    } else {
        WARN "Failed to push branch '$branch' to '$remote'."
    }

    INFO "Pushing tag $tagName to $remote..."
    & git push $remote $tagName
    if ($LASTEXITCODE -eq 0) {
        OK "Tag '$tagName' pushed to '$remote'."
    } else {
        WARN "Failed to push tag '$tagName' to '$remote'."
    }
}

# -----------------------------
# STEP 7 — Generate RESTORE_MASTER.md
# -----------------------------
INFO "Generating RESTORE_MASTER.md (master restore guide)..."

$latestTags = & git tag --sort=-creatordate 2>$null
$latestTagsList = @()
if ($latestTags) {
    $latestTagsList = $latestTags -split "`n" | Where-Object { $_.Trim() -ne "" } | Select-Object -First 10
}

# Build restore guide content
$tagListSection = ""
if ($latestTagsList.Count -gt 0) {
    $tagListSection = "Recent tags (max 10):`n"
    foreach ($t in $latestTagsList) {
        $tagListSection += "- $t`n"
    }
} else {
    $tagListSection = "No tags found in repository.`n"
}

$restoreContent = @"
# FunAging.club — RESTORE MASTER GUIDE

Generated automatically by **ONEPACK v14 — Hybrid Backup & Restore Engine**
Timestamp: $timestamp

## 1. Concept

- ทุกครั้งที่รัน ONEPACK v14 ระบบจะสร้าง **snapshot tag** หนึ่งตัวเสมอ
- snapshot นี้สามารถใช้เป็นจุด restore ได้ทุกเมื่อ
- โดยปกติ tag จะมีรูปแบบ:

  - stable-v14-YYYYMMDD-HHmmss

## 2. Latest Snapshot Tag (From This Run)

- Latest tag from this run: $tagName

### Restore from this exact snapshot

````bash
# สร้าง branch ใหม่จาก snapshot แท็กนี้
git fetch --all --tags
git checkout tags/$tagName -b restore-$tagName

# จากนั้นสามารถรันระบบตามปกติ เช่น
pwsh .\onepack_funaging_v13.ps1
````

## 3. Other Recent Snapshot Tags

$tagListSection
## 4. Full Restore Procedure (Recommended)

1. ตรวจสอบให้แน่ใจว่าไม่มีงานค้างที่ยังไม่ backup:
   ````bash
   git status
   ````

2. เลือกแท็ก snapshot ที่ต้องการ (เช่น $tagName หรือ stable อื่น ๆ)
3. สร้าง branch ใหม่จากแท็กนั้น:

   ````bash
   git fetch --all --tags
   git checkout tags/<TAG_NAME> -b restore-<TAG_NAME>
   ````

4. ตรวจสอบไฟล์สำคัญ:
   - backend/app/main.py
   - backend/app/new_main.py
   - backend/app/routes/*.py
   - backend/Dockerfile.backend
   - docker-compose.sas.yml
   - frontend/.env.local

5. รัน ONEPACK และ verifier ที่เหมาะสม:

   ````bash
   pwsh .\onepack_funaging_v13.ps1
   pwsh .\onepack_verifier_v13.ps1
   ````

6. เมื่อตรวจสอบว่าระบบกลับมาทำงานได้สมบูรณ์แล้ว:
   - สามารถ merge เข้ากับ branch หลัก (เช่น main)
   - หรือใช้ branch restore-* เป็นฐานในการพัฒนาต่อ

## 5. Notes

- ONEPACK v14 สร้าง snapshot ทั้ง **เมื่อมีการเปลี่ยนแปลงไฟล์สำคัญ** และ **เมื่อไม่มีการเปลี่ยนแปลง (tag-only)**
- ควร push tags ขึ้น GitHub เสมอ เพื่อความปลอดภัยของข้อมูล
- ถ้า snapshot หนึ่ง ๆ ใช้งานได้ดี แนะนำให้จดบันทึกในระบบหรือตั้งชื่อ tag เพิ่มเติมเช่น prod-stable-YYYYMMDD
"@

try {
    $restoreContent | Set-Content -Path "RESTORE_MASTER.md" -Encoding UTF8
    OK "RESTORE_MASTER.md generated/updated successfully."
} catch {
    WARN "Failed to write RESTORE_MASTER.md: $($_.Exception.Message)"
}

Write-Output ""
Write-Output "==============================================================="
Write-Host  "ONEPACK v14 COMPLETED — Hybrid backup + restore guide ready." -ForegroundColor Green
Write-Output "  - Snapshot tag (this run): $tagName"
Write-Output "  - Branch: $branch"
Write-Output "  - Restore guide: RESTORE_MASTER.md"
Write-Output "==============================================================="
Write-Output ""


