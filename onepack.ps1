# OnePack - GitHub Backup & Update Automation Script
# สำหรับ Windows PowerShell

param(
    [string]$Action = "backup",
    [string]$Message = "Auto backup - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
)

# Configuration
# Auto-detect GitHub repo from git remote, or set manually
$ProjectRoot = $PSScriptRoot
$Branch = "main"

# Try to get GitHub repo from git remote
function Get-GitHubRepo {
    $remote = git remote get-url origin 2>$null
    if ($remote) {
        # Convert SSH to HTTPS if needed
        if ($remote -match "git@github\.com:(.+)/(.+)\.git") {
            return "https://github.com/$($matches[1])/$($matches[2]).git"
        }
        return $remote
    }
    return $null
}

$GitHubRepo = Get-GitHubRepo
if (-not $GitHubRepo) {
    Write-Warning "GitHub repository not detected. Please run setup-github.ps1 first."
    Write-Warning "Or manually set `$GitHubRepo in this script."
}

# Colors for output
function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Yellow
}

# Check if git is initialized
function Test-GitInitialized {
    if (-not (Test-Path "$ProjectRoot\.git")) {
        Write-Warning "Git repository not initialized. Initializing..."
        Set-Location $ProjectRoot
        git init
        git branch -M $Branch
        Write-Success "Git repository initialized."
    }
}

# Check if remote is set
function Test-GitRemote {
    $remote = git remote get-url origin 2>$null
    if (-not $remote) {
        if ($GitHubRepo) {
            Write-Warning "Git remote not set. Setting remote..."
            git remote add origin $GitHubRepo
            Write-Success "Git remote set to: $GitHubRepo"
        } else {
            Write-Error "GitHub repository URL not configured."
            Write-Info "Please run: .\setup-github.ps1"
            Write-Info "Or manually set `$GitHubRepo in onepack.ps1"
            exit 1
        }
    } else {
        # Update GitHubRepo from actual remote
        $script:GitHubRepo = Get-GitHubRepo
    }
}

# Backup function
function Backup-ToGitHub {
    Write-Info "=== OnePack Backup ==="
    Write-Info "Starting backup process..."
    
    Set-Location $ProjectRoot
    
    # Check git status
    $status = git status --porcelain
    if (-not $status) {
        Write-Success "No changes to commit."
        return
    }
    
    # Add all changes
    Write-Info "Adding changes..."
    git add .
    
    # Commit
    Write-Info "Committing changes..."
    git commit -m $Message
    
    # Push to GitHub
    Write-Info "Pushing to GitHub..."
    try {
        git push origin $Branch
        Write-Success "✅ Backup completed successfully!"
        Write-Success "📦 Changes pushed to: $GitHubRepo"
    } catch {
        Write-Error "❌ Failed to push to GitHub: $_"
        Write-Warning "💡 You may need to set up GitHub credentials or SSH keys."
    }
}

# Restore function
function Restore-FromGitHub {
    Write-Info "=== OnePack Restore ==="
    Write-Info "Restoring from GitHub..."
    
    Set-Location $ProjectRoot
    
    # Pull latest changes
    Write-Info "Pulling latest changes from GitHub..."
    try {
        git pull origin $Branch
        Write-Success "✅ Restore completed successfully!"
        Write-Success "📦 Latest changes pulled from: $GitHubRepo"
    } catch {
        Write-Error "❌ Failed to pull from GitHub: $_"
    }
}

# Status function
function Show-Status {
    Write-Info "=== OnePack Status ==="
    
    Set-Location $ProjectRoot
    
    # Git status
    Write-Info "Git Status:"
    git status
    
    # Last commit
    Write-Info "`nLast Commit:"
    git log -1 --pretty=format:"%h - %an, %ar : %s"
    
    # Remote info
    Write-Info "`nRemote Repository:"
    git remote -v
}

# Main execution
function Main {
    Write-Info "🚀 OnePack - GitHub Backup & Update Automation"
    Write-Info "Project Root: $ProjectRoot"
    Write-Info "Action: $Action"
    
    # Try to detect GitHub repo
    if (-not $GitHubRepo) {
        $GitHubRepo = Get-GitHubRepo
    }
    
    if ($GitHubRepo) {
        Write-Info "Repository: $GitHubRepo"
    }
    Write-Info ""
    
    # Initialize git if needed
    Test-GitInitialized
    Test-GitRemote
    
    switch ($Action.ToLower()) {
        "backup" {
            Backup-ToGitHub
        }
        "restore" {
            Restore-FromGitHub
        }
        "status" {
            Show-Status
        }
        default {
            Write-Error "Unknown action: $Action"
            Write-Info "Available actions: backup, restore, status"
            Write-Info ""
            Write-Info "Usage:"
            Write-Info "  .\onepack.ps1 -Action backup -Message 'Your commit message'"
            Write-Info "  .\onepack.ps1 -Action restore"
            Write-Info "  .\onepack.ps1 -Action status"
        }
    }
}

# Run main function
Main

