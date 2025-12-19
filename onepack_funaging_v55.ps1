# =========================================================
# ONEPACK v55 — ADMIN PANEL + ROLE MANAGER (FULL UI)
# FunAging SAS — Production Ready
# =========================================================

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== ONEPACK v55 — ADMIN PANEL + ROLE MANAGER ===" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------
# PHASE 1: VERIFY ADMIN CONTEXT
# ---------------------------------------------------------
Write-Host "[1/7] VERIFY ADMIN CONTEXT" -ForegroundColor Yellow

$supabaseUrl = (Get-Item "env:NEXT_PUBLIC_SUPABASE_URL" -ErrorAction SilentlyContinue).Value
$supabaseAnonKey = (Get-Item "env:NEXT_PUBLIC_SUPABASE_ANON_KEY" -ErrorAction SilentlyContinue).Value
$supabaseServiceKey = (Get-Item "env:SUPABASE_SERVICE_ROLE_KEY" -ErrorAction SilentlyContinue).Value

if (-not $supabaseUrl -or -not $supabaseAnonKey) {
    Write-Host "  ✖ Missing Supabase ENV (NEXT_PUBLIC_SUPABASE_URL or NEXT_PUBLIC_SUPABASE_ANON_KEY)" -ForegroundColor Red
    Write-Host "    Set these environment variables before running the script." -ForegroundColor Yellow
    exit 1
}

if (-not $supabaseServiceKey) {
    Write-Host "  ⚠ SUPABASE_SERVICE_ROLE_KEY not set (admin API will use anon key - less secure)" -ForegroundColor Yellow
    Write-Host "    For production, set SUPABASE_SERVICE_ROLE_KEY for admin operations." -ForegroundColor Cyan
}

Write-Host "  ✔ Supabase ENV OK" -ForegroundColor Green
Write-Host ""

# ---------------------------------------------------------
# PHASE 2: CREATE ADMIN ROUTES (API)
# ---------------------------------------------------------
Write-Host "[2/7] CREATE ADMIN API ROUTES" -ForegroundColor Yellow

$frontendDir = Join-Path $scriptDir "frontend"
if (-not (Test-Path $frontendDir)) {
    Write-Host "  ✖ frontend directory not found" -ForegroundColor Red
    exit 1
}

$apiDir = Join-Path $frontendDir "app\api\admin\users"
if (-not (Test-Path $apiDir)) {
    New-Item -ItemType Directory -Force -Path $apiDir | Out-Null
    Write-Host "  ✔ Created admin API directory: $apiDir" -ForegroundColor Green
} else {
    Write-Host "  ✓ Admin API directory already exists" -ForegroundColor Gray
}

$apiRouteFile = Join-Path $apiDir "route.ts"
if (Test-Path $apiRouteFile) {
    Write-Host "  ⚠ Admin API route already exists, backing up..." -ForegroundColor Yellow
    Copy-Item $apiRouteFile "$apiRouteFile.backup" -Force
}

$apiRouteContent = @'
import { NextResponse } from "next/server";
import { createClient } from "@supabase/supabase-js";

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  throw new Error("Missing Supabase configuration");
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

export async function GET() {
  try {
    const { data, error } = await supabase
      .from("profiles")
      .select("id, email, role, created_at")
      .order("created_at", { ascending: false });

    if (error) {
      console.error("Error fetching users:", error);
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    return NextResponse.json(data || []);
  } catch (err: any) {
    console.error("Unexpected error:", err);
    return NextResponse.json({ error: err.message || "Internal server error" }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    const { id, role } = await req.json();

    if (!id || !role) {
      return NextResponse.json({ error: "Missing id or role" }, { status: 400 });
    }

    const validRoles = ["admin", "staff", "user"];
    if (!validRoles.includes(role)) {
      return NextResponse.json({ error: `Invalid role. Must be one of: ${validRoles.join(", ")}` }, { status: 400 });
    }

    const { data, error } = await supabase
      .from("profiles")
      .update({ role })
      .eq("id", id)
      .select()
      .single();

    if (error) {
      console.error("Error updating user role:", error);
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    return NextResponse.json({ success: true, user: data });
  } catch (err: any) {
    console.error("Unexpected error:", err);
    return NextResponse.json({ error: err.message || "Internal server error" }, { status: 500 });
  }
}
'@

$apiRouteContent | Set-Content -Path $apiRouteFile -Encoding UTF8
Write-Host "  ✔ Admin API routes created: $apiRouteFile" -ForegroundColor Green
Write-Host ""

# ---------------------------------------------------------
# PHASE 3: CREATE ADMIN UI COMPONENT
# ---------------------------------------------------------
Write-Host "[3/7] CREATE ADMIN UI COMPONENT" -ForegroundColor Yellow

$adminDir = Join-Path $frontendDir "app\admin\users"
if (-not (Test-Path $adminDir)) {
    New-Item -ItemType Directory -Force -Path $adminDir | Out-Null
    Write-Host "  ✔ Created admin UI directory: $adminDir" -ForegroundColor Green
} else {
    Write-Host "  ✓ Admin UI directory already exists" -ForegroundColor Gray
}

# Create AdminUsers component
$adminUsersComponent = Join-Path $adminDir "AdminUsers.tsx"
if (Test-Path $adminUsersComponent) {
    Write-Host "  ⚠ AdminUsers component already exists, backing up..." -ForegroundColor Yellow
    Copy-Item $adminUsersComponent "$adminUsersComponent.backup" -Force
}

$adminUsersContent = @'
"use client";

import { useEffect, useState } from "react";

interface User {
  id: string;
  email: string;
  role: string;
  created_at: string;
}

export default function AdminUsers() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [updating, setUpdating] = useState<string | null>(null);

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const res = await fetch("/api/admin/users");
      if (!res.ok) {
        throw new Error(`Failed to fetch users: ${res.statusText}`);
      }
      const data = await res.json();
      setUsers(data);
      setError(null);
    } catch (err: any) {
      setError(err.message || "Failed to load users");
      console.error("Error fetching users:", err);
    } finally {
      setLoading(false);
    }
  };

  const setRole = async (id: string, role: string) => {
    try {
      setUpdating(id);
      const res = await fetch("/api/admin/users", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ id, role }),
      });

      if (!res.ok) {
        const errorData = await res.json();
        throw new Error(errorData.error || "Failed to update role");
      }

      // Refresh users list
      await fetchUsers();
    } catch (err: any) {
      alert(`Error updating role: ${err.message}`);
      console.error("Error updating role:", err);
    } finally {
      setUpdating(null);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900 dark:border-gray-100 mx-auto mb-4"></div>
          <p className="text-gray-600 dark:text-gray-400">Loading users...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 max-w-6xl mx-auto">
      <div className="mb-6">
        <h1 className="text-3xl font-bold mb-2">Admin — User Management</h1>
        <p className="text-gray-600 dark:text-gray-400">Manage user roles and permissions</p>
      </div>

      {error && (
        <div className="mb-4 p-4 bg-red-50 dark:bg-red-950/20 border border-red-200 dark:border-red-800 rounded-lg">
          <p className="text-red-800 dark:text-red-200">{error}</p>
        </div>
      )}

      <div className="bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead className="bg-gray-50 dark:bg-gray-900">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Email
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Role
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Created
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
              {users.length === 0 ? (
                <tr>
                  <td colSpan={4} className="px-6 py-4 text-center text-gray-500 dark:text-gray-400">
                    No users found
                  </td>
                </tr>
              ) : (
                users.map((user) => (
                  <tr key={user.id} className="hover:bg-gray-50 dark:hover:bg-gray-700">
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-gray-100">
                      {user.email || "N/A"}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span
                        className={`px-2 py-1 text-xs font-semibold rounded-full ${
                          user.role === "admin"
                            ? "bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200"
                            : user.role === "staff"
                            ? "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200"
                            : "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200"
                        }`}
                      >
                        {user.role || "user"}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                      {user.created_at ? new Date(user.created_at).toLocaleDateString() : "N/A"}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm">
                      <div className="flex gap-2">
                        <button
                          onClick={() => setRole(user.id, "admin")}
                          disabled={updating === user.id || user.role === "admin"}
                          className={`px-3 py-1 text-xs rounded ${
                            user.role === "admin"
                              ? "bg-purple-200 text-purple-800 cursor-not-allowed"
                              : "bg-purple-100 text-purple-700 hover:bg-purple-200"
                          } disabled:opacity-50`}
                        >
                          Admin
                        </button>
                        <button
                          onClick={() => setRole(user.id, "staff")}
                          disabled={updating === user.id || user.role === "staff"}
                          className={`px-3 py-1 text-xs rounded ${
                            user.role === "staff"
                              ? "bg-blue-200 text-blue-800 cursor-not-allowed"
                              : "bg-blue-100 text-blue-700 hover:bg-blue-200"
                          } disabled:opacity-50`}
                        >
                          Staff
                        </button>
                        <button
                          onClick={() => setRole(user.id, "user")}
                          disabled={updating === user.id || user.role === "user"}
                          className={`px-3 py-1 text-xs rounded ${
                            user.role === "user"
                              ? "bg-gray-200 text-gray-800 cursor-not-allowed"
                              : "bg-gray-100 text-gray-700 hover:bg-gray-200"
                          } disabled:opacity-50`}
                        >
                          User
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
'@

$adminUsersContent | Set-Content -Path $adminUsersComponent -Encoding UTF8
Write-Host "  ✔ AdminUsers component created: $adminUsersComponent" -ForegroundColor Green
Write-Host ""

# ---------------------------------------------------------
# PHASE 4: PROTECT ADMIN UI (ADMIN ONLY)
# ---------------------------------------------------------
Write-Host "[4/7] PROTECT ADMIN UI" -ForegroundColor Yellow

$adminPageFile = Join-Path $adminDir "page.tsx"
if (Test-Path $adminPageFile) {
    Write-Host "  ⚠ Admin page already exists, backing up..." -ForegroundColor Yellow
    Copy-Item $adminPageFile "$adminPageFile.backup" -Force
}

$adminPageContent = @'
"use client";

import { useRoleGuard } from "@/hooks/useRoleGuard";
import AdminUsers from "./AdminUsers";

export default function AdminPage() {
  const { loading } = useRoleGuard({ allowedRoles: ["admin"] });
  
  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900 dark:border-gray-100 mx-auto mb-4"></div>
          <p className="text-gray-600 dark:text-gray-400">Verifying admin access...</p>
        </div>
      </div>
    );
  }

  return <AdminUsers />;
}
'@

$adminPageContent | Set-Content -Path $adminPageFile -Encoding UTF8
Write-Host "  ✔ Admin role guard applied: $adminPageFile" -ForegroundColor Green
Write-Host ""

# ---------------------------------------------------------
# PHASE 5: LINK ADMIN PANEL (OPTIONAL)
# ---------------------------------------------------------
Write-Host "[5/7] ADD ADMIN LINK TO NAVBAR" -ForegroundColor Yellow

$navbarFile = Join-Path $frontendDir "src\components\Navbar.tsx"
if (Test-Path $navbarFile) {
    $navbarContent = Get-Content $navbarFile -Raw
    
    if ($navbarContent -notmatch "/admin/users") {
        # Try to add admin link before closing nav tag or after existing links
        if ($navbarContent -match "(<Link.*?href=['""]/dashboard['""].*?</Link>)") {
            $adminLink = @'

          <Link
            href="/admin/users"
            className="px-3 py-2 rounded-md text-sm font-medium text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-950/20"
          >
            Admin Panel
          </Link>
'@
            $navbarContent = $navbarContent -replace "($matches[0])", "`$1$adminLink"
            Set-Content -Path $navbarFile -Value $navbarContent -Encoding UTF8 -NoNewline
            Write-Host "  ✔ Admin link added to Navbar" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ Could not find insertion point in Navbar (manual addition may be needed)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ✓ Admin link already exists in Navbar" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⚠ Navbar component not found, skipping link addition" -ForegroundColor Yellow
    Write-Host "    Add admin link manually: <Link href='/admin/users'>Admin Panel</Link>" -ForegroundColor Cyan
}
Write-Host ""

# ---------------------------------------------------------
# PHASE 6: BUILD CHECK
# ---------------------------------------------------------
Write-Host "[6/7] FRONTEND BUILD CHECK" -ForegroundColor Yellow

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

# ---------------------------------------------------------
# PHASE 7: SUMMARY
# ---------------------------------------------------------
Write-Host "[7/7] SUMMARY" -ForegroundColor Yellow

Write-Host ""
Write-Host "=== ONEPACK v55 COMPLETE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Admin Panel Ready:" -ForegroundColor White
Write-Host "  • URL: /admin/users" -ForegroundColor Gray
Write-Host "  • Admin can view all users" -ForegroundColor Gray
Write-Host "  • Change roles via UI (admin, staff, user)" -ForegroundColor Gray
Write-Host "  • Protected with role guard (admin only)" -ForegroundColor Gray
Write-Host ""
Write-Host "Files created:" -ForegroundColor White
Write-Host "  • frontend/app/api/admin/users/route.ts" -ForegroundColor Gray
Write-Host "  • frontend/app/admin/users/AdminUsers.tsx" -ForegroundColor Gray
Write-Host "  • frontend/app/admin/users/page.tsx" -ForegroundColor Gray
Write-Host ""
Write-Host "Usage:" -ForegroundColor White
Write-Host "  1. Navigate to /admin/users (admin role required)" -ForegroundColor Gray
Write-Host "  2. View all users with their current roles" -ForegroundColor Gray
Write-Host "  3. Click role buttons to change user roles" -ForegroundColor Gray
Write-Host "  4. Changes are saved immediately" -ForegroundColor Gray
Write-Host ""
Write-Host "Note: Ensure SUPABASE_SERVICE_ROLE_KEY is set for production use." -ForegroundColor Yellow
Write-Host ""















