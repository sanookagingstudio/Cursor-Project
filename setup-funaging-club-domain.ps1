Param(
    [string]$Domain = "funaging.club"
)

Write-Host "=== FunAging / SAS — Vercel Domain Helper ===" -ForegroundColor Cyan
Write-Host "Target domain: $Domain" -ForegroundColor Yellow
Write-Host ""

Write-Host "[1/4] Checking Vercel CLI..." -ForegroundColor Yellow
$vercelCmd = Get-Command vercel -ErrorAction SilentlyContinue
if (-not $vercelCmd) {
    Write-Error "Vercel CLI is not installed. Install with: npm i -g vercel"
    exit 1
}
Write-Host ""
Write-Host "Vercel CLI OK" -ForegroundColor Green

Write-Host "[2/4] Checking link..." -ForegroundColor Yellow
if (-not (Test-Path ".vercel")) {
    vercel link
} else {
    Write-Host ".vercel exists" -ForegroundColor Green
}
Write-Host ""

Write-Host "[3/4] Detecting project name..." -ForegroundColor Yellow
$projectJsonPath = ".vercel\project.json"
$projectName = $null

if (Test-Path $projectJsonPath) {
    try {
        $projectJson = Get-Content $projectJsonPath -Raw | ConvertFrom-Json
        $projectName = $projectJson.name
    } catch {}
}

Write-Host ""
Write-Host "[4/4] Adding domain..." -ForegroundColor Yellow

if ($projectName) {
    vercel domains add $Domain $projectName
} else {
    vercel domains add $Domain
}

vercel domains inspect $Domain

Write-Host ""
Write-Host "DONE" -ForegroundColor Green
