# 🔍 Sanook Master V2 - ตรวจสอบสถานะ Auto-Startup

$ErrorActionPreference = "Continue"

Write-Host "🔍 ตรวจสอบสถานะ Auto-Startup" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

$hasAutoStartup = $false

# ตรวจสอบ Task Scheduler
Write-Host "🔍 ตรวจสอบ Task Scheduler..." -ForegroundColor Yellow
$task = Get-ScheduledTask -TaskName "SanookMasterV2-AutoStart" -ErrorAction SilentlyContinue

if ($task) {
    Write-Host "   ✅ พบ Task: SanookMasterV2-AutoStart" -ForegroundColor Green
    Write-Host "   📊 สถานะ: $($task.State)" -ForegroundColor Cyan
    
    if ($task.State -eq "Ready") {
        Write-Host "   ✅ Task พร้อมทำงาน" -ForegroundColor Green
        $hasAutoStartup = $true
    } else {
        Write-Host "   ⚠️  Task ไม่พร้อมทำงาน" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ❌ ไม่พบ Task Scheduler" -ForegroundColor Red
    Write-Host "   💡 ยังไม่ได้ติดตั้ง Auto-Startup" -ForegroundColor Yellow
}

Write-Host ""

# ตรวจสอบ Windows Service
Write-Host "🔍 ตรวจสอบ Windows Service..." -ForegroundColor Yellow
$service = Get-Service -Name "SanookMasterV2" -ErrorAction SilentlyContinue

if ($service) {
    Write-Host "   ✅ พบ Service: SanookMasterV2" -ForegroundColor Green
    Write-Host "   📊 สถานะ: $($service.Status)" -ForegroundColor Cyan
    $hasAutoStartup = $true
} else {
    Write-Host "   ℹ️  ไม่พบ Windows Service" -ForegroundColor Gray
}

Write-Host ""

# สรุป
Write-Host "==============================" -ForegroundColor Cyan
if ($hasAutoStartup) {
    Write-Host "✅ ระบบมี Auto-Startup ติดตั้งแล้ว" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 หมายเหตุ:" -ForegroundColor Yellow
    Write-Host "   - ระบบจะเริ่มต้นอัตโนมัติเมื่อเปิดเครื่อง" -ForegroundColor Gray
    Write-Host "   - ตรวจสอบสถานะ: .\check-system.ps1" -ForegroundColor Gray
} else {
    Write-Host "❌ ยังไม่ได้ติดตั้ง Auto-Startup" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 วิธีติดตั้ง:" -ForegroundColor Yellow
    Write-Host "   1. เปิด PowerShell เป็น Administrator" -ForegroundColor White
    Write-Host "   2. รัน: .\install-service.ps1" -ForegroundColor White
    Write-Host "   3. เลือก 'y' เมื่อถาม Task Scheduler" -ForegroundColor White
    Write-Host ""
    Write-Host "   หรือใช้ Manual:" -ForegroundColor Cyan
    Write-Host "   .\start-system.ps1" -ForegroundColor Gray
}

Write-Host ""


