# 🚀 Sanook Master V2 - System Startup Script
# เริ่มต้นระบบทั้งหมดอัตโนมัติ (Frontend + Backend + Redis + Celery)

param(
    [switch]$SkipRedis,
    [switch]$SkipBackend,
    [switch]$SkipFrontend,
    [switch]$SkipCelery
)

$ErrorActionPreference = "Continue"

Write-Host "🚀 Sanook Master V2 - System Startup" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# ตรวจสอบว่าอยู่ในโฟลเดอร์โปรเจกต์
if (-not (Test-Path "package.json")) {
    Write-Host "❌ Error: ไม่พบ package.json" -ForegroundColor Red
    Write-Host "   กรุณารันสคริปต์นี้ในโฟลเดอร์โปรเจกต์" -ForegroundColor Yellow
    exit 1
}

$projectRoot = Get-Location
Write-Host "📁 Project Root: $projectRoot" -ForegroundColor Green
Write-Host ""

# ============================================
# 1. ตรวจสอบและเริ่ม Redis
# ============================================
if (-not $SkipRedis) {
    Write-Host "🔍 ตรวจสอบ Redis..." -ForegroundColor Yellow
    
    $redisRunning = $false
    
    # ตรวจสอบว่า Redis ทำงานอยู่หรือไม่
    try {
        $redisTest = Test-NetConnection -ComputerName localhost -Port 6379 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        if ($redisTest.TcpTestSucceeded) {
            $redisRunning = $true
            Write-Host "✅ Redis กำลังทำงานอยู่แล้ว (localhost:6379)" -ForegroundColor Green
        }
    } catch {
        # Redis ไม่ทำงาน
    }
    
    if (-not $redisRunning) {
        Write-Host "⚠️  Redis ไม่ทำงาน" -ForegroundColor Yellow
        
        # ตรวจสอบว่า Redis ติดตั้งผ่าน Docker หรือไม่
        $dockerRedis = $false
        try {
            $dockerPs = docker ps -a --filter "name=redis" --format "{{.Names}}" 2>$null
            if ($dockerPs -match "redis") {
                $dockerRedis = $true
                Write-Host "📦 พบ Redis Container ใน Docker" -ForegroundColor Cyan
                
                # เริ่ม Redis Container
                Write-Host "🚀 กำลังเริ่ม Redis Container..." -ForegroundColor Yellow
                docker start redis 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✅ Redis Container เริ่มทำงานแล้ว" -ForegroundColor Green
                    Start-Sleep -Seconds 2
                    $redisRunning = $true
                } else {
                    # ถ้าไม่มี container ชื่อ redis ลองสร้างใหม่
                    Write-Host "📦 กำลังสร้าง Redis Container..." -ForegroundColor Yellow
                    docker run -d --name redis -p 6379:6379 redis:latest 2>$null
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "✅ Redis Container สร้างและเริ่มทำงานแล้ว" -ForegroundColor Green
                        Start-Sleep -Seconds 3
                        $redisRunning = $true
                    }
                }
            }
        } catch {
            # Docker ไม่พร้อมใช้งาน
        }
        
        if (-not $redisRunning) {
            Write-Host "⚠️  ไม่สามารถเริ่ม Redis อัตโนมัติได้" -ForegroundColor Yellow
            Write-Host "   กรุณาเริ่ม Redis ด้วยวิธีใดวิธีหนึ่ง:" -ForegroundColor Yellow
            Write-Host "   1. Docker: docker run -d --name redis -p 6379:6379 redis:latest" -ForegroundColor Cyan
            Write-Host "   2. Windows Service: ตรวจสอบว่า Redis Service ทำงานอยู่" -ForegroundColor Cyan
            Write-Host "   3. Manual: เปิด Redis Server ด้วยตัวเอง" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "   หรือรันสคริปต์นี้ด้วย -SkipRedis เพื่อข้าม Redis" -ForegroundColor Yellow
            Write-Host ""
            
            $continue = Read-Host "ต้องการดำเนินการต่อหรือไม่? (y/n)"
            if ($continue -ne "y" -and $continue -ne "Y") {
                exit 1
            }
        }
    }
    Write-Host ""
}

# ============================================
# 2. เริ่ม Backend Server
# ============================================
if (-not $SkipBackend) {
    Write-Host "🔍 ตรวจสอบ Backend..." -ForegroundColor Yellow
    
    if (-not (Test-Path "backend")) {
        Write-Host "⚠️  ไม่พบโฟลเดอร์ backend" -ForegroundColor Yellow
        Write-Host "   ข้าม Backend Server" -ForegroundColor Yellow
    } else {
        Write-Host "🚀 กำลังเริ่ม Backend Server (FastAPI)..." -ForegroundColor Yellow
        
        $backendScript = @"
cd `"$projectRoot\backend`"
if (Test-Path `".env`") {
    Write-Host `"✅ พบไฟล์ .env`" -ForegroundColor Green
} else {
    Write-Host `"⚠️  ไม่พบไฟล์ .env - ใช้ค่า default`" -ForegroundColor Yellow
}
Write-Host `"🌐 Backend API: http://localhost:8000`" -ForegroundColor Cyan
Write-Host `"📚 API Docs: http://localhost:8000/docs`" -ForegroundColor Cyan
uvicorn app.main:app --reload --port 8000
"@
        
        Start-Process powershell -ArgumentList "-NoExit", "-Command", $backendScript
        Write-Host "✅ Backend Server เริ่มทำงานแล้ว (Terminal ใหม่)" -ForegroundColor Green
        Start-Sleep -Seconds 2
    }
    Write-Host ""
}

# ============================================
# 3. เริ่ม Celery Worker
# ============================================
if (-not $SkipCelery) {
    Write-Host "🔍 ตรวจสอบ Celery Worker..." -ForegroundColor Yellow
    
    if (-not (Test-Path "backend")) {
        Write-Host "⚠️  ไม่พบโฟลเดอร์ backend" -ForegroundColor Yellow
        Write-Host "   ข้าม Celery Worker" -ForegroundColor Yellow
    } else {
        Write-Host "🚀 กำลังเริ่ม Celery Worker..." -ForegroundColor Yellow
        
        $celeryScript = @"
cd `"$projectRoot\backend`"
Write-Host `"⚙️  Celery Worker กำลังทำงาน...`" -ForegroundColor Cyan
celery -A app.core.celery_app worker --loglevel=info
"@
        
        Start-Process powershell -ArgumentList "-NoExit", "-Command", $celeryScript
        Write-Host "✅ Celery Worker เริ่มทำงานแล้ว (Terminal ใหม่)" -ForegroundColor Green
        Start-Sleep -Seconds 2
    }
    Write-Host ""
}

# ============================================
# 4. เริ่ม Frontend
# ============================================
if (-not $SkipFrontend) {
    Write-Host "🔍 ตรวจสอบ Frontend..." -ForegroundColor Yellow
    
    if (-not (Test-Path "node_modules")) {
        Write-Host "⚠️  ยังไม่ได้ติดตั้ง dependencies" -ForegroundColor Yellow
        Write-Host "🚀 กำลังติดตั้ง dependencies..." -ForegroundColor Yellow
        npm install
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ การติดตั้ง dependencies ล้มเหลว" -ForegroundColor Red
            exit 1
        }
        Write-Host "✅ ติดตั้ง dependencies เสร็จแล้ว" -ForegroundColor Green
        Write-Host ""
    }
    
    Write-Host "🚀 กำลังเริ่ม Frontend Development Server..." -ForegroundColor Yellow
    
    $frontendScript = @"
cd `"$projectRoot`"
Write-Host `"🌐 Frontend: http://localhost:8080`" -ForegroundColor Cyan
npm run dev
"@
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $frontendScript
    Write-Host "✅ Frontend เริ่มทำงานแล้ว (Terminal ใหม่)" -ForegroundColor Green
    Write-Host ""
}

# ============================================
# สรุป
# ============================================
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "✅ ระบบเริ่มทำงานแล้ว!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 สรุป Services:" -ForegroundColor Cyan
if (-not $SkipRedis) {
    Write-Host "   ✅ Redis: localhost:6379" -ForegroundColor Green
}
if (-not $SkipBackend) {
    Write-Host "   ✅ Backend API: http://localhost:8000" -ForegroundColor Green
    Write-Host "   📚 API Docs: http://localhost:8000/docs" -ForegroundColor Cyan
}
if (-not $SkipCelery) {
    Write-Host "   ✅ Celery Worker: กำลังทำงาน" -ForegroundColor Green
}
if (-not $SkipFrontend) {
    Write-Host "   ✅ Frontend: http://localhost:8080" -ForegroundColor Green
}
Write-Host ""
Write-Host "💡 Tips:" -ForegroundColor Yellow
Write-Host "   - ปิด Terminal เพื่อหยุด Services" -ForegroundColor Gray
Write-Host "   - ใช้ Ctrl+C ในแต่ละ Terminal เพื่อหยุด Service" -ForegroundColor Gray
Write-Host ""
Write-Host "🎉 พร้อมใช้งาน!" -ForegroundColor Green


