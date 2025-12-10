Write-Host "== SUPABASE DEEP SCAN START ==" -ForegroundColor Cyan

# ===== CONFIG =====
$SUPABASE_URL  = "https://klgypptqcegupwtdmuepz.supabase.co"
$SERVICE_KEY   = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtsZ3lwdHFjZWd1cHd0ZG11ZXB6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MzExNjUzOSwiZXhwIjoyMDc4NjkyNTM5fQ.pQvClFNL6_FpfO_xewpo6qRDiKl8IoVSlu3NOM7ZQ8o"
# ==================

# Force TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "`n=== TEST 1: BASE URL ===" -ForegroundColor Yellow
try {
    $res1 = Invoke-WebRequest -Uri $SUPABASE_URL -Method GET -TimeoutSec 10
    Write-Host "✔ BASE URL OK" -ForegroundColor Green
}
catch {
    Write-Host "❌ BASE URL FAIL" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host "`n=== TEST 2: AUTH HEALTH ===" -ForegroundColor Yellow
try {
    $res2 = Invoke-WebRequest `
        -Uri ($SUPABASE_URL + "/auth/v1/health") `
        -Headers @{ apikey=$SERVICE_KEY; Authorization="Bearer $SERVICE_KEY" } `
        -TimeoutSec 10
    Write-Host "✔ AUTH HEALTH OK" -ForegroundColor Green
}
catch {
    Write-Host "❌ AUTH HEALTH FAIL" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host "`n=== TEST 3: ADMIN LIST USERS ===" -ForegroundColor Yellow
try {
    $res3 = Invoke-WebRequest `
        -Uri ($SUPABASE_URL + "/auth/v1/admin/users") `
        -Headers @{ apikey=$SERVICE_KEY; Authorization="Bearer $SERVICE_KEY" } `
        -TimeoutSec 10
    Write-Host "✔ ADMIN USERS OK" -ForegroundColor Green
}
catch {
    Write-Host "❌ ADMIN USERS FAIL" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host "`n=== TEST 4: SERVICE ROLE KEY VALIDATION ===" -ForegroundColor Yellow
try {
    $res4 = Invoke-WebRequest `
        -Uri ($SUPABASE_URL + "/auth/v1/admin/users") `
        -Method OPTIONS `
        -Headers @{ apikey=$SERVICE_KEY; Authorization="Bearer $SERVICE_KEY" } `
        -TimeoutSec 10
    Write-Host "✔ SERVICE ROLE KEY VALID" -ForegroundColor Green
}
catch {
    Write-Host "❌ SERVICE ROLE KEY INVALID" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host "`n== SUPABASE DEEP SCAN COMPLETE ==" -ForegroundColor Cyan
