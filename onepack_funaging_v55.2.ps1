# =====================================================
# ONEPACK v55.2 — FIX /admin/users ROUTE
# =====================================================

$ErrorActionPreference = "Continue"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
Set-Location $scriptDir

Write-Host ""
Write-Host "=== ONEPACK v55.2 — FIX ADMIN ROUTE ===" -ForegroundColor Cyan
Write-Host ""

# -------- PHASE 1: CREATE ADMIN ROUTE STRUCTURE --------
Write-Host "[1/4] CREATE admin/users route" -ForegroundColor Yellow

$frontendDir = Join-Path $scriptDir "frontend"
if (-not (Test-Path $frontendDir)) {
    Write-Host "  ✖ frontend directory not found" -ForegroundColor Red
    exit 1
}

$adminDir = Join-Path $frontendDir "app\admin\users"
if (-not (Test-Path $adminDir)) {
    New-Item -ItemType Directory -Force -Path $adminDir | Out-Null
    Write-Host "  ✔ Created admin/users directory: $adminDir" -ForegroundColor Green
} else {
    Write-Host "  ✓ Admin/users directory already exists" -ForegroundColor Gray
}

# -------- PHASE 2: CREATE AdminUsers COMPONENT --------
Write-Host "[2/4] CREATE AdminUsers UI" -ForegroundColor Yellow

$adminUsersFile = Join-Path $adminDir "AdminUsers.tsx"
if (Test-Path $adminUsersFile) {
    Write-Host "  ⚠ AdminUsers.tsx already exists, backing up..." -ForegroundColor Yellow
    Copy-Item $adminUsersFile "$adminUsersFile.backup" -Force
}

$adminUsersContent = @'
"use client";

import { useEffect, useState } from "react";

type User = {
  id: string;
  email: string;
  role: string;
  created_at?: string;
};

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
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id, role })
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
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
              {users.length === 0 ? (
                <tr>
                  <td colSpan={3} className="px-6 py-4 text-center text-gray-500 dark:text-gray-400">
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

$adminUsersContent | Set-Content -Path $adminUsersFile -Encoding UTF8
Write-Host "  ✔ AdminUsers component created: $adminUsersFile" -ForegroundColor Green
Write-Host ""

# -------- PHASE 3: CREATE page.tsx WITH ROLE GUARD --------
Write-Host "[3/4] CREATE page.tsx (admin only)" -ForegroundColor Yellow

# Check if useRoleGuard hook exists
$hookFile = Join-Path $frontendDir "hooks\useRoleGuard.ts"
if (-not (Test-Path $hookFile)) {
    Write-Host "  ⚠ useRoleGuard hook not found. Run ONEPACK v53 first to create it." -ForegroundColor Yellow
    Write-Host "    Creating a basic page.tsx without role guard..." -ForegroundColor Cyan
}

$pageFile = Join-Path $adminDir "page.tsx"
if (Test-Path $pageFile) {
    Write-Host "  ⚠ page.tsx already exists, backing up..." -ForegroundColor Yellow
    Copy-Item $pageFile "$pageFile.backup" -Force
}

if (Test-Path $hookFile) {
    $pageContent = @'
"use client";

import { useRoleGuard } from "@/hooks/useRoleGuard";
import AdminUsers from "./AdminUsers";

export default function AdminUsersPage() {
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
} else {
    # Fallback without role guard
    $pageContent = @'
"use client";

import AdminUsers from "./AdminUsers";

export default function AdminUsersPage() {
  // NOTE: Role guard not available. Run ONEPACK v53 to enable role protection.
  return <AdminUsers />;
}
'@
    Write-Host "  ⚠ Created page.tsx without role guard (useRoleGuard hook not found)" -ForegroundColor Yellow
}

$pageContent | Set-Content -Path $pageFile -Encoding UTF8
Write-Host "  ✔ Admin page created: $pageFile" -ForegroundColor Green
Write-Host ""

# -------- PHASE 4: RESTART FRONTEND --------
Write-Host "[4/4] RESTART FRONTEND" -ForegroundColor Yellow

Write-Host "  Stopping existing Node processes..." -ForegroundColor Gray
try {
    $nodeProcesses = Get-Process node -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -like "*node.exe*"
    }
    
    if ($nodeProcesses) {
        $processCount = $nodeProcesses.Count
        $nodeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Host "  ✔ Stopped $processCount Node process(es)" -ForegroundColor Green
    } else {
        Write-Host "  ✓ No existing Node processes found" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ⚠ Could not stop processes: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "  Starting frontend dev server..." -ForegroundColor Gray
$frontendCmd = "-NoExit -Command `"cd '$frontendDir'; npm run dev`""
try {
    Start-Process powershell -ArgumentList $frontendCmd -WindowStyle Normal
    Write-Host "  ✔ Frontend dev server started in new window" -ForegroundColor Green
    Write-Host "    Waiting for server to initialize..." -ForegroundColor Gray
    Start-Sleep -Seconds 5
    
    # Quick health check
    $maxRetries = 3
    $retryCount = 0
    while ($retryCount -lt $maxRetries) {
        try {
            $resp = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 3
            if ($resp.StatusCode -eq 200) {
                Write-Host "  ✔ Frontend is responding" -ForegroundColor Green
                break
            }
        } catch {
            $retryCount++
            if ($retryCount -lt $maxRetries) {
                Start-Sleep -Seconds 3
            }
        }
    }
    
    if ($retryCount -eq $maxRetries) {
        Write-Host "  ⚠ Frontend may still be starting (check the PowerShell window)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ✖ Failed to start frontend: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "    Start manually with: cd frontend && npm run dev" -ForegroundColor Cyan
}

Write-Host ""

# -------- SUMMARY --------
Write-Host "=== ONEPACK v55.2 COMPLETE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Admin route fixed:" -ForegroundColor White
Write-Host "  • Route: /admin/users" -ForegroundColor Gray
Write-Host "  • Component: AdminUsers.tsx" -ForegroundColor Gray
Write-Host "  • Page: page.tsx (with role guard)" -ForegroundColor Gray
Write-Host ""
Write-Host "Access:" -ForegroundColor White
Write-Host "  • URL: http://localhost:3000/admin/users" -ForegroundColor Gray
Write-Host "  • Requires: admin role" -ForegroundColor Gray
Write-Host ""
Write-Host "Note: Frontend dev server is running in a separate PowerShell window." -ForegroundColor Yellow
Write-Host "      Close that window to stop the server." -ForegroundColor Yellow
Write-Host ""















