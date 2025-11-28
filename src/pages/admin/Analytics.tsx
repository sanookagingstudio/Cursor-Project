import { AdminLayout } from "@/layouts/AdminLayout";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { 
  Users,
  TrendingUp,
  Globe,
  Clock,
  BarChart3,
  Loader2
} from "lucide-react";
import { useState, useEffect } from "react";
import { useToast } from "@/components/ui/use-toast";

interface UserAnalytics {
  total_users: number;
  active_users: { dau: number; wau: number; mau: number };
  new_users: number;
  returning_users: number;
  retention_rate: number;
  growth_rate: number;
}

interface ContentAnalytics {
  most_viewed: Array<{ content_id: string; content_type: string; count: number }>;
  most_liked: Array<{ content_id: string; content_type: string; count: number }>;
  most_shared: Array<{ content_id: string; content_type: string; count: number }>;
  most_downloaded: Array<{ content_id: string; content_type: string; count: number }>;
  trending: any[];
}

interface TimeAnalytics {
  peak_hours: Array<{ hour: number; count: number }>;
  peak_days: Array<{ day: string; count: number }>;
  peak_months: any[];
  average_session_duration: number;
}

interface GeographicAnalytics {
  users_by_country: Record<string, number>;
  users_by_region: Record<string, number>;
  top_countries: Array<{ country: string; users: number }>;
}

interface FeatureUsage {
  feature_adoption: Record<string, number>;
  feature_usage_stats: Record<string, any>;
  most_used_features: Array<{ feature: string; usage: number; users: number }>;
}

export default function Analytics() {
  const { toast } = useToast();
  const [loading, setLoading] = useState(true);
  const [userAnalytics, setUserAnalytics] = useState<UserAnalytics | null>(null);
  const [contentAnalytics, setContentAnalytics] = useState<ContentAnalytics | null>(null);
  const [timeAnalytics, setTimeAnalytics] = useState<TimeAnalytics | null>(null);
  const [geographicAnalytics, setGeographicAnalytics] = useState<GeographicAnalytics | null>(null);
  const [featureUsage, setFeatureUsage] = useState<FeatureUsage | null>(null);
  const [activeTab, setActiveTab] = useState("overview");

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      
      // Load all analytics data
      const [usersRes, contentRes, timeRes, geoRes, featuresRes] = await Promise.all([
        fetch("/api/analytics/users"),
        fetch("/api/analytics/content"),
        fetch("/api/analytics/time"),
        fetch("/api/analytics/geographic"),
        fetch("/api/analytics/features")
      ]);

      if (usersRes.ok) {
        const data = await usersRes.json();
        setUserAnalytics(data);
      }

      if (contentRes.ok) {
        const data = await contentRes.json();
        setContentAnalytics(data);
      }

      if (timeRes.ok) {
        const data = await timeRes.json();
        setTimeAnalytics(data);
      }

      if (geoRes.ok) {
        const data = await geoRes.json();
        setGeographicAnalytics(data);
      }

      if (featuresRes.ok) {
        const data = await featuresRes.json();
        setFeatureUsage(data);
      }
    } catch (error) {
      console.error("Error loading analytics:", error);
      toast({
        title: "Error",
        description: "Failed to load analytics data",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center min-h-screen">
          <Loader2 className="h-8 w-8 animate-spin" />
        </div>
      </AdminLayout>
    );
  }

  return (
    <AdminLayout>
      <div className="container-padding space-y-6">
        <div>
          <h1 className="text-5xl font-bold mb-2">Analytics & Statistics</h1>
          <p className="text-2xl text-muted-foreground">
            Track user behavior, content performance, and system usage
          </p>
        </div>

        {/* Overview Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Total Users</CardTitle>
              <Users className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">
                {userAnalytics?.total_users || 0}
              </div>
              <p className="text-base text-muted-foreground mt-1">
                All registered users
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Active Users (DAU)</CardTitle>
              <TrendingUp className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">
                {userAnalytics?.active_users?.dau || 0}
              </div>
              <p className="text-base text-muted-foreground mt-1">
                Daily active users
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">New Users</CardTitle>
              <Users className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">
                {userAnalytics?.new_users || 0}
              </div>
              <p className="text-base text-muted-foreground mt-1">
                This period
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Retention Rate</CardTitle>
              <BarChart3 className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">
                {userAnalytics?.retention_rate?.toFixed(1) || 0}%
              </div>
              <p className="text-base text-muted-foreground mt-1">
                User retention
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Main Content Tabs */}
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-5 text-base">
            <TabsTrigger value="overview" className="text-base">
              Overview
            </TabsTrigger>
            <TabsTrigger value="users" className="text-base">
              Users
            </TabsTrigger>
            <TabsTrigger value="content" className="text-base">
              Content
            </TabsTrigger>
            <TabsTrigger value="time" className="text-base">
              Time
            </TabsTrigger>
            <TabsTrigger value="geographic" className="text-base">
              Geographic
            </TabsTrigger>
          </TabsList>

          {/* Overview Tab */}
          <TabsContent value="overview" className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <Card>
                <CardHeader>
                  <CardTitle className="text-2xl font-bold">Active Users</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-2">
                    <div className="flex justify-between">
                      <span className="text-base">Daily (DAU)</span>
                      <span className="text-base font-bold">{userAnalytics?.active_users?.dau || 0}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-base">Weekly (WAU)</span>
                      <span className="text-base font-bold">{userAnalytics?.active_users?.wau || 0}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-base">Monthly (MAU)</span>
                      <span className="text-base font-bold">{userAnalytics?.active_users?.mau || 0}</span>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="text-2xl font-bold">Most Used Features</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-2">
                    {featureUsage?.most_used_features?.slice(0, 5).map((feature, index) => (
                      <div key={index} className="flex justify-between">
                        <span className="text-base capitalize">{feature.feature.replace("_", " ")}</span>
                        <span className="text-base font-bold">{feature.usage}</span>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>

          {/* Users Tab */}
          <TabsContent value="users" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">User Analytics</CardTitle>
                <CardDescription className="text-lg">User statistics and behavior</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <div className="text-base font-semibold">Total Users</div>
                      <div className="text-3xl font-bold">{userAnalytics?.total_users || 0}</div>
                    </div>
                    <div>
                      <div className="text-base font-semibold">New Users</div>
                      <div className="text-3xl font-bold">{userAnalytics?.new_users || 0}</div>
                    </div>
                    <div>
                      <div className="text-base font-semibold">Returning Users</div>
                      <div className="text-3xl font-bold">{userAnalytics?.returning_users || 0}</div>
                    </div>
                    <div>
                      <div className="text-base font-semibold">Retention Rate</div>
                      <div className="text-3xl font-bold">{userAnalytics?.retention_rate?.toFixed(1) || 0}%</div>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Content Tab */}
          <TabsContent value="content" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Content Analytics</CardTitle>
                <CardDescription className="text-lg">Most popular content</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div>
                    <h3 className="text-xl font-semibold mb-2">Most Viewed</h3>
                    <div className="space-y-2">
                      {contentAnalytics?.most_viewed?.slice(0, 5).map((item, index) => (
                        <div key={index} className="flex justify-between p-2 border rounded">
                          <span className="text-base">{item.content_type} - {item.content_id.substring(0, 8)}</span>
                          <span className="text-base font-bold">{item.count} views</span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Time Tab */}
          <TabsContent value="time" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Time Analytics</CardTitle>
                <CardDescription className="text-lg">Peak hours and session duration</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div>
                    <div className="text-base font-semibold">Average Session Duration</div>
                    <div className="text-3xl font-bold">
                      {timeAnalytics?.average_session_duration ? 
                        `${Math.round(timeAnalytics.average_session_duration / 60)} minutes` : 
                        "0 minutes"}
                    </div>
                  </div>
                  <div>
                    <h3 className="text-xl font-semibold mb-2">Peak Hours</h3>
                    <div className="space-y-2">
                      {timeAnalytics?.peak_hours?.slice(0, 5).map((hour, index) => (
                        <div key={index} className="flex justify-between">
                          <span className="text-base">{hour.hour}:00</span>
                          <span className="text-base font-bold">{hour.count} views</span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Geographic Tab */}
          <TabsContent value="geographic" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Geographic Analytics</CardTitle>
                <CardDescription className="text-lg">Users by country</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  {geographicAnalytics?.top_countries?.slice(0, 10).map((country, index) => (
                    <div key={index} className="flex justify-between p-2 border rounded">
                      <span className="text-base">{country.country || "Unknown"}</span>
                      <span className="text-base font-bold">{country.users} users</span>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </AdminLayout>
  );
}

