Param(
    [int]$Port = 8000
)

$ErrorActionPreference = "Stop"

Write-Host "== SAS Backend – AUTH + RUNNER FULL v2.0 (Windows) ==" -ForegroundColor Cyan

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

if (Test-Path ".\.venv") {
    Write-Host "Activating .venv..." -ForegroundColor Yellow
    .\.venv\Scripts\Activate.ps1
} else {
    Write-Host "No .venv found, using global Python..." -ForegroundColor DarkYellow
}

if (-not $Env:AUTH_ADMIN_EMAIL) { $Env:AUTH_ADMIN_EMAIL = "admin@example.com" }
if (-not $Env:AUTH_ADMIN_PASSWORD) { $Env:AUTH_ADMIN_PASSWORD = "Admin1234!" }
if (-not $Env:AUTH_SECRET_KEY) { $Env:AUTH_SECRET_KEY = "CHANGE_ME_AUTH_SECRET_KEY" }

Write-Host "[*] Bootstrapping auth (auto-admin + token)..." -ForegroundColor Cyan
python bootstrap_auth.py

Write-Host "[*] Starting backend on port $Port ..." -ForegroundColor Green
python -m uvicorn app.main:app --host 0.0.0.0 --port $Port --reload
