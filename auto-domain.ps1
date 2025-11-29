# Auto Setup Domain
$ErrorActionPreference = "Continue"

Write-Host "Checking domain status..." -ForegroundColor Cyan
$status = vercel domains inspect funaging.studio 2>&1

if ($status -match "configured properly" -or $status -match "ready") {
    Write-Host "Domain is ready!" -ForegroundColor Green
} else {
    Write-Host "Domain needs DNS configuration" -ForegroundColor Yellow
    Write-Host "Add A record: funaging.studio -> 76.76.21.21" -ForegroundColor White
    Write-Host "Or change nameservers to:" -ForegroundColor White
    Write-Host "  ns1.vercel-dns.com" -ForegroundColor Gray
    Write-Host "  ns2.vercel-dns.com" -ForegroundColor Gray
}

# Verify
vercel domains verify funaging.studio

