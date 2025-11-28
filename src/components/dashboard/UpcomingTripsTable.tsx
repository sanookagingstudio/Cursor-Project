import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { MapPin, Eye } from "lucide-react";

export function UpcomingTripsTable() {
  const trips = [
    { id: 1, destination: "Ayutthaya Heritage", date: "Mar 15, 2025", participants: 24, status: "confirmed" },
    { id: 2, destination: "Floating Market", date: "Mar 22, 2025", participants: 18, status: "confirmed" },
    { id: 3, destination: "Mountain Retreat", date: "Apr 5, 2025", participants: 32, status: "pending" },
    { id: 4, destination: "Beach Paradise", date: "Apr 12, 2025", participants: 28, status: "confirmed" },
    { id: 5, destination: "Temple Tour", date: "Apr 18, 2025", participants: 15, status: "pending" },
  ];

  return (
    <Card className="col-span-full">
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-2xl">
          <MapPin className="h-6 w-6" />
          Upcoming Trips
        </CardTitle>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Destination</TableHead>
              <TableHead>Date</TableHead>
              <TableHead>Participants</TableHead>
              <TableHead>Status</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {trips.map((trip) => (
              <TableRow key={trip.id}>
                <TableCell className="font-medium text-base">{trip.destination}</TableCell>
                <TableCell className="text-base">{trip.date}</TableCell>
                <TableCell className="text-base">{trip.participants} members</TableCell>
                <TableCell>
                  <Badge variant={trip.status === "confirmed" ? "default" : "secondary"} className="text-base px-3 py-1">
                    {trip.status}
                  </Badge>
                </TableCell>
                <TableCell className="text-right">
                  <Button variant="ghost" size="lg">
                    <Eye className="h-5 w-5" />
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
