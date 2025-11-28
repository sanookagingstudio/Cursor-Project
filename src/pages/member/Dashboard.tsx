import { MemberLayout } from "@/layouts/MemberLayout";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { 
  Heart, 
  Activity, 
  Gift, 
  Clock, 
  Camera, 
  TrendingUp,
  Calendar,
  MapPin,
  Sparkles,
  Apple,
  Droplet,
  Moon,
  Sun
} from "lucide-react";
import { useTranslation } from "react-i18next";
import { Link } from "react-router-dom";

export default function MemberDashboard() {
  const { t } = useTranslation();

  const healthMetrics = [
    { label: "Heart Rate", value: "72 bpm", icon: Heart, status: "normal", color: "text-green-500" },
    { label: "Blood Pressure", value: "120/80", icon: Activity, status: "normal", color: "text-green-500" },
    { label: "Activity Today", value: "6,420 steps", icon: TrendingUp, status: "good", color: "text-blue-500" },
  ];

  const activePromotions = [
    { 
      title: "Premium Trip Discount", 
      discount: "20%", 
      expiry: "3 days left",
      type: "trip",
      urgent: true
    },
    { 
      title: "Media Center Credits", 
      discount: "50 credits", 
      expiry: "7 days left",
      type: "credits",
      urgent: false
    },
    { 
      title: "Activity Bundle", 
      discount: "15%", 
      expiry: "14 days left",
      type: "activity",
      urgent: false
    },
  ];

  const personalizedTips = [
    {
      icon: Apple,
      title: "Blood Type A+ Nutrition",
      description: "Foods rich in iron and vitamin C are excellent for your blood type. Try spinach and citrus fruits.",
      category: "Nutrition"
    },
    {
      icon: Moon,
      title: "Aries Energy Balance",
      description: "As an Aries, morning exercise and meditation will help balance your natural energy and enthusiasm.",
      category: "Zodiac"
    },
    {
      icon: Droplet,
      title: "Chakra Alignment",
      description: "Your root chakra needs attention. Try grounding exercises and walking barefoot on natural surfaces.",
      category: "Wellness"
    },
    {
      icon: Sun,
      title: "Seasonal Wellness",
      description: "During hot season, stay hydrated and avoid outdoor activities during peak hours (11am-3pm).",
      category: "Season"
    }
  ];

  const upcomingActivities = [
    { date: "2024-01-20", title: "Yoga Class", time: "09:00 AM", location: "Studio A" },
    { date: "2024-01-22", title: "Art Workshop", time: "02:00 PM", location: "Creative Space" },
  ];

  return (
    <MemberLayout>
      <div className="min-h-screen bg-gradient-to-br from-background via-secondary/20 to-background">
        <div className="container-padding max-w-7xl mx-auto py-8 space-y-8">
          {/* Welcome Header with Premium Feel */}
          <div className="premium-card rounded-2xl p-8 border">
            <div className="flex items-center justify-between">
              <div className="space-y-2">
                <h1 className="text-4xl font-bold bg-gradient-to-r from-primary via-accent to-primary bg-clip-text text-transparent">
                  Welcome Back!
                </h1>
                <p className="text-lg text-muted-foreground">
                  Your personalized wellness journey continues
                </p>
              </div>
              <Badge className="premium-gradient text-white px-6 py-2 text-lg">
                Premium Member
              </Badge>
            </div>
          </div>

          {/* Health Dashboard */}
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-2xl font-semibold flex items-center gap-2">
                <Heart className="h-6 w-6 text-primary" />
                Health Dashboard
              </h2>
              <Button variant="outline" asChild>
                <Link to="/member/health">View Details</Link>
              </Button>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {healthMetrics.map((metric, index) => (
                <Card key={index} className="p-6 card-shadow hover:card-shadow-hover transition-all">
                  <div className="flex items-start justify-between">
                    <div className="space-y-2 flex-1">
                      <p className="text-sm text-muted-foreground">{metric.label}</p>
                      <p className="text-3xl font-bold">{metric.value}</p>
                      <Badge variant="outline" className={metric.color}>
                        {metric.status}
                      </Badge>
                    </div>
                    <metric.icon className={`h-10 w-10 ${metric.color}`} />
                  </div>
                </Card>
              ))}
            </div>
          </div>

          {/* Active Promotions & Benefits */}
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-2xl font-semibold flex items-center gap-2">
                <Gift className="h-6 w-6 text-primary" />
                Active Benefits & Promotions
              </h2>
              <Button variant="outline" asChild>
                <Link to="/promotions">All Offers</Link>
              </Button>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {activePromotions.map((promo, index) => (
                <Card key={index} className={`p-6 card-shadow hover:card-shadow-hover transition-all relative overflow-hidden ${promo.urgent ? 'border-2 border-primary' : ''}`}>
                  {promo.urgent && (
                    <div className="absolute top-0 right-0 bg-destructive text-white px-3 py-1 text-xs font-bold rounded-bl-lg">
                      URGENT
                    </div>
                  )}
                  <div className="space-y-3">
                    <Badge variant="secondary">{promo.type}</Badge>
                    <h3 className="text-xl font-semibold">{promo.title}</h3>
                    <div className="flex items-center gap-2">
                      <Clock className="h-4 w-4 text-muted-foreground" />
                      <p className="text-sm text-muted-foreground">{promo.expiry}</p>
                    </div>
                    <div className="premium-gradient text-white rounded-lg p-4 text-center">
                      <p className="text-3xl font-bold">{promo.discount}</p>
                      <p className="text-sm">OFF</p>
                    </div>
                    <Button className="w-full" variant={promo.urgent ? "default" : "outline"}>
                      Use Now
                    </Button>
                  </div>
                </Card>
              ))}
            </div>
          </div>

          {/* Personalized Recommendations - WOW Factor */}
          <div className="space-y-4">
            <div className="flex items-center gap-2">
              <Sparkles className="h-6 w-6 text-primary animate-pulse" />
              <h2 className="text-2xl font-semibold">
                Personalized Just for You
              </h2>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {personalizedTips.map((tip, index) => (
                <Card key={index} className="p-6 card-shadow hover:card-shadow-hover transition-all">
                  <div className="flex gap-4">
                    <div className="w-12 h-12 rounded-full premium-gradient flex items-center justify-center flex-shrink-0">
                      <tip.icon className="h-6 w-6 text-white" />
                    </div>
                    <div className="space-y-2 flex-1">
                      <div className="flex items-center justify-between">
                        <h3 className="font-semibold text-lg">{tip.title}</h3>
                        <Badge variant="outline" className="text-xs">{tip.category}</Badge>
                      </div>
                      <p className="text-sm text-muted-foreground leading-relaxed">
                        {tip.description}
                      </p>
                    </div>
                  </div>
                </Card>
              ))}
            </div>
          </div>

          {/* Quick Actions */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <Card className="p-6 card-shadow hover:card-shadow-hover transition-all cursor-pointer group">
              <Link to="/media-library" className="block space-y-4">
                <div className="w-12 h-12 rounded-lg premium-gradient flex items-center justify-center group-hover:scale-110 transition-transform">
                  <Camera className="h-6 w-6 text-white" />
                </div>
                <div>
                  <h3 className="text-lg font-semibold">Media Center</h3>
                  <p className="text-sm text-muted-foreground">Create & access your memories</p>
                </div>
              </Link>
            </Card>

            <Card className="p-6 card-shadow hover:card-shadow-hover transition-all cursor-pointer group">
              <Link to="/member/my-trips" className="block space-y-4">
                <div className="w-12 h-12 rounded-lg premium-gradient flex items-center justify-center group-hover:scale-110 transition-transform">
                  <MapPin className="h-6 w-6 text-white" />
                </div>
                <div>
                  <h3 className="text-lg font-semibold">My Trips</h3>
                  <p className="text-sm text-muted-foreground">View & manage your journeys</p>
                </div>
              </Link>
            </Card>

            <Card className="p-6 card-shadow hover:card-shadow-hover transition-all cursor-pointer group">
              <Link to="/calendar" className="block space-y-4">
                <div className="w-12 h-12 rounded-lg premium-gradient flex items-center justify-center group-hover:scale-110 transition-transform">
                  <Calendar className="h-6 w-6 text-white" />
                </div>
                <div>
                  <h3 className="text-lg font-semibold">FUN Calendar</h3>
                  <p className="text-sm text-muted-foreground">Schedule activities & events</p>
                </div>
              </Link>
            </Card>
          </div>

          {/* Upcoming Activities */}
          <Card className="p-6 card-shadow">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-2xl font-semibold flex items-center gap-2">
                <Calendar className="h-6 w-6 text-primary" />
                Upcoming Activities
              </h2>
              <Button variant="outline" asChild>
                <Link to="/member/my-activities">View All</Link>
              </Button>
            </div>
            <div className="space-y-4">
              {upcomingActivities.map((activity, index) => (
                <div key={index} className="flex items-center gap-4 p-4 rounded-lg bg-secondary/50 hover:bg-secondary transition-colors">
                  <div className="text-center">
                    <p className="text-2xl font-bold text-primary">
                      {new Date(activity.date).getDate()}
                    </p>
                    <p className="text-xs text-muted-foreground">
                      {new Date(activity.date).toLocaleDateString('en', { month: 'short' })}
                    </p>
                  </div>
                  <div className="flex-1">
                    <h3 className="font-semibold">{activity.title}</h3>
                    <p className="text-sm text-muted-foreground">{activity.time} • {activity.location}</p>
                  </div>
                  <Button size="sm">Join</Button>
                </div>
              ))}
            </div>
          </Card>
        </div>
      </div>
    </MemberLayout>
  );
}
