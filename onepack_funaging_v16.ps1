# ================================================
# ONEPACK v16 — Jarvis Self-Healing Engine
# Project: FunAging.club (sanook-master-v2-main)
# Non-interactive, safe auto-heal + auto-backup
# ================================================
param(
    [switch]$SkipBackup
)

$ErrorActionPreference = "Stop"

# ---------- Helpers ----------
function New-LogFile {
    $root = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
    $logDir = Join-Path $root ".jarvis"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir | Out-Null
    }
    $ts = Get-Date -Format "yyyyMMdd-HHmmss"
    return Join-Path $logDir "jarvis_v16_$ts.log"
}

$LogFile = New-LogFile

function Log {
    param([string]$Message, [ConsoleColor]$Color = [ConsoleColor]::White)
    $ts   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$ts  $Message"
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $line
}

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

function Ensure-DockerEngine {
    Log "[HEAL] Checking Docker engine..." Cyan
    try {
        docker info | Out-Null
        Log "[HEAL] Docker engine is running." Green
        return $true
    }
    catch {
        Log "[HEAL] Docker not running, trying to start Windows service 'com.docker.service'..." Yellow
        try {
            net start com.docker.service | Out-Null
            Start-Sleep -Seconds 8
            docker info | Out-Null
            Log "[HEAL] Docker engine started successfully." Green
            return $true
        }
        catch {
            Log "[ERROR] Cannot start Docker engine: $($_.Exception.Message)" Red
            return $false
        }
    }
}

function Heal-DockerStack {
    param(
        [string]$ComposeFile = "docker-compose.sas.yml"
    )

    if (-not (Test-Path $ComposeFile)) {
        Log "[ERROR] $ComposeFile not found — cannot heal Docker stack." Red
        return
    }

    Log "[HEAL] Restarting Docker stack (sas_db + sas_backend)..." Cyan
    try {
        docker compose -f $ComposeFile down --remove-orphans 2>&1 | Out-Null
    }
    catch {
        Log "[HEAL] docker compose down reported an error (ignored): $($_.Exception.Message)" Yellow
    }

    try {
        docker compose -f $ComposeFile up -d --build
        Log "[HEAL] docker compose up -d --build issued." Green
    }
    catch {
        Log "[ERROR] docker compose up failed: $($_.Exception.Message)" Red
    }

    Log "[HEAL] Waiting 20 seconds for services to warm up..." Cyan
    Start-Sleep -Seconds 20
}

function Run-VerifierV13 {
    $root = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
    $verifierPath = Join-Path $root "onepack_verifier_v13.ps1"
    if (-not (Test-Path $verifierPath)) {
        Log "[INFO] onepack_verifier_v13.ps1 not found — skipping explicit v13 verification." Yellow
        return $true
    }

    Log "[INFO] Running ONEPACK v13 verifier..." Cyan
    try {
        & $verifierPath 2>&1 | Out-Null
        Log "[INFO] Verifier v13 completed." Green
        return $true
    }
    catch {
        Log "[WARN] Verifier v13 reported errors: $($_.Exception.Message)" Yellow
        return $false
    }
}

function Auto-Backup-WithV15B {
    param(
        [string]$Reason = "Jarvis v16 auto-backup"
    )
    $root = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
    $v15B = Join-Path $root "onepack_funaging_v15B.ps1"

    if (-not (Test-Path $v15B)) {
        Log "[INFO] v15B manager not found — running simplified backup." Yellow

        try {
            git add . 2>&1 | Out-Null
            $ts   = Get-Date -Format "yyyyMMdd-HHmmss"
            $msg  = "[AUTO-BACKUP][v16] $Reason - $ts"
            git commit -m $msg 2>&1 | Out-Null
            $tag  = "stable-v16-$ts"
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

# ---------- MAIN ----------
Log "================================================" Cyan
Log "ONEPACK v16 — Jarvis Self-Healing Engine START" Cyan
Log "================================================" Cyan

# Ensure we are at repo root
$RepoRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $RepoRoot

# Quick structure sanity
if (-not (Test-Path "backend") -or -not (Test-Path "frontend") -or -not (Test-Path "docker-compose.sas.yml")) {
    Log "[ERROR] Project structure not correct (backend/frontend/docker-compose.sas.yml missing)." Red
    Log "[ABORT] Self-heal cannot continue. Please restore repository structure." Red
    exit 1
}

$needsHeal = $false

# 1) Pre-check via v13 verifier (if available)
$verifierOk = Run-VerifierV13
if (-not $verifierOk) {
    $needsHeal = $true
}

# 2) Explicit backend health check
$healthOk = Test-BackendHealth
if (-not $healthOk) {
    $needsHeal = $true
}

if (-not $needsHeal) {
    Log "[STATUS] System already healthy — no heal required." Green
}
else {
    Log "[STATUS] Issues detected — starting auto-heal sequence." Yellow

    # Step H1: Ensure Docker engine
    if (-not (Ensure-DockerEngine)) {
        Log "[FATAL] Docker engine cannot be started. Aborting." Red
        exit 1
    }

    # Step H2: Restart + rebuild stack
    Heal-DockerStack

    # Step H3: Re-check health
    $healthAfter = Test-BackendHealth
    if ($healthAfter) {
        Log "[RESULT] Auto-heal SUCCESS — backend healthy after repair." Green
    }
    else {
        Log "[RESULT] Auto-heal INCOMPLETE — backend still not healthy. Check logs & docker status." Red
    }
}

# 3) Auto-backup when system is healthy (unless skipped)
if (-not $SkipBackup) {
    $finalHealth = Test-BackendHealth
    if ($finalHealth) {
        Auto-Backup-WithV15B -Reason "Jarvis v16 post-heal snapshot"
    }
    else {
        Log "[BACKUP] Skipped auto-backup because backend health is not OK." Yellow
    }
}
else {
    Log "[BACKUP] SkipBackup flag set — auto-backup disabled for this run." Yellow
}

Log "================================================" Cyan
Log "ONEPACK v16 COMPLETE — see log file: $LogFile" Cyan
Log "================================================" Cyan
Log ""
















