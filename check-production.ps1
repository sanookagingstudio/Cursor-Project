# Sanook Master V2 - Production URL Checker
# ตรวจสอบว่า Production URL ทำงานได้หรือไม่

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "🌐 Sanook Master V2 - Production URL Checker" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# 1. ตรวจสอบ Vercel Project
# ============================================
Write-Host "🔍 ตรวจสอบ Vercel Project..." -ForegroundColor Yellow

$vercelInstalled = Get-Command vercel -ErrorAction SilentlyContinue
if (-not $vercelInstalled) {
    Write-Host "   ⚠️  Vercel CLI ยังไม่ได้ติดตั้ง" -ForegroundColor Yellow
    Write-Host "   💡 ติดตั้งด้วย: npm i -g vercel" -ForegroundColor Gray
} else {
    Write-Host "   ✅ Vercel CLI: ติดตั้งแล้ว" -ForegroundColor Green
    
    # ตรวจสอบว่า login แล้วหรือยัง
    $vercelWhoami = vercel whoami 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Vercel Login: $vercelWhoami" -ForegroundColor Green
        
        # ตรวจสอบว่า project linked หรือไม่
        if (Test-Path ".vercel") {
            Write-Host "   ✅ Project: Linked" -ForegroundColor Green
            
            # อ่าน project info
            $projectJson = Get-Content ".vercel/project.json" -ErrorAction SilentlyContinue | ConvertFrom-Json
            if ($projectJson) {
                Write-Host "   📦 Project ID: $($projectJson.projectId)" -ForegroundColor Gray
                Write-Host "   📦 Org ID: $($projectJson.orgId)" -ForegroundColor Gray
            }
        } else {
            Write-Host "   ⚠️  Project: ยังไม่ได้ link" -ForegroundColor Yellow
            Write-Host "   💡 Link ด้วย: vercel link" -ForegroundColor Gray
        }
    } else {
        Write-Host "   ⚠️  Vercel: ยังไม่ได้ login" -ForegroundColor Yellow
        Write-Host "   💡 Login ด้วย: vercel login" -ForegroundColor Gray
    }
}

Write-Host ""

# ============================================
# 2. ตรวจสอบ Environment Variables ใน Vercel
# ============================================
Write-Host "🔍 ตรวจสอบ Environment Variables..." -ForegroundColor Yellow

if ($vercelInstalled -and (Test-Path ".vercel")) {
    Write-Host "   💡 ตรวจสอบ Environment Variables ใน Vercel Dashboard:" -ForegroundColor Gray
    Write-Host "      https://vercel.com/dashboard" -ForegroundColor Gray
    Write-Host "   💡 ต้องมี:" -ForegroundColor Gray
    Write-Host "      - VITE_SUPABASE_URL" -ForegroundColor White
    Write-Host "      - VITE_SUPABASE_PUBLISHABLE_KEY" -ForegroundColor White
} else {
    Write-Host "   ⚠️  ไม่สามารถตรวจสอบได้ (ต้องติดตั้ง Vercel CLI และ link project)" -ForegroundColor Yellow
}

Write-Host ""

# ============================================
# 3. ตรวจสอบ Production URL
# ============================================
Write-Host "🌐 ตรวจสอบ Production URL..." -ForegroundColor Yellow

# ลองหา production URL จาก git remote หรือ vercel
$productionUrl = $null

# ตรวจสอบจาก vercel
if ($vercelInstalled -and (Test-Path ".vercel")) {
    try {
        $vercelInfo = vercel inspect --scope 2>&1
        if ($LASTEXITCODE -eq 0) {
            # Extract URL from vercel output
            $urlMatch = $vercelInfo | Select-String -Pattern "https://.*\.vercel\.app"
            if ($urlMatch) {
                $productionUrl = $urlMatch.Matches[0].Value
            }
        }
    } catch {
        # Ignore errors
    }
}

# ถ้าไม่พบ ให้ถามผู้ใช้
if (-not $productionUrl) {
    $productionUrl = Read-Host "กรุณาใส่ Production URL (เช่น https://your-project.vercel.app)"
}

if ($productionUrl) {
    Write-Host "   🔗 Production URL: $productionUrl" -ForegroundColor Cyan
    Write-Host ""
    
    # ทดสอบ connection
    Write-Host "   🔍 กำลังทดสอบ connection..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri $productionUrl -TimeoutSec 10 -ErrorAction Stop -UseBasicParsing
        
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✅ Connection: สำเร็จ (Status: $($response.StatusCode))" -ForegroundColor Green
            
            # ตรวจสอบว่า HTML มี content หรือไม่
            if ($response.Content -match "<div id=`"root`">") {
                Write-Host "   ✅ HTML Structure: ถูกต้อง" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️  HTML Structure: อาจไม่ถูกต้อง" -ForegroundColor Yellow
            }
            
            # ตรวจสอบว่า Supabase config มีหรือไม่
            if ($response.Content -match "VITE_SUPABASE") {
                Write-Host "   ⚠️  พบ Supabase config ใน HTML (อาจมีปัญหา)" -ForegroundColor Yellow
            }
            
        } else {
            Write-Host "   ⚠️  Connection: Status Code $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Connection: ล้มเหลว" -ForegroundColor Red
        Write-Host "   💡 Error: $($_.Exception.Message)" -ForegroundColor Gray
        Write-Host "   💡 ตรวจสอบว่า:" -ForegroundColor Yellow
        Write-Host "      - URL ถูกต้องหรือไม่" -ForegroundColor White
        Write-Host "      - Deployment สำเร็จหรือไม่" -ForegroundColor White
        Write-Host "      - Environment Variables ตั้งค่าแล้วหรือไม่" -ForegroundColor White
    }
} else {
    Write-Host "   ⚠️  ไม่พบ Production URL" -ForegroundColor Yellow
}

Write-Host ""

# ============================================
# 4. ตรวจสอบ Build
# ============================================
Write-Host "🏗️  ตรวจสอบ Build..." -ForegroundColor Yellow

if (Test-Path "dist") {
    Write-Host "   ✅ dist folder: พบ" -ForegroundColor Green
    if (Test-Path "dist/index.html") {
        Write-Host "   ✅ dist/index.html: พบ" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  dist/index.html: ไม่พบ" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ⚠️  dist folder: ไม่พบ (ยังไม่ได้ build)" -ForegroundColor Yellow
    Write-Host "   💡 Build ด้วย: npm run build" -ForegroundColor Gray
}

Write-Host ""

# ============================================
# สรุป
# ============================================
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "📊 สรุป" -ForegroundColor Cyan
Write-Host ""

Write-Host "💡 วิธีตรวจสอบ Production URL:" -ForegroundColor Yellow
Write-Host "   1. ไปที่ Vercel Dashboard: https://vercel.com/dashboard" -ForegroundColor White
Write-Host "   2. เลือก Project ของคุณ" -ForegroundColor White
Write-Host "   3. ดู Production URL ในหน้า Overview" -ForegroundColor White
Write-Host "   4. ตรวจสอบ Environment Variables ใน Settings > Environment Variables" -ForegroundColor White
Write-Host ""

Write-Host "💡 วิธี Deploy:" -ForegroundColor Yellow
Write-Host "   1. Push code ไป GitHub" -ForegroundColor White
Write-Host "   2. Vercel จะ auto-deploy อัตโนมัติ" -ForegroundColor White
Write-Host "   3. หรือ deploy ด้วย: vercel --prod" -ForegroundColor White
Write-Host ""

Write-Host "💡 ถ้า Production URL ไม่ทำงาน:" -ForegroundColor Yellow
Write-Host "   1. ตรวจสอบ Environment Variables ใน Vercel Dashboard" -ForegroundColor White
Write-Host "   2. ตรวจสอบ Deployment Logs ใน Vercel Dashboard" -ForegroundColor White
Write-Host "   3. ตรวจสอบว่า Build สำเร็จหรือไม่" -ForegroundColor White
Write-Host "   4. ลอง Redeploy: vercel --prod" -ForegroundColor White
Write-Host ""

