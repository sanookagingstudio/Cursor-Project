# ============================================================
# ONEPACK v17 — Jarvis Monitoring + Snapshot Dashboard Engine
# Project: FunAging.club (sanook-master-v2-main)
# Mode: Non-interactive, safe-by-default
# ============================================================
param(
    [switch]$SummaryOnly,  # ถ้าต้องการแค่สรุปสถานะ / dashboard ไม่ต้อง heal/backup
    [switch]$SkipBackup    # ข้ามขั้นตอน backup (ใช้ตอน debug หรือทดสอบ)
)

$ErrorActionPreference = "Stop"

# ----------------- Helpers: Logging -----------------
function New-LogFile {
    $root = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
    $logDir = Join-Path $root ".jarvis"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir | Out-Null
    }
    $ts = Get-Date -Format "yyyyMMdd-HHmmss"
    return Join-Path $logDir "jarvis_v17_$ts.log"
}

$LogFile = New-LogFile

function Log {
    param(
        [string]$Message,
        [ConsoleColor]$Color = [ConsoleColor]::White
    )
    $ts   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$ts  $Message"
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $line
}

# ----------------- Helpers: Health -----------------
function Test-BackendHealth {
    param(
        [string]$UrlRoot = "http://localhost:8000"
    )
    try {
        $health = Invoke-WebRequest "$UrlRoot/health" -UseBasicParsing -TimeoutSec 5
        if ($health.StatusCode -ne 200) {
            Log "[HEALTH] /health returned HTTP $($health.StatusCode)" Yellow
            return $false
        }
        Log "[HEALTH] /health OK → $($health.Content)" Green

        $root = Invoke-WebRequest "$UrlRoot/" -UseBasicParsing -TimeoutSec 5
        if ($root.StatusCode -ne 200) {
            Log "[HEALTH] / returned HTTP $($root.StatusCode)" Yellow
            return $false
        }
        Log "[HEALTH] / OK → $($root.Content)" Green
        return $true
    }
    catch {
        Log "[HEALTH] Backend not reachable: $($_.Exception.Message)" Yellow
        return $false
    }
}

# ----------------- Helpers: Git -----------------
function Ensure-GitRepo {
    try {
        git rev-parse --is-inside-work-tree 2>$null | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Get-GitSummary {
    $summary = [ordered]@{}

    try {
        $branch = (git branch --show-current 2>$null).Trim()
        if (-not $branch) {
            $branch = (git rev-parse --abbrev-ref HEAD 2>$null).Trim()
        }
        $summary["Branch"] = if ($branch) { $branch } else { "<unknown>" }
    }
    catch {
        $summary["Branch"] = "<unknown>"
    }

    try {
        $tags = git tag --sort=-creatordate 2>$null | Select-Object -First 10
        $summary["Tags"] = if ($tags) { ($tags -join "`n") } else { "<none>" }
    }
    catch {
        $summary["Tags"] = "<none>"
    }

    try {
        $log = git log -10 --oneline 2>$null
        $summary["RecentCommits"] = if ($log) { ($log -join "`n") } else { "<none>" }
    }
    catch {
        $summary["RecentCommits"] = "<none>"
    }

    try {
        $status = git status --short 2>$null
        if ([string]::IsNullOrWhiteSpace($status)) {
            $summary["WorkingTree"] = "clean"
        }
        else {
            $summary["WorkingTree"] = "dirty`n$status"
        }
    }
    catch {
        $summary["WorkingTree"] = "<unknown>"
    }

    return $summary
}

# ----------------- Helpers: Docker -----------------
function Get-DockerSummary {
    $info = [ordered]@{}
    try {
        docker info 2>&1 | Out-Null
        $info["Engine"] = "running"
    }
    catch {
        $info["Engine"] = "not running"
        return $info
    }

    try {
        $ps = docker ps --format '{{.Names}}|{{.Status}}|{{.Ports}}' 2>$null
        if (-not $ps) {
            $info["Containers"] = "<none running>"
        }
        else {
            $info["Containers"] = ($ps -join "`n")
        }
    }
    catch {
        $info["Containers"] = "<error>"
    }

    return $info
}

# ----------------- Helpers: Jarvis Logs -----------------
function Get-JarvisLogTail {
    $root = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
    $logDir = Join-Path $root ".jarvis"
    if (-not (Test-Path $logDir)) {
        return "<no .jarvis directory>"
    }

    $files = Get-ChildItem $logDir -Filter "jarvis_v*.log" -ErrorAction SilentlyContinue |
             Sort-Object LastWriteTime -Descending |
             Select-Object -First 3

    if (-not $files) {
        return "<no jarvis_v*.log yet>"
    }

    $builder = New-Object System.Text.StringBuilder
    foreach ($f in $files) {
        [void]$builder.AppendLine("### $($f.Name)")
        try {
            $tail = Get-Content $f.FullName -Tail 10 -ErrorAction SilentlyContinue
            if ($tail) {
                foreach ($line in $tail) {
                    [void]$builder.AppendLine($line)
                }
                [void]$builder.AppendLine("")
            }
        }
        catch {
            [void]$builder.AppendLine("<error reading log>")
        }
    }

    return $builder.ToString().TrimEnd()
}

# ----------------- Helpers: Dashboard -----------------
function Generate-Dashboard {
    $root = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
    $file = Join-Path $root "JARVIS_STATUS_DASHBOARD.md"

    $now         = Get-Date
    $nowStr      = $now.ToString("yyyy-MM-dd HH:mm:ss")
    $gitSummary  = if (Ensure-GitRepo) { Get-GitSummary } else { $null }
    $dockerInfo  = Get-DockerSummary
    $jarvisTail  = Get-JarvisLogTail
    $backendOk   = Test-BackendHealth

    $supabaseEnv = ""
    if (Test-Path ".env") { $supabaseEnv += ".env`n" }
    if (Test-Path "frontend/.env.local") { $supabaseEnv += "frontend/.env.local`n" }
    if (-not $supabaseEnv) { $supabaseEnv = "<not found>" }

    $gitBranch       = if ($gitSummary) { $gitSummary["Branch"] } else { "<not a git repo>" }
    $gitTags         = if ($gitSummary) { $gitSummary["Tags"] } else { "<not a git repo>" }
    $gitRecent       = if ($gitSummary) { $gitSummary["RecentCommits"] } else { "<not a git repo>" }
    $gitWorkingTree  = if ($gitSummary) { $gitSummary["WorkingTree"] } else { "<not a git repo>" }
    $dockerEngine    = $dockerInfo["Engine"]
    $dockerContainers= $dockerInfo["Containers"]

    $backendStatus = if ($backendOk) { "HEALTHY" } else { "UNHEALTHY" }

    $content = @"
# Jarvis Status Dashboard — FunAging.club

- Generated at: $nowStr
- Backend status: **$backendStatus**
- Docker engine: **$dockerEngine**
- Git branch: **$gitBranch**

---

## 1. Backend Health Check

Status: **$backendStatus**

Checked endpoints:

- `GET /health`
- `GET /`

If UNHEALTHY → ใช้ `onepack_funaging_v16.ps1` เพื่อ auto-heal อีกครั้งได้เลย.

---

## 2. Docker Containers

Engine: **$dockerEngine**

```
$dockerContainers
```

---

## 3. Git Summary

### Branch
```
$gitBranch
```

### Working Tree
```
$gitWorkingTree
```

### Latest Tags
```
$gitTags
```

### Recent Commits
```
$gitRecent
```

---

## 4. Environment Files (Supabase / Backend / Frontend)

Detected:

```
$supabaseEnv
```

---

## 5. Jarvis Recent Logs (v16 / v17 etc.)

```
$jarvisTail
```

---

## 6. Quick Commands (Reference)

- Run self-heal:
  - `pwsh .\onepack_funaging_v16.ps1`

- Run version manager (non-interactive):
  - Show inventory: `pwsh .\onepack_funaging_v15B.ps1 -ShowInventory`
  - Backup now:     `pwsh .\onepack_funaging_v15B.ps1 -Backup`

- Full check + dashboard:
  - `pwsh .\onepack_funaging_v17.ps1`

---
"@

    Set-Content -Path $file -Value $content -Encoding UTF8
    Log "[DASHBOARD] JARVIS_STATUS_DASHBOARD.md generated." Green
    return $file
}

# ----------------- Helpers: Backup via v15B -----------------
function Auto-Backup-WithV15B {
    param(
        [string]$Reason = "Jarvis v17 monitor snapshot"
    )

    if (-not (Ensure-GitRepo)) {
        Log "[BACKUP] Not a git repository — skip backup." Yellow
        return
    }

    $root = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
    $v15B = Join-Path $root "onepack_funaging_v15B.ps1"

    if (-not (Test-Path $v15B)) {
        Log "[BACKUP] v15B not found — using simplified backup." Yellow
        try {
            git add . 2>&1 | Out-Null
            $ts  = Get-Date -Format "yyyyMMdd-HHmmss"
            $msg = "[AUTO-BACKUP][v17] $Reason - $ts"
            git commit -m $msg 2>&1 | Out-Null
            $tag = "stable-v17-$ts"
            git tag -a $tag -m $msg 2>&1 | Out-Null
            git push origin HEAD 2>&1 | Out-Null
            git push origin $tag 2>&1 | Out-Null
            Log "[BACKUP] Simple backup + tag $tag pushed to origin." Green
        }
        catch {
            Log "[ERROR] Simplified backup failed: $($_.Exception.Message)" Red
        }
        return
    }

    try {
        Log "[BACKUP] Running v15B auto-backup engine..." Cyan
        & $v15B -Backup 2>&1 | Out-Null
        Log "[BACKUP] v15B backup completed." Green
    }
    catch {
        Log "[ERROR] v15B backup failed: $($_.Exception.Message)" Red
    }
}

# ----------------- MAIN -----------------
Log "================================================" Cyan
Log "ONEPACK v17 — Jarvis Monitoring + Snapshot START" Cyan
Log "================================================" Cyan

# Ensure repo root
$RepoRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $RepoRoot

# Quick structure sanity
if (-not (Test-Path "backend") -or -not (Test-Path "frontend") -or -not (Test-Path "docker-compose.sas.yml")) {
    Log "[ERROR] Project structure not correct (backend/frontend/docker-compose.sas.yml missing)." Red
    Log "[ABORT] Cannot continue monitoring." Red
    exit 1
}

# 1) Heal (via v16) unless SummaryOnly
if (-not $SummaryOnly) {
    $v16Path = Join-Path $RepoRoot "onepack_funaging_v16.ps1"
    if (Test-Path $v16Path) {
        Log "[INFO] Running ONEPACK v16 (self-heal) with SkipBackup..." Cyan
        try {
            & $v16Path -SkipBackup 2>&1 | Out-Null
            Log "[INFO] ONEPACK v16 finished." Green
        }
        catch {
            Log "[WARN] ONEPACK v16 execution error (continuing anyway): $($_.Exception.Message)" Yellow
        }
    }
    else {
        Log "[INFO] v16 self-heal script not found — skipping heal step." Yellow
    }
}
else {
    Log "[INFO] SummaryOnly flag set — skipping heal step." Yellow
}

# 2) Health check AFTER potential heal
$backendHealthy = Test-BackendHealth

# 3) Backup (if not skipped and health OK)
if (-not $SkipBackup -and -not $SummaryOnly) {
    if ($backendHealthy) {
        Auto-Backup-WithV15B -Reason "Jarvis v17 post-monitor (healthy)"
    }
    else {
        Log "[BACKUP] Skipping backup — backend is not healthy." Yellow
    }
}
elseif ($SkipBackup) {
    Log "[BACKUP] SkipBackup flag set — backup disabled for this run." Yellow
}
elseif ($SummaryOnly) {
    Log "[BACKUP] SummaryOnly mode — no backup executed." Yellow
}

# 4) Generate dashboard
$dashFile = Generate-Dashboard

Log "================================================" Cyan
Log "ONEPACK v17 COMPLETE — Dashboard: $dashFile" Cyan
Log "Log file: $LogFile" Cyan
Log "================================================" Cyan
Log ""



