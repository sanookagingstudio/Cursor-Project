import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { FilterBar } from "@/components/ui/filter-bar";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { 
  MapPin, 
  Calendar, 
  Users, 
  Clock,
  Plus,
  Eye,
  Edit,
  Trash2,
  CheckCircle,
  AlertCircle,
  DollarSign
} from "lucide-react";

export default function FUNTrip() {
  const upcomingTrips = [
    { 
      id: 1, 
      name: "Ayutthaya Heritage Tour", 
      date: "Mar 15, 2025",
      time: "08:00 AM",
      participants: 24,
      capacity: 30,
      guide: "Somchai R.",
      status: "confirmed",
      revenue: 36000,
      cost: 28000
    },
    { 
      id: 2, 
      name: "Floating Market Experience", 
      date: "Mar 22, 2025",
      time: "07:00 AM",
      participants: 18,
      capacity: 25,
      guide: "Niran W.",
      status: "confirmed",
      revenue: 27000,
      cost: 22000
    },
    { 
      id: 3, 
      name: "Mountain Retreat", 
      date: "Apr 5, 2025",
      time: "06:00 AM",
      participants: 32,
      capacity: 35,
      guide: "Amara L.",
      status: "pending",
      revenue: 48000,
      cost: 38000
    },
  ];

  const pastTrips = [
    { 
      id: 4, 
      name: "Temple Tour", 
      date: "Feb 28, 2025",
      participants: 22,
      guide: "Somchai R.",
      status: "completed",
      revenue: 33000,
      cost: 26000,
      profit: 7000,
      rating: 4.8
    },
    { 
      id: 5, 
      name: "Beach Paradise", 
      date: "Feb 15, 2025",
      participants: 28,
      guide: "Niran W.",
      status: "completed",
      revenue: 42000,
      cost: 34000,
      profit: 8000,
      rating: 4.9
    },
  ];

  const stats = [
    { label: "Total Trips", value: "45", trend: "+8 this month" },
    { label: "Upcoming Trips", value: "8", trend: "Next 30 days" },
    { label: "Total Revenue", value: "฿1.2M", trend: "+15% vs last month" },
    { label: "Avg Satisfaction", value: "4.7/5", trend: "Based on 142 reviews" },
  ];

  return (
    <AdminLayout>
      <div className="space-y-6">
        <div className="flex justify-between items-start">
          <SectionHeader
            title="FUN Trip Management"
            description="Manage trips, schedules, and monitor trip performance"
          />
          <Button className="btn-elderly">
            <Plus className="h-4 w-4 mr-2" />
            Create New Trip
          </Button>
        </div>

        {/* Stats Overview */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {stats.map((stat) => (
            <Card key={stat.label}>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">{stat.label}</CardTitle>
                <MapPin className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stat.value}</div>
                <p className="text-xs text-muted-foreground">{stat.trend}</p>
              </CardContent>
            </Card>
          ))}
        </div>

        {/* Tabs for Trip Views */}
        <Tabs defaultValue="upcoming" className="space-y-4">
          <TabsList>
            <TabsTrigger value="upcoming">Upcoming Trips</TabsTrigger>
            <TabsTrigger value="past">Past Trips</TabsTrigger>
            <TabsTrigger value="planning">Planning</TabsTrigger>
          </TabsList>

          <TabsContent value="upcoming" className="space-y-4">
            <Card>
              <CardContent className="pt-6">
                <FilterBar searchPlaceholder="Search trips...">
                  <Select>
                    <SelectTrigger className="w-[180px]">
                      <SelectValue placeholder="Status" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Status</SelectItem>
                      <SelectItem value="confirmed">Confirmed</SelectItem>
                      <SelectItem value="pending">Pending</SelectItem>
                      <SelectItem value="cancelled">Cancelled</SelectItem>
                    </SelectContent>
                  </Select>
                  <Select>
                    <SelectTrigger className="w-[180px]">
                      <SelectValue placeholder="Guide" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Guides</SelectItem>
                      <SelectItem value="somchai">Somchai R.</SelectItem>
                      <SelectItem value="niran">Niran W.</SelectItem>
                      <SelectItem value="amara">Amara L.</SelectItem>
                    </SelectContent>
                  </Select>
                </FilterBar>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Upcoming Trips</CardTitle>
              </CardHeader>
              <CardContent>
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Trip Name</TableHead>
                      <TableHead>Date & Time</TableHead>
                      <TableHead>Participants</TableHead>
                      <TableHead>Guide</TableHead>
                      <TableHead>Revenue/Cost</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead className="text-right">Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {upcomingTrips.map((trip) => (
                      <TableRow key={trip.id}>
                        <TableCell className="font-medium">{trip.name}</TableCell>
                        <TableCell>
                          <div className="flex flex-col gap-1">
                            <div className="flex items-center gap-1">
                              <Calendar className="h-3 w-3" />
                              {trip.date}
                            </div>
                            <div className="flex items-center gap-1 text-xs text-muted-foreground">
                              <Clock className="h-3 w-3" />
                              {trip.time}
                            </div>
                          </div>
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center gap-2">
                            <Users className="h-4 w-4 text-muted-foreground" />
                            {trip.participants}/{trip.capacity}
                          </div>
                        </TableCell>
                        <TableCell>{trip.guide}</TableCell>
                        <TableCell>
                          <div className="flex flex-col gap-1 text-xs">
                            <span className="text-accent">฿{trip.revenue.toLocaleString()}</span>
                            <span className="text-muted-foreground">฿{trip.cost.toLocaleString()}</span>
                          </div>
                        </TableCell>
                        <TableCell>
                          <Badge variant={trip.status === "confirmed" ? "default" : "secondary"}>
                            {trip.status}
                          </Badge>
                        </TableCell>
                        <TableCell className="text-right">
                          <div className="flex justify-end gap-2">
                            <Button variant="ghost" size="sm">
                              <Eye className="h-4 w-4" />
                            </Button>
                            <Button variant="ghost" size="sm">
                              <Edit className="h-4 w-4" />
                            </Button>
                            <Button variant="ghost" size="sm">
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="past" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Completed Trips</CardTitle>
              </CardHeader>
              <CardContent>
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Trip Name</TableHead>
                      <TableHead>Date</TableHead>
                      <TableHead>Participants</TableHead>
                      <TableHead>Guide</TableHead>
                      <TableHead>Financial</TableHead>
                      <TableHead>Rating</TableHead>
                      <TableHead className="text-right">Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {pastTrips.map((trip) => (
                      <TableRow key={trip.id}>
                        <TableCell className="font-medium">{trip.name}</TableCell>
                        <TableCell>{trip.date}</TableCell>
                        <TableCell>
                          <div className="flex items-center gap-2">
                            <Users className="h-4 w-4 text-muted-foreground" />
                            {trip.participants}
                          </div>
                        </TableCell>
                        <TableCell>{trip.guide}</TableCell>
                        <TableCell>
                          <div className="flex flex-col gap-1 text-xs">
                            <span className="text-accent">Revenue: ฿{trip.revenue.toLocaleString()}</span>
                            <span className="text-muted-foreground">Cost: ฿{trip.cost.toLocaleString()}</span>
                            <span className="font-semibold">Profit: ฿{trip.profit.toLocaleString()}</span>
                          </div>
                        </TableCell>
                        <TableCell>
                          <Badge variant="default">⭐ {trip.rating}</Badge>
                        </TableCell>
                        <TableCell className="text-right">
                          <Button variant="ghost" size="sm">
                            <Eye className="h-4 w-4" />
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="planning" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Trips in Planning Stage</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-center py-12">
                  <MapPin className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
                  <h3 className="text-lg font-semibold mb-2">No trips in planning</h3>
                  <p className="text-muted-foreground mb-4">Start planning your next adventure</p>
                  <Button className="btn-elderly">
                    <Plus className="h-4 w-4 mr-2" />
                    Create New Trip
                  </Button>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </AdminLayout>
  );
}
