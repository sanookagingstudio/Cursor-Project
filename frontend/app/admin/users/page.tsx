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
