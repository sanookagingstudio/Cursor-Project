Write-Host "=== FORCE DNS START ===" -ForegroundColor Cyan

# Set DNS for all active adapters → Google DNS + Cloudflare DNS
Write-Host "[1] Setting DNS on all active network adapters..." -ForegroundColor Yellow
$adapters = Get-DnsClientServerAddress -AddressFamily IPv4

foreach ($ad in $adapters) {
    try {
        Set-DnsClientServerAddress `
            -InterfaceIndex $ad.InterfaceIndex `
            -ServerAddresses ("8.8.8.8","1.1.1.1") -ErrorAction Stop

        Write-Host "  ✓ Adapter $($ad.InterfaceAlias) updated" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ Failed to update adapter $($ad.InterfaceAlias)" -ForegroundColor Red
    }
}

# 2) Reset WinHTTP proxy DNS
Write-Host "[2] Resetting WinHTTP proxy..." -ForegroundColor Yellow
netsh winhttp reset proxy

# 3) Flush DNS
Write-Host "[3] Flushing DNS cache..." -ForegroundColor Yellow
ipconfig /flushdns

# 4) Reset Winsock
Write-Host "[4] Resetting Winsock..." -ForegroundColor Yellow
netsh winsock reset

# 5) Reset IP stack
Write-Host "[5] Resetting IP stack..." -ForegroundColor Yellow
netsh int ip reset

# 6) Test DNS resolve
$domain = "klgypptqcegupwtdmuepz.supabase.co"
Write-Host "[6] Testing DNS resolve for $domain ..." -ForegroundColor Yellow
try {
    $dns = Resolve-DnsName $domain -ErrorAction Stop
    Write-Host "  ✓ DNS OK → $($dns.IPAddress)" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ DNS FAILED → Cannot resolve domain" -ForegroundColor Red
}

# 7) Test HTTPS connectivity
Write-Host "[7] Testing HTTPS connectivity..." -ForegroundColor Yellow
try {
    $res = Invoke-WebRequest -Uri "https://$domain" -UseBasicParsing -TimeoutSec 10
    Write-Host "  ✓ HTTPS OK" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ HTTPS FAILED → $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "=== FORCE DNS COMPLETE ===" -ForegroundColor Cyan











