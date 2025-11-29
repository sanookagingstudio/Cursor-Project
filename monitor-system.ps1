# 🔄 Sanook Master V2 - System Health Monitor & Self-Healing
# ตรวจสอบและฟื้นฟูระบบอัตโนมัติ

param(
    [int]$CheckInterval = 30,  # ตรวจสอบทุก 30 วินาที
    [switch]$RunOnce,          # รันครั้งเดียวแล้วหยุด
    [switch]$Silent            # ไม่แสดง output
)

$ErrorActionPreference = "Continue"
$projectRoot = Get-Location

# Log file
$logFile = Join-Path $projectRoot "system-monitor.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path $logFile -Value $logMessage
    if (-not $Silent) {
        Write-Host $logMessage
    }
}

function Check-Redis {
    try {
        $test = Test-NetConnection -ComputerName localhost -Port 6379 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        return $test.TcpTestSucceeded
    } catch {
        return $false
    }
}

function Check-Backend {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8000/health" -TimeoutSec 2 -ErrorAction Stop
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}

function Check-Frontend {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 2 -ErrorAction Stop
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}

function Check-Celery {
    $processes = Get-Process -Name "celery" -ErrorAction SilentlyContinue
    return $null -ne $processes -and $processes.Count -gt 0
}

function Start-Redis {
    Write-Log "🔄 กำลังเริ่ม Redis..." "WARN"
    try {
        # ตรวจสอบ Docker Redis
        $dockerRedis = docker ps -a --filter "name=redis" --format "{{.Names}}" 2>$null
        if ($dockerRedis -match "redis") {
            docker start redis 2>$null
            Start-Sleep -Seconds 3
            if (Check-Redis) {
                Write-Log "✅ Redis เริ่มทำงานแล้ว" "SUCCESS"
                return $true
            }
        }
        
        # ถ้าไม่มี Docker Redis ลองสร้างใหม่
        docker run -d --name redis -p 6379:6379 redis:latest 2>$null
        Start-Sleep -Seconds 3
        if (Check-Redis) {
            Write-Log "✅ Redis Container สร้างและเริ่มทำงานแล้ว" "SUCCESS"
            return $true
        }
    } catch {
        Write-Log "❌ ไม่สามารถเริ่ม Redis ได้: $_" "ERROR"
    }
    return $false
}

function Start-Backend {
    Write-Log "🔄 กำลังเริ่ม Backend API..." "WARN"
    try {
        $backendScript = @"
cd `"$projectRoot\backend`"
uvicorn app.main:app --reload --port 8000
"@
        Start-Process powershell -ArgumentList "-NoExit", "-Command", $backendScript -WindowStyle Minimized
        Start-Sleep -Seconds 5
        
        # รอให้ Backend เริ่มทำงาน (max 30 วินาที)
        $maxWait = 30
        $waited = 0
        while (-not (Check-Backend) -and $waited -lt $maxWait) {
            Start-Sleep -Seconds 2
            $waited += 2
        }
        
        if (Check-Backend) {
            Write-Log "✅ Backend API เริ่มทำงานแล้ว" "SUCCESS"
            return $true
        } else {
            Write-Log "⚠️  Backend API ยังไม่พร้อม (รอ $maxWait วินาที)" "WARN"
            return $false
        }
    } catch {
        Write-Log "❌ ไม่สามารถเริ่ม Backend ได้: $_" "ERROR"
        return $false
    }
}

function Start-Celery {
    Write-Log "🔄 กำลังเริ่ม Celery Worker..." "WARN"
    try {
        $celeryScript = @"
cd `"$projectRoot\backend`"
celery -A app.core.celery_app worker --loglevel=info
"@
        Start-Process powershell -ArgumentList "-NoExit", "-Command", $celeryScript -WindowStyle Minimized
        Start-Sleep -Seconds 3
        
        if (Check-Celery) {
            Write-Log "✅ Celery Worker เริ่มทำงานแล้ว" "SUCCESS"
            return $true
        } else {
            Write-Log "⚠️  Celery Worker อาจยังไม่พร้อม" "WARN"
            return $false
        }
    } catch {
        Write-Log "❌ ไม่สามารถเริ่ม Celery ได้: $_" "ERROR"
        return $false
    }
}

function Start-Frontend {
    Write-Log "🔄 กำลังเริ่ม Frontend..." "WARN"
    try {
        $frontendScript = @"
cd `"$projectRoot`"
npm run dev
"@
        Start-Process powershell -ArgumentList "-NoExit", "-Command", $frontendScript -WindowStyle Minimized
        Start-Sleep -Seconds 5
        
        # รอให้ Frontend เริ่มทำงาน (max 30 วินาที)
        $maxWait = 30
        $waited = 0
        while (-not (Check-Frontend) -and $waited -lt $maxWait) {
            Start-Sleep -Seconds 2
            $waited += 2
        }
        
        if (Check-Frontend) {
            Write-Log "✅ Frontend เริ่มทำงานแล้ว" "SUCCESS"
            return $true
        } else {
            Write-Log "⚠️  Frontend ยังไม่พร้อม (รอ $maxWait วินาที)" "WARN"
            return $false
        }
    } catch {
        Write-Log "❌ ไม่สามารถเริ่ม Frontend ได้: $_" "ERROR"
        return $false
    }
}

function Monitor-System {
    Write-Log "🔍 ตรวจสอบระบบ..." "INFO"
    
    $issues = @()
    $fixed = @()
    
    # ตรวจสอบ Redis
    if (-not (Check-Redis)) {
        Write-Log "❌ Redis ไม่ทำงาน" "ERROR"
        $issues += "Redis"
        if (Start-Redis) {
            $fixed += "Redis"
        }
    } else {
        Write-Log "✅ Redis: OK" "INFO"
    }
    
    # ตรวจสอบ Backend
    if (-not (Check-Backend)) {
        Write-Log "❌ Backend API ไม่ทำงาน" "ERROR"
        $issues += "Backend"
        if (Start-Backend) {
            $fixed += "Backend"
        }
    } else {
        Write-Log "✅ Backend API: OK" "INFO"
    }
    
    # ตรวจสอบ Celery
    if (-not (Check-Celery)) {
        Write-Log "⚠️  Celery Worker ไม่ทำงาน" "WARN"
        $issues += "Celery"
        if (Start-Celery) {
            $fixed += "Celery"
        }
    } else {
        Write-Log "✅ Celery Worker: OK" "INFO"
    }
    
    # ตรวจสอบ Frontend (optional - ไม่ critical)
    if (-not (Check-Frontend)) {
        Write-Log "⚠️  Frontend ไม่ทำงาน (ไม่ critical)" "WARN"
        # ไม่ auto-restart Frontend (ให้ user เริ่มเอง)
    } else {
        Write-Log "✅ Frontend: OK" "INFO"
    }
    
    # สรุป
    if ($issues.Count -gt 0) {
        Write-Log "⚠️  พบปัญหา: $($issues -join ', ')" "WARN"
        if ($fixed.Count -gt 0) {
            Write-Log "✅ แก้ไขแล้ว: $($fixed -join ', ')" "SUCCESS"
        }
    } else {
        Write-Log "✅ ระบบทำงานปกติทั้งหมด" "SUCCESS"
    }
    
    Write-Log "---" "INFO"
}

# Main loop
if (-not $Silent) {
    Write-Host "🔄 Sanook Master V2 - System Health Monitor" -ForegroundColor Cyan
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host "ตรวจสอบทุก $CheckInterval วินาที" -ForegroundColor Yellow
    Write-Host "Log file: $logFile" -ForegroundColor Gray
    Write-Host ""
}

Write-Log "🚀 เริ่มต้น System Monitor" "INFO"

if ($RunOnce) {
    Monitor-System
} else {
    # Continuous monitoring
    while ($true) {
        Monitor-System
        Start-Sleep -Seconds $CheckInterval
    }
}


