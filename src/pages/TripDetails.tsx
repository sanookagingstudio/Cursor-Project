import { PublicLayout } from "@/layouts/PublicLayout";
import { useParams } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { MapPin, Calendar, Clock, Users, Heart, DollarSign, Camera } from "lucide-react";

export default function TripDetails() {
  const { id } = useParams();

  const trip = {
    title: "Ayutthaya Heritage Day Trip",
    location: "Ayutthaya, Thailand",
    duration: "Full Day (8 hours)",
    date: "Every Saturday",
    price: "฿1,200 per person",
    capacity: "15 people",
    difficulty: "Easy",
    careLevel: "Standard",
    highlights: [
      "UNESCO World Heritage temples",
      "Traditional Thai lunch",
      "Professional care staff",
      "Wheelchair accessible",
    ],
    itinerary: [
      { time: "7:00 AM", activity: "Pick-up from SAS Center" },
      { time: "9:00 AM", activity: "Arrive at Wat Mahathat" },
      { time: "10:30 AM", activity: "Visit Wat Phra Si Sanphet" },
      { time: "12:00 PM", activity: "Traditional Thai lunch" },
      { time: "2:00 PM", activity: "Boat ride along the river" },
      { time: "3:30 PM", activity: "Free time & shopping" },
      { time: "5:00 PM", activity: "Return to Bangkok" },
    ],
    included: [
      "Round-trip transportation",
      "English-speaking guide",
      "All entrance fees",
      "Lunch and water",
      "Travel insurance",
      "Care staff (1:5 ratio)",
    ],
    healthNotes: "Suitable for those who can walk short distances. Wheelchairs available if needed.",
  };

  return (
    <PublicLayout>
      <div className="section-padding bg-gradient-warm">
        <div className="max-w-5xl mx-auto container-padding">
          {/* Hero */}
          <div className="mb-8">
            <div className="flex items-center gap-2 mb-4">
              <Badge variant="secondary">Cultural</Badge>
              <Badge variant="outline">{trip.difficulty}</Badge>
            </div>
            <h1 className="mb-4">{trip.title}</h1>
            <p className="text-xl text-muted-foreground flex items-center gap-2">
              <MapPin className="h-5 w-5" />
              {trip.location}
            </p>
          </div>

          {/* Key Facts */}
          <div className="grid md:grid-cols-4 gap-4 mb-8">
            <Card>
              <CardContent className="pt-6">
                <Clock className="h-8 w-8 text-primary mb-2" />
                <p className="text-sm text-muted-foreground">Duration</p>
                <p className="text-lg font-medium">{trip.duration}</p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6">
                <Calendar className="h-8 w-8 text-primary mb-2" />
                <p className="text-sm text-muted-foreground">Schedule</p>
                <p className="text-lg font-medium">{trip.date}</p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6">
                <Users className="h-8 w-8 text-primary mb-2" />
                <p className="text-sm text-muted-foreground">Capacity</p>
                <p className="text-lg font-medium">{trip.capacity}</p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6">
                <DollarSign className="h-8 w-8 text-primary mb-2" />
                <p className="text-sm text-muted-foreground">Price</p>
                <p className="text-lg font-medium">{trip.price}</p>
              </CardContent>
            </Card>
          </div>

          {/* Tabs */}
          <Tabs defaultValue="itinerary" className="mb-8">
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="itinerary">Itinerary</TabsTrigger>
              <TabsTrigger value="included">What's Included</TabsTrigger>
              <TabsTrigger value="health">Health Notes</TabsTrigger>
            </TabsList>

            <TabsContent value="itinerary">
              <Card>
                <CardHeader>
                  <CardTitle>Daily Schedule</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {trip.itinerary.map((item, idx) => (
                      <div key={idx} className="flex gap-4">
                        <div className="w-24 text-primary font-medium">{item.time}</div>
                        <div className="flex-1 text-lg">{item.activity}</div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="included">
              <Card>
                <CardHeader>
                  <CardTitle>Package Includes</CardTitle>
                </CardHeader>
                <CardContent>
                  <ul className="space-y-3">
                    {trip.included.map((item) => (
                      <li key={item} className="flex items-start gap-2">
                        <span className="text-primary mt-1">✓</span>
                        <span className="text-lg">{item}</span>
                      </li>
                    ))}
                  </ul>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="health">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Heart className="h-5 w-5 text-primary" />
                    Health & Accessibility
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-lg mb-4">{trip.healthNotes}</p>
                  <div className="space-y-2">
                    <p className="font-medium">Care Level: {trip.careLevel}</p>
                    <p className="text-muted-foreground">
                      Our professional care staff will be with you throughout the journey to ensure
                      your comfort and safety.
                    </p>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>

          {/* Highlights */}
          <Card className="mb-8">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Camera className="h-5 w-5 text-primary" />
                Trip Highlights
              </CardTitle>
            </CardHeader>
            <CardContent>
              <ul className="grid md:grid-cols-2 gap-3">
                {trip.highlights.map((highlight) => (
                  <li key={highlight} className="flex items-start gap-2">
                    <span className="text-primary mt-1">★</span>
                    <span className="text-lg">{highlight}</span>
                  </li>
                ))}
              </ul>
            </CardContent>
          </Card>

          {/* CTA */}
          <div className="flex gap-4">
            <Button size="lg" className="btn-elderly flex-1 md:flex-initial">
              <Calendar className="mr-2 h-5 w-5" />
              Book This Trip
            </Button>
            <Button variant="outline" size="lg" className="btn-elderly">
              Ask Questions
            </Button>
          </div>
        </div>
      </div>
    </PublicLayout>
  );
}
