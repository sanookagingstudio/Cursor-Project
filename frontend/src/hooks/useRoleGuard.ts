"use client";

import { useEffect, useState } from "react";
import { supabase } from '@/config/supabase';
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


