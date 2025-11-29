# 🔧 Sanook Master V2 - Setup Vercel Environment Variables
# ตั้งค่า Environment Variables ใน Vercel อัตโนมัติ

param(
    [string]$ProjectName = "cursor-project-x6xu",
    [string]$SupabaseUrl = "",
    [string]$SupabaseKey = "",
    [string]$ApiUrl = ""
)

$ErrorActionPreference = "Continue"

Write-Host "🔧 Sanook Master V2 - Setup Vercel Environment Variables" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# ตรวจสอบว่า Vercel CLI ติดตั้งแล้วหรือยัง
$vercelInstalled = Get-Command vercel -ErrorAction SilentlyContinue

if (-not $vercelInstalled) {
    Write-Host "⚠️  Vercel CLI ยังไม่ได้ติดตั้ง" -ForegroundColor Yellow
    Write-Host "🔧 กำลังติดตั้ง Vercel CLI..." -ForegroundColor Yellow
    npm i -g vercel
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ การติดตั้ง Vercel CLI ล้มเหลว" -ForegroundColor Red
        Write-Host "💡 กรุณาติดตั้งด้วยตนเอง: npm i -g vercel" -ForegroundColor Yellow
        exit 1
    } else {
        Write-Host "✅ ติดตั้ง Vercel CLI สำเร็จ" -ForegroundColor Green
    }
}

Write-Host ""

# อ่าน Environment Variables จาก .env (ถ้ามี)
$envFile = ".env"
if (Test-Path $envFile) {
    Write-Host "📄 พบไฟล์ .env - กำลังอ่านค่า..." -ForegroundColor Yellow
    
    $envContent = Get-Content $envFile
    foreach ($line in $envContent) {
        if ($line -match "^VITE_SUPABASE_URL=(.+)$") {
            if ([string]::IsNullOrEmpty($SupabaseUrl)) {
                $SupabaseUrl = $matches[1].Trim()
            }
        }
        if ($line -match "^VITE_SUPABASE_ANON_KEY=(.+)$") {
            if ([string]::IsNullOrEmpty($SupabaseKey)) {
                $SupabaseKey = $matches[1].Trim()
            }
        }
        if ($line -match "^VITE_API_BASE_URL=(.+)$") {
            if ([string]::IsNullOrEmpty($ApiUrl)) {
                $ApiUrl = $matches[1].Trim()
            }
        }
    }
    
    Write-Host "✅ อ่านค่า Environment Variables จาก .env แล้ว" -ForegroundColor Green
} else {
    Write-Host "⚠️  ไม่พบไฟล์ .env" -ForegroundColor Yellow
}

Write-Host ""

# ถ้ายังไม่มีค่า ให้ถามผู้ใช้
if ([string]::IsNullOrEmpty($SupabaseUrl)) {
    $SupabaseUrl = Read-Host "กรุณาใส่ VITE_SUPABASE_URL (หรือกด Enter เพื่อข้าม)"
}

if ([string]::IsNullOrEmpty($SupabaseKey)) {
    $SupabaseKey = Read-Host "กรุณาใส่ VITE_SUPABASE_PUBLISHABLE_KEY (หรือกด Enter เพื่อข้าม)"
}

if ([string]::IsNullOrEmpty($ApiUrl)) {
    $ApiUrl = Read-Host "กรุณาใส่ VITE_API_BASE_URL (หรือกด Enter เพื่อข้าม)"
}

Write-Host ""
Write-Host "🔧 กำลังตั้งค่า Environment Variables ใน Vercel..." -ForegroundColor Yellow
Write-Host ""

# ตั้งค่า Environment Variables
$envVars = @()

if (-not [string]::IsNullOrEmpty($SupabaseUrl)) {
    $envVars += @{
        key = "VITE_SUPABASE_URL"
        value = $SupabaseUrl
    }
    Write-Host "✅ VITE_SUPABASE_URL: $SupabaseUrl" -ForegroundColor Green
}

if (-not [string]::IsNullOrEmpty($SupabaseKey)) {
    $envVars += @{
        key = "VITE_SUPABASE_PUBLISHABLE_KEY"
        value = $SupabaseKey
    }
    Write-Host "✅ VITE_SUPABASE_PUBLISHABLE_KEY: [HIDDEN]" -ForegroundColor Green
}

if (-not [string]::IsNullOrEmpty($ApiUrl)) {
    $envVars += @{
        key = "VITE_API_BASE_URL"
        value = $ApiUrl
    }
    Write-Host "✅ VITE_API_BASE_URL: $ApiUrl" -ForegroundColor Green
}

Write-Host ""
Write-Host "⚠️  หมายเหตุ: Vercel CLI ไม่รองรับการตั้งค่า Environment Variables ผ่าน command line โดยตรง" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 วิธีตั้งค่า Environment Variables:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   1. ไปที่ Vercel Dashboard:" -ForegroundColor White
Write-Host "      https://vercel.com/dashboard" -ForegroundColor Gray
Write-Host ""
Write-Host "   2. เลือก Project: $ProjectName" -ForegroundColor White
Write-Host ""
Write-Host "   3. ไปที่ Settings → Environment Variables" -ForegroundColor White
Write-Host ""
Write-Host "   4. เพิ่ม Environment Variables:" -ForegroundColor White
if (-not [string]::IsNullOrEmpty($SupabaseUrl)) {
    Write-Host "      Key: VITE_SUPABASE_URL" -ForegroundColor Gray
    Write-Host "      Value: $SupabaseUrl" -ForegroundColor Gray
    Write-Host ""
}
if (-not [string]::IsNullOrEmpty($SupabaseKey)) {
    Write-Host "      Key: VITE_SUPABASE_PUBLISHABLE_KEY" -ForegroundColor Gray
    Write-Host "      Value: [HIDDEN - ดูจาก .env]" -ForegroundColor Gray
    Write-Host ""
}
if (-not [string]::IsNullOrEmpty($ApiUrl)) {
    Write-Host "      Key: VITE_API_BASE_URL" -ForegroundColor Gray
    Write-Host "      Value: $ApiUrl" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "   5. คลิก 'Save'" -ForegroundColor White
Write-Host ""
Write-Host "   6. Redeploy:" -ForegroundColor White
Write-Host "      Deployments → ... → Redeploy" -ForegroundColor Gray
Write-Host ""

# สร้างไฟล์ template สำหรับ copy-paste
$templateFile = "vercel-env-template.txt"
$templateContent = @"
# Vercel Environment Variables
# Copy and paste these values in Vercel Dashboard → Settings → Environment Variables

VITE_SUPABASE_URL=$SupabaseUrl
VITE_SUPABASE_PUBLISHABLE_KEY=$SupabaseKey
VITE_API_BASE_URL=$ApiUrl
"@

$templateContent | Out-File -FilePath $templateFile -Encoding UTF8 -Force

Write-Host "✅ สร้างไฟล์ template: $templateFile" -ForegroundColor Green
Write-Host "   เปิดไฟล์นี้เพื่อ copy-paste ไป Vercel Dashboard" -ForegroundColor Gray
Write-Host ""

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "✅ Setup Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. เปิดไฟล์: $templateFile" -ForegroundColor White
Write-Host "   2. Copy values ไปตั้งค่าใน Vercel Dashboard" -ForegroundColor White
Write-Host "   3. Redeploy ใน Vercel" -ForegroundColor White
Write-Host ""


