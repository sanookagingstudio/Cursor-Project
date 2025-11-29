# 🚀 Sanook Master V2 - Automated Deployment Script
# Deploy อัตโนมัติ - เปลี่ยน Platform ได้ง่าย

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("lovable", "vercel", "netlify", "all")]
    [string]$Platform = "all",
    
    [Parameter(Mandatory=$false)]
    [string]$Domain = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$Production
)

$ErrorActionPreference = "Continue"

Write-Host "🚀 Sanook Master V2 - Automated Deployment" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = Get-Location

# ตรวจสอบว่าอยู่ในโฟลเดอร์โปรเจกต์
if (-not (Test-Path "package.json")) {
    Write-Host "❌ Error: ไม่พบ package.json" -ForegroundColor Red
    Write-Host "   กรุณารันสคริปต์นี้ในโฟลเดอร์โปรเจกต์" -ForegroundColor Yellow
    exit 1
}

# Build project ก่อน
Write-Host "🔨 กำลัง Build Project..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build ล้มเหลว" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build สำเร็จ" -ForegroundColor Green
Write-Host ""

# Deploy ตาม Platform ที่เลือก
if ($Platform -eq "all" -or $Platform -eq "lovable") {
    Write-Host "📦 Deploy ผ่าน Lovable..." -ForegroundColor Cyan
    Write-Host "   1. ไปที่: https://lovable.dev/projects/b1dcfbcc-757f-4cf7-a141-fc9cb774d4b9" -ForegroundColor Gray
    Write-Host "   2. คลิก Share → Publish" -ForegroundColor Gray
    Write-Host "   3. เลือก Domain หรือใช้ Domain ฟรี" -ForegroundColor Gray
    Write-Host ""
}

if ($Platform -eq "all" -or $Platform -eq "vercel") {
    Write-Host "📦 Deploy ผ่าน Vercel..." -ForegroundColor Cyan
    
    # ตรวจสอบว่า Vercel CLI ติดตั้งแล้วหรือยัง
    $vercelInstalled = Get-Command vercel -ErrorAction SilentlyContinue
    
    if (-not $vercelInstalled) {
        Write-Host "   ⚠️  Vercel CLI ยังไม่ได้ติดตั้ง" -ForegroundColor Yellow
        Write-Host "   🔧 กำลังติดตั้ง Vercel CLI..." -ForegroundColor Yellow
        npm i -g vercel
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "   ❌ การติดตั้ง Vercel CLI ล้มเหลว" -ForegroundColor Red
            Write-Host "   💡 กรุณาติดตั้งด้วยตนเอง: npm i -g vercel" -ForegroundColor Yellow
        } else {
            Write-Host "   ✅ ติดตั้ง Vercel CLI สำเร็จ" -ForegroundColor Green
        }
    }
    
    Write-Host "   🚀 กำลัง Deploy..." -ForegroundColor Yellow
    
    if ($Production) {
        vercel --prod
    } else {
        vercel
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Deploy Vercel สำเร็จ" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Deploy Vercel อาจมีปัญหา - ตรวจสอบ output ด้านบน" -ForegroundColor Yellow
    }
    Write-Host ""
}

if ($Platform -eq "all" -or $Platform -eq "netlify") {
    Write-Host "📦 Deploy ผ่าน Netlify..." -ForegroundColor Cyan
    
    # ตรวจสอบว่า Netlify CLI ติดตั้งแล้วหรือยัง
    $netlifyInstalled = Get-Command netlify -ErrorAction SilentlyContinue
    
    if (-not $netlifyInstalled) {
        Write-Host "   ⚠️  Netlify CLI ยังไม่ได้ติดตั้ง" -ForegroundColor Yellow
        Write-Host "   🔧 กำลังติดตั้ง Netlify CLI..." -ForegroundColor Yellow
        npm i -g netlify-cli
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "   ❌ การติดตั้ง Netlify CLI ล้มเหลว" -ForegroundColor Red
            Write-Host "   💡 กรุณาติดตั้งด้วยตนเอง: npm i -g netlify-cli" -ForegroundColor Yellow
        } else {
            Write-Host "   ✅ ติดตั้ง Netlify CLI สำเร็จ" -ForegroundColor Green
        }
    }
    
    Write-Host "   🚀 กำลัง Deploy..." -ForegroundColor Yellow
    
    if ($Production) {
        netlify deploy --prod
    } else {
        netlify deploy
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Deploy Netlify สำเร็จ" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Deploy Netlify อาจมีปัญหา - ตรวจสอบ output ด้านบน" -ForegroundColor Yellow
    }
    Write-Host ""
}

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "✅ Deployment Process เสร็จสมบูรณ์!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Tips:" -ForegroundColor Yellow
Write-Host "   - ตรวจสอบ URL ที่ได้จาก output ด้านบน" -ForegroundColor Gray
Write-Host "   - ตั้งค่า Custom Domain ใน Platform Dashboard" -ForegroundColor Gray
Write-Host "   - ดูคู่มือ: DEPLOYMENT_GUIDE.md" -ForegroundColor Gray
Write-Host ""

