#!/bin/bash
# OnePack - GitHub Backup & Update Automation Script
# สำหรับ Linux/Mac

ACTION="${1:-backup}"
MESSAGE="${2:-Auto backup - $(date '+%Y-%m-%d %H:%M:%S')}"

# Configuration
GITHUB_REPO="your-github-repo-url"  # เปลี่ยนเป็น URL ของ GitHub repo
BRANCH="main"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Functions
info() {
    echo -e "${CYAN}==> $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if git is initialized
check_git_init() {
    if [ ! -d "$PROJECT_ROOT/.git" ]; then
        warning "Git repository not initialized. Initializing..."
        cd "$PROJECT_ROOT"
        git init
        git branch -M "$BRANCH"
        success "Git repository initialized."
    fi
}

# Check if remote is set
check_git_remote() {
    if ! git remote get-url origin &>/dev/null; then
        warning "Git remote not set. Setting remote..."
        git remote add origin "$GITHUB_REPO"
        success "Git remote set to: $GITHUB_REPO"
    fi
}

# Backup function
backup() {
    info "=== OnePack Backup ==="
    info "Starting backup process..."
    
    cd "$PROJECT_ROOT"
    
    # Check if there are changes
    if [ -z "$(git status --porcelain)" ]; then
        success "No changes to commit."
        return
    fi
    
    # Add all changes
    info "Adding changes..."
    git add .
    
    # Commit
    info "Committing changes..."
    git commit -m "$MESSAGE"
    
    # Push to GitHub
    info "Pushing to GitHub..."
    if git push origin "$BRANCH"; then
        success "Backup completed successfully!"
        success "📦 Changes pushed to: $GITHUB_REPO"
    else
        error "Failed to push to GitHub."
        warning "💡 You may need to set up GitHub credentials or SSH keys."
    fi
}

# Restore function
restore() {
    info "=== OnePack Restore ==="
    info "Restoring from GitHub..."
    
    cd "$PROJECT_ROOT"
    
    # Pull latest changes
    info "Pulling latest changes from GitHub..."
    if git pull origin "$BRANCH"; then
        success "Restore completed successfully!"
        success "📦 Latest changes pulled from: $GITHUB_REPO"
    else
        error "Failed to pull from GitHub."
    fi
}

# Status function
status() {
    info "=== OnePack Status ==="
    
    cd "$PROJECT_ROOT"
    
    # Git status
    info "Git Status:"
    git status
    
    # Last commit
    echo ""
    info "Last Commit:"
    git log -1 --pretty=format:"%h - %an, %ar : %s"
    
    # Remote info
    echo ""
    info "Remote Repository:"
    git remote -v
}

# Main execution
main() {
    info "🚀 OnePack - GitHub Backup & Update Automation"
    info "Project Root: $PROJECT_ROOT"
    info "Action: $ACTION"
    echo ""
    
    # Initialize git if needed
    check_git_init
    check_git_remote
    
    case "$ACTION" in
        backup)
            backup
            ;;
        restore)
            restore
            ;;
        status)
            status
            ;;
        *)
            error "Unknown action: $ACTION"
            info "Available actions: backup, restore, status"
            echo ""
            info "Usage:"
            info "  ./onepack.sh backup 'Your commit message'"
            info "  ./onepack.sh restore"
            info "  ./onepack.sh status"
            exit 1
            ;;
    esac
}

# Run main function
main

