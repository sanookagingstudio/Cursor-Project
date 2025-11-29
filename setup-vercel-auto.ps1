# Auto Setup Vercel Production
$ErrorActionPreference = "Continue"

# Read .env
$envContent = Get-Content ".env"
$supabaseUrl = ""
$supabaseKey = ""

foreach ($line in $envContent) {
    if ($line -match '^VITE_SUPABASE_URL="?(.+?)"?$') {
        $supabaseUrl = $matches[1].Trim('"')
    }
    if ($line -match '^VITE_SUPABASE_PUBLISHABLE_KEY="?(.+?)"?$') {
        $supabaseKey = $matches[1].Trim('"')
    }
}

if ([string]::IsNullOrEmpty($supabaseUrl) -or [string]::IsNullOrEmpty($supabaseKey)) {
    Write-Host "Error: Missing Supabase credentials in .env"
    exit 1
}

# Check login
$whoami = vercel whoami 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Please run: vercel login"
    exit 1
}

# Link project
if (-not (Test-Path ".vercel")) {
    vercel link --yes 2>&1 | Out-Null
}

# Add env vars
$supabaseUrl | vercel env add VITE_SUPABASE_URL production --yes 2>&1 | Out-Null
$supabaseKey | vercel env add VITE_SUPABASE_PUBLISHABLE_KEY production --yes 2>&1 | Out-Null

# Deploy
vercel --prod --yes

