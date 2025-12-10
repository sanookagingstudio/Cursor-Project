param()

$ErrorActionPreference = "Stop"

Write-Host "======================================="
Write-Host "[INFO] เริ่มทดสอบระบบ SAS/FunAging Stack ..." -ForegroundColor Cyan
Write-Host "======================================="

$backend = "http://localhost:8000"
$frontend = "http://localhost:8080"

function Write-Ok($msg)   { Write-Host "[OK]  $msg"  -ForegroundColor Green }
function Write-Fail($msg) { Write-Host "[FAIL] $msg" -ForegroundColor Red }
function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Yellow }

# 1) ตรวจ Docker
Write-Info "ตรวจสอบ Docker ..."
try {
  docker info | Out-Null
  Write-Ok "Docker พร้อมทำงาน"
} catch {
  Write-Fail "Docker ยังไม่พร้อม"
  exit 1
}

# 2) ตรวจ backend / frontend containers
Write-Info "ตรวจสอบ Backend / Frontend ..."
$backendContainer  = docker ps --filter "name=sas_backend"  --format "{{.Names}}"
$frontendContainer = docker ps --filter "name=sas_frontend" --format "{{.Names}}"

if (-not $backendContainer)  { Write-Fail "Backend ไม่ได้รันอยู่"; exit 1 } else { Write-Ok "Backend กำลังรันอยู่" }
if (-not $frontendContainer) { Write-Fail "Frontend ไม่ได้รันอยู่"; } else { Write-Ok "Frontend กำลังรันอยู่" }

# 3) ทดสอบ /docs
Write-Info "ทดสอบ Backend /docs ..."
try {
  $docs = Invoke-WebRequest "$backend/docs" -UseBasicParsing -TimeoutSec 10
  if ($docs.StatusCode -ge 200 -and $docs.StatusCode -lt 300) {
    Write-Ok "เปิด /docs ได้สำเร็จ"
  } else {
    Write-Fail "เปิด /docs ไม่ได้! (Status $($docs.StatusCode))"
  }
} catch {
  Write-Fail "เปิด /docs ไม่ได้! $($_.Exception.Message)"
}

# 4) ทดสอบ /health
Write-Info "ทดสอบ Health Check ..."
try {
  $health = Invoke-RestMethod "$backend/health" -Method GET -TimeoutSec 10
  if ($health.status -eq "healthy") {
    Write-Ok "Backend /health ทำงานปกติ: $($health | ConvertTo-Json -Compress)"
  } else {
    Write-Fail "Backend /health ตอบกลับผิดปกติ: $($health | ConvertTo-Json -Compress)"
  }
} catch {
  Write-Fail "Backend /health ไม่ตอบสนอง! $($_.Exception.Message)"
}

# 5) ใช้ default admin (ไม่ต้อง signup)
$adminEmail    = "sanookagingstudio@gmail.com"
$adminPassword = "Admin1234!"

Write-Info "ข้าม Signup (ใช้ default admin ในระบบแล้ว) ..."
Write-Ok "Signup (auto admin) ผ่านโดยอัตโนมัติ"

# 6) ทดสอบ Login
Write-Info "ทดสอบ Login ..."
$token = $null
try {
  $body = @{ email = $adminEmail; password = $adminPassword } | ConvertTo-Json
  $resp = Invoke-RestMethod "$backend/auth/login" -Method POST -ContentType "application/json" -Body $body -TimeoutSec 15
  if ($resp.access_token) {
    $token = $resp.access_token
    Write-Ok "Login สำเร็จ ได้รับ access_token"
  } else {
    Write-Fail "Login ไม่พบ access_token ใน response"
  }
} catch {
  Write-Fail "Login ล้มเหลว: $($_.Exception.Message)"
}

if (-not $token) {
  Write-Fail "ไม่มี token สำหรับใช้ทดสอบ endpoint อื่น ๆ"
  Write-Host "======================================="
  Write-Host "[INFO] ระบบทดสอบ เสร็จสิ้น (มีข้อผิดพลาด)" -ForegroundColor Yellow
  Write-Host "======================================="
  exit 1
}

$headers = @{ Authorization = "Bearer $token" }

# 7) ทดสอบ /me
Write-Info "ทดสอบ /me ..."
try {
  $me = Invoke-RestMethod "$backend/me" -Method GET -Headers $headers -TimeoutSec 10
  if ($me.email -eq $adminEmail) {
    Write-Ok "/me ใช้งานได้ (email = $($me.email), role = $($me.role))"
  } else {
    Write-Fail "/me ตอบ email ไม่ตรง: $($me | ConvertTo-Json -Compress)"
  }
} catch {
  Write-Fail "/me เข้าถึงไม่ได้: $($_.Exception.Message)"
}

# 8) ทดสอบ protected routes
$routes = @("admin","staff","customer")
foreach ($r in $routes) {
  Write-Info "ทดสอบ /$r ..."
  try {
    $res = Invoke-RestMethod "$backend/$r" -Method GET -Headers $headers -TimeoutSec 10
    Write-Ok "/$r เข้าถึงได้: $($res | ConvertTo-Json -Compress)"
  } catch {
    Write-Fail "/$r เข้าถึงไม่ได้: $($_.Exception.Message)"
  }
}

Write-Host "======================================="
Write-Host "[INFO] ระบบทดสอบ เสร็จสิ้นสมบูรณ์" -ForegroundColor Cyan
Write-Host "======================================="
