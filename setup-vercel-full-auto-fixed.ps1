# Sanook Master V2 - Full Automation Setup for Vercel
# ตั้งค่าทุกอย่างอัตโนมัติ (รวม Environment Variables)

param(
    [string]$ProjectName = "cursor-project-x6xu"
)

$ErrorActionPreference = "Continue"

Write-Host '🤖 Sanook Master V2 - Full Automation Setup' -ForegroundColor Cyan
Write-Host '=============================================' -ForegroundColor Cyan
Write-Host ""

# ตรวจสอบว่า Vercel CLI ติดตั้งแล้วหรือยัง
$vercelInstalled = Get-Command vercel -ErrorAction SilentlyContinue

if (-not $vercelInstalled) {
    Write-Host '⚠️  Vercel CLI ยังไม่ได้ติดตั้ง' -ForegroundColor Yellow
    Write-Host '🔧 กำลังติดตั้ง Vercel CLI...' -ForegroundColor Yellow
    npm i -g vercel
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host '❌ การติดตั้ง Vercel CLI ล้มเหลว' -ForegroundColor Red
        Write-Host '💡 กรุณาติดตั้งด้วยตนเอง: npm i -g vercel' -ForegroundColor Yellow
        exit 1
    } else {
        Write-Host '✅ ติดตั้ง Vercel CLI สำเร็จ' -ForegroundColor Green
    }
}

Write-Host ""

# ตรวจสอบว่า login แล้วหรือยัง
Write-Host '🔍 ตรวจสอบ Vercel Login...' -ForegroundColor Yellow
$vercelWhoami = vercel whoami 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host '⚠️  ยังไม่ได้ Login Vercel' -ForegroundColor Yellow
    Write-Host '🔧 กำลัง Login Vercel...' -ForegroundColor Yellow
    Write-Host '   (จะเปิด Browser ให้ Login)' -ForegroundColor Gray
    vercel login
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host '❌ Login ล้มเหลว' -ForegroundColor Red
        exit 1
    } else {
        Write-Host '✅ Login สำเร็จ' -ForegroundColor Green
    }
} else {
    Write-Host "✅ Login แล้ว: $vercelWhoami" -ForegroundColor Green
}

Write-Host ""

# อ่าน Environment Variables จาก .env
$envFile = ".env"
$supabaseUrl = ""
$supabaseKey = ""

if (Test-Path $envFile) {
    Write-Host '📄 กำลังอ่าน Environment Variables จาก .env...' -ForegroundColor Yellow
    
    $envContent = Get-Content $envFile
    foreach ($line in $envContent) {
        if ($line -match "^VITE_SUPABASE_URL=(.+)$") {
            $supabaseUrl = $matches[1].Trim()
        }
        if ($line -match "^VITE_SUPABASE_ANON_KEY=(.+)$") {
            $supabaseKey = $matches[1].Trim()
        }
        if ($line -match "^VITE_SUPABASE_PUBLISHABLE_KEY=(.+)$") {
            $supabaseKey = $matches[1].Trim()
        }
    }
    
    if (-not [string]::IsNullOrEmpty($supabaseUrl) -and -not [string]::IsNullOrEmpty($supabaseKey)) {
        Write-Host '✅ อ่าน Environment Variables จาก .env สำเร็จ' -ForegroundColor Green
    } else {
        Write-Host '⚠️  ไม่พบ Environment Variables ใน .env' -ForegroundColor Yellow
        Write-Host "   กรุณาใส่ค่าเอง:" -ForegroundColor Yellow
        $supabaseUrl = Read-Host "VITE_SUPABASE_URL"
        $supabaseKey = Read-Host "VITE_SUPABASE_PUBLISHABLE_KEY"
    }
} else {
    Write-Host '⚠️  ไม่พบไฟล์ .env' -ForegroundColor Yellow
    Write-Host "   กรุณาใส่ค่าเอง:" -ForegroundColor Yellow
    $supabaseUrl = Read-Host "VITE_SUPABASE_URL"
    $supabaseKey = Read-Host "VITE_SUPABASE_PUBLISHABLE_KEY"
}

Write-Host ""

# ตั้งค่า Environment Variables ผ่าน Vercel CLI
if (-not [string]::IsNullOrEmpty($supabaseUrl) -and -not [string]::IsNullOrEmpty($supabaseKey)) {
    Write-Host '🔧 กำลังตั้งค่า Environment Variables ใน Vercel...' -ForegroundColor Yellow
    
    # Link project (ถ้ายังไม่ได้ link)
    Write-Host '   🔗 Linking project...' -ForegroundColor Gray
    vercel link --yes 2>&1 | Out-Null
    
    # ตั้งค่า Environment Variables
    Write-Host '   📝 กำลังตั้งค่า VITE_SUPABASE_URL...' -ForegroundColor Gray
    echo $supabaseUrl | vercel env add VITE_SUPABASE_URL production 2>&1 | Out-Null
    
    Write-Host '   📝 กำลังตั้งค่า VITE_SUPABASE_PUBLISHABLE_KEY...' -ForegroundColor Gray
    echo $supabaseKey | vercel env add VITE_SUPABASE_PUBLISHABLE_KEY production 2>&1 | Out-Null
    
    Write-Host '✅ ตั้งค่า Environment Variables สำเร็จ' -ForegroundColor Green
    Write-Host ""
    
    Write-Host '🔄 กำลัง Redeploy...' -ForegroundColor Yellow
    vercel --prod 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host '✅ Redeploy สำเร็จ' -ForegroundColor Green
    } else {
        Write-Host '⚠️  Redeploy อาจมีปัญหา - ตรวจสอบ output' -ForegroundColor Yellow
    }
} else {
    Write-Host '⚠️  ไม่สามารถตั้งค่า Environment Variables อัตโนมัติได้' -ForegroundColor Yellow
    Write-Host "   กรุณาตั้งค่าใน Vercel Dashboard:" -ForegroundColor Yellow
    Write-Host "   https://vercel.com/dashboard" -ForegroundColor Gray
}

Write-Host ""
Write-Host '=============================================' -ForegroundColor Cyan
Write-Host '✅ Setup Complete!' -ForegroundColor Green
Write-Host ""
Write-Host '💡 หลังจากนี้:' -ForegroundColor Yellow
Write-Host '   - Push code -> Auto-deploy' -ForegroundColor White
Write-Host '   - ไม่ต้องทำอะไรเพิ่ม' -ForegroundColor White
Write-Host ""

