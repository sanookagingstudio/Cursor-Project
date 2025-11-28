# Simple GitHub Setup Script
param(
    [string]$Username = "SanookAgingStudio",
    [string]$RepoName = "sanook-master-v2"
)

Write-Host "`n=== GitHub Setup - Sanook Master V2 ===" -ForegroundColor Cyan
Write-Host ""

# Check Git
Write-Host "[1/5] Checking Git..." -ForegroundColor Yellow
try {
    git --version | Out-Null
    Write-Host "  OK" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: Git not found" -ForegroundColor Red
    exit 1
}

# Initialize Git
Write-Host "[2/5] Initializing Git..." -ForegroundColor Yellow
if (-not (Test-Path ".git")) {
    git init | Out-Null
    git branch -M main | Out-Null
    Write-Host "  OK - Git initialized" -ForegroundColor Green
} else {
    Write-Host "  OK - Already initialized" -ForegroundColor Green
}

# Check remote
Write-Host "[3/5] Checking remote..." -ForegroundColor Yellow
$remote = git remote get-url origin 2>$null
if ($remote) {
    Write-Host "  Remote exists: $remote" -ForegroundColor Yellow
    $change = Read-Host "  Change it? (y/n)"
    if ($change -eq "y") {
        git remote remove origin
    } else {
        Write-Host "  Keeping existing remote" -ForegroundColor Green
        exit 0
    }
}

# Add remote
Write-Host "[4/5] Adding GitHub remote..." -ForegroundColor Yellow
$repoUrl = "https://github.com/$Username/$RepoName.git"
git remote add origin $repoUrl
Write-Host "  OK - Remote added: $repoUrl" -ForegroundColor Green

# Prepare commit
Write-Host "[5/5] Preparing files..." -ForegroundColor Yellow
git add . | Out-Null
$status = git status --porcelain
if ($status) {
    Write-Host "  Files ready to commit" -ForegroundColor Green
    $commit = Read-Host "  Create initial commit? (y/n)"
    if ($commit -eq "y") {
        git commit -m "Initial commit - Sanook Master V2" | Out-Null
        Write-Host "  OK - Initial commit created" -ForegroundColor Green
    }
} else {
    Write-Host "  No changes to commit" -ForegroundColor Yellow
}

Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Create repository on GitHub:" -ForegroundColor Yellow
Write-Host "   https://github.com/new" -ForegroundColor White
Write-Host "   Name: $RepoName" -ForegroundColor White
Write-Host "   Visibility: Private" -ForegroundColor White
Write-Host "   DO NOT initialize with README" -ForegroundColor White
Write-Host ""
Write-Host "2. Push to GitHub:" -ForegroundColor Yellow
Write-Host "   git push -u origin main" -ForegroundColor White
Write-Host ""
Write-Host "3. Test OnePack:" -ForegroundColor Yellow
Write-Host "   .\onepack.ps1 -Action status" -ForegroundColor White
Write-Host ""

