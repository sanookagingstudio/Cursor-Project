param(
    [string]$adminEmail
)

Write-Host ""
Write-Host "=== APPLY SQL: Bootstrap Super Admin (Supabase) ===" -ForegroundColor Yellow
Write-Host ""

if (-not $adminEmail) {
    Write-Host "กรุณาระบุอีเมลของ Super Admin เช่น:" -ForegroundColor Red
    Write-Host "   .\apply-sql.ps1 ""sanookagingstudio@gmail.com""" -ForegroundColor Yellow
    exit
}

# Path ไปยังไฟล์ SQL
$sqlFile = "supabase/admin_bootstrap.sql"

if (-not (Test-Path $sqlFile)) {
    Write-Host "ERROR: ไม่พบไฟล์ SQL: $sqlFile" -ForegroundColor Red
    exit
}

Write-Host "ไฟล์ SQL ที่ใช้: $sqlFile" -ForegroundColor Green
Write-Host "Super Admin Email: $adminEmail" -ForegroundColor Green

Write-Host ""
Write-Host "---------------------------------------------"
Write-Host " 1) เข้า Supabase → SQL Editor"
Write-Host " 2) เปิดไฟล์: $sqlFile"
Write-Host " 3) แทนค่าตัวแปร :admin_email ด้วย $adminEmail"
Write-Host " 4) กด RUN"
Write-Host "---------------------------------------------"
Write-Host ""

Write-Host "เมื่อรันไฟล์ SQL เสร็จแล้ว คุณจะกลายเป็น Super Admin ทันที" -ForegroundColor Cyan
Write-Host ""

Write-Host "=== APPLY SQL COMPLETE ===" -ForegroundColor Green
