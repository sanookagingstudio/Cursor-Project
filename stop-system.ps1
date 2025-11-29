# 🛑 Sanook Master V2 - Stop All Services
# หยุด Services ทั้งหมด

$ErrorActionPreference = "Continue"

Write-Host "🛑 Sanook Master V2 - Stop All Services" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

# ============================================
# 1. หยุด Frontend (Vite)
# ============================================
Write-Host "🔍 หยุด Frontend (Vite)..." -ForegroundColor Yellow
$viteProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*vite*" -or $_.Path -like "*node*"
}
if ($viteProcesses) {
    $viteProcesses | ForEach-Object {
        Write-Host "   🛑 หยุด Process: $($_.Id)" -ForegroundColor Cyan
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
    Write-Host "   ✅ Frontend หยุดแล้ว" -ForegroundColor Green
} else {
    Write-Host "   ℹ️  ไม่พบ Frontend process" -ForegroundColor Gray
}
Write-Host ""

# ============================================
# 2. หยุด Backend (Uvicorn)
# ============================================
Write-Host "🔍 หยุด Backend (Uvicorn)..." -ForegroundColor Yellow
$uvicornProcesses = Get-Process -Name "python" -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*uvicorn*"
}
if ($uvicornProcesses) {
    $uvicornProcesses | ForEach-Object {
        Write-Host "   🛑 หยุด Process: $($_.Id)" -ForegroundColor Cyan
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
    Write-Host "   ✅ Backend หยุดแล้ว" -ForegroundColor Green
} else {
    Write-Host "   ℹ️  ไม่พบ Backend process" -ForegroundColor Gray
}
Write-Host ""

# ============================================
# 3. หยุด Celery Worker
# ============================================
Write-Host "🔍 หยุด Celery Worker..." -ForegroundColor Yellow
$celeryProcesses = Get-Process -Name "celery" -ErrorAction SilentlyContinue
if ($celeryProcesses) {
    $celeryProcesses | ForEach-Object {
        Write-Host "   🛑 หยุด Process: $($_.Id)" -ForegroundColor Cyan
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
    Write-Host "   ✅ Celery Worker หยุดแล้ว" -ForegroundColor Green
} else {
    Write-Host "   ℹ️  ไม่พบ Celery process" -ForegroundColor Gray
}
Write-Host ""

# ============================================
# 4. หยุด Redis (Docker) - Optional
# ============================================
Write-Host "🔍 ตรวจสอบ Redis Docker Container..." -ForegroundColor Yellow
try {
    $dockerRedis = docker ps --filter "name=redis" --format "{{.Names}}" 2>$null
    if ($dockerRedis -match "redis") {
        $stopRedis = Read-Host "   พบ Redis Container - ต้องการหยุดหรือไม่? (y/n)"
        if ($stopRedis -eq "y" -or $stopRedis -eq "Y") {
            docker stop redis 2>$null
            Write-Host "   ✅ Redis Container หยุดแล้ว" -ForegroundColor Green
        } else {
            Write-Host "   ℹ️  ยังคงทำงาน Redis Container" -ForegroundColor Gray
        }
    } else {
        Write-Host "   ℹ️  ไม่พบ Redis Container" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ℹ️  Docker ไม่พร้อมใช้งาน" -ForegroundColor Gray
}
Write-Host ""

# ============================================
# สรุป
# ============================================
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "✅ หยุด Services เสร็จแล้ว" -ForegroundColor Green
Write-Host ""
Write-Host "💡 หมายเหตุ:" -ForegroundColor Cyan
Write-Host "   - Services ที่รันใน Terminal ต้องปิด Terminal ด้วยตนเอง" -ForegroundColor Gray
Write-Host "   - Redis Container ยังทำงานอยู่ (ถ้าไม่หยุด)" -ForegroundColor Gray
Write-Host ""


