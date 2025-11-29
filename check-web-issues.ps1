# Sanook Master V2 - Web Issues Diagnostic Tool
# ตรวจสอบปัญหาหน้าเว็บว่างเปล่าและ connection issues แบบอัตโนมัติ

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "🔍 Sanook Master V2 - Web Issues Diagnostic" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

$issuesFound = @()
$warningsFound = @()

# ============================================
# 1. ตรวจสอบไฟล์ .env
# ============================================
Write-Host "📄 ตรวจสอบไฟล์ .env..." -ForegroundColor Yellow
$envFile = ".env"

if (-not (Test-Path $envFile)) {
    $issuesFound += "Missing .env file"
    Write-Host "   ❌ ไม่พบไฟล์ .env" -ForegroundColor Red
    Write-Host "   💡 สร้างไฟล์ .env และเพิ่ม:" -ForegroundColor Yellow
    Write-Host "      VITE_SUPABASE_URL=your_url" -ForegroundColor Gray
    Write-Host "      VITE_SUPABASE_PUBLISHABLE_KEY=your_key" -ForegroundColor Gray
} else {
    Write-Host "   ✅ พบไฟล์ .env" -ForegroundColor Green
    
    $envContent = Get-Content $envFile -ErrorAction SilentlyContinue
    $hasSupabaseUrl = $false
    $hasSupabaseKey = $false
    
    foreach ($line in $envContent) {
        if ($line -match "^VITE_SUPABASE_URL\s*=") {
            $hasSupabaseUrl = $true
            $urlValue = ($line -split "=", 2)[1].Trim()
            if ([string]::IsNullOrWhiteSpace($urlValue) -or $urlValue -eq "your_url") {
                $issuesFound += "VITE_SUPABASE_URL not set"
                Write-Host "   ⚠️  VITE_SUPABASE_URL ไม่ได้ตั้งค่า" -ForegroundColor Yellow
            } else {
                Write-Host "   ✅ VITE_SUPABASE_URL: $($urlValue.Substring(0, [Math]::Min(30, $urlValue.Length)))..." -ForegroundColor Green
            }
        }
        if ($line -match "^VITE_SUPABASE_PUBLISHABLE_KEY\s*=") {
            $hasSupabaseKey = $true
            $keyValue = ($line -split "=", 2)[1].Trim()
            if ([string]::IsNullOrWhiteSpace($keyValue) -or $keyValue -eq "your_key") {
                $issuesFound += "VITE_SUPABASE_PUBLISHABLE_KEY not set"
                Write-Host "   ⚠️  VITE_SUPABASE_PUBLISHABLE_KEY ไม่ได้ตั้งค่า" -ForegroundColor Yellow
            } else {
                Write-Host "   ✅ VITE_SUPABASE_PUBLISHABLE_KEY: $($keyValue.Substring(0, [Math]::Min(20, $keyValue.Length)))..." -ForegroundColor Green
            }
        }
    }
    
    if (-not $hasSupabaseUrl) {
        $issuesFound += "VITE_SUPABASE_URL missing in .env"
        Write-Host "   ❌ ไม่พบ VITE_SUPABASE_URL ใน .env" -ForegroundColor Red
    }
    if (-not $hasSupabaseKey) {
        $issuesFound += "VITE_SUPABASE_PUBLISHABLE_KEY missing in .env"
        Write-Host "   ❌ ไม่พบ VITE_SUPABASE_PUBLISHABLE_KEY ใน .env" -ForegroundColor Red
    }
}

Write-Host ""

# ============================================
# 2. ตรวจสอบ Frontend Server
# ============================================
Write-Host "🌐 ตรวจสอบ Frontend Server..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 3 -ErrorAction Stop -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ Frontend Server: ทำงานอยู่ (http://localhost:8080)" -ForegroundColor Green
        
        # ตรวจสอบว่า HTML มี content หรือไม่
        if ($response.Content -match "<div id=`"root`">") {
            Write-Host "   ✅ HTML Structure: ถูกต้อง" -ForegroundColor Green
        } else {
            $warningsFound += "HTML structure may be incorrect"
            Write-Host "   ⚠️  HTML structure อาจไม่ถูกต้อง" -ForegroundColor Yellow
        }
    }
} catch {
    $issuesFound += "Frontend Server not running"
    Write-Host "   ❌ Frontend Server: ไม่ทำงาน" -ForegroundColor Red
    Write-Host "   💡 รันคำสั่ง: npm run dev" -ForegroundColor Yellow
}

Write-Host ""

# ============================================
# 3. ตรวจสอบ Node Modules
# ============================================
Write-Host "📦 ตรวจสอบ Dependencies..." -ForegroundColor Yellow
if (Test-Path "node_modules") {
    Write-Host "   ✅ node_modules: พบ" -ForegroundColor Green
    
    # ตรวจสอบ package.json
    if (Test-Path "package.json") {
        $packageJson = Get-Content "package.json" | ConvertFrom-Json
        Write-Host "   ✅ package.json: พบ" -ForegroundColor Green
    } else {
        $issuesFound += "package.json missing"
        Write-Host "   ❌ ไม่พบ package.json" -ForegroundColor Red
    }
} else {
    $issuesFound += "node_modules missing"
    Write-Host "   ❌ ไม่พบ node_modules" -ForegroundColor Red
    Write-Host "   💡 รันคำสั่ง: npm install" -ForegroundColor Yellow
}

Write-Host ""

# ============================================
# 4. ตรวจสอบ Build Files
# ============================================
Write-Host "🏗️  ตรวจสอบ Build Files..." -ForegroundColor Yellow
if (Test-Path "dist") {
    Write-Host "   ✅ dist folder: พบ" -ForegroundColor Green
    if (Test-Path "dist/index.html") {
        Write-Host "   ✅ dist/index.html: พบ" -ForegroundColor Green
    } else {
        $warningsFound += "dist/index.html missing"
        Write-Host "   ⚠️  ไม่พบ dist/index.html" -ForegroundColor Yellow
    }
} else {
    $warningsFound += "dist folder missing (may not be built yet)"
    Write-Host "   ⚠️  ไม่พบ dist folder (อาจยังไม่ได้ build)" -ForegroundColor Yellow
}

Write-Host ""

# ============================================
# 5. ตรวจสอบ Console Errors (แนะนำ)
# ============================================
Write-Host "💻 ตรวจสอบ Browser Console..." -ForegroundColor Yellow
Write-Host "   💡 เปิด Browser Developer Tools (F12)" -ForegroundColor Gray
Write-Host "   💡 ไปที่ Console tab" -ForegroundColor Gray
Write-Host "   💡 ดู error messages (สีแดง)" -ForegroundColor Gray
Write-Host "   💡 ดู warning messages (สีเหลือง)" -ForegroundColor Gray

Write-Host ""

# ============================================
# 6. ตรวจสอบ Network Requests
# ============================================
Write-Host "🌐 ตรวจสอบ Network Requests..." -ForegroundColor Yellow
Write-Host "   💡 เปิด Browser Developer Tools (F12)" -ForegroundColor Gray
Write-Host "   💡 ไปที่ Network tab" -ForegroundColor Gray
Write-Host "   💡 Refresh หน้าเว็บ (F5)" -ForegroundColor Gray
Write-Host "   💡 ดู requests ที่ fail (สีแดง)" -ForegroundColor Gray

Write-Host ""

# ============================================
# สรุปผลการตรวจสอบ
# ============================================
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "📊 สรุปผลการตรวจสอบ" -ForegroundColor Cyan
Write-Host ""

if ($issuesFound.Count -eq 0 -and $warningsFound.Count -eq 0) {
    Write-Host "✅ ไม่พบปัญหาที่ชัดเจน" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 ถ้าหน้าเว็บยังว่างเปล่า:" -ForegroundColor Yellow
    Write-Host "   1. ตรวจสอบ Browser Console (F12)" -ForegroundColor White
    Write-Host "   2. ตรวจสอบ Network tab" -ForegroundColor White
    Write-Host "   3. ลอง Clear Cache (Ctrl+Shift+Delete)" -ForegroundColor White
    Write-Host "   4. ลองเปิดใน Incognito mode" -ForegroundColor White
} else {
    if ($issuesFound.Count -gt 0) {
        Write-Host "❌ พบปัญหา:" -ForegroundColor Red
        foreach ($issue in $issuesFound) {
            Write-Host "   $issue" -ForegroundColor Red
        }
        Write-Host ""
    }
    
    if ($warningsFound.Count -gt 0) {
        Write-Host "⚠️  คำเตือน:" -ForegroundColor Yellow
        foreach ($warning in $warningsFound) {
            Write-Host "   $warning" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    
    Write-Host "💡 วิธีแก้ไข:" -ForegroundColor Yellow
    Write-Host "   1. แก้ไขปัญหาที่พบด้านบน" -ForegroundColor White
    Write-Host "   2. Restart development server (npm run dev)" -ForegroundColor White
    Write-Host "   3. Clear browser cache" -ForegroundColor White
}

Write-Host ""
Write-Host "Read more details: CONNECTION_FAIL_FIX.md" -ForegroundColor Cyan
Write-Host ""
