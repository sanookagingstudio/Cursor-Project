import { MemberLayout } from "@/layouts/MemberLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { ActivityCard } from "@/components/cards/ActivityCard";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";

export default function MyActivities() {
  const upcomingActivities = [
    { title: "Morning Tai Chi", description: "Gentle movements for balance and flexibility", time: "8:00 AM", duration: "90 min", location: "Garden", intensity: "Low" as const, capacity: 20 },
    { title: "Art & Crafts", description: "Creative expression through art", time: "2:00 PM", duration: "120 min", location: "Studio A", intensity: "Low" as const, capacity: 15 },
    { title: "Music Therapy", description: "Therapeutic music activities", time: "10:00 AM", duration: "60 min", location: "Music Room", intensity: "Low" as const, capacity: 12 },
  ];

  const pastActivities = [
    { title: "Brain Games", description: "Cognitive exercises and puzzles", time: "Completed", duration: "60 min", location: "Library", intensity: "Medium" as const, capacity: 15 },
    { title: "Cooking Class", description: "Learn healthy cooking techniques", time: "Completed", duration: "120 min", location: "Kitchen", intensity: "Low" as const, capacity: 10 },
  ];

  return (
    <MemberLayout>
      <SectionHeader
        title="My Activities"
        description="View your registered activities and participation history"
      />

      <div className="grid lg:grid-cols-4 gap-6 mb-8">
        <Card>
          <CardContent className="pt-6">
            <p className="text-sm text-muted-foreground mb-1">Registered</p>
            <p className="text-3xl font-bold text-primary">{upcomingActivities.length}</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <p className="text-sm text-muted-foreground mb-1">Completed</p>
            <p className="text-3xl font-bold">{pastActivities.length}</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <p className="text-sm text-muted-foreground mb-1">This Week</p>
            <p className="text-3xl font-bold">5</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <p className="text-sm text-muted-foreground mb-1">Attendance Rate</p>
            <p className="text-3xl font-bold">95%</p>
          </CardContent>
        </Card>
      </div>

      <Tabs defaultValue="upcoming">
        <TabsList>
          <TabsTrigger value="upcoming">Upcoming</TabsTrigger>
          <TabsTrigger value="past">Past Activities</TabsTrigger>
        </TabsList>

        <TabsContent value="upcoming" className="mt-6">
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {upcomingActivities.map((activity) => (
              <ActivityCard key={activity.title} {...activity} />
            ))}
          </div>
        </TabsContent>

        <TabsContent value="past" className="mt-6">
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {pastActivities.map((activity) => (
              <ActivityCard key={activity.title} {...activity} />
            ))}
          </div>
        </TabsContent>
      </Tabs>
    </MemberLayout>
  );
}
