import { useEffect, useState } from "react";
import { Badge } from "@/components/ui/badge";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/contexts/AuthContext";
import { Shield } from "lucide-react";

type AppRole = 'member' | 'staff' | 'admin';

export function UserRolesBadge() {
  const { user } = useAuth();
  const [roles, setRoles] = useState<AppRole[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (user) {
      fetchUserRoles();
    }
  }, [user]);

  const fetchUserRoles = async () => {
    if (!user) return;
    
    const { data } = await supabase
      .from('user_roles')
      .select('role')
      .eq('user_id', user.id);
    
    if (data) {
      setRoles(data.map(r => r.role as AppRole));
    }
    setLoading(false);
  };

  const getRoleColor = (role: AppRole) => {
    switch (role) {
      case 'admin':
        return 'destructive';
      case 'staff':
        return 'default';
      case 'member':
        return 'secondary';
    }
  };

  const getRoleLabel = (role: AppRole) => {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'staff':
        return 'Staff';
      case 'member':
        return 'Member';
    }
  };

  if (loading) {
    return <Badge variant="outline">Loading...</Badge>;
  }

  if (roles.length === 0) {
    return <Badge variant="outline">No Roles</Badge>;
  }

  return (
    <div className="flex items-center gap-2 flex-wrap">
      <Shield className="h-4 w-4 text-muted-foreground" />
      {roles.map((role) => (
        <Badge key={role} variant={getRoleColor(role)}>
          {getRoleLabel(role)}
        </Badge>
      ))}
    </div>
  );
}
