import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { ActionBar } from "@/components/ui/action-bar";
import { DataTable } from "@/components/tables/DataTable";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { useTranslation } from "react-i18next";

export default function Staff() {
  const { t } = useTranslation();
  
  const columns = [
    { key: "name", label: t("admin.staff.name") },
    { key: "role", label: t("admin.staff.role") },
    { key: "certification", label: t("admin.staff.certification") },
    { key: "schedule", label: t("admin.staff.schedule") },
    { key: "status", label: t("admin.staff.status") },
  ];

  const data = [
    {
      name: "Sarah Johnson",
      role: "Care Nurse",
      certification: "RN, CPR Certified",
      schedule: "Mon-Fri, 8AM-4PM",
      status: "Active",
    },
    {
      name: "Michael Chen",
      role: "Activity Coordinator",
      certification: "Recreation Therapy",
      schedule: "Mon-Sat, 9AM-5PM",
      status: "Active",
    },
    {
      name: "Lisa Wong",
      role: "Care Assistant",
      certification: "CNA, First Aid",
      schedule: "Tue-Sat, 7AM-3PM",
      status: "Active",
    },
    {
      name: "David Park",
      role: "Driver",
      certification: "Professional License",
      schedule: "Mon-Fri, 6AM-2PM",
      status: "On Leave",
    },
  ];

  return (
    <AdminLayout>
      <SectionHeader
        title={t("admin.staff.title")}
        description={t("admin.staff.description")}
      />

      <ActionBar
        actions={[
          { type: "add", label: t("admin.staff.addStaff") },
          { type: "export", label: t("admin.staff.exportList") },
          { type: "refresh" },
        ]}
        className="mb-6"
      />

      <DataTable columns={columns} data={data} />
    </AdminLayout>
  );
}
