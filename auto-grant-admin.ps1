# AUTO-GRANT-ADMIN PowerShell Script
# Runs the Node.js script to auto-grant admin privileges

Write-Host "🚀 AUTO-GRANT-ADMIN Script Starting..." -ForegroundColor Cyan
Write-Host ""

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js is not installed or not in PATH" -ForegroundColor Red
    Write-Host "   Please install Node.js from https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "⚠️  .env file not found" -ForegroundColor Yellow
    Write-Host "   Creating .env file template..." -ForegroundColor Yellow
    @"
VITE_SUPABASE_URL=your_supabase_url_here
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
"@ | Out-File -FilePath ".env" -Encoding UTF8
    Write-Host "   ✅ Created .env file. Please fill in your Supabase credentials." -ForegroundColor Yellow
    Write-Host "   Then run this script again." -ForegroundColor Yellow
    exit 1
}

# Check if supabase/.env.local exists
if (-not (Test-Path "supabase\.env.local")) {
    Write-Host "⚠️  supabase/.env.local not found" -ForegroundColor Yellow
    Write-Host "   Creating supabase/.env.local file template..." -ForegroundColor Yellow
    
    # Create supabase directory if it doesn't exist
    if (-not (Test-Path "supabase")) {
        New-Item -ItemType Directory -Path "supabase" | Out-Null
    }
    
    @"
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
"@ | Out-File -FilePath "supabase\.env.local" -Encoding UTF8
    Write-Host "   ✅ Created supabase/.env.local file." -ForegroundColor Yellow
    Write-Host "   Please add your SUPABASE_SERVICE_ROLE_KEY from Supabase dashboard:" -ForegroundColor Yellow
    Write-Host "   Settings > API > service_role key" -ForegroundColor Yellow
    Write-Host "   Then run this script again." -ForegroundColor Yellow
    exit 1
}

# Install dotenv if not present
Write-Host "📦 Checking dependencies..." -ForegroundColor Cyan
$dotenvInstalled = npm list dotenv 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "   Installing dotenv..." -ForegroundColor Yellow
    npm install dotenv --save-dev
}

# Run the script
Write-Host ""
Write-Host "▶️  Running auto-grant-admin script..." -ForegroundColor Cyan
Write-Host ""

node scripts/auto-grant-admin.js

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ AUTO-GRANT-ADMIN completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Sign in at http://localhost:8080/admin/signin" -ForegroundColor White
    Write-Host "   2. Use email: sanookagingstudio@gmail.com" -ForegroundColor White
    Write-Host "   3. Navigate to /admin/dashboard" -ForegroundColor White
    Write-Host "   4. Verify you have full admin access" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "❌ AUTO-GRANT-ADMIN failed. Please check the error messages above." -ForegroundColor Red
    exit 1
}
















