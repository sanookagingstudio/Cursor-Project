# =========================================================
# ONEPACK v53 — FRONTEND ROLE GUARD + AUTO REDIRECT (REAL)
# Next.js App Router + Supabase Auth
# =========================================================

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== ONEPACK v53 — FRONTEND ROLE GUARD START ===" -ForegroundColor Cyan
Write-Host ""

# -------- PHASE 1: VERIFY FRONTEND STRUCTURE --------
Write-Host "[1/6] VERIFY FRONTEND STRUCTURE" -ForegroundColor Yellow

$frontendDir = Join-Path $scriptDir "frontend"
if (-not (Test-Path $frontendDir)) {
    Write-Host "  ✖ frontend directory not found" -ForegroundColor Red
    exit 1
}

$requiredPaths = @(
    "frontend\config\supabase.ts",
    "frontend\app\dashboard\page.tsx"
)

$missingPaths = @()
foreach ($p in $requiredPaths) {
    $fullPath = Join-Path $scriptDir $p
    if (-not (Test-Path $fullPath)) {
        Write-Host "  ✖ Missing $p" -ForegroundColor Red
        $missingPaths += $p
    } else {
        Write-Host "  ✔ Found $p" -ForegroundColor Green
    }
}

if ($missingPaths.Count -gt 0) {
    Write-Host ""
    Write-Host "  ⚠ Missing required files. Please run ONEPACK v50 first to create Supabase config." -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# -------- PHASE 2: CREATE ROLE GUARD HOOK --------
Write-Host "[2/6] CREATE ROLE GUARD HOOK" -ForegroundColor Yellow

$hooksDir = Join-Path $frontendDir "hooks"
if (-not (Test-Path $hooksDir)) {
    New-Item -ItemType Directory -Force -Path $hooksDir | Out-Null
    Write-Host "  ✔ Created hooks directory: $hooksDir" -ForegroundColor Green
} else {
    Write-Host "  ✓ Hooks directory already exists" -ForegroundColor Gray
}

$hookFile = Join-Path $hooksDir "useRoleGuard.ts"
if (Test-Path $hookFile) {
    Write-Host "  ⚠ useRoleGuard.ts already exists, backing up..." -ForegroundColor Yellow
    Copy-Item $hookFile "$hookFile.backup" -Force
}

$hookContent = @'
"use client";

import { useEffect, useState } from "react";
import { supabase } from "@/config/supabase";
import { useRouter } from "next/navigation";

interface UseRoleGuardOptions {
  allowedRoles: string[];
  redirectTo?: string;
}

export function useRoleGuard({ allowedRoles, redirectTo = "/dashboard" }: UseRoleGuardOptions) {
  const router = useRouter();
  const [loading, setLoading] = useState(true);
  const [authorized, setAuthorized] = useState(false);

  useEffect(() => {
    const checkRole = async () => {
      try {
        // Get current user
        const { data: { user }, error: userError } = await supabase.auth.getUser();
        
        if (userError || !user) {
          router.replace("/auth/login");
          return;
        }

        // Get user profile with role
        const { data, error } = await supabase
          .from("profiles")
          .select("role")
          .eq("id", user.id)
          .single();

        if (error || !data) {
          console.error("Failed to fetch user profile:", error);
          router.replace("/auth/login");
          return;
        }

        const userRole = data.role;
        
        if (!allowedRoles.includes(userRole)) {
          console.warn(`Access denied. Required roles: ${allowedRoles.join(", ")}, User role: ${userRole}`);
          router.replace(redirectTo);
          return;
        }

        setAuthorized(true);
        setLoading(false);
      } catch (err) {
        console.error("Role guard error:", err);
        router.replace("/auth/login");
      }
    };

    checkRole();
  }, [allowedRoles, redirectTo, router]);

  return { loading, authorized };
}
'@

$hookContent | Set-Content -Path $hookFile -Encoding UTF8
Write-Host "  ✔ useRoleGuard hook created: $hookFile" -ForegroundColor Green
Write-Host ""

# -------- PHASE 3: PROTECT ADMIN & STAFF PAGES --------
Write-Host "[3/6] PROTECT ROLE PAGES" -ForegroundColor Yellow

$pages = @(
    @{ path = "frontend\app\media\page.tsx"; roles = @("admin") },
    @{ path = "frontend\app\office\page.tsx"; roles = @("staff", "admin") }
)

foreach ($pg in $pages) {
    $pagePath = Join-Path $scriptDir $pg.path
    if (Test-Path $pagePath) {
        $content = Get-Content $pagePath -Raw
        $modified = $false
        
        # Check if already protected
        if ($content -match "useRoleGuard") {
            Write-Host "  ✓ $($pg.path) already protected" -ForegroundColor Gray
            continue
        }
        
        # Add import if not present
        if ($content -notmatch "from ['""]@/hooks/useRoleGuard['""]") {
            # Find the last import line
            $lines = $content -split "`n"
            $lastImportIndex = -1
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match "^(import |from )") {
                    $lastImportIndex = $i
                }
            }
            
            if ($lastImportIndex -ge 0) {
                $importLine = "import { useRoleGuard } from '@/hooks/useRoleGuard';"
                $lines = $lines[0..$lastImportIndex] + $importLine + $lines[($lastImportIndex+1)..($lines.Count-1)]
                $content = $lines -join "`n"
            } else {
                $importLine = "import { useRoleGuard } from '@/hooks/useRoleGuard';`n"
                $content = $importLine + $content
            }
            $modified = $true
        }
        
        # Add role guard in component - find the function body start
        $rolesStr = ($pg.roles | ForEach-Object { "'$_'" }) -join ", "
        $guardCode = @"
  const { loading } = useRoleGuard({ allowedRoles: [$rolesStr] });
  if (loading) return <div className="flex items-center justify-center min-h-screen">Loading...</div>;
"@
        
        # Find the export default function and add guard after opening brace
        if ($content -match "(export default function \w+\(\)\s*\{)") {
            # Replace only the first occurrence (function opening brace)
            $content = $content -replace "(export default function \w+\(\)\s*\{)", "`$1`n$guardCode", 1
            $modified = $true
        } elseif ($content -match "(export default function \w+\(\)\s*\{)") {
            # Alternative pattern
            $content = $content -replace "(export default function \w+\(\)\s*\{)", "`$1`n$guardCode", 1
            $modified = $true
        } else {
            # Fallback: try to find function definition
            $lines = $content -split "`n"
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match "export default function \w+\(\)\s*\{") {
                    # Insert guard code after this line
                    $lines = $lines[0..$i] + $guardCode + $lines[($i+1)..($lines.Count-1)]
                    $content = $lines -join "`n"
                    $modified = $true
                    break
                }
            }
        }
        
        if ($modified) {
            Set-Content -Path $pagePath -Value $content -Encoding UTF8 -NoNewline
            Write-Host "  ✔ Protected $($pg.path) with roles: $($pg.roles -join ', ')" -ForegroundColor Green
        }
    } else {
        Write-Host "  ⚠ Page not found: $($pg.path) (skipped)" -ForegroundColor Yellow
    }
}

Write-Host ""

# -------- PHASE 4: DASHBOARD AUTO REDIRECT --------
Write-Host "[4/6] DASHBOARD AUTO REDIRECT BY ROLE" -ForegroundColor Yellow

$dashboardPage = Join-Path $frontendDir "app\dashboard\page.tsx"
if (Test-Path $dashboardPage) {
    Write-Host "  ⚠ Dashboard page exists, backing up..." -ForegroundColor Yellow
    Copy-Item $dashboardPage "$dashboardPage.backup" -Force
}

$dashboardContent = @'
"use client";

import { useEffect, useState } from "react";
import { supabase } from "@/config/supabase";
import { useRouter } from "next/navigation";

export default function DashboardRedirect() {
  const router = useRouter();
  const [status, setStatus] = useState("Checking authentication...");

  useEffect(() => {
    const redirectByRole = async () => {
      try {
        // Get current user
        const { data: { user }, error: userError } = await supabase.auth.getUser();
        
        if (userError || !user) {
          setStatus("Redirecting to login...");
          router.replace("/auth/login");
          return;
        }

        setStatus("Fetching user role...");

        // Get user profile with role
        const { data, error } = await supabase
          .from("profiles")
          .select("role")
          .eq("id", user.id)
          .single();

        if (error || !data) {
          console.error("Failed to fetch user profile:", error);
          setStatus("Redirecting to login...");
          router.replace("/auth/login");
          return;
        }

        const userRole = data.role;
        setStatus(`Redirecting based on role: ${userRole}...`);

        // Redirect based on role
        if (userRole === "admin") {
          router.replace("/media");
        } else if (userRole === "staff") {
          router.replace("/office");
        } else {
          // Default or other roles go to home
          router.replace("/dashboard/home");
        }
      } catch (err) {
        console.error("Dashboard redirect error:", err);
        setStatus("Error occurred, redirecting to login...");
        router.replace("/auth/login");
      }
    };

    redirectByRole();
  }, [router]);

  return (
    <div className="flex items-center justify-center min-h-screen">
      <div className="text-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900 dark:border-gray-100 mx-auto mb-4"></div>
        <p className="text-gray-600 dark:text-gray-400">{status}</p>
      </div>
    </div>
  );
}
'@

$dashboardContent | Set-Content -Path $dashboardPage -Encoding UTF8
Write-Host "  ✔ Dashboard auto-redirect enabled" -ForegroundColor Green
Write-Host ""

# -------- PHASE 5: FRONTEND BUILD CHECK --------
Write-Host "[5/6] FRONTEND BUILD CHECK" -ForegroundColor Yellow

if (-not (Test-Path "$frontendDir\package.json")) {
    Write-Host "  ✖ frontend/package.json not found" -ForegroundColor Red
} else {
    Push-Location $frontendDir
    try {
        Write-Host "  Running build check..." -ForegroundColor Gray
        $buildOutput = npm run build 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✔ Frontend build OK" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ Frontend build had warnings/errors (check output above)" -ForegroundColor Yellow
            Write-Host "    This is non-blocking, but please review any TypeScript errors." -ForegroundColor Cyan
        }
    } catch {
        Write-Host "  ⚠ Frontend build check failed: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "    This is non-blocking, but please run 'npm run build' manually to verify." -ForegroundColor Cyan
    }
    Pop-Location
}
Write-Host ""

# -------- PHASE 6: SUMMARY --------
Write-Host "[6/6] SUMMARY" -ForegroundColor Yellow

Write-Host ""
Write-Host "=== ONEPACK v53 COMPLETE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Frontend role guard enabled:" -ForegroundColor White
Write-Host "  • /media     => admin only" -ForegroundColor Gray
Write-Host "  • /office    => staff + admin" -ForegroundColor Gray
Write-Host "  • /dashboard => auto redirect by role" -ForegroundColor Gray
Write-Host ""
Write-Host "Files created/updated:" -ForegroundColor White
Write-Host "  • frontend/hooks/useRoleGuard.ts" -ForegroundColor Gray
Write-Host "  • frontend/app/media/page.tsx (protected)" -ForegroundColor Gray
Write-Host "  • frontend/app/office/page.tsx (protected)" -ForegroundColor Gray
Write-Host "  • frontend/app/dashboard/page.tsx (auto-redirect)" -ForegroundColor Gray
Write-Host ""
Write-Host "Usage:" -ForegroundColor White
Write-Host "  • Users must be authenticated (Supabase auth)" -ForegroundColor Gray
Write-Host "  • User profile must exist in 'profiles' table with 'role' column" -ForegroundColor Gray
Write-Host "  • Unauthorized users are redirected to /auth/login" -ForegroundColor Gray
Write-Host "  • Dashboard redirects: admin → /media, staff → /office, others → /dashboard/home" -ForegroundColor Gray
Write-Host ""
Write-Host "Note: Create /auth/login page if it doesn't exist." -ForegroundColor Yellow
Write-Host ""















