import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { FilterBar } from "@/components/ui/filter-bar";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Users, UserPlus, Search, Eye, Edit, Mail, Phone, Calendar } from "lucide-react";

export default function CustomerManagement() {
  const customers = [
    { 
      id: 1, 
      name: "Mrs. Sompong Chai", 
      memberID: "FUN001234", 
      plan: "Monthly", 
      status: "active", 
      joinDate: "Jan 2024",
      phone: "08X-XXX-1234",
      email: "sompong@email.com",
      lastActivity: "Today"
    },
    { 
      id: 2, 
      name: "Mr. Niran Wong", 
      memberID: "FUN001235", 
      plan: "Per-Trip", 
      status: "active", 
      joinDate: "Feb 2024",
      phone: "08X-XXX-5678",
      email: "niran@email.com",
      lastActivity: "2 days ago"
    },
    { 
      id: 3, 
      name: "Mrs. Amara Lee", 
      memberID: "FUN001236", 
      plan: "Monthly", 
      status: "inactive", 
      joinDate: "Dec 2023",
      phone: "08X-XXX-9012",
      email: "amara@email.com",
      lastActivity: "1 week ago"
    },
    { 
      id: 4, 
      name: "Mr. Somchai Rit", 
      memberID: "FUN001237", 
      plan: "Walk-In", 
      status: "active", 
      joinDate: "Mar 2024",
      phone: "08X-XXX-3456",
      email: "somchai@email.com",
      lastActivity: "Yesterday"
    },
    { 
      id: 5, 
      name: "Mrs. Noi Tan", 
      memberID: "FUN001238", 
      plan: "Monthly", 
      status: "active", 
      joinDate: "Jan 2024",
      phone: "08X-XXX-7890",
      email: "noi@email.com",
      lastActivity: "Today"
    },
  ];

  const stats = [
    { label: "Total Customers", value: "248", trend: "+18 this month" },
    { label: "Active Members", value: "232", trend: "93.5% retention" },
    { label: "New This Month", value: "18", trend: "+12.5% growth" },
    { label: "Monthly Plans", value: "165", trend: "66.5% conversion" },
  ];

  return (
    <AdminLayout>
      <div className="space-y-6">
        <SectionHeader
          title="Customer Management"
          description="Manage members, track engagement, and maintain relationships"
        />

        {/* Stats Overview */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {stats.map((stat) => (
            <Card key={stat.label}>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">{stat.label}</CardTitle>
                <Users className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stat.value}</div>
                <p className="text-xs text-muted-foreground">{stat.trend}</p>
              </CardContent>
            </Card>
          ))}
        </div>

        {/* Search and Filters */}
        <Card>
          <CardContent className="pt-6">
            <FilterBar searchPlaceholder="Search by name, ID, or email...">
              <Select>
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="Plan Type" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Plans</SelectItem>
                  <SelectItem value="monthly">Monthly</SelectItem>
                  <SelectItem value="per-trip">Per-Trip</SelectItem>
                  <SelectItem value="walk-in">Walk-In</SelectItem>
                </SelectContent>
              </Select>
              <Select>
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="Status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Status</SelectItem>
                  <SelectItem value="active">Active</SelectItem>
                  <SelectItem value="inactive">Inactive</SelectItem>
                </SelectContent>
              </Select>
              <Button>
                <UserPlus className="h-4 w-4 mr-2" />
                Add New Member
              </Button>
            </FilterBar>
          </CardContent>
        </Card>

        {/* Customer Table */}
        <Card>
          <CardHeader>
            <CardTitle>All Members</CardTitle>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Member</TableHead>
                  <TableHead>Member ID</TableHead>
                  <TableHead>Contact</TableHead>
                  <TableHead>Plan</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Join Date</TableHead>
                  <TableHead>Last Activity</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {customers.map((customer) => (
                  <TableRow key={customer.id}>
                    <TableCell className="font-medium">{customer.name}</TableCell>
                    <TableCell>
                      <Badge variant="outline">{customer.memberID}</Badge>
                    </TableCell>
                    <TableCell>
                      <div className="flex flex-col gap-1 text-xs">
                        <div className="flex items-center gap-1">
                          <Phone className="h-3 w-3" />
                          {customer.phone}
                        </div>
                        <div className="flex items-center gap-1">
                          <Mail className="h-3 w-3" />
                          {customer.email}
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant="secondary">{customer.plan}</Badge>
                    </TableCell>
                    <TableCell>
                      <Badge variant={customer.status === "active" ? "default" : "destructive"}>
                        {customer.status}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-1 text-sm">
                        <Calendar className="h-3 w-3" />
                        {customer.joinDate}
                      </div>
                    </TableCell>
                    <TableCell className="text-sm text-muted-foreground">
                      {customer.lastActivity}
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="flex justify-end gap-2">
                        <Button variant="ghost" size="sm">
                          <Eye className="h-4 w-4" />
                        </Button>
                        <Button variant="ghost" size="sm">
                          <Edit className="h-4 w-4" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>
    </AdminLayout>
  );
}
