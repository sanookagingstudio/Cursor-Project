# Fully Automated Deploy - Run this after vercel login completes
$ErrorActionPreference = "Continue"

Write-Host "🚀 Auto Deploy Script" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Login
Write-Host "Step 1: Checking Vercel login..." -ForegroundColor Yellow
$whoami = vercel whoami 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Not logged in" -ForegroundColor Red
    Write-Host ""
    Write-Host "Quick fix:" -ForegroundColor Yellow
    Write-Host "1. Complete 'vercel login' in the other terminal" -ForegroundColor White
    Write-Host "2. Run this script again: .\AUTO_DEPLOY.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Or use: .\wait-and-deploy.ps1 (auto-waits for login)" -ForegroundColor Cyan
    exit 1
} else {
    Write-Host "✅ Logged in as: $whoami" -ForegroundColor Green
}

Write-Host ""

# Step 2: Get credentials
Write-Host "Step 2: Reading credentials..." -ForegroundColor Yellow
$env = Get-Content ".env" -Raw
$url = if ($env -match 'VITE_SUPABASE_URL="?([^"\r\n]+)"?') { $matches[1] } else { "" }
$key = if ($env -match 'VITE_SUPABASE_PUBLISHABLE_KEY="?([^"\r\n]+)"?') { $matches[1] } else { "" }

if (!$url -or !$key) {
    Write-Host "❌ Missing credentials in .env" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Credentials found" -ForegroundColor Green
Write-Host ""

# Step 3: Link project
Write-Host "Step 3: Linking project..." -ForegroundColor Yellow
if (!(Test-Path ".vercel")) {
    vercel link --yes 2>&1 | Out-Null
    Write-Host "✅ Project linked" -ForegroundColor Green
} else {
    Write-Host "✅ Project already linked" -ForegroundColor Green
}
Write-Host ""

# Step 4: Set environment variables
Write-Host "Step 4: Setting environment variables..." -ForegroundColor Yellow
$url | vercel env add VITE_SUPABASE_URL production --yes 2>&1 | Out-Null
$key | vercel env add VITE_SUPABASE_PUBLISHABLE_KEY production --yes 2>&1 | Out-Null
Write-Host "✅ Environment variables set" -ForegroundColor Green
Write-Host ""

# Step 5: Deploy
Write-Host "Step 5: Deploying to production..." -ForegroundColor Yellow
Write-Host ""
vercel --prod --yes

Write-Host ""
Write-Host "✅ Deployment complete!" -ForegroundColor Green
