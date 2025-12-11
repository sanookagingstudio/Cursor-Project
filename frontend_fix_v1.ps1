# ============================================================

# FRONTEND-FIX V1 — FULL AUTO-REPAIR (Next.js Self-Healing)

# สำหรับโปรเจกต์ FunAging.club (SAS v1 Baseline)

# ไม่มีคำอธิบาย — ONE PACK พร้อมรันบน Cursor ทันที

# เซฟเป็น: frontend_fix_v1.ps1 แล้วรันด้วย pwsh

# ============================================================



$ErrorActionPreference = "Stop"



$LOG = "frontend_fix_v1.log"

function LOG($msg) {

    Add-Content -Path $LOG -Value "$(Get-Date -Format o) $msg"

}



LOG "[START] FRONTEND-FIX V1"



# ------------------------------------------------------------

# PHASE A — ตรวจสอบโครงสร้าง frontend

# ------------------------------------------------------------



$FRONTEND = "frontend"

if (!(Test-Path $FRONTEND)) {

    LOG "[A] frontend/ ไม่พบ — สร้างใหม่"

    New-Item -ItemType Directory -Path $FRONTEND | Out-Null

}



# ------------------------------------------------------------

# PHASE B — package.json (สร้างใหม่ถ้าไม่มี)

# ------------------------------------------------------------



$PKG = Join-Path $FRONTEND "package.json"



if (!(Test-Path $PKG)) {

    LOG "[B] ไม่มี package.json — สร้างใหม่ตาม SAS v1 baseline"



@"

{

  "name": "funaging-frontend",

  "version": "1.0.0",

  "private": true,

  "scripts": {

    "dev": "next dev -p 3000",

    "build": "next build",

    "start": "next start -p 3000"

  },

  "dependencies": {

    "next": "14.1.0",

    "react": "18.2.0",

    "react-dom": "18.2.0",

    "@supabase/supabase-js": "2.45.0",

    "lucide-react": "latest",

    "tailwindcss": "3.4.0",

    "postcss": "8.4.35",

    "autoprefixer": "10.4.20"

  }

}

"@ | Set-Content -Path $PKG -Encoding UTF8

}



LOG "[B] package.json OK"



# ------------------------------------------------------------

# PHASE C — Tailwind baseline (config + globals)

# ------------------------------------------------------------



$TAILWIND = Join-Path $FRONTEND "tailwind.config.js"

if (!(Test-Path $TAILWIND)) {

@"

module.exports = {

  content: [

    "./app/**/*.{js,ts,jsx,tsx}",

    "./components/**/*.{js,ts,jsx,tsx}"

  ],

  theme: { extend: {} },

  plugins: []

}

"@ | Set-Content -Path $TAILWIND -Encoding UTF8

    LOG "[C] tailwind.config.js created"

}



$POSTCSS = Join-Path $FRONTEND "postcss.config.js"

if (!(Test-Path $POSTCSS)) {

@"

module.exports = {

  plugins: {

    tailwindcss: {},

    autoprefixer: {}

  }

}

"@ | Set-Content -Path $POSTCSS -Encoding UTF8

    LOG "[C] postcss.config.js created"

}



# globals.css

$STYLES = Join-Path $FRONTEND "app\globals.css"

if (!(Test-Path (Split-Path $STYLES))) { New-Item -ItemType Directory -Path (Split-Path $STYLES) | Out-Null }



@"

@tailwind base;

@tailwind components;

@tailwind utilities;

"@ | Set-Content -Path $STYLES -Encoding UTF8



LOG "[C] Tailwind baseline OK"



# ------------------------------------------------------------

# PHASE D — โครงสร้าง Next.js app router

# ------------------------------------------------------------



$APPJS = Join-Path $FRONTEND "app\page.tsx"

if (!(Test-Path $APPJS)) {

@"

export default function Home() {

  return (

    <div class='p-10 text-3xl font-bold'>

      FunAging Frontend is running 🎉

    </div>

  );

}

"@ | Set-Content -Path $APPJS -Encoding UTF8

LOG "[D] page.tsx created"

}



# ------------------------------------------------------------

# PHASE E — ติดตั้ง Dependencies แบบ Self-Healing

# ------------------------------------------------------------



LOG "[E] เริ่มติดตั้ง dependencies"



Push-Location $FRONTEND



if (Test-Path "package-lock.json") { Remove-Item "package-lock.json" -Force }

if (Test-Path "node_modules") { Remove-Item "node_modules" -Recurse -Force }



LOG "[E] running npm install..."

npm install | Out-Null



LOG "[E] npm install เสร็จสมบูรณ์"



Pop-Location



# ------------------------------------------------------------

# PHASE F — เริ่ม dev server อัตโนมัติ

# ------------------------------------------------------------



LOG "[F] starting frontend dev server..."



Start-Process pwsh -ArgumentList "-Command", "cd frontend; npm run dev" -WindowStyle Minimized



LOG "[F] frontend dev started"



# ------------------------------------------------------------

# END

# ------------------------------------------------------------



LOG "[DONE] FRONTEND-FIX V1 FINISHED"



"FRONTEND-FIX V1 COMPLETE — ดู log ได้ที่ $LOG"





