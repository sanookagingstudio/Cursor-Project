Write-Host "== ONEPACK: SUPABASE ADMIN AUTO INIT ==" -ForegroundColor Cyan

# ทำงานที่โฟลเดอร์ของสคริปต์นี้เสมอ
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host "[1] Cleaning old admin-init scripts..." -ForegroundColor Yellow

# ลบสคริปต์เก่าที่ชื่อคล้าย ๆ ทั้งหมด ยกเว้นไฟล์ onepack ตัวนี้เอง
Get-ChildItem -Path $root -Filter "supabase*-admin-init*.ps1" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -ne $MyInvocation.MyCommand.Path } |
    Remove-Item -Force -ErrorAction SilentlyContinue

# เตรียม path ไฟล์ใหม่
$adminScriptPath = Join-Path $root "supabase-admin-init.ps1"

Write-Host "[2] Creating fresh supabase-admin-init.ps1..." -ForegroundColor Yellow

# เนื้อหาสคริปต์จริง สำหรับสร้าง / ตรวจ admin
$scriptContent = @'
Write-Host "== SUPABASE ADMIN INIT ==" -ForegroundColor Cyan

# ===== CONFIG =====
$SUPABASE_URL   = "https://klgypptqcegupwtdmuepz.supabase.co"
$SERVICE_KEY    = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtsZ3lwdHFjZWd1cHd0ZG11ZXB6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MzExNjUzOSwiZXhwIjoyMDc4NjkyNTM5fQ.pQvClFNL6_FpfO_xewpo6qRDiKl8IoVSlu3NOM7ZQ8o"
$ADMIN_EMAIL    = "sanookagingstudio@gmail.com"
$ADMIN_PASSWORD = "Ake@8814883"
# ==================

if (-not $SUPABASE_URL -or -not $SERVICE_KEY) {
    Write-Host "❌ Missing SUPABASE_URL or SERVICE_KEY" -ForegroundColor Red
    exit 1
}

# prepare headers
$headers = @{
    "apikey"        = $SERVICE_KEY
    "Authorization" = "Bearer $SERVICE_KEY"
}

# --- CHECK EXISTING ---
$encodedEmail = [uri]::EscapeDataString($ADMIN_EMAIL)
$checkUrl = "$SUPABASE_URL/auth/v1/admin/users?email=$encodedEmail"

Write-Host "Checking existing admin..." -ForegroundColor Yellow

try {
    $existing = Invoke-RestMethod -Uri $checkUrl -Headers $headers -Method GET
} catch {
    Write-Host "⚠ Cannot check existing user. Continue..." -ForegroundColor Yellow
    $existing = @()
}

if ($existing -and $existing.Count -gt 0) {
    Write-Host "✔ Admin already exists: $($existing[0].id)" -ForegroundColor Green
    exit 0
}

# --- CREATE ADMIN ---
$createUrl = "$SUPABASE_URL/auth/v1/admin/users"

$body = @{
    email         = $ADMIN_EMAIL
    password      = $ADMIN_PASSWORD
    email_confirm = $true
    user_metadata = @{ role = "admin" }
    app_metadata  = @{ role = "admin" }
} | ConvertTo-Json

Write-Host "Creating admin user..." -ForegroundColor Yellow

try {
    $result = Invoke-RestMethod -Uri $createUrl -Headers $headers `
        -Method POST -Body $body -ContentType "application/json"
} catch {
    Write-Host "❌ ERROR creating admin user" -ForegroundColor Red
    Write-Host $_
    exit 1
}

Write-Host "✔ Admin created successfully!" -ForegroundColor Green

if ($result.id) {
    Write-Host "User ID: $($result.id)"
} else {
    Write-Output $result
}

Write-Host "== DONE ==" -ForegroundColor Cyan
'@

# เขียนไฟล์ใหม่ทับแบบบังคับ
Set-Content -Path $adminScriptPath -Value $scriptContent -Encoding UTF8 -Force

Write-Host "[3] File written: $adminScriptPath" -ForegroundColor Green

# รันไฟล์ใหม่ทันที
Write-Host "[4] Running supabase-admin-init.ps1..." -ForegroundColor Yellow
& $adminScriptPath

Write-Host "[5] ONEPACK COMPLETED ==" -ForegroundColor Cyan












