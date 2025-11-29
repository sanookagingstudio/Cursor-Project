# Deploy to Production - Auto Setup
$ErrorActionPreference = "Continue"

# Read .env
$envContent = Get-Content ".env"
$supabaseUrl = ""
$supabaseKey = ""

foreach ($line in $envContent) {
    if ($line -match '^VITE_SUPABASE_URL="?(.+?)"?$') {
        $supabaseUrl = $matches[1]
    }
    if ($line -match '^VITE_SUPABASE_PUBLISHABLE_KEY="?(.+?)"?$') {
        $supabaseKey = $matches[1]
    }
}

# Check if logged in
$whoami = vercel whoami 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Please login to Vercel first: vercel login"
    exit 1
}

# Link project if not linked
if (-not (Test-Path ".vercel")) {
    vercel link --yes
}

# Set environment variables
$supabaseUrl | vercel env add VITE_SUPABASE_URL production --yes
$supabaseKey | vercel env add VITE_SUPABASE_PUBLISHABLE_KEY production --yes

# Deploy
vercel --prod --yes

