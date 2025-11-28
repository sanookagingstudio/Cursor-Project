# Update Git Remote URL
param(
    [Parameter(Mandatory=$true)]
    [string]$RepositoryName
)

$Username = "SanookAgingStudio"
$NewRemote = "https://github.com/$Username/$RepositoryName.git"

Write-Host "`n=== Updating Git Remote ===" -ForegroundColor Cyan
Write-Host "Repository: $RepositoryName" -ForegroundColor Yellow
Write-Host "New URL: $NewRemote" -ForegroundColor Yellow
Write-Host ""

# Remove old remote
git remote remove origin 2>$null

# Add new remote
git remote add origin $NewRemote

Write-Host "✅ Remote updated successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next: Push to GitHub" -ForegroundColor Cyan
Write-Host "  git push -u origin main" -ForegroundColor White

