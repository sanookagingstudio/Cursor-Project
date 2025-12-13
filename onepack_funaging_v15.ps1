# ================================
# ONEPACK v15 — Jarvis Version Manager (Menu Mode)
# Project: FunAging.club (sanook-master-v2-main)
# ================================

$ErrorActionPreference = "Stop"

function Write-Title {
    param([string]$Text)
    Write-Host ""
    Write-Host "===============================================================" -ForegroundColor Cyan
    Write-Host " $Text" -ForegroundColor Cyan
    Write-Host "===============================================================" -ForegroundColor Cyan
}

function Pause-Jarvis {
    Write-Host ""
    Read-Host "กด Enter เพื่อกลับไปเมนูหลัก"
}

function Get-CurrentBranch {
    try {
        $b = (git rev-parse --abbrev-ref HEAD 2>$null).Trim()
        if ([string]::IsNullOrWhiteSpace($b)) { return "<unknown>" }
        return $b
    } catch {
        return "<not-a-git-repo>"
    }
}

function Get-LatestStableTag {
    try {
        $tags = git tag --list "stable-*" --sort=-creatordate 2>$null
        if (-not $tags) { return "<none>" }
        return $tags | Select-Object -First 1
    } catch {
        return "<none>"
    }
}

function Show-VersionInventory {
    Write-Title "VERSION INVENTORY"

    try {
        $branch = Get-CurrentBranch
        $stableTag = Get-LatestStableTag

        Write-Host "Current Branch: " -NoNewline
        Write-Host "$branch" -ForegroundColor Green
        Write-Host "Latest Stable Tag: " -NoNewline
        Write-Host "$stableTag" -ForegroundColor Green
        Write-Host ""

        Write-Host "Branches:" -ForegroundColor Yellow
        try {
            $branches = git branch --format="%(refname:short)" 2>$null
            if ($branches) {
                $branches | ForEach-Object {
                    if ($_ -eq $branch) {
                        Write-Host " * $_ (current)" -ForegroundColor Green
                    } else {
                        Write-Host "   $_"
                    }
                }
            } else {
                Write-Host " (no branches found)"
            }
        } catch {
            Write-Host "ไม่สามารถอ่านรายชื่อ branch ได้: $($_.Exception.Message)" -ForegroundColor Red
        }

        Write-Host ""
        Write-Host "Tags:" -ForegroundColor Yellow
        try {
            $tags = git tag --sort=-creatordate 2>$null
            if ($tags) {
                $counter = 1
                foreach ($t in $tags) {
                    $style = "White"
                    if ($t -like "stable-*") { $style = "Green" }
                    elseif ($t -like "snapshot-*") { $style = "Yellow" }
                    Write-Host (" {0:00}) " -f $counter) -NoNewline
                    Write-Host "$t" -ForegroundColor $style
                    $counter++
                }
            } else {
                Write-Host " (no tags found)"
            }
        } catch {
            Write-Host "ไม่สามารถอ่านรายชื่อ tag ได้: $($_.Exception.Message)" -ForegroundColor Red
        }

        Write-Host ""
        Write-Host "Recommended restore point:" -ForegroundColor Yellow
        Write-Host " → $stableTag" -ForegroundColor Green
    } catch {
        Write-Host "เกิดข้อผิดพลาดใน Version Inventory: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Invoke-SystemHealthCheck {
    Write-Title "SYSTEM HEALTH CHECK"

    $status = [ordered]@{
        DockerRunning       = $false
        SasBackendExists    = $false
        SasBackendRunning   = $false
        SasDbRunning        = $false
        BackendHealthOk     = $false
        FrontendEnvExists   = $false
        FrontendEnvHasApi   = $false
    }

    # Docker
    Write-Host "[INFO] Checking Docker engine..."
    try {
        docker info | Out-Null
        $status.DockerRunning = $true
        Write-Host "[OK]   Docker engine running."
    } catch {
        Write-Host "[FAIL] Docker engine not running: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Containers
    if ($status.DockerRunning) {
        Write-Host "[INFO] Checking containers..."
        try {
            $names = docker ps -a --format "{{.Names}}" 2>$null
            if ($names -contains "sas_backend") { $status.SasBackendExists = $true }
            if ($names -contains "sas_db") { $status.SasDbRunning = $true } # presence check

            $runningNames = docker ps --format "{{.Names}}" 2>$null
            if ($runningNames -contains "sas_backend") { $status.SasBackendRunning = $true }
            if ($runningNames -contains "sas_db") { $status.SasDbRunning = $true }

            Write-Host ("[OK]   sas_backend exists: {0}, running: {1}" -f $status.SasBackendExists, $status.SasBackendRunning)
            Write-Host ("[OK]   sas_db running: {0}" -f $status.SasDbRunning)
        } catch {
            Write-Host "[FAIL] ตรวจสอบ container ไม่สำเร็จ: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # Backend health
    if ($status.SasBackendRunning) {
        Write-Host "[INFO] Checking backend http://localhost:8000/health ..."
        try {
            $resp = Invoke-WebRequest "http://localhost:8000/health" -UseBasicParsing -TimeoutSec 5
            if ($resp.StatusCode -eq 200) {
                $status.BackendHealthOk = $true
                Write-Host "[OK]   Backend health 200 OK"
                if ($resp.Content) {
                    Write-Host "       Response: $($resp.Content)"
                }
            } else {
                Write-Host "[WARN] Backend /health status: $($resp.StatusCode)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "[FAIL] Backend /health ไม่ตอบ: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "[WARN] Backend container ยังไม่รัน จึงข้าม health check" -ForegroundColor Yellow
    }

    # Frontend env
    Write-Host "[INFO] Checking frontend .env.local ..."
    $envPath = Join-Path "frontend" ".env.local"
    if (Test-Path $envPath) {
        $status.FrontendEnvExists = $true
        Write-Host "[OK]   frontend/.env.local found."
        try {
            $content = Get-Content $envPath -ErrorAction Stop
            if ($content -match "NEXT_PUBLIC_API_URL") {
                $status.FrontendEnvHasApi = $true
                Write-Host "[OK]   NEXT_PUBLIC_API_URL is defined."
            } else {
                Write-Host "[WARN] NEXT_PUBLIC_API_URL is missing in .env.local." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "[WARN] อ่าน .env.local ไม่สำเร็จ: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[WARN] frontend/.env.local not found." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Summary:" -ForegroundColor Cyan
    Write-Host ("  Docker running        : {0}" -f $status.DockerRunning)
    Write-Host ("  sas_backend running   : {0}" -f $status.SasBackendRunning)
    Write-Host ("  sas_db running        : {0}" -f $status.SasDbRunning)
    Write-Host ("  Backend /health 200   : {0}" -f $status.BackendHealthOk)
    Write-Host ("  Frontend .env.local   : {0}" -f $status.FrontendEnvExists)
    Write-Host ("  API URL configured    : {0}" -f $status.FrontendEnvHasApi)

    return $status
}

function Invoke-BackupSnapshot {
    Write-Title "AUTO-SNAPSHOT BACKUP (v15)"

    try {
        git rev-parse --is-inside-work-tree 2>$null | Out-Null
    } catch {
        Write-Host "[FAIL] ไม่ได้อยู่ใน Git repo, ยกเลิก backup." -ForegroundColor Red
        return
    }

    $branch = Get-CurrentBranch
    Write-Host "[INFO] Current branch: $branch"

    $changes = git status --porcelain 2>$null
    if (-not $changes) {
        Write-Host "[INFO] ไม่มีไฟล์ที่เปลี่ยนแปลง แต่จะสร้าง snapshot tag ให้ได้หากต้องการ."
    } else {
        Write-Host "[INFO] มีไฟล์ที่เปลี่ยนแปลง:"
        $changes | ForEach-Object { Write-Host "   $_" }
    }

    $confirm = Read-Host "ต้องการสร้าง backup snapshot และ push ไป GitHub หรือไม่? (Y/N)"
    if ($confirm -notin @("Y","y","ใช่","yes","YES")) {
        Write-Host "[INFO] ยกเลิกการสร้าง snapshot."
        return
    }

    $ts = (Get-Date).ToString("yyyyMMdd-HHmmss")
    $tagName = "stable-v15-$ts"
    $commitMsg = "[AUTO-SNAPSHOT][v15] FunAging snapshot $ts"

    try {
        git add . 2>$null
        Write-Host "[OK]   git add ."

        if ($changes) {
            git commit -m $commitMsg 2>$null
            Write-Host "[OK]   Commit created: $commitMsg"
        } else {
            Write-Host "[INFO] ไม่มีการเปลี่ยนแปลงใหม่, ข้าม commit."
        }

        git tag -a $tagName -m "Stable snapshot v15 $ts" 2>$null
        Write-Host "[OK]   Tag created: $tagName"

        $remote = (git remote 2>$null | Select-Object -First 1)
        if ($remote) {
            Write-Host "[INFO] Pushing branch '$branch' to '$remote'..."
            git push $remote $branch 2>$null
            Write-Host "[OK]   Branch pushed."

            Write-Host "[INFO] Pushing tag '$tagName' to '$remote'..."
            git push $remote $tagName 2>$null
            Write-Host "[OK]   Tag pushed."
        } else {
            Write-Host "[WARN] ไม่มี remote ใน repo นี้ ข้ามขั้นตอน push." -ForegroundColor Yellow
        }

        Write-Host ""
        Write-Host "✅ Backup snapshot เสร็จสมบูรณ์: $tagName" -ForegroundColor Green
    } catch {
        Write-Host "[FAIL] เกิดข้อผิดพลาดระหว่าง backup: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Invoke-RestoreVersion {
    Write-Title "RESTORE VERSION FROM TAG"

    try {
        $tags = git tag --sort=-creatordate 2>$null
    } catch {
        Write-Host "[FAIL] ไม่สามารถอ่าน tag ได้: $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    if (-not $tags) {
        Write-Host "ไม่มี tag ให้ restore." -ForegroundColor Yellow
        return
    }

    Write-Host "Available tags (ใหม่→เก่า):" -ForegroundColor Yellow
    $index = 1
    $tagArray = @()
    foreach ($t in $tags) {
        $tagArray += $t
        $color = "White"
        if ($t -like "stable-*") { $color = "Green" }
        elseif ($t -like "snapshot-*") { $color = "Yellow" }
        Write-Host (" {0:00}) " -f $index) -NoNewline
        Write-Host "$t" -ForegroundColor $color
        $index++
    }

    $choice = Read-Host "เลือกหมายเลข tag ที่ต้องการ restore (หรือกด Enter เพื่อยกเลิก)"
    if ([string]::IsNullOrWhiteSpace($choice)) {
        Write-Host "[INFO] ยกเลิก restore."
        return
    }

    if (-not [int]::TryParse($choice, [ref]0)) {
        Write-Host "[FAIL] ต้องเป็นตัวเลข." -ForegroundColor Red
        return
    }

    $choiceIndex = [int]$choice
    if ($choiceIndex -lt 1 -or $choiceIndex -gt $tagArray.Count) {
        Write-Host "[FAIL] หมายเลขไม่อยู่ในช่วง." -ForegroundColor Red
        return
    }

    $selectedTag = $tagArray[$choiceIndex-1]
    Write-Host ""
    Write-Host "คุณเลือก tag: $selectedTag" -ForegroundColor Cyan

    $confirmBackup = Read-Host "ต้องการสร้าง backup snapshot ปัจจุบันก่อน restore หรือไม่? (Y/N)"
    if ($confirmBackup -in @("Y","y","ใช่","yes","YES")) {
        Invoke-BackupSnapshot
    }

    $restoreBranch = "restore-$selectedTag"
    Write-Host "[INFO] Checkout tag ไปยัง branch ใหม่: $restoreBranch"
    try {
        git checkout -b $restoreBranch $selectedTag 2>$null
        Write-Host "✅ Restore สำเร็จ ตอนนี้อยู่ที่ branch: $restoreBranch" -ForegroundColor Green
    } catch {
        Write-Host "[FAIL] Restore ไม่สำเร็จ: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Invoke-CloneVersion {
    Write-Title "CLONE VERSION FOR NEW PROJECT"

    try {
        $tags = git tag --sort=-creatordate 2>$null
    } catch {
        Write-Host "[FAIL] ไม่สามารถอ่าน tag ได้: $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    if (-not $tags) {
        Write-Host "ไม่มี tag ให้ clone." -ForegroundColor Yellow
        return
    }

    Write-Host "Available tags (ใหม่→เก่า):" -ForegroundColor Yellow
    $index = 1
    $tagArray = @()
    foreach ($t in $tags) {
        $tagArray += $t
        $color = "White"
        if ($t -like "stable-*") { $color = "Green" }
        elseif ($t -like "snapshot-*") { $color = "Yellow" }
        Write-Host (" {0:00}) " -f $index) -NoNewline
        Write-Host "$t" -ForegroundColor $color
        $index++
    }

    $choice = Read-Host "เลือกหมายเลข tag ที่ต้องการ clone (หรือกด Enter เพื่อยกเลิก)"
    if ([string]::IsNullOrWhiteSpace($choice)) {
        Write-Host "[INFO] ยกเลิก clone."
        return
    }

    if (-not [int]::TryParse($choice, [ref]0)) {
        Write-Host "[FAIL] ต้องเป็นตัวเลข." -ForegroundColor Red
        return
    }

    $choiceIndex = [int]$choice
    if ($choiceIndex -lt 1 -or $choiceIndex -gt $tagArray.Count) {
        Write-Host "[FAIL] หมายเลขไม่อยู่ในช่วง." -ForegroundColor Red
        return
    }

    $selectedTag = $tagArray[$choiceIndex-1]
    $targetPath = Read-Host "ระบุโฟลเดอร์ปลายทางใหม่ (เช่น D:\SanookAgingStudio\FunAging-Clone-v1)"

    if ([string]::IsNullOrWhiteSpace($targetPath)) {
        Write-Host "[INFO] ยกเลิก clone."
        return
    }

    if (Test-Path $targetPath) {
        Write-Host "[FAIL] โฟลเดอร์เป้าหมายมีอยู่แล้ว: $targetPath" -ForegroundColor Red
        return
    }

    try {
        New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
        Write-Host "[INFO] สร้างโฟลเดอร์: $targetPath"

        Write-Host "[INFO] Export ไฟล์จาก tag $selectedTag ไปยังโฟลเดอร์ใหม่..."
        # ใช้ git archive + tar ซึ่งมีบน Windows 10+ อยู่แล้ว
        git archive $selectedTag | tar -x -C $targetPath
        Write-Host "✅ Clone เสร็จสมบูรณ์: $targetPath" -ForegroundColor Green
        Write-Host "   คุณสามารถเปิดโฟลเดอร์นี้ใน Cursor แล้วเริ่มโปรเจกต์ใหม่ได้ทันที."
    } catch {
        Write-Host "[FAIL] Clone ไม่สำเร็จ: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Invoke-JarvisDiagnosis {
    Write-Title "JARVIS DIAGNOSIS & SUGGESTIONS"

    $status = Invoke-SystemHealthCheck

    Write-Host ""
    Write-Host "Jarvis Suggestions:" -ForegroundColor Magenta

    $problems = @()

    if (-not $status.DockerRunning) {
        $problems += "Docker engine ไม่ทำงาน → เปิด Docker Desktop ก่อน แล้วรัน onepack_funaging_v11 หรือ v13."
    }
    if ($status.DockerRunning -and (-not $status.SasBackendRunning)) {
        $problems += "sas_backend ไม่ได้รัน → ใช้ docker compose -f docker-compose.sas.yml up -d --build หรือรัน ONEPACK v11/v13."
    }
    if ($status.DockerRunning -and (-not $status.SasDbRunning)) {
        $problems += "sas_db ไม่ได้รัน → ตรวจ docker logs sas_db และ docker compose up -d."
    }
    if ($status.SasBackendRunning -and (-not $status.BackendHealthOk)) {
        $problems += "Backend รันอยู่แต่ /health ไม่ 200 → ดู docker logs sas_backend, ตรวจ Supabase URL/Key, หรือใช้ onepack_selftest_v12.ps1."
    }
    if (-not $status.FrontendEnvExists) {
        $problems += "frontend/.env.local ไม่มี → ควรสร้างไฟล์ .env.local หรือใช้ ONEPACK ที่สร้าง env ให้อัตโนมัติ."
    } elseif (-not $status.FrontendEnvHasApi) {
        $problems += "NEXT_PUBLIC_API_URL ไม่ถูกตั้งค่าใน .env.local → ตั้งค่าเป็น http://localhost:8000 หรือ Backend URL บน Production."
    }

    if ($problems.Count -eq 0) {
        Write-Host "✅ Jarvis ไม่พบปัญหาสำคัญ ระบบพร้อมใช้งาน." -ForegroundColor Green
    } else {
        $i = 1
        foreach ($p in $problems) {
            Write-Host (" {0:00}) {1}" -f $i, $p) -ForegroundColor Yellow
            $i++
        }
    }
}

function Show-RestoreGuide {
    Write-Title "MASTER RESTORE GUIDE"

    $path1 = "RESTORE_MASTER.md"
    $path2 = "RESTORE.md"

    if (Test-Path $path1) {
        Write-Host "[INFO] แสดงไฟล์ $path1" -ForegroundColor Green
        Get-Content $path1 | ForEach-Object { Write-Host $_ }
    } elseif (Test-Path $path2) {
        Write-Host "[INFO] แสดงไฟล์ $path2" -ForegroundColor Green
        Get-Content $path2 | ForEach-Object { Write-Host $_ }
    } else {
        Write-Host "[WARN] ไม่พบ RESTORE_MASTER.md หรือ RESTORE.md" -ForegroundColor Yellow
        Write-Host "คุณสามารถใช้ ONEPACK v14 เพื่อสร้าง RESTORE_MASTER.md ได้อีกครั้ง."
    }
}

# ================================
# MAIN MENU LOOP
# ================================

Write-Title "ONEPACK v15 — JARVIS VERSION MANAGER"

$branch = Get-CurrentBranch
$stableTag = Get-LatestStableTag
Write-Host "Project : FunAging.club (sanook-master-v2-main)"
Write-Host "Branch  : $branch"
Write-Host "Stable  : $stableTag"
Write-Host ""

while ($true) {
    Write-Host "---------------------------------------------------------------"
    Write-Host " เลือกเมนู:"
    Write-Host "  1) Show Version Inventory        (ดู tags, branches, restore points)"
    Write-Host "  2) System Health Check           (ตรวจ Docker, Backend, Frontend)"
    Write-Host "  3) Backup Now (Auto-Snapshot)    (commit + tag + push)"
    Write-Host "  4) Restore Version               (เลือก tag แล้ว restore)"
    Write-Host "  5) Clone Version for New Project (สร้างโปรเจกต์ใหม่จาก tag)"
    Write-Host "  6) Jarvis Diagnosis & Suggestion (วิเคราะห์และแนะนำการแก้ไข)"
    Write-Host "  7) Show Restore Guide            (ดู RESTORE_MASTER/RESTORE)"
    Write-Host "  8) Exit"
    Write-Host "---------------------------------------------------------------"
    $choice = Read-Host "กรอกหมายเลขเมนู (1-8)"

    switch ($choice) {
        '1' { Show-VersionInventory; Pause-Jarvis }
        '2' { Invoke-SystemHealthCheck | Out-Null; Pause-Jarvis }
        '3' { Invoke-BackupSnapshot; Pause-Jarvis }
        '4' { Invoke-RestoreVersion; Pause-Jarvis }
        '5' { Invoke-CloneVersion; Pause-Jarvis }
        '6' { Invoke-JarvisDiagnosis | Out-Null; Pause-Jarvis }
        '7' { Show-RestoreGuide; Pause-Jarvis }
        '8' { Write-Host "ออกจาก ONEPACK v15 แล้วครับ." -ForegroundColor Cyan; break }
        default {
            Write-Host "กรุณาเลือกตัวเลข 1-8" -ForegroundColor Yellow
        }
    }
}



