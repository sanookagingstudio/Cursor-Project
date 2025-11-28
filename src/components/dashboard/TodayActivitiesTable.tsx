import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Calendar, Users } from "lucide-react";

export function TodayActivitiesTable() {
  const activities = [
    { id: 1, name: "Morning Exercise", time: "08:00 AM", participants: 18, capacity: 20, status: "ongoing" },
    { id: 2, name: "Art & Craft", time: "10:00 AM", participants: 12, capacity: 15, status: "scheduled" },
    { id: 3, name: "Cooking Class", time: "02:00 PM", participants: 8, capacity: 10, status: "scheduled" },
    { id: 4, name: "Music Therapy", time: "03:00 PM", participants: 22, capacity: 30, status: "scheduled" },
    { id: 5, name: "Brain Games", time: "04:30 PM", participants: 15, capacity: 25, status: "scheduled" },
  ];

  return (
    <Card className="col-span-full">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Calendar className="h-5 w-5" />
          Today's Activities
        </CardTitle>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Activity</TableHead>
              <TableHead>Time</TableHead>
              <TableHead>Attendance</TableHead>
              <TableHead>Status</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {activities.map((activity) => (
              <TableRow key={activity.id}>
                <TableCell className="font-medium">{activity.name}</TableCell>
                <TableCell>{activity.time}</TableCell>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <Users className="h-4 w-4 text-muted-foreground" />
                    {activity.participants}/{activity.capacity}
                  </div>
                </TableCell>
                <TableCell>
                  <Badge variant={activity.status === "ongoing" ? "default" : "secondary"}>
                    {activity.status}
                  </Badge>
                </TableCell>
                <TableCell className="text-right">
                  <Button variant="ghost" size="sm">
                    Check In
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}
