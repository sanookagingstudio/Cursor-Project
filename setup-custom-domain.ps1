# Setup Custom Domain: funaging.studio
$ErrorActionPreference = "Continue"

Write-Host "🌐 Setting up custom domain: funaging.studio" -ForegroundColor Cyan
Write-Host ""

# Check login
$whoami = vercel whoami 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Not logged in. Run: vercel login" -ForegroundColor Red
    exit 1
}

# Add domain
Write-Host "Adding domain..." -ForegroundColor Yellow
vercel domains add funaging.studio

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Domain added!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Check DNS configuration:" -ForegroundColor White
    vercel domains inspect funaging.studio
    Write-Host ""
    Write-Host "2. Update DNS records at your domain registrar" -ForegroundColor White
    Write-Host "3. Wait for DNS propagation (5-30 minutes)" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "⚠️  Domain may already exist or need manual setup" -ForegroundColor Yellow
    Write-Host "Check: vercel domains ls" -ForegroundColor Gray
}

