import { PublicLayout } from "@/layouts/PublicLayout";
import { useParams } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Calendar, Clock, Users, Heart, Brain, Music } from "lucide-react";

export default function ActivityDetails() {
  const { id } = useParams();

  const activity = {
    title: "Morning Tai Chi & Meditation",
    category: "Exercise",
    time: "8:00 AM - 9:30 AM",
    duration: "90 minutes",
    capacity: "20 people",
    enrolled: 15,
    instructor: "Master Lin",
    intensity: "Low",
    benefits: ["Improves balance", "Reduces stress", "Enhances flexibility", "Social connection"],
    description: "Start your day with gentle Tai Chi movements followed by guided meditation. Perfect for all fitness levels, this activity helps improve balance, flexibility, and mental clarity.",
    requirements: "Comfortable clothing, water bottle",
    location: "Garden Pavilion",
    schedule: ["Monday", "Wednesday", "Friday"],
  };

  return (
    <PublicLayout>
      <div className="section-padding bg-gradient-warm">
        <div className="max-w-5xl mx-auto container-padding">
          <div className="mb-8">
            <div className="flex items-center gap-2 mb-4">
              <Badge variant="secondary">{activity.category}</Badge>
              <Badge variant="outline">{activity.intensity} Intensity</Badge>
            </div>
            <h1 className="mb-4">{activity.title}</h1>
            <p className="text-xl text-muted-foreground">{activity.description}</p>
          </div>

          <div className="grid md:grid-cols-2 gap-6 mb-8">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Clock className="h-5 w-5 text-primary" />
                  Schedule & Time
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div>
                  <p className="text-sm text-muted-foreground">Time</p>
                  <p className="text-lg font-medium">{activity.time}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Duration</p>
                  <p className="text-lg font-medium">{activity.duration}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Days</p>
                  <div className="flex gap-2 mt-1">
                    {activity.schedule.map((day) => (
                      <Badge key={day}>{day}</Badge>
                    ))}
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Users className="h-5 w-5 text-primary" />
                  Capacity & Enrollment
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div>
                  <p className="text-sm text-muted-foreground">Instructor</p>
                  <p className="text-lg font-medium">{activity.instructor}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Capacity</p>
                  <p className="text-lg font-medium">{activity.capacity}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Current Enrollment</p>
                  <p className="text-lg font-medium">{activity.enrolled} enrolled</p>
                  <div className="w-full bg-muted rounded-full h-2 mt-2">
                    <div
                      className="gradient-primary h-2 rounded-full"
                      style={{ width: `${(activity.enrolled / 20) * 100}%` }}
                    />
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

          <Card className="mb-8">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Heart className="h-5 w-5 text-primary" />
                Health Benefits
              </CardTitle>
            </CardHeader>
            <CardContent>
              <ul className="grid md:grid-cols-2 gap-3">
                {activity.benefits.map((benefit) => (
                  <li key={benefit} className="flex items-start gap-2">
                    <span className="text-primary mt-1">✓</span>
                    <span className="text-lg">{benefit}</span>
                  </li>
                ))}
              </ul>
            </CardContent>
          </Card>

          <Card className="mb-8">
            <CardHeader>
              <CardTitle>What to Bring</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-lg">{activity.requirements}</p>
              <p className="text-muted-foreground mt-2">Location: {activity.location}</p>
            </CardContent>
          </Card>

          <div className="flex gap-4">
            <Button size="lg" className="btn-elderly flex-1 md:flex-initial">
              <Calendar className="mr-2 h-5 w-5" />
              Join This Activity
            </Button>
            <Button variant="outline" size="lg" className="btn-elderly">
              Share
            </Button>
          </div>
        </div>
      </div>
    </PublicLayout>
  );
}
