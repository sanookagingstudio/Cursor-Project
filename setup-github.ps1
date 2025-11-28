# Setup GitHub Repository for Sanook Master V2
# Script สำหรับตั้งค่า GitHub repository ใหม่

param(
    [string]$GitHubUsername = "",
    [string]$RepositoryName = "sanook-master-v2"
)

# Colors
function Write-Header {
    param([string]$Message)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Step {
    param([int]$Step, [string]$Message)
    Write-Host "`n[Step $Step] $Message" -ForegroundColor Yellow
}

# Main
Write-Header "🚀 GitHub Repository Setup - Sanook Master V2"

# Step 1: Check Git
Write-Step 1 "Checking Git installation..."
try {
    $gitVersion = git --version
    Write-Success "Git installed: $gitVersion"
} catch {
    Write-Error "Git is not installed. Please install Git first."
    exit 1
}

# Step 2: Initialize Git (if not already)
Write-Step 2 "Initializing Git repository..."
if (-not (Test-Path ".git")) {
    git init
    git branch -M main
    Write-Success "Git repository initialized."
} else {
    Write-Info "Git repository already initialized."
}

# Step 3: Check if remote exists
Write-Step 3 "Checking existing remote..."
$existingRemote = git remote get-url origin 2>$null
if ($existingRemote) {
    Write-Warning "Remote already exists: $existingRemote"
    $overwrite = Read-Host "Do you want to change it? (y/n)"
    if ($overwrite -eq "y") {
        git remote remove origin
        Write-Success "Old remote removed."
    } else {
        Write-Info "Keeping existing remote."
        exit 0
    }
}

# Step 4: Get GitHub username
Write-Step 4 "Getting GitHub username..."
if ([string]::IsNullOrEmpty($GitHubUsername)) {
    $GitHubUsername = Read-Host "Enter your GitHub username"
}

if ([string]::IsNullOrEmpty($GitHubUsername)) {
    Write-Error "GitHub username is required."
    exit 1
}

Write-Success "GitHub username: $GitHubUsername"

# Step 5: Repository name
Write-Step 5 "Setting repository name..."
Write-Info "Repository name: $RepositoryName"
$confirm = Read-Host "Use this name? (y/n)"
if ($confirm -ne "y") {
    $RepositoryName = Read-Host "Enter repository name"
}

# Step 6: Create GitHub repository URL
$GitHubRepo = "https://github.com/$GitHubUsername/$RepositoryName.git"
Write-Info "Repository URL: $GitHubRepo"

# Step 7: Add remote
Write-Step 6 "Adding GitHub remote..."
git remote add origin $GitHubRepo
Write-Success "Remote added: $GitHubRepo"

# Step 8: Create .gitignore if not exists
Write-Step 7 "Checking .gitignore..."
if (-not (Test-Path ".gitignore")) {
    Write-Warning ".gitignore not found. Creating default..."
    # Basic .gitignore will be created
}

# Step 9: Initial commit
Write-Step 8 "Preparing initial commit..."
git add .
$hasChanges = git status --porcelain
if ($hasChanges) {
    Write-Info "Files to commit:"
    git status --short
    
    $commit = Read-Host "`nCreate initial commit? (y/n)"
    if ($commit -eq "y") {
        git commit -m "Initial commit - Sanook Master V2"
        Write-Success "Initial commit created."
    }
} else {
    Write-Info "No changes to commit."
}

# Step 10: Instructions
Write-Header "📋 Next Steps"

Write-Host "1. Create repository on GitHub:" -ForegroundColor Yellow
Write-Host "   Go to: https://github.com/new" -ForegroundColor White
Write-Host "   Repository name: $RepositoryName" -ForegroundColor White
Write-Host "   Visibility: Private (recommended)" -ForegroundColor White
Write-Host "   DO NOT initialize with README, .gitignore, or license" -ForegroundColor White

Write-Host "`n2. Push to GitHub:" -ForegroundColor Yellow
Write-Host "   git push -u origin main" -ForegroundColor White

Write-Host "`n3. Update OnePack script:" -ForegroundColor Yellow
Write-Host "   Edit onepack.ps1 and set:" -ForegroundColor White
Write-Host "   `$GitHubRepo = `"$GitHubRepo`"" -ForegroundColor White

Write-Host "`n4. Test OnePack:" -ForegroundColor Yellow
Write-Host "   .\onepack.ps1 -Action status" -ForegroundColor White

Write-Header "✅ Setup Complete!"

Write-Info "Repository URL: $GitHubRepo"
Write-Info "Branch: main"
Write-Info "You can now use OnePack script for backup/restore."

