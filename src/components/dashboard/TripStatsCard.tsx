import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { MapPin, Calendar, CheckCircle } from "lucide-react";

interface TripStatsCardProps {
  upcomingTrips: number;
  tripsThisMonth: number;
  completedTrips: number;
}

export function TripStatsCard({ upcomingTrips, tripsThisMonth, completedTrips }: TripStatsCardProps) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-lg font-semibold">Trips</CardTitle>
        <MapPin className="h-6 w-6 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div className="text-4xl font-bold">{upcomingTrips}</div>
        <p className="text-base text-muted-foreground mb-3">Upcoming trips</p>
        <div className="flex items-center gap-4 text-base">
          <div className="flex items-center gap-1">
            <Calendar className="h-4 w-4 text-primary" />
            <span>{tripsThisMonth} this month</span>
          </div>
          <div className="flex items-center gap-1">
            <CheckCircle className="h-4 w-4 text-accent" />
            <span>{completedTrips} completed</span>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
