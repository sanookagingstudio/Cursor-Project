Write-Host "=== RUN TESTS (BASIC HEALTH) ==="
try {
  $resp = Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -UseBasicParsing -TimeoutSec 5
  Write-Host "Backend /health status: $($resp.StatusCode)"
} catch {
  Write-Host "Backend /health check failed"
}
try {
  $resp2 = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
  Write-Host "Frontend / status: $($resp2.StatusCode)"
} catch {
  Write-Host "Frontend / check failed"
}
