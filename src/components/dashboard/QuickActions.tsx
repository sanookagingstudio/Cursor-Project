import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Plus, UserPlus, MapPin, Calendar, FileText, Users } from "lucide-react";

export function QuickActions() {
  const actions = [
    { icon: UserPlus, label: "Add Member", color: "text-primary" },
    { icon: MapPin, label: "Create Trip", color: "text-accent" },
    { icon: Calendar, label: "Schedule Activity", color: "text-blue-500" },
    { icon: FileText, label: "Generate Report", color: "text-purple-500" },
    { icon: Users, label: "Staff Schedule", color: "text-orange-500" },
  ];

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Plus className="h-5 w-5" />
          Quick Actions
        </CardTitle>
      </CardHeader>
      <CardContent className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-3">
        {actions.map((action) => (
          <Button
            key={action.label}
            variant="outline"
            className="h-auto flex-col gap-2 py-4"
          >
            <action.icon className={`h-6 w-6 ${action.color}`} />
            <span className="text-xs">{action.label}</span>
          </Button>
        ))}
      </CardContent>
    </Card>
  );
}
