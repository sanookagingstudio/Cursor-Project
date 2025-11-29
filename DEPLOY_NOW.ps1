# Deploy Now - One Command
$ErrorActionPreference = "SilentlyContinue"

# Get credentials from .env
$env = Get-Content ".env" -Raw
$url = if ($env -match 'VITE_SUPABASE_URL="?([^"\r\n]+)"?') { $matches[1] } else { "" }
$key = if ($env -match 'VITE_SUPABASE_PUBLISHABLE_KEY="?([^"\r\n]+)"?') { $matches[1] } else { "" }

if (!$url -or !$key) {
    Write-Host "Error: Missing credentials" -ForegroundColor Red
    exit 1
}

# Check Vercel login
vercel whoami | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Run: vercel login" -ForegroundColor Yellow
    exit 1
}

# Setup
if (!(Test-Path ".vercel")) { vercel link --yes | Out-Null }
$url | vercel env add VITE_SUPABASE_URL production --yes | Out-Null
$key | vercel env add VITE_SUPABASE_PUBLISHABLE_KEY production --yes | Out-Null

# Deploy
Write-Host "Deploying..." -ForegroundColor Cyan
vercel --prod --yes

