import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Users, UserPlus, TrendingUp } from "lucide-react";
import { Badge } from "@/components/ui/badge";

interface MemberStatsCardProps {
  totalMembers: number;
  newThisMonth: number;
  activeToday: number;
}

export function MemberStatsCard({ totalMembers, newThisMonth, activeToday }: MemberStatsCardProps) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-lg font-semibold">Members</CardTitle>
        <Users className="h-6 w-6 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div className="text-4xl font-bold">{totalMembers.toLocaleString()}</div>
        <div className="flex items-center gap-4 mt-3">
          <div className="flex items-center gap-1">
            <UserPlus className="h-4 w-4 text-accent" />
            <span className="text-base text-muted-foreground">
              +{newThisMonth} this month
            </span>
          </div>
          <Badge variant="secondary" className="flex items-center gap-1 text-base px-3 py-1">
            <TrendingUp className="h-4 w-4" />
            {activeToday} active today
          </Badge>
        </div>
      </CardContent>
    </Card>
  );
}
