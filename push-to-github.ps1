# Push to GitHub - Final Step
param(
    [Parameter(Mandatory=$true)]
    [string]$RepositoryName
)

$Username = "SanookAgingStudio"
$RemoteUrl = "https://github.com/$Username/$RepositoryName.git"

Write-Host "`n=== Final Setup - Push to GitHub ===" -ForegroundColor Cyan
Write-Host "Repository: $RepositoryName" -ForegroundColor Yellow
Write-Host "URL: $RemoteUrl" -ForegroundColor Yellow
Write-Host ""

# Update remote
Write-Host "[1/3] Updating remote..." -ForegroundColor Yellow
git remote remove origin 2>$null
git remote add origin $RemoteUrl
Write-Host "  ✅ Remote updated" -ForegroundColor Green

# Verify remote
Write-Host "[2/3] Verifying remote..." -ForegroundColor Yellow
git remote -v
Write-Host "  ✅ Remote verified" -ForegroundColor Green

# Push
Write-Host "[3/3] Pushing to GitHub..." -ForegroundColor Yellow
Write-Host "  This may require authentication..." -ForegroundColor Cyan
Write-Host ""

try {
    git push -u origin main
    Write-Host "`n✅ SUCCESS! Code pushed to GitHub!" -ForegroundColor Green
    Write-Host "`nRepository URL: $RemoteUrl" -ForegroundColor Cyan
    Write-Host "`nYou can now:" -ForegroundColor Yellow
    Write-Host "  - View on GitHub: $RemoteUrl" -ForegroundColor White
    Write-Host "  - Use OnePack: .\onepack.ps1 -Action backup" -ForegroundColor White
} catch {
    Write-Host "`n⚠️  Push failed. Possible reasons:" -ForegroundColor Yellow
    Write-Host "  1. Repository not created on GitHub yet" -ForegroundColor White
    Write-Host "  2. Authentication required (use Personal Access Token)" -ForegroundColor White
    Write-Host "  3. Repository name mismatch" -ForegroundColor White
    Write-Host "`nTo fix:" -ForegroundColor Yellow
    Write-Host "  1. Create repository on GitHub: https://github.com/new" -ForegroundColor White
    Write-Host "  2. Name: $RepositoryName" -ForegroundColor White
    Write-Host "  3. Run this script again" -ForegroundColor White
}

