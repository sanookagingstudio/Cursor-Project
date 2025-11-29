# Wait for Vercel Login then Deploy
$ErrorActionPreference = "Continue"

Write-Host "Waiting for Vercel login..." -ForegroundColor Cyan
Write-Host "Please complete authentication in browser" -ForegroundColor Yellow
Write-Host ""

$maxAttempts = 60
$attempt = 0

while ($attempt -lt $maxAttempts) {
    $whoami = vercel whoami 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Login successful! Logged in as: $whoami" -ForegroundColor Green
        Write-Host ""
        break
    }
    
    Start-Sleep -Seconds 2
    $attempt++
    Write-Host "Checking... ($attempt/$maxAttempts)" -ForegroundColor Gray
}

if ($attempt -ge $maxAttempts) {
    Write-Host "❌ Login timeout. Please run 'vercel login' manually" -ForegroundColor Red
    exit 1
}

Write-Host "Starting deployment..." -ForegroundColor Cyan
Write-Host ""

# Get credentials
$env = Get-Content ".env" -Raw
$url = if ($env -match 'VITE_SUPABASE_URL="?([^"\r\n]+)"?') { $matches[1] } else { "" }
$key = if ($env -match 'VITE_SUPABASE_PUBLISHABLE_KEY="?([^"\r\n]+)"?') { $matches[1] } else { "" }

if (!$url -or !$key) {
    Write-Host "Error: Missing credentials" -ForegroundColor Red
    exit 1
}

# Link project
if (!(Test-Path ".vercel")) {
    Write-Host "Linking project..." -ForegroundColor Cyan
    vercel link --yes 2>&1 | Out-Null
}

# Set env vars
Write-Host "Setting environment variables..." -ForegroundColor Cyan
$url | vercel env add VITE_SUPABASE_URL production --yes 2>&1 | Out-Null
$key | vercel env add VITE_SUPABASE_PUBLISHABLE_KEY production --yes 2>&1 | Out-Null

# Deploy
Write-Host "Deploying..." -ForegroundColor Cyan
vercel --prod --yes

