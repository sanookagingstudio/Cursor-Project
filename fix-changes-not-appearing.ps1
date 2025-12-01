# Fix: Changes Not Appearing on funaging.club
# แก้ไขปัญหา: แก้ไขไฟล์แล้วแต่ไม่เห็นการเปลี่ยนแปลง

$ErrorActionPreference = "Continue"
Write-Host ""
Write-Host "=== แก้ไขปัญหา: ไม่เห็นการเปลี่ยนแปลงบน funaging.club ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Vercel Login
Write-Host "[1/6] ตรวจสอบ Vercel Login..." -ForegroundColor Yellow
$whoami = vercel whoami 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] ยังไม่ได้ login Vercel" -ForegroundColor Red
    Write-Host "   กำลัง login..." -ForegroundColor Yellow
    vercel login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[X] Login ไม่สำเร็จ" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[OK] Login แล้ว: $whoami" -ForegroundColor Green
}
Write-Host ""

# Step 2: Check Project Link
Write-Host "[2/6] ตรวจสอบ Project Link..." -ForegroundColor Yellow
if (-not (Test-Path ".vercel")) {
    Write-Host "[!] ยังไม่ได้ link project" -ForegroundColor Yellow
    Write-Host "   กำลัง link..." -ForegroundColor Yellow
    vercel link --yes
} else {
    Write-Host "[OK] Project linked แล้ว" -ForegroundColor Green
}
Write-Host ""

# Step 3: Clear Local Cache
Write-Host "[3/6] ลบ Local Cache..." -ForegroundColor Yellow
if (Test-Path "node_modules\.vite") {
    Remove-Item -Recurse -Force "node_modules\.vite" -ErrorAction SilentlyContinue
    Write-Host "[OK] ลบ Vite cache แล้ว" -ForegroundColor Green
}
if (Test-Path "dist") {
    Remove-Item -Recurse -Force "dist" -ErrorAction SilentlyContinue
    Write-Host "[OK] ลบ dist folder แล้ว" -ForegroundColor Green
}
Write-Host ""

# Step 4: Build Locally (Optional Check)
Write-Host "[4/6] ตรวจสอบ Build..." -ForegroundColor Yellow
Write-Host "   กำลัง build..." -ForegroundColor Gray
$buildOutput = npm run build 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Build สำเร็จ" -ForegroundColor Green
} else {
    Write-Host "[!] Build มีปัญหา (แต่จะ deploy ต่อไป)" -ForegroundColor Yellow
    Write-Host $buildOutput -ForegroundColor Gray
}
Write-Host ""

# Step 5: Deploy to Production
Write-Host "[5/6] Deploy ไป Production..." -ForegroundColor Yellow
Write-Host "   กำลัง deploy ไป funaging.club..." -ForegroundColor Gray
Write-Host ""
$deployOutput = vercel --prod --yes 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Deploy สำเร็จ!" -ForegroundColor Green
    Write-Host ""
    Write-Host $deployOutput -ForegroundColor Gray
} else {
    Write-Host "[X] Deploy ไม่สำเร็จ" -ForegroundColor Red
    Write-Host $deployOutput -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 6: Instructions
Write-Host "[6/6] ขั้นตอนต่อไป..." -ForegroundColor Yellow
Write-Host ""
Write-Host "[OK] Deploy เสร็จแล้ว! ตอนนี้ทำตามขั้นตอนนี้:" -ForegroundColor Green
Write-Host ""
Write-Host "1. รอ 1-2 นาที ให้ Vercel build เสร็จ" -ForegroundColor White
Write-Host "2. เปิด https://funaging.club" -ForegroundColor White
Write-Host "3. Hard Refresh: กด Ctrl + Shift + R (Windows) หรือ Cmd + Shift + R (Mac)" -ForegroundColor White
Write-Host "4. ถ้ายังไม่เห็น:" -ForegroundColor White
Write-Host "   - เปิด Developer Tools (F12)" -ForegroundColor Gray
Write-Host "   - คลิกขวาที่ปุ่ม Refresh" -ForegroundColor Gray
Write-Host "   - เลือก 'Empty Cache and Hard Reload'" -ForegroundColor Gray
Write-Host ""
Write-Host "5. ตรวจสอบ Vercel Dashboard:" -ForegroundColor White
Write-Host "   https://vercel.com/dashboard" -ForegroundColor Cyan
Write-Host "   -> ดู deployment ล่าสุด -> ควรเป็น 'Ready' (สีเขียว)" -ForegroundColor Gray
Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""
