\Stop = "Stop"

Write-Host "=== RESTORE PREVIOUS VERSION (STEP-BY-STEP) ===" -ForegroundColor Cyan

# อ่าน meta
\ = ".\versions\meta.json"
if (-not (Test-Path \)) {
    Write-Host "ไม่พบ meta.json - ยังไม่เคยสร้างเวอร์ชัน" -ForegroundColor Red
    exit 1
}

\@{currentVersion=0} = Get-Content \ | ConvertFrom-Json
if (-not \@{currentVersion=0}.currentVersion -or \@{currentVersion=0}.currentVersion -le 1) {
    Write-Host "ยังไม่มีเวอร์ชันก่อนหน้าให้ Restore (currentVersion  1)" -ForegroundColor Yellow
    exit 0
}

\ = [int]\@{currentVersion=0}.currentVersion
\ = \ - 1

\ = ".\versions\v\.json"
if (-not (Test-Path \)) {
    Write-Host "ไม่พบไฟล์ข้อมูลของเวอร์ชัน v\" -ForegroundColor Red
    exit 1
}

\ = Get-Content \ | ConvertFrom-Json
\ = \.tag
\ = \.commit

Write-Host "เวอร์ชันปัจจุบัน: v\" -ForegroundColor Yellow
Write-Host "กำลังจะ Restore ย้อนกลับไปยังเวอร์ชันก่อนหน้า: v\ (\)" -ForegroundColor Yellow
Write-Host "Commit: \" -ForegroundColor Yellow

Write-Host "
คำเตือน: การ Restore จะเขียนทับโค้ดปัจจุบันทั้งหมด" -ForegroundColor Red
Write-Host "ระบบจะสร้างโฟลเดอร์ backup ก่อน Restore ให้โดยอัตโนมัติ" -ForegroundColor Yellow
\ = Read-Host "พิมพ์ YES (ตัวใหญ่) เพื่อยืนยันการ Restore ทีละระดับ"
if (\ -ne "YES") {
    Write-Host "ยกเลิกการ Restore" -ForegroundColor Yellow
    exit 0
}

# สร้าง backup ก่อน restore
\ = Get-Date -Format "yyyyMMdd_HHmmss"
\ = ".\versions\backup-before-restore"
if (-not (Test-Path \)) {
    New-Item -ItemType Directory -Path \ | Out-Null
}
\ = Join-Path \ "backup_\\_from_v\"
New-Item -ItemType Directory -Path \ | Out-Null

Write-Host "กำลังสำรองโค้ดปัจจุบันไปที่: \" -ForegroundColor Yellow
robocopy . \ /MIR /XD .git versions /NFL /NDL /NJH /NJS /NC /NS | Out-Null

# ใช้ git reset ไปยัง commit ของเวอร์ชันก่อนหน้า
Write-Host "กำลัง git reset --hard ไปยัง commit ของ v\ ..." -ForegroundColor Yellow
git reset --hard \

# npm install + build เพื่อตรวจสอบ
Write-Host "กำลัง npm install..." -ForegroundColor Yellow
npm install

Write-Host "กำลัง npm run build..." -ForegroundColor Yellow
npm run build

# อัปเดต currentVersion ใน meta
\@{currentVersion=0}.currentVersion = \
\@{currentVersion=0} | ConvertTo-Json | Set-Content -Path \ -Encoding UTF8

Write-Host "Restore สำเร็จ: ตอนนี้อยู่ที่เวอร์ชัน v\" -ForegroundColor Green
Write-Host "หากต้องการย้อนกลับไปเวอร์ชันก่อน ๆ ให้รันสคริปต์นี้ซ้ำ (ทีละระดับ)" -ForegroundColor Cyan
