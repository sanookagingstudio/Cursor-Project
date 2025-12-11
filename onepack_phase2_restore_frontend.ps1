param()

$ErrorActionPreference = "Stop"

function Write-Section($text) {
    Write-Host ""
    Write-Host "=== $text ===" -ForegroundColor Cyan
}

function Write-Ok($text) {
    Write-Host "✔ $text" -ForegroundColor Green
}

function Write-Warn($text) {
    Write-Host "⚠ $text" -ForegroundColor Yellow
}

function Write-ErrMsg($text) {
    Write-Host "✖ $text" -ForegroundColor Red
}

Write-Section "PHASE 2 :: FUNAGING FRONTEND FULL AUTO RESTORE (NEXT.JS 14)"

# 1) Validate root
if (-not (Test-Path (Join-Path (Get-Location) "backend"))) {
    Write-ErrMsg "Backend folder not found. Make sure you run this at sanook-master-v2-main root."
    exit 1
}
if (-not (Test-Path (Join-Path (Get-Location) "frontend"))) {
    Write-Warn "No frontend folder found. A fresh frontend will be created."
} else {
    Write-Ok "Root appears to be correct (backend/frontend structure found)."
}

$root = Get-Location
$frontendPath = Join-Path $root "frontend"

# 2) Backup existing frontend
Write-Section "BACKUP CURRENT FRONTEND"

if (Test-Path $frontendPath) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupName = "frontend_BACKUP_{0}" -f $timestamp
    $backupPath = Join-Path $root $backupName

    Write-Warn "Existing frontend detected. Copying to: $backupName"
    # Stop any node processes that might be using the folder
    Get-Process -Name node -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    
    # Try rename first, fallback to copy if locked
    try {
        Rename-Item -Path $frontendPath -NewName $backupName -ErrorAction Stop
        Write-Ok "Frontend backup created (renamed): $backupName"
    } catch {
        Write-Warn "Rename failed, trying copy instead..."
        Copy-Item -Path $frontendPath -Destination $backupPath -Recurse -Force
        Remove-Item -Path $frontendPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Ok "Frontend backup created (copied): $backupName"
    }
} else {
    Write-Ok "No existing frontend folder. Fresh create."
}

# 3) Create new frontend structure
Write-Section "CREATE NEW NEXT.JS 14 FRONTEND (APP ROUTER + TAILWIND)"

New-Item -ItemType Directory -Path $frontendPath -Force | Out-Null

$srcPath = Join-Path $frontendPath "src"
$appPath = Join-Path $srcPath "app"
$componentsPath = Join-Path $srcPath "components"
$publicPath = Join-Path $frontendPath "public"

New-Item -ItemType Directory -Path $srcPath -Force | Out-Null
New-Item -ItemType Directory -Path $appPath -Force | Out-Null
New-Item -ItemType Directory -Path $componentsPath -Force | Out-Null
New-Item -ItemType Directory -Path $publicPath -Force | Out-Null

# 3.1 package.json
$packageJsonContent = @'
{
  "name": "funaging-frontend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "autoprefixer": "^10.4.20",
    "lucide-react": "^0.460.0",
    "next": "14.1.0",
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "tailwindcss": "^3.4.17"
  },
  "devDependencies": {
    "@types/node": "20.10.5",
    "@types/react": "18.2.37",
    "@types/react-dom": "18.2.15",
    "eslint": "^8.56.0",
    "eslint-config-next": "14.1.0",
    "postcss": "^8.4.49",
    "typescript": "^5.6.3"
  }
}
'@
Set-Content -Path (Join-Path $frontendPath "package.json") -Value $packageJsonContent -Encoding UTF8

# 3.2 next.config.js
$nextConfigContent = @'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: false,
  swcMinify: true,
  images: {
    domains: [
      "localhost",
      "127.0.0.1",
      "lh3.googleusercontent.com",
      "images.unsplash.com",
      "cdn.jsdelivr.net"
    ]
  }
};

module.exports = nextConfig;
'@
Set-Content -Path (Join-Path $frontendPath "next.config.js") -Value $nextConfigContent -Encoding UTF8

# 3.3 tsconfig.json
$tsconfigContent = @'
{
  "compilerOptions": {
    "target": "ESNext",
    "lib": ["DOM", "DOM.Iterable", "ESNext"],
    "allowJs": false,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": [
    "next-env.d.ts",
    "src/**/*",
    "next.config.js",
    "tailwind.config.ts",
    "postcss.config.cjs"
  ],
  "exclude": ["node_modules"]
}
'@
Set-Content -Path (Join-Path $frontendPath "tsconfig.json") -Value $tsconfigContent -Encoding UTF8

# 3.4 next-env.d.ts
$nextEnvContent = @'
/// <reference types="next" />
/// <reference types="next/image-types/global" />

// NOTE: This file should not be edited
'@
Set-Content -Path (Join-Path $frontendPath "next-env.d.ts") -Value $nextEnvContent -Encoding UTF8

# 3.5 postcss.config.cjs
$postcssContent = @'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {}
  }
};
'@
Set-Content -Path (Join-Path $frontendPath "postcss.config.cjs") -Value $postcssContent -Encoding UTF8

# 3.6 tailwind.config.ts
$tailwindConfigContent = @'
import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}"
  ],
  theme: {
    extend: {
      colors: {
        fun: {
          orange: "#ff7a3c",
          green: "#32c48d",
          cream: "#fdf6e9"
        }
      },
      boxShadow: {
        "sas-soft": "0 18px 45px rgba(15,23,42,0.45)"
      }
    }
  },
  plugins: []
};

export default config;
'@
Set-Content -Path (Join-Path $frontendPath "tailwind.config.ts") -Value $tailwindConfigContent -Encoding UTF8

# 3.7 globals.css
$stylesPath = Join-Path $srcPath "app"
New-Item -ItemType Directory -Path $stylesPath -Force | Out-Null

$globalsCssContent = @'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --fun-orange: #ff7a3c;
  --fun-green: #32c48d;
  --fun-cream: #fdf6e9;
}

body {
  @apply bg-slate-950 text-slate-50 antialiased;
}

.fun-gradient-bg {
  background: radial-gradient(circle at top left, rgba(250, 204, 21, 0.24), transparent 55%),
              radial-gradient(circle at bottom right, rgba(56, 189, 248, 0.20), transparent 55%),
              radial-gradient(circle at top right, rgba(251, 113, 133, 0.32), transparent 55%);
}
'@
Set-Content -Path (Join-Path $stylesPath "globals.css") -Value $globalsCssContent -Encoding UTF8

# 3.8 RootLayout (layout.tsx)
$layoutContent = @'
import type { Metadata } from "next";
import "./globals.css";
import Link from "next/link";
import { ReactNode } from "react";

export const metadata: Metadata = {
  title: "FunAging.club — SAS Dashboard",
  description: "Sanook Aging Studio — FunAging Dashboard & Modules"
};

type NavItem = {
  href: string;
  label: string;
};

const NAV_ITEMS: NavItem[] = [
  { href: "/", label: "Dashboard" },
  { href: "/office", label: "SAS Office" },
  { href: "/trip", label: "Trip Planner" },
  { href: "/media", label: "Media Creator" },
  { href: "/insights", label: "Insights" }
];

function NavLink({ href, children }: { href: string; children: ReactNode }) {
  return (
    <Link
      href={href}
      className="flex items-center rounded-xl px-3 py-2 text-sm font-medium text-slate-300 hover:text-white hover:bg-slate-800/80 transition-colors"
    >
      {children}
    </Link>
  );
}

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="th">
      <body className="min-h-screen bg-slate-950 text-slate-50">
        <div className="fun-gradient-bg pointer-events-none fixed inset-0 opacity-60" />
        <div className="relative z-10 flex min-h-screen">
          {/* Sidebar (Desktop) */}
          <aside className="hidden md:flex w-64 flex-col border-r border-slate-800 bg-slate-950/70 backdrop-blur">
            <div className="px-6 pt-5 pb-4 border-b border-slate-800">
              <div className="text-xs font-semibold tracking-[0.2em] text-slate-400 uppercase">
                FunAging
              </div>
              <div className="mt-1 text-xl font-semibold text-white">
                Sanook Aging Studio
              </div>
              <div className="mt-1 text-xs text-slate-400">
                SAS v1 · Dashboard Shell
              </div>
            </div>
            <nav className="flex-1 px-3 py-4 space-y-1">
              {NAV_ITEMS.map((item) => (
                <NavLink key={item.href} href={item.href}>
                  {item.label}
                </NavLink>
              ))}
            </nav>
            <div className="px-4 py-4 border-t border-slate-800 text-xs text-slate-500">
              Ready for V11 · Frontend restored
            </div>
          </aside>

          {/* Main */}
          <main className="flex-1 flex flex-col">
            {/* Top bar (Mobile / shared) */}
            <header className="flex items-center justify-between border-b border-slate-800 bg-slate-950/80 px-4 py-3 md:px-6">
              <div>
                <div className="text-xs font-semibold tracking-[0.2em] text-slate-400 uppercase">
                  FunAging
                </div>
                <div className="text-base font-semibold text-white">
                  SAS Control Panel
                </div>
              </div>
              <div className="flex items-center gap-2 text-xs md:hidden">
                {NAV_ITEMS.map((item) => (
                  <Link
                    key={item.href}
                    href={item.href}
                    className="rounded-lg bg-slate-900/80 px-2 py-1 text-[11px] text-slate-300"
                  >
                    {item.label}
                  </Link>
                ))}
              </div>
            </header>

            {/* Content */}
            <div className="flex-1 px-4 py-5 md:px-8 md:py-8">
              {children}
            </div>
          </main>
        </div>
      </body>
    </html>
  );
}
'@
Set-Content -Path (Join-Path $appPath "layout.tsx") -Value $layoutContent -Encoding UTF8

# 3.9 Dashboard page (page.tsx)
$dashboardPageContent = @'
function StatCard(props: { label: string; value: string; hint?: string }) {
  return (
    <div className="rounded-2xl border border-slate-800 bg-slate-950/70 px-4 py-3 shadow-sas-soft">
      <div className="text-xs font-medium text-slate-400">{props.label}</div>
      <div className="mt-1 text-2xl font-semibold text-white">{props.value}</div>
      {props.hint && (
        <div className="mt-1 text-[11px] text-slate-500">{props.hint}</div>
      )}
    </div>
  );
}

export default function DashboardPage() {
  return (
    <div className="space-y-6">
      <div>
        <div className="inline-flex items-center rounded-full border border-emerald-500/40 bg-emerald-500/10 px-3 py-1 text-[11px] font-medium text-emerald-300">
          FUNAGING·SAS v1 RESTORED
        </div>
        <h1 className="mt-3 text-2xl md:text-3xl font-semibold tracking-tight text-white">
          FunAging Master Dashboard
        </h1>
        <p className="mt-1 max-w-2xl text-sm text-slate-400">
          Frontend shell is restored and ready for V11. Use the left navigation
          to open SAS Office, Trip Planner, Media Creator, and Insights.
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-4">
        <StatCard
          label="System Status"
          value="ONLINE"
          hint="Frontend shell OK — Next.js 14"
        />
        <StatCard
          label="Modules Mounted"
          value="4"
          hint="Office · Trip · Media · Insights"
        />
        <StatCard
          label="Environment"
          value="LOCAL"
          hint="http://localhost:3000"
        />
        <StatCard
          label="Ready for"
          value="V11"
          hint="Safe baseline for next phase"
        />
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <div className="rounded-2xl border border-slate-800 bg-slate-950/80 px-4 py-4 shadow-sas-soft">
          <h2 className="text-sm font-semibold text-white">
            What is restored in this Phase?
          </h2>
          <ul className="mt-2 space-y-1.5 text-xs text-slate-400">
            <li>• Clean Next.js 14 + App Router project</li>
            <li>• Tailwind CSS wired and ready</li>
            <li>• Global SAS layout with navigation</li>
            <li>• Core routes: Dashboard, Office, Trip, Media, Insights</li>
            <li>• Safe baseline that does not touch backend / Supabase</li>
          </ul>
        </div>

        <div className="rounded-2xl border border-slate-800 bg-slate-950/80 px-4 py-4 shadow-sas-soft">
          <h2 className="text-sm font-semibold text-white">
            Next Actions (V11+)
          </h2>
          <ul className="mt-2 space-y-1.5 text-xs text-slate-400">
            <li>• Plug real SAS Office UI into <code>/office</code></li>
            <li>• Plug Trip Planner UI into <code>/trip</code></li>
            <li>• Plug Media Creator UI into <code>/media</code></li>
            <li>• Connect Insights to Sentinel / analytics data</li>
            <li>• Keep backend + Supabase unchanged and stable</li>
          </ul>
        </div>
      </div>
    </div>
  );
}
'@
Set-Content -Path (Join-Path $appPath "page.tsx") -Value $dashboardPageContent -Encoding UTF8

# 3.10 Office page
New-Item -ItemType Directory -Path (Join-Path $appPath "office") -Force | Out-Null
$officePageContent = @'
export default function OfficePage() {
  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-white">
          SAS Office
        </h1>
        <p className="mt-1 text-sm text-slate-400">
          Placeholder shell for SAS Office module. The original UI can be
          plugged back here without touching backend logic.
        </p>
      </div>
      <div className="rounded-2xl border border-slate-800 bg-slate-950/80 px-4 py-4 shadow-sas-soft">
        <h2 className="text-sm font-semibold text-white">
          Office Module Status
        </h2>
        <p className="mt-2 text-xs text-slate-400">
          Frontend route is restored and ready. Connect existing forms, tables,
          and flows for customers, staff, and admin profiles in the next phases.
        </p>
      </div>
    </div>
  );
}
'@
Set-Content -Path (Join-Path $appPath "office/page.tsx") -Value $officePageContent -Encoding UTF8

# 3.11 Trip page
New-Item -ItemType Directory -Path (Join-Path $appPath "trip") -Force | Out-Null
$tripPageContent = @'
export default function TripPage() {
  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-white">
          Trip Planner
        </h1>
        <p className="mt-1 text-sm text-slate-400">
          Placeholder shell for FunAging trip planner. Use this area to mount
          the real travel flows, packages, and itinerary UI.
        </p>
      </div>
      <div className="rounded-2xl border border-slate-800 bg-slate-950/80 px-4 py-4 shadow-sas-soft">
        <h2 className="text-sm font-semibold text-white">
          Upcoming Integration
        </h2>
        <ul className="mt-2 space-y-1.5 text-xs text-slate-400">
          <li>• Connect to trip database and search filters</li>
          <li>• Show saved plans for each customer</li>
          <li>• Integrate with SAS Office profiles & bookings</li>
        </ul>
      </div>
    </div>
  );
}
'@
Set-Content -Path (Join-Path $appPath "trip/page.tsx") -Value $tripPageContent -Encoding UTF8

# 3.12 Media page
New-Item -ItemType Directory -Path (Join-Path $appPath "media") -Force | Out-Null
$mediaPageContent = @'
export default function MediaPage() {
  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-white">
          Media Creator
        </h1>
        <p className="mt-1 text-sm text-slate-400">
          Placeholder shell for FunAging Media OS integration. Mount your
          content queues, generator tools, and publishing pipelines here.
        </p>
      </div>
      <div className="rounded-2xl border border-slate-800 bg-slate-950/80 px-4 py-4 shadow-sas-soft">
        <h2 className="text-sm font-semibold text-white">
          Integration Notes
        </h2>
        <p className="mt-2 text-xs text-slate-400">
          This page is intentionally minimal and safe. It will host the actual
          Media OS UI in later phases without modifying backend or auth.
        </p>
      </div>
    </div>
  );
}
'@
Set-Content -Path (Join-Path $appPath "media/page.tsx") -Value $mediaPageContent -Encoding UTF8

# 3.13 Insights page
New-Item -ItemType Directory -Path (Join-Path $appPath "insights") -Force | Out-Null
$insightsPageContent = @'
export default function InsightsPage() {
  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-white">
          Insights & Sentinel
        </h1>
        <p className="mt-1 text-sm text-slate-400">
          Placeholder shell for AI insights, Sentinel alerts, and metrics.
        </p>
      </div>
      <div className="rounded-2xl border border-slate-800 bg-slate-950/80 px-4 py-4 shadow-sas-soft">
        <h2 className="text-sm font-semibold text-white">
          Data Wiring (Next Phases)
        </h2>
        <ul className="mt-2 space-y-1.5 text-xs text-slate-400">
          <li>• Connect to backend endpoints for stats and alerts</li>
          <li>• Show cards for cost, usage, and health checks</li>
          <li>• Keep this shell stable as a UI baseline</li>
        </ul>
      </div>
    </div>
  );
}
'@
Set-Content -Path (Join-Path $appPath "insights/page.tsx") -Value $insightsPageContent -Encoding UTF8

Write-Ok "New frontend structure generated."

# 4) Install dependencies & start dev server
Write-Section "INSTALL DEPENDENCIES & START DEV SERVER"

Set-Location $frontendPath

Write-Host "→ Running: npm install" -ForegroundColor Magenta
npm install

Write-Host "→ Running: npm run dev (port 3000)" -ForegroundColor Magenta
npm run dev

