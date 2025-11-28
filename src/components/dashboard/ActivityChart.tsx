import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from "recharts";
import { Activity } from "lucide-react";

export function ActivityChart() {
  const data = [
    { day: "Mon", morning: 45, afternoon: 38, evening: 22 },
    { day: "Tue", morning: 52, afternoon: 42, evening: 28 },
    { day: "Wed", morning: 48, afternoon: 45, evening: 25 },
    { day: "Thu", morning: 55, afternoon: 48, evening: 30 },
    { day: "Fri", morning: 58, afternoon: 52, evening: 35 },
    { day: "Sat", morning: 65, afternoon: 55, evening: 40 },
    { day: "Sun", morning: 42, afternoon: 38, evening: 32 },
  ];

  return (
    <Card className="col-span-full lg:col-span-1">
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-2xl">
          <Activity className="h-6 w-6" />
          Activity Participation
        </CardTitle>
      </CardHeader>
      <CardContent>
        <ResponsiveContainer width="100%" height={300}>
          <BarChart data={data}>
            <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
            <XAxis dataKey="day" className="text-base" />
            <YAxis className="text-base" />
            <Tooltip />
            <Legend />
            <Bar dataKey="morning" fill="hsl(var(--primary))" name="Morning" />
            <Bar dataKey="afternoon" fill="hsl(var(--accent))" name="Afternoon" />
            <Bar dataKey="evening" fill="hsl(var(--muted))" name="Evening" />
          </BarChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}
