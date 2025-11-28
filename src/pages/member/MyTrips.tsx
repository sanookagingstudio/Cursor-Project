import { MemberLayout } from "@/layouts/MemberLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { TripCard } from "@/components/cards/TripCard";
import { Card, CardContent } from "@/components/ui/card";

export default function MyTrips() {
  const upcomingTrips = [
    {
      title: "Ayutthaya Heritage",
      description: "UNESCO World Heritage temples and culture",
      location: "Ayutthaya",
      duration: "Full Day",
      price: "฿1,200",
      date: "Next Saturday",
    },
    {
      title: "Floating Market Tour",
      description: "Traditional Thai floating market experience",
      location: "Damnoen Saduak",
      duration: "Half Day",
      price: "฿800",
      date: "In 2 weeks",
    },
  ];

  const pastTrips = [
    {
      title: "Hua Hin Beach Resort",
      description: "Relaxing beach getaway with activities",
      location: "Hua Hin",
      duration: "2 Days",
      price: "฿3,500",
      date: "Last month",
    },
  ];

  return (
    <MemberLayout>
      <SectionHeader
        title="My Trips"
        description="Manage your trip bookings and explore new destinations"
      />

      <div className="grid lg:grid-cols-4 gap-6 mb-8">
        <Card>
          <CardContent className="pt-6">
            <p className="text-sm text-muted-foreground mb-1">Booked Trips</p>
            <p className="text-3xl font-bold text-primary">{upcomingTrips.length}</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <p className="text-sm text-muted-foreground mb-1">Completed</p>
            <p className="text-3xl font-bold">{pastTrips.length}</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <p className="text-sm text-muted-foreground mb-1">Total Spent</p>
            <p className="text-3xl font-bold">฿5,500</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <p className="text-sm text-muted-foreground mb-1">Next Trip</p>
            <p className="text-xl font-bold">This Saturday</p>
          </CardContent>
        </Card>
      </div>

      <Tabs defaultValue="upcoming">
        <TabsList>
          <TabsTrigger value="upcoming">Upcoming Trips</TabsTrigger>
          <TabsTrigger value="past">Past Trips</TabsTrigger>
        </TabsList>

        <TabsContent value="upcoming" className="mt-6">
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {upcomingTrips.map((trip) => (
              <TripCard key={trip.title} {...trip} />
            ))}
          </div>
        </TabsContent>

        <TabsContent value="past" className="mt-6">
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {pastTrips.map((trip) => (
              <TripCard key={trip.title} {...trip} />
            ))}
          </div>
        </TabsContent>
      </Tabs>
    </MemberLayout>
  );
}
