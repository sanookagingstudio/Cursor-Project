# 🔧 Sanook Master V2 - Install Windows Service
# ติดตั้งระบบเป็น Windows Service สำหรับ Auto-Startup

$ErrorActionPreference = "Stop"

# ต้องรันเป็น Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ Error: ต้องรันเป็น Administrator" -ForegroundColor Red
    Write-Host "   คลิกขวาที่ PowerShell และเลือก 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

$projectRoot = Get-Location
$serviceName = "SanookMasterV2"
$serviceDisplayName = "Sanook Master V2 - Media Creator System"
$serviceDescription = "Auto-startup service for Sanook Master V2 system (Backend, Celery, Redis)"

Write-Host "🔧 Sanook Master V2 - Install Windows Service" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Service Name: $serviceName" -ForegroundColor Yellow
Write-Host "Project Root: $projectRoot" -ForegroundColor Yellow
Write-Host ""

# ตรวจสอบว่ามี service อยู่แล้วหรือไม่
$existingService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($existingService) {
    Write-Host "⚠️  พบ Service ที่มีอยู่แล้ว" -ForegroundColor Yellow
    $remove = Read-Host "ต้องการลบและติดตั้งใหม่หรือไม่? (y/n)"
    if ($remove -eq "y" -or $remove -eq "Y") {
        Write-Host "🛑 กำลังหยุด Service..." -ForegroundColor Yellow
        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        
        Write-Host "🗑️  กำลังลบ Service..." -ForegroundColor Yellow
        sc.exe delete $serviceName
        Start-Sleep -Seconds 2
    } else {
        Write-Host "❌ ยกเลิกการติดตั้ง" -ForegroundColor Red
        exit 0
    }
}

# สร้าง service script
$serviceScript = Join-Path $projectRoot "sanook-service.ps1"
$serviceScriptContent = @"
# Sanook Master V2 - Service Script
# รันโดย Windows Service

`$ErrorActionPreference = "Continue"
`$projectRoot = "$projectRoot"

# เปลี่ยนไปที่ project root
Set-Location `$projectRoot

# เริ่มต้นระบบ
& ".\start-system.ps1" -SkipFrontend

# รัน monitor ในพื้นหลัง
Start-Process powershell -ArgumentList "-WindowStyle Hidden", "-File", "`$projectRoot\monitor-system.ps1", "-Silent"
"@

$serviceScriptContent | Out-File -FilePath $serviceScript -Encoding UTF8

Write-Host "✅ สร้าง Service Script แล้ว: $serviceScript" -ForegroundColor Green
Write-Host ""

# สร้าง service
Write-Host "🔧 กำลังติดตั้ง Windows Service..." -ForegroundColor Yellow

# ใช้ NSSM (Non-Sucking Service Manager) หรือ PowerShell Service
# สำหรับ PowerShell Service ต้องใช้ .NET หรือ Win32 Service

Write-Host ""
Write-Host "⚠️  หมายเหตุ: Windows Service ต้องใช้ NSSM หรือ .NET Service" -ForegroundColor Yellow
Write-Host ""
Write-Host "วิธีที่ 1: ใช้ NSSM (แนะนำ)" -ForegroundColor Cyan
Write-Host "  1. ดาวน์โหลด NSSM: https://nssm.cc/download" -ForegroundColor White
Write-Host "  2. Extract และรันคำสั่ง:" -ForegroundColor White
Write-Host "     nssm install $serviceName `"$PSHOME\powershell.exe`"" -ForegroundColor Gray
Write-Host "     nssm set $serviceName AppParameters `"-File `"$serviceScript`"`"" -ForegroundColor Gray
Write-Host "     nssm set $serviceName DisplayName `"$serviceDisplayName`"" -ForegroundColor Gray
Write-Host "     nssm set $serviceName Description `"$serviceDescription`"" -ForegroundColor Gray
Write-Host "     nssm set $serviceName Start SERVICE_AUTO_START" -ForegroundColor Gray
Write-Host "     nssm start $serviceName" -ForegroundColor Gray
Write-Host ""

Write-Host "วิธีที่ 2: ใช้ Task Scheduler (ง่ายกว่า)" -ForegroundColor Cyan
Write-Host "  1. เปิด Task Scheduler" -ForegroundColor White
Write-Host "  2. Create Basic Task" -ForegroundColor White
Write-Host "  3. Trigger: When the computer starts" -ForegroundColor White
Write-Host "  4. Action: Start a program" -ForegroundColor White
Write-Host "  5. Program: powershell.exe" -ForegroundColor White
Write-Host "  6. Arguments: -File `"$serviceScript`"" -ForegroundColor White
Write-Host "  7. Run whether user is logged on or not" -ForegroundColor White
Write-Host ""

$taskName = "SanookMasterV2-AutoStart"
$useTaskScheduler = Read-Host "ต้องการสร้าง Task Scheduler อัตโนมัติหรือไม่? (y/n)"
if ($useTaskScheduler -eq "y" -or $useTaskScheduler -eq "Y") {
    Write-Host "🔧 กำลังสร้าง Task Scheduler..." -ForegroundColor Yellow
    
    # ลบ task เก่า (ถ้ามี)
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    
    # สร้าง task ใหม่
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$serviceScript`""
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType ServiceAccount -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description $serviceDescription
    
    Write-Host "✅ สร้าง Task Scheduler แล้ว: $taskName" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 ตรวจสอบ Task:" -ForegroundColor Cyan
    Write-Host "   Get-ScheduledTask -TaskName `"$taskName`"" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🚀 Task จะเริ่มต้นอัตโนมัติเมื่อเปิดเครื่อง" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ การติดตั้งเสร็จสมบูรณ์!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Tips:" -ForegroundColor Yellow
Write-Host "   - ตรวจสอบสถานะ: .\check-system.ps1" -ForegroundColor Gray
Write-Host "   - ดู Logs: system-monitor.log" -ForegroundColor Gray
if ($useTaskScheduler -eq "y" -or $useTaskScheduler -eq "Y") {
    Write-Host "   - หยุด Task: Unregister-ScheduledTask -TaskName `"$taskName`"" -ForegroundColor Gray
}
Write-Host ""


