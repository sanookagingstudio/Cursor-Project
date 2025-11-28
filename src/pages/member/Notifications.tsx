import { MemberLayout } from "@/layouts/MemberLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { 
  Bell, 
  Check, 
  Trash2,
  Calendar,
  MapPin,
  Users,
  AlertCircle,
  Gift,
  Star,
  Clock
} from "lucide-react";

export default function Notifications() {
  const notifications = [
    {
      id: 1,
      type: "trip",
      icon: MapPin,
      title: "Trip Reminder: Ayutthaya Heritage Tour",
      message: "Your trip is scheduled for tomorrow at 8:00 AM. Please arrive 15 minutes early.",
      time: "2 hours ago",
      read: false,
      color: "text-primary"
    },
    {
      id: 2,
      type: "activity",
      icon: Calendar,
      title: "New Activity Available",
      message: "Morning Yoga class has been added to this week's schedule. Book your spot now!",
      time: "5 hours ago",
      read: false,
      color: "text-accent"
    },
    {
      id: 3,
      type: "announcement",
      icon: Bell,
      title: "Special Promotion",
      message: "Get 20% off on all March trips. Limited time offer!",
      time: "1 day ago",
      read: false,
      color: "text-orange-500"
    },
    {
      id: 4,
      type: "social",
      icon: Users,
      title: "Join our Community Event",
      message: "Monthly social gathering this Saturday. Meet fellow members and share experiences!",
      time: "1 day ago",
      read: true,
      color: "text-blue-500"
    },
    {
      id: 5,
      type: "feedback",
      icon: Star,
      title: "Rate Your Recent Trip",
      message: "How was your Temple Tour experience? Your feedback helps us improve.",
      time: "2 days ago",
      read: true,
      color: "text-yellow-500"
    },
    {
      id: 6,
      type: "alert",
      icon: AlertCircle,
      title: "Weather Update",
      message: "Light rain expected during Beach Paradise trip. Don't forget your umbrella!",
      time: "3 days ago",
      read: true,
      color: "text-red-500"
    },
  ];

  const unreadCount = notifications.filter(n => !n.read).length;

  return (
    <MemberLayout>
      <div className="container-padding section-padding max-w-4xl mx-auto space-y-6">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-3xl font-bold mb-2">Notifications</h1>
            <p className="text-muted-foreground">
              You have {unreadCount} unread notification{unreadCount !== 1 ? 's' : ''}
            </p>
          </div>
          <div className="flex gap-2">
            <Button variant="outline" size="sm">
              <Check className="h-4 w-4 mr-2" />
              Mark All Read
            </Button>
            <Button variant="outline" size="sm">
              <Trash2 className="h-4 w-4 mr-2" />
              Clear All
            </Button>
          </div>
        </div>

        <Tabs defaultValue="all" className="space-y-4">
          <TabsList>
            <TabsTrigger value="all">
              All
              {unreadCount > 0 && (
                <Badge variant="default" className="ml-2">{unreadCount}</Badge>
              )}
            </TabsTrigger>
            <TabsTrigger value="unread">Unread</TabsTrigger>
            <TabsTrigger value="trips">Trips</TabsTrigger>
            <TabsTrigger value="activities">Activities</TabsTrigger>
          </TabsList>

          <TabsContent value="all" className="space-y-3">
            {notifications.map((notification) => (
              <Card key={notification.id} className={!notification.read ? "border-primary/50" : ""}>
                <CardContent className="pt-6">
                  <div className="flex items-start gap-4">
                    <div className={`p-3 rounded-lg bg-muted ${notification.color}`}>
                      <notification.icon className="h-5 w-5" />
                    </div>
                    <div className="flex-1 space-y-1">
                      <div className="flex items-start justify-between">
                        <div>
                          <h4 className="font-semibold">{notification.title}</h4>
                          {!notification.read && (
                            <Badge variant="default" className="ml-2">New</Badge>
                          )}
                        </div>
                        <div className="flex items-center gap-2">
                          <span className="text-xs text-muted-foreground flex items-center gap-1">
                            <Clock className="h-3 w-3" />
                            {notification.time}
                          </span>
                        </div>
                      </div>
                      <p className="text-muted-foreground">{notification.message}</p>
                      <div className="flex gap-2 mt-3">
                        {!notification.read && (
                          <Button size="sm" variant="outline">
                            <Check className="h-4 w-4 mr-1" />
                            Mark as Read
                          </Button>
                        )}
                        <Button size="sm" variant="ghost">
                          <Trash2 className="h-4 w-4 mr-1" />
                          Delete
                        </Button>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </TabsContent>

          <TabsContent value="unread" className="space-y-3">
            {notifications.filter(n => !n.read).map((notification) => (
              <Card key={notification.id} className="border-primary/50">
                <CardContent className="pt-6">
                  <div className="flex items-start gap-4">
                    <div className={`p-3 rounded-lg bg-muted ${notification.color}`}>
                      <notification.icon className="h-5 w-5" />
                    </div>
                    <div className="flex-1 space-y-1">
                      <div className="flex items-start justify-between">
                        <div>
                          <h4 className="font-semibold">{notification.title}</h4>
                          <Badge variant="default" className="ml-2">New</Badge>
                        </div>
                        <span className="text-xs text-muted-foreground flex items-center gap-1">
                          <Clock className="h-3 w-3" />
                          {notification.time}
                        </span>
                      </div>
                      <p className="text-muted-foreground">{notification.message}</p>
                      <div className="flex gap-2 mt-3">
                        <Button size="sm" variant="outline">
                          <Check className="h-4 w-4 mr-1" />
                          Mark as Read
                        </Button>
                        <Button size="sm" variant="ghost">
                          <Trash2 className="h-4 w-4 mr-1" />
                          Delete
                        </Button>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </TabsContent>

          <TabsContent value="trips" className="space-y-3">
            {notifications.filter(n => n.type === "trip" || n.type === "alert").map((notification) => (
              <Card key={notification.id} className={!notification.read ? "border-primary/50" : ""}>
                <CardContent className="pt-6">
                  <div className="flex items-start gap-4">
                    <div className={`p-3 rounded-lg bg-muted ${notification.color}`}>
                      <notification.icon className="h-5 w-5" />
                    </div>
                    <div className="flex-1 space-y-1">
                      <div className="flex items-start justify-between">
                        <div>
                          <h4 className="font-semibold">{notification.title}</h4>
                          {!notification.read && (
                            <Badge variant="default" className="ml-2">New</Badge>
                          )}
                        </div>
                        <span className="text-xs text-muted-foreground flex items-center gap-1">
                          <Clock className="h-3 w-3" />
                          {notification.time}
                        </span>
                      </div>
                      <p className="text-muted-foreground">{notification.message}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </TabsContent>

          <TabsContent value="activities" className="space-y-3">
            {notifications.filter(n => n.type === "activity").map((notification) => (
              <Card key={notification.id} className={!notification.read ? "border-primary/50" : ""}>
                <CardContent className="pt-6">
                  <div className="flex items-start gap-4">
                    <div className={`p-3 rounded-lg bg-muted ${notification.color}`}>
                      <notification.icon className="h-5 w-5" />
                    </div>
                    <div className="flex-1 space-y-1">
                      <div className="flex items-start justify-between">
                        <div>
                          <h4 className="font-semibold">{notification.title}</h4>
                          {!notification.read && (
                            <Badge variant="default" className="ml-2">New</Badge>
                          )}
                        </div>
                        <span className="text-xs text-muted-foreground flex items-center gap-1">
                          <Clock className="h-3 w-3" />
                          {notification.time}
                        </span>
                      </div>
                      <p className="text-muted-foreground">{notification.message}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </TabsContent>
        </Tabs>
      </div>
    </MemberLayout>
  );
}
