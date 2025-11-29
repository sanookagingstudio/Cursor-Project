# 🔍 Sanook Master V2 - System Status Check
# ตรวจสอบสถานะของ Services ทั้งหมด

$ErrorActionPreference = "Continue"

Write-Host "🔍 Sanook Master V2 - System Status Check" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$allOk = $true

# ============================================
# 1. ตรวจสอบ Redis
# ============================================
Write-Host "🔍 ตรวจสอบ Redis..." -ForegroundColor Yellow
try {
    $redisTest = Test-NetConnection -ComputerName localhost -Port 6379 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    if ($redisTest.TcpTestSucceeded) {
        Write-Host "   ✅ Redis: ทำงานอยู่ (localhost:6379)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Redis: ไม่ทำงาน" -ForegroundColor Red
        $allOk = $false
    }
} catch {
    Write-Host "   ❌ Redis: ไม่สามารถเชื่อมต่อได้" -ForegroundColor Red
    $allOk = $false
}

# ตรวจสอบ Docker Redis
try {
    $dockerRedis = docker ps --filter "name=redis" --format "{{.Names}}" 2>$null
    if ($dockerRedis -match "redis") {
        Write-Host "   📦 Docker Redis Container: ทำงานอยู่" -ForegroundColor Cyan
    }
} catch {
    # Docker ไม่พร้อมใช้งาน
}

Write-Host ""

# ============================================
# 2. ตรวจสอบ Backend API
# ============================================
Write-Host "🔍 ตรวจสอบ Backend API..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/health" -TimeoutSec 2 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ Backend API: ทำงานอยู่ (http://localhost:8000)" -ForegroundColor Green
        $healthData = $response.Content | ConvertFrom-Json
        if ($healthData.status -eq "ok") {
            Write-Host "   ✅ Health Status: OK" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Health Status: Degraded" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "   ❌ Backend API: ไม่ทำงาน" -ForegroundColor Red
    $allOk = $false
}

Write-Host ""

# ============================================
# 3. ตรวจสอบ Frontend
# ============================================
Write-Host "🔍 ตรวจสอบ Frontend..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 2 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ Frontend: ทำงานอยู่ (http://localhost:8080)" -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ Frontend: ไม่ทำงาน" -ForegroundColor Red
    $allOk = $false
}

Write-Host ""

# ============================================
# 4. ตรวจสอบ Celery Worker
# ============================================
Write-Host "🔍 ตรวจสอบ Celery Worker..." -ForegroundColor Yellow
try {
    $celeryProcess = Get-Process -Name "celery" -ErrorAction SilentlyContinue
    if ($celeryProcess) {
        Write-Host "   ✅ Celery Worker: ทำงานอยู่" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Celery Worker: ไม่พบ process" -ForegroundColor Yellow
        Write-Host "      (อาจทำงานใน Terminal อื่น)" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ⚠️  Celery Worker: ไม่พบ process" -ForegroundColor Yellow
}

Write-Host ""

# ============================================
# สรุป
# ============================================
Write-Host "=========================================" -ForegroundColor Cyan
if ($allOk) {
    Write-Host "✅ ระบบทำงานปกติ" -ForegroundColor Green
} else {
    Write-Host "⚠️  ระบบมีปัญหา - กรุณาตรวจสอบ Services ที่ไม่ทำงาน" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 ใช้สคริปต์นี้เพื่อเริ่มต้นระบบ:" -ForegroundColor Cyan
    Write-Host "   .\start-system.ps1" -ForegroundColor White
}
Write-Host ""


