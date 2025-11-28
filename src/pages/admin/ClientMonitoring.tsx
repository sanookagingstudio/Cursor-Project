import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { ActionBar } from "@/components/ui/action-bar";
import { DataTable } from "@/components/tables/DataTable";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Search } from "lucide-react";

export default function ClientMonitoring() {
  const columns = [
    { key: "name", label: "Client Name" },
    { key: "age", label: "Age" },
    { key: "mobility", label: "Mobility" },
    { key: "health", label: "Health Status" },
    { key: "lastVisit", label: "Last Visit" },
    { key: "riskLevel", label: "Risk Level" },
  ];

  const clients = [
    {
      name: "John Doe",
      age: "68",
      mobility: "Independent",
      health: "Stable",
      lastVisit: "2024-03-15",
      riskLevel: "Low",
    },
    {
      name: "Jane Smith",
      age: "72",
      mobility: "Walker",
      health: "Monitoring",
      lastVisit: "2024-03-14",
      riskLevel: "Medium",
    },
    {
      name: "Bob Wilson",
      age: "65",
      mobility: "Independent",
      health: "Excellent",
      lastVisit: "2024-03-16",
      riskLevel: "Low",
    },
    {
      name: "Alice Brown",
      age: "75",
      mobility: "Wheelchair",
      health: "Under Care",
      lastVisit: "2024-03-10",
      riskLevel: "High",
    },
  ];

  return (
    <AdminLayout>
      <SectionHeader
        title="Client Monitoring"
        description="Track client health, activities, and wellbeing"
      />

      <ActionBar
        actions={[
          { type: "add", label: "Add Client" },
          { type: "export", label: "Export List" },
          { type: "refresh" },
        ]}
        className="mb-6"
      />

      <div className="mb-6">
        <div className="relative max-w-md">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-5 w-5" />
          <Input placeholder="Search clients..." className="pl-10 text-lg" />
        </div>
      </div>

      <DataTable columns={columns} data={clients} />
    </AdminLayout>
  );
}
