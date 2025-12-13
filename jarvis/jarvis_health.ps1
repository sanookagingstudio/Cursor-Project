Write-Host "=== JARVIS HEALTH CHECK ==="
$now = Get-Date
Write-Host "Timestamp : $now"

$targets = @(
  "http://127.0.0.1:8000/health",
  "http://127.0.0.1:8000/trip/ping",
  "http://127.0.0.1:8000/office/ping",
  "http://127.0.0.1:8000/media/ping",
  "http://localhost:3000",
  "http://localhost:3000/api/health"
)

foreach ($t in $targets) {
  try {
    $r = Invoke-WebRequest -Uri $t -UseBasicParsing -TimeoutSec 5
    Write-Host "[OK] $t => $($r.StatusCode)"
  } catch {
    Write-Host "[FAIL] $t"
  }
}
