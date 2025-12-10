Write-Host "=== FORCE CUSTOM DNS RESOLVER (NO ADMIN) ===" -ForegroundColor Cyan

$domain = "klgypptqcegupwtdmuepz.supabase.co"

# 1) Try direct DNS resolve normally
Write-Host "[1] Windows DNS resolve..." -ForegroundColor Yellow
try {
    $res = Resolve-DnsName $domain -ErrorAction Stop
    Write-Host "  ✓ Windows DNS OK → $($res.IPAddress)" -ForegroundColor Green
    $ip = $res.IPAddress
}
catch {
    Write-Host "  ✗ Windows DNS FAILED — switching to custom DNS" -ForegroundColor Red

    # 2) Force DNS query to 8.8.8.8 and 1.1.1.1 manually
    $dnsServers = @("8.8.8.8","1.1.1.1")
    $ip = $null

    foreach ($dns in $dnsServers) {
        Write-Host "    → Querying DNS server $dns" -ForegroundColor Yellow
        try {
            $resolved = Resolve-DnsName -Name $domain -Server $dns -ErrorAction Stop
            if ($resolved -and $resolved.IPAddress) {
                $ip = $resolved.IPAddress | Select-Object -First 1
                Write-Host "    ✓ Custom DNS OK → $ip" -ForegroundColor Green
                break
            }
        }
        catch {
            # DNS query failed, try next server
        }
    }

    if (-not $ip) {
        Write-Host "  ✗ ALL DNS FAILED — cannot resolve domain" -ForegroundColor Red
        exit 1
    }
}

# 3) Test HTTPS using resolved IP (bypass DNS entirely)
Write-Host "[3] Testing HTTPS via direct IP bypassing DNS..." -ForegroundColor Yellow
try {
    $url = "https://$ip"
    $r = Invoke-WebRequest -Uri $url -Headers @{ Host = $domain } -UseBasicParsing -TimeoutSec 10
    Write-Host "  ✓ HTTPS OK via direct IP" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ HTTPS FAILED → $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "=== CUSTOM DNS RESOLVER COMPLETE ===" -ForegroundColor Cyan

