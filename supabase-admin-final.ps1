Write-Host "== SUPABASE ADMIN INIT ==" -ForegroundColor Cyan

$env:SUPABASE_URL         = "https://klgypptqcegupwtdmuepz.supabase.co"
$env:SUPABASE_SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtsZ3lwdHFjZWd1cHd0ZG11ZXB6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MzExNjUzOSwiZXhwIjoyMDc4NjkyNTM5fQ.pQvClFNL6_FpfO_xewpo6qRDiKl8IoVSlu3NOM7ZQ8o"
$env:ADMIN_EMAIL          = "sanookagingstudio@gmail.com"
$env:ADMIN_PASSWORD       = "Ake@8814883"

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js not installed" -ForegroundColor Red
    exit 1
}

Write-Host "Running Supabase Admin Init..." -ForegroundColor Yellow

node scripts/auto-init-admin.js

Write-Host "== DONE ==" -ForegroundColor Green
