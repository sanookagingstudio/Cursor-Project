# Deploy to Production

## Quick Deploy

1. Login to Vercel:
```powershell
vercel login
```

2. Run deploy script:
```powershell
.\DEPLOY_NOW.ps1
```

## Manual Steps

1. Link project (if not linked):
```powershell
vercel link --yes
```

2. Set environment variables:
```powershell
# Get values from .env
$url = (Get-Content .env | Select-String "VITE_SUPABASE_URL").ToString().Split("=")[1].Trim('"')
$key = (Get-Content .env | Select-String "VITE_SUPABASE_PUBLISHABLE_KEY").ToString().Split("=")[1].Trim('"')

# Add to Vercel
$url | vercel env add VITE_SUPABASE_URL production --yes
$key | vercel env add VITE_SUPABASE_PUBLISHABLE_KEY production --yes
```

3. Deploy:
```powershell
vercel --prod --yes
```

