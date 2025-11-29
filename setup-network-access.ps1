# 🌐 Sanook Master V2 - Setup Network Access
# ตั้งค่าให้เข้าถึงจากมือถือ/คอมเครื่องอื่นผ่าน Local Network

$ErrorActionPreference = "Continue"

Write-Host "🌐 Sanook Master V2 - Setup Network Access" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ตรวจสอบว่าเป็น Administrator หรือไม่
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️  ต้องการสิทธิ์ Administrator เพื่อเปิด Firewall" -ForegroundColor Yellow
    Write-Host "   คลิกขวาที่ PowerShell และเลือก 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   หรือรันคำสั่งนี้ใน PowerShell (Admin):" -ForegroundColor Cyan
    Write-Host "   New-NetFirewallRule -DisplayName `"Sanook Frontend`" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow" -ForegroundColor Gray
    Write-Host "   New-NetFirewallRule -DisplayName `"Sanook Backend`" -Direction Inbound -LocalPort 8000 -Protocol TCP -Action Allow" -ForegroundColor Gray
    Write-Host ""
}

# หา IP Address
Write-Host "🔍 กำลังหา IP Address..." -ForegroundColor Yellow
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.IPAddress -notlike "127.*" -and 
    $_.IPAddress -notlike "169.254.*"
} | Select-Object -ExpandProperty IPAddress

if ($ipAddresses.Count -eq 0) {
    Write-Host "❌ ไม่พบ IP Address" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📡 IP Address ที่พบ:" -ForegroundColor Green
foreach ($ip in $ipAddresses) {
    Write-Host "   - $ip" -ForegroundColor Cyan
}

$primaryIP = $ipAddresses[0]
Write-Host ""
Write-Host "✅ ใช้ IP หลัก: $primaryIP" -ForegroundColor Green
Write-Host ""

# เปิด Firewall (ถ้าเป็น Admin)
if ($isAdmin) {
    Write-Host "🔥 กำลังตั้งค่า Firewall..." -ForegroundColor Yellow
    
    # ตรวจสอบว่ามี rule อยู่แล้วหรือไม่
    $frontendRule = Get-NetFirewallRule -DisplayName "Sanook Frontend" -ErrorAction SilentlyContinue
    $backendRule = Get-NetFirewallRule -DisplayName "Sanook Backend" -ErrorAction SilentlyContinue
    
    if (-not $frontendRule) {
        New-NetFirewallRule -DisplayName "Sanook Frontend" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow | Out-Null
        Write-Host "   ✅ เปิด Port 8080 (Frontend)" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  Port 8080 เปิดอยู่แล้ว" -ForegroundColor Gray
    }
    
    if (-not $backendRule) {
        New-NetFirewallRule -DisplayName "Sanook Backend" -Direction Inbound -LocalPort 8000 -Protocol TCP -Action Allow | Out-Null
        Write-Host "   ✅ เปิด Port 8000 (Backend)" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  Port 8000 เปิดอยู่แล้ว" -ForegroundColor Gray
    }
    
    Write-Host ""
} else {
    Write-Host "⚠️  ข้ามการตั้งค่า Firewall (ต้องการสิทธิ์ Admin)" -ForegroundColor Yellow
    Write-Host ""
}

# แสดงข้อมูลการเข้าถึง
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "✅ ตั้งค่าเสร็จสมบูรณ์!" -ForegroundColor Green
Write-Host ""
Write-Host "📱 วิธีเข้าถึงจากมือถือ/คอมเครื่องอื่น:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Frontend (Web App):" -ForegroundColor Yellow
Write-Host "   http://$primaryIP:8080" -ForegroundColor White
Write-Host ""
Write-Host "   Backend API:" -ForegroundColor Yellow
Write-Host "   http://$primaryIP:8000" -ForegroundColor White
Write-Host ""
Write-Host "   API Docs:" -ForegroundColor Yellow
Write-Host "   http://$primaryIP:8000/docs" -ForegroundColor White
Write-Host ""

# แสดง QR Code (ถ้ามี qrencode)
$qrencode = Get-Command qrencode -ErrorAction SilentlyContinue
if ($qrencode) {
    Write-Host "📱 QR Code:" -ForegroundColor Cyan
    qrencode -t ANSI "http://$primaryIP:8080"
    Write-Host ""
}

Write-Host "💡 Tips:" -ForegroundColor Yellow
Write-Host "   - ต้องอยู่ใน WiFi เดียวกัน" -ForegroundColor Gray
Write-Host "   - IP อาจเปลี่ยน (ถ้าใช้ DHCP)" -ForegroundColor Gray
Write-Host "   - ใช้ Static IP เพื่อความเสถียร" -ForegroundColor Gray
Write-Host ""

# แสดงคำสั่งสำหรับ Static IP (optional)
Write-Host "🔧 ตั้งค่า Static IP (Optional):" -ForegroundColor Cyan
Write-Host "   1. เปิด Network Settings" -ForegroundColor Gray
Write-Host "   2. Change adapter options" -ForegroundColor Gray
Write-Host "   3. Properties → IPv4 → Use the following IP address" -ForegroundColor Gray
Write-Host "   4. ใส่ IP: $primaryIP" -ForegroundColor Gray
Write-Host ""


