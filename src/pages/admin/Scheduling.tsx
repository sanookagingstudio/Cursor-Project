import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { ActionBar } from "@/components/ui/action-bar";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Calendar } from "lucide-react";

export default function Scheduling() {
  const shifts = [
    { day: "Monday", staff: "Sarah, Michael, Lisa", coverage: "Full" },
    { day: "Tuesday", staff: "Michael, Lisa, David", coverage: "Full" },
    { day: "Wednesday", staff: "Sarah, Michael, Lisa", coverage: "Full" },
    { day: "Thursday", staff: "Sarah, Lisa, David", coverage: "Adequate" },
    { day: "Friday", staff: "Sarah, Michael, David", coverage: "Full" },
    { day: "Saturday", staff: "Michael, Lisa", coverage: "Adequate" },
    { day: "Sunday", staff: "On-call only", coverage: "Minimal" },
  ];

  return (
    <AdminLayout>
      <SectionHeader
        title="Scheduling & Shifts"
        description="Manage staff schedules and shift coverage"
      />

      <ActionBar
        actions={[
          { type: "add", label: "Add Shift" },
          { type: "export", label: "Export Schedule" },
          { type: "print", label: "Print Schedule" },
        ]}
        className="mb-6"
      />

      <div className="grid gap-4">
        {shifts.map((shift) => (
          <Card key={shift.day}>
            <CardContent className="flex items-center justify-between p-6">
              <div className="flex items-center gap-4">
                <Calendar className="h-8 w-8 text-primary" />
                <div>
                  <h4 className="font-semibold text-lg">{shift.day}</h4>
                  <p className="text-muted-foreground">{shift.staff}</p>
                </div>
              </div>
              <Badge
                variant={
                  shift.coverage === "Full"
                    ? "default"
                    : shift.coverage === "Adequate"
                    ? "secondary"
                    : "outline"
                }
              >
                {shift.coverage} Coverage
              </Badge>
            </CardContent>
          </Card>
        ))}
      </div>
    </AdminLayout>
  );
}
