import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { ActionBar } from "@/components/ui/action-bar";
import { DataTable } from "@/components/tables/DataTable";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Clock, CreditCard, FileText } from "lucide-react";

export default function EmployeeManagement() {
  const columns = [
    { key: "name", label: "ชื่อพนักงาน" },
    { key: "position", label: "ตำแหน่ง" },
    { key: "shift", label: "กะงาน" },
    { key: "attendance", label: "เวลาเข้างาน" },
    { key: "status", label: "สถานะ" },
  ];

  const employees = [
    {
      name: "สมชาย ใจดี",
      position: "พยาบาล",
      shift: "เช้า (08:00-16:00)",
      attendance: "08:05",
      status: "ทำงาน",
    },
    {
      name: "สมหญิง รักงาน",
      position: "ผู้ช่วยดูแล",
      shift: "บ่าย (14:00-22:00)",
      attendance: "14:00",
      status: "ทำงาน",
    },
    {
      name: "วิชัย มานะ",
      position: "คนขับรถ",
      shift: "เช้า (06:00-14:00)",
      attendance: "05:55",
      status: "ทำงาน",
    },
    {
      name: "สุดา พักผ่อน",
      position: "พยาบาล",
      shift: "เช้า (08:00-16:00)",
      attendance: "-",
      status: "ลา",
    },
  ];

  return (
    <AdminLayout>
      <SectionHeader
        title="🟩 FUN OFFICE - Employee"
        description="จัดการพนักงาน บันทึกเวลา กะงาน และเงินเดือน"
      />

      <div className="grid md:grid-cols-3 gap-4 mb-6">
        <Button variant="outline" className="h-20 flex-col gap-2">
          <Clock className="h-6 w-6" />
          <span>บันทึกเวลาเข้างาน</span>
        </Button>
        <Button variant="outline" className="h-20 flex-col gap-2">
          <CreditCard className="h-6 w-6" />
          <span>ระบบเงินเดือน</span>
        </Button>
        <Button variant="outline" className="h-20 flex-col gap-2">
          <FileText className="h-6 w-6" />
          <span>ประวัติการเบิกจ่าย</span>
        </Button>
      </div>

      <ActionBar
        actions={[
          { type: "add", label: "เพิ่มพนักงาน" },
          { type: "export", label: "Export" },
          { type: "refresh" },
        ]}
        className="mb-6"
      />

      <DataTable columns={columns} data={employees} />
    </AdminLayout>
  );
}
