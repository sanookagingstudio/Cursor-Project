import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useToast } from "@/hooks/use-toast";
import { Shield, UserPlus, Trash2, Search } from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";

type AppRole = 'member' | 'staff' | 'admin';

interface UserWithRole {
  id: string;
  email: string;
  full_name: string;
  roles: AppRole[];
}

export default function RoleManagement() {
  const [users, setUsers] = useState<UserWithRole[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedUserId, setSelectedUserId] = useState<string>("");
  const [selectedRole, setSelectedRole] = useState<AppRole>("member");
  const { toast } = useToast();

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    setLoading(true);
    
    // Fetch all profiles
    const { data: profiles, error: profilesError } = await supabase
      .from('profiles')
      .select('id, full_name');

    if (profilesError) {
      toast({
        title: "Error fetching users",
        description: profilesError.message,
        variant: "destructive",
      });
      setLoading(false);
      return;
    }

    // Fetch all user roles
    const { data: userRoles, error: rolesError } = await supabase
      .from('user_roles')
      .select('user_id, role');

    if (rolesError) {
      toast({
        title: "Error fetching roles",
        description: rolesError.message,
        variant: "destructive",
      });
      setLoading(false);
      return;
    }

    // Get user emails from auth (note: admin.listUsers requires service role)
    // For now, we'll work with what we have from profiles
    const { data: authData } = await supabase.auth.getUser();

    // Combine data
    const combinedUsers: UserWithRole[] = profiles.map((profile) => {
      const roles = userRoles?.filter(r => r.user_id === profile.id).map(r => r.role as AppRole) || [];
      
      return {
        id: profile.id,
        email: 'user@example.com', // We'll show this as placeholder for now
        full_name: profile.full_name || 'No name',
        roles,
      };
    });

    setUsers(combinedUsers);
    setLoading(false);
  };

  const addRole = async () => {
    if (!selectedUserId || !selectedRole) {
      toast({
        title: "Missing information",
        description: "Please select a user and role",
        variant: "destructive",
      });
      return;
    }

    const { error } = await supabase
      .from('user_roles')
      .insert({ user_id: selectedUserId, role: selectedRole });

    if (error) {
      if (error.code === '23505') {
        toast({
          title: "Role already exists",
          description: "This user already has this role",
          variant: "destructive",
        });
      } else {
        toast({
          title: "Error adding role",
          description: error.message,
          variant: "destructive",
        });
      }
    } else {
      toast({
        title: "Role added",
        description: `Successfully added ${selectedRole} role`,
      });
      fetchUsers();
    }
  };

  const removeRole = async (userId: string, role: AppRole) => {
    const { error } = await supabase
      .from('user_roles')
      .delete()
      .eq('user_id', userId)
      .eq('role', role);

    if (error) {
      toast({
        title: "Error removing role",
        description: error.message,
        variant: "destructive",
      });
    } else {
      toast({
        title: "Role removed",
        description: `Successfully removed ${role} role`,
      });
      fetchUsers();
    }
  };

  const filteredUsers = users.filter(user => 
    user.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
    user.full_name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const getRoleBadgeVariant = (role: AppRole) => {
    switch (role) {
      case 'admin': return 'destructive';
      case 'staff': return 'default';
      case 'member': return 'secondary';
    }
  };

  return (
    <AdminLayout>
      <SectionHeader
        title="Role Management"
        description="Manage user roles and permissions across the system"
      />

      <div className="grid gap-6">
        {/* Stats Cards */}
        <div className="grid gap-4 md:grid-cols-3">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Total Users</CardTitle>
              <Shield className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{users.length}</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Admins</CardTitle>
              <Shield className="h-4 w-4 text-destructive" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">
                {users.filter(u => u.roles.includes('admin')).length}
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Staff</CardTitle>
              <Shield className="h-4 w-4 text-primary" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">
                {users.filter(u => u.roles.includes('staff')).length}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Add Role Dialog */}
        <Card>
          <CardHeader>
            <CardTitle>Add Role to User</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid gap-4 md:grid-cols-3">
              <div>
                <Label>Select User</Label>
                <Select value={selectedUserId} onValueChange={setSelectedUserId}>
                  <SelectTrigger>
                    <SelectValue placeholder="Choose user" />
                  </SelectTrigger>
                  <SelectContent>
                    {users.filter(u => u.id && u.id !== "").map((user) => (
                      <SelectItem key={user.id} value={user.id}>
                        {user.email} - {user.full_name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label>Select Role</Label>
                <Select value={selectedRole} onValueChange={(val) => setSelectedRole(val as AppRole)}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="member">Member</SelectItem>
                    <SelectItem value="staff">Staff</SelectItem>
                    <SelectItem value="admin">Admin</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div className="flex items-end">
                <Button onClick={addRole} className="w-full">
                  <UserPlus className="mr-2 h-4 w-4" />
                  Add Role
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Users List */}
        <Card>
          <CardHeader>
            <CardTitle>All Users</CardTitle>
            <div className="relative">
              <Search className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search users..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-10"
              />
            </div>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="text-center py-8">Loading users...</div>
            ) : (
              <div className="space-y-4">
                {filteredUsers.map((user) => (
                  <div
                    key={user.id}
                    className="flex items-center justify-between p-4 border rounded-lg hover:bg-accent/50 transition-colors"
                  >
                    <div className="flex-1">
                      <p className="font-medium">{user.full_name}</p>
                      <p className="text-base text-muted-foreground">{user.email}</p>
                    </div>
                    <div className="flex items-center gap-2">
                      {user.roles.length === 0 ? (
                        <Badge variant="outline">No roles</Badge>
                      ) : (
                        user.roles.map((role) => (
                          <div key={role} className="flex items-center gap-1">
                            <Badge variant={getRoleBadgeVariant(role)}>
                              {role}
                            </Badge>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => removeRole(user.id, role)}
                              className="h-6 w-6 p-0"
                            >
                              <Trash2 className="h-3 w-3" />
                            </Button>
                          </div>
                        ))
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </AdminLayout>
  );
}
