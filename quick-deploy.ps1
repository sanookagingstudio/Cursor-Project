# Quick Deploy to Production
$ErrorActionPreference = "SilentlyContinue"

# Read credentials
$env = Get-Content ".env" -Raw
$url = ([regex]'VITE_SUPABASE_URL="?([^"]+)"?').Match($env).Groups[1].Value
$key = ([regex]'VITE_SUPABASE_PUBLISHABLE_KEY="?([^"]+)"?').Match($env).Groups[1].Value

# Setup Vercel
if (-not (Test-Path ".vercel")) { vercel link --yes | Out-Null }
$url | vercel env add VITE_SUPABASE_URL production --yes | Out-Null
$key | vercel env add VITE_SUPABASE_PUBLISHABLE_KEY production --yes | Out-Null

# Deploy
vercel --prod --yes

