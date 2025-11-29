# Deploy Now - One Command
# Run this in Cursor Terminal after vercel login completes
$ErrorActionPreference = "Continue"

Write-Host "Checking Vercel login..." -ForegroundColor Cyan
$whoami = vercel whoami 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Not logged in" -ForegroundColor Red
    Write-Host ""
    Write-Host "Steps:" -ForegroundColor Yellow
    Write-Host "1. Run: vercel login" -ForegroundColor White
    Write-Host "2. Complete authentication in browser" -ForegroundColor White
    Write-Host "3. Run this script again: .\DEPLOY_NOW.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Or use: .\wait-and-deploy.ps1 (auto-wait for login)" -ForegroundColor Cyan
    exit 1
}

Write-Host "Logged in as: $whoami" -ForegroundColor Green

# Get credentials from .env
Write-Host "Reading credentials..." -ForegroundColor Cyan
$env = Get-Content ".env" -Raw
$url = if ($env -match 'VITE_SUPABASE_URL="?([^"\r\n]+)"?') { $matches[1] } else { "" }
$key = if ($env -match 'VITE_SUPABASE_PUBLISHABLE_KEY="?([^"\r\n]+)"?') { $matches[1] } else { "" }

if (!$url -or !$key) {
    Write-Host "Error: Missing credentials in .env" -ForegroundColor Red
    exit 1
}

Write-Host "Credentials found" -ForegroundColor Green

# Link project
if (!(Test-Path ".vercel")) {
    Write-Host "Linking project..." -ForegroundColor Cyan
    vercel link --yes 2>&1 | Out-Null
}

# Set environment variables
Write-Host "Setting environment variables..." -ForegroundColor Cyan
$url | vercel env add VITE_SUPABASE_URL production --yes 2>&1 | Out-Null
$key | vercel env add VITE_SUPABASE_PUBLISHABLE_KEY production --yes 2>&1 | Out-Null

# Deploy
Write-Host "Deploying to production..." -ForegroundColor Cyan
vercel --prod --yes
