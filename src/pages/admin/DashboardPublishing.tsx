import { AdminLayout } from "@/layouts/AdminLayout";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { 
  LayoutDashboard,
  TrendingUp,
  DollarSign,
  Eye,
  Upload,
  Calendar,
  BarChart3,
  FileVideo,
  Plus,
  Loader2,
  CheckCircle2,
  XCircle,
  Clock
} from "lucide-react";
import { useState } from "react";
import { useToast } from "@/components/ui/use-toast";

export default function DashboardPublishing() {
  const { toast } = useToast();
  const [activeTab, setActiveTab] = useState("overview");

  return (
    <AdminLayout>
      <div className="space-y-8 w-full">
        <div>
          <h1 className="text-5xl font-bold mb-4 flex items-center gap-3">
            <LayoutDashboard className="h-10 w-10 text-primary" />
            Dashboard & Publishing
          </h1>
          <p className="text-lg text-muted-foreground">
            Manage content channels, series, episodes, and publish to multiple platforms. Track performance and revenue.
          </p>
        </div>

        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-4 text-base">
            <TabsTrigger value="overview" className="text-base">Overview</TabsTrigger>
            <TabsTrigger value="channels" className="text-base">Channels</TabsTrigger>
            <TabsTrigger value="publishing" className="text-base">Publishing</TabsTrigger>
            <TabsTrigger value="analytics" className="text-base">Analytics</TabsTrigger>
          </TabsList>

          {/* Overview Tab */}
          <TabsContent value="overview" className="space-y-4">
            <div className="grid gap-4 md:grid-cols-4">
              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-lg font-semibold">Channels</CardTitle>
                  <FileVideo className="h-6 w-6 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-4xl font-bold">0</div>
                  <p className="text-base text-muted-foreground">Total channels</p>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-lg font-semibold">Episodes</CardTitle>
                  <Upload className="h-6 w-6 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-4xl font-bold">0</div>
                  <p className="text-base text-muted-foreground">Total episodes</p>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-lg font-semibold">Views</CardTitle>
                  <Eye className="h-6 w-6 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-4xl font-bold">0</div>
                  <p className="text-base text-muted-foreground">Total views</p>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-lg font-semibold">Revenue</CardTitle>
                  <DollarSign className="h-6 w-6 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-4xl font-bold">฿0</div>
                  <p className="text-base text-muted-foreground">Total revenue</p>
                </CardContent>
              </Card>
            </div>

            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Recent Episodes</CardTitle>
                <CardDescription className="text-lg">Latest episodes across all channels</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="text-center py-8 text-muted-foreground text-base">
                    No episodes yet. Create your first episode to get started.
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Channels Tab */}
          <TabsContent value="channels" className="space-y-4">
            <Card>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <div>
                    <CardTitle className="text-2xl font-bold">Content Channels</CardTitle>
                    <CardDescription className="text-lg">Organize your content into channels and series</CardDescription>
                  </div>
                  <Button size="lg" className="text-base">
                    <Plus className="mr-2 h-5 w-5" />
                    New Channel
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="text-center py-8 text-muted-foreground text-base">
                    No channels yet. Create your first channel to get started.
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Publishing Tab */}
          <TabsContent value="publishing" className="space-y-4">
            <Card>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <div>
                    <CardTitle className="text-2xl font-bold">Publishing Queue</CardTitle>
                    <CardDescription className="text-lg">Manage content publishing to platforms</CardDescription>
                  </div>
                  <Button size="lg" className="text-base">
                    <Plus className="mr-2 h-5 w-5" />
                    New Publication
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Select Episode</Label>
                    <Select>
                      <SelectTrigger className="text-base h-12">
                        <SelectValue placeholder="Choose an episode" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="ep1" className="text-base">Episode 1</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Platform</Label>
                    <Select>
                      <SelectTrigger className="text-base h-12">
                        <SelectValue placeholder="Select platform" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="youtube" className="text-base">YouTube</SelectItem>
                        <SelectItem value="tiktok" className="text-base">TikTok</SelectItem>
                        <SelectItem value="facebook" className="text-base">Facebook</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Schedule (Optional)</Label>
                    <Input type="datetime-local" className="text-base h-12" />
                  </div>

                  <Button size="lg" className="text-base w-full">
                    <Upload className="mr-2 h-5 w-5" />
                    Publish
                  </Button>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Publication Status</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex items-center justify-between p-4 border rounded-lg">
                    <div className="flex items-center gap-3">
                      <CheckCircle2 className="h-6 w-6 text-green-500" />
                      <div>
                        <p className="text-base font-semibold">Published</p>
                        <p className="text-sm text-muted-foreground">YouTube - Episode 1</p>
                      </div>
                    </div>
                    <Badge variant="outline" className="text-base">Published</Badge>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Analytics Tab */}
          <TabsContent value="analytics" className="space-y-4">
            <div className="grid gap-4 md:grid-cols-2">
              <Card>
                <CardHeader>
                  <CardTitle className="text-2xl font-bold">Performance Metrics</CardTitle>
                  <CardDescription className="text-lg">Views, engagement, and watch time</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <div className="flex items-center justify-between">
                      <span className="text-base">Total Views</span>
                      <span className="text-2xl font-bold">0</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-base">Total Likes</span>
                      <span className="text-2xl font-bold">0</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-base">Engagement Rate</span>
                      <span className="text-2xl font-bold">0%</span>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="text-2xl font-bold">Revenue Analytics</CardTitle>
                  <CardDescription className="text-lg">Revenue breakdown by source</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <div className="flex items-center justify-between">
                      <span className="text-base">Total Revenue</span>
                      <span className="text-2xl font-bold">฿0</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-base">Total Cost</span>
                      <span className="text-2xl font-bold">฿0</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-base">Profit</span>
                      <span className="text-2xl font-bold">฿0</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-base">ROI</span>
                      <span className="text-2xl font-bold">0%</span>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>

            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Top Performers</CardTitle>
                <CardDescription className="text-lg">Best performing episodes</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="text-center py-8 text-muted-foreground text-base">
                  No performance data yet. Publish content to see analytics.
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </AdminLayout>
  );
}

