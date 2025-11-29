# Check Vercel Login Status
$whoami = vercel whoami 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Logged in as: $whoami" -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ Not logged in" -ForegroundColor Red
    Write-Host "Run: vercel login" -ForegroundColor Yellow
    exit 1
}

