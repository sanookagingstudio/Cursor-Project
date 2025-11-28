import { AdminLayout } from "@/layouts/AdminLayout";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { 
  DollarSign,
  Server,
  Brain,
  Plug,
  TrendingUp,
  AlertCircle,
  Loader2
} from "lucide-react";
import { useState, useEffect } from "react";
import { useToast } from "@/components/ui/use-toast";

interface CostSummary {
  total_monthly_cost: number;
  cost_by_category: {
    infrastructure: number;
    ai_services: number;
    third_party: number;
  };
  cost_trends: any[];
  upcoming_renewals: Array<{
    item: string;
    type: string;
    renewal_date: string;
    cost: number;
  }>;
}

export default function CostManagement() {
  const { toast } = useToast();
  const [loading, setLoading] = useState(true);
  const [costSummary, setCostSummary] = useState<CostSummary | null>(null);
  const [activeTab, setActiveTab] = useState("overview");

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      
      const summaryRes = await fetch("/api/cost/summary");
      if (summaryRes.ok) {
        const data = await summaryRes.json();
        setCostSummary(data);
      }
    } catch (error) {
      console.error("Error loading cost data:", error);
      toast({
        title: "Error",
        description: "Failed to load cost data",
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
          <h1 className="text-5xl font-bold mb-2">Cost & Infrastructure Management</h1>
          <p className="text-2xl text-muted-foreground">
            Track and manage infrastructure costs, AI providers, and third-party services
          </p>
        </div>

        {/* Cost Overview Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Total Monthly Cost</CardTitle>
              <DollarSign className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">
                ฿{costSummary?.total_monthly_cost?.toLocaleString() || "0"}
              </div>
              <p className="text-base text-muted-foreground mt-1">
                Per month
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Infrastructure</CardTitle>
              <Server className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">
                ฿{costSummary?.cost_by_category?.infrastructure?.toLocaleString() || "0"}
              </div>
              <p className="text-base text-muted-foreground mt-1">
                Domain, Hosting, CDN
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">AI Services</CardTitle>
              <Brain className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">
                ฿{costSummary?.cost_by_category?.ai_services?.toLocaleString() || "0"}
              </div>
              <p className="text-base text-muted-foreground mt-1">
                AI Providers
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Third-Party</CardTitle>
              <Plug className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">
                ฿{costSummary?.cost_by_category?.third_party?.toLocaleString() || "0"}
              </div>
              <p className="text-base text-muted-foreground mt-1">
                Integrations
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Main Content Tabs */}
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-4 text-base">
            <TabsTrigger value="overview" className="text-base">
              Overview
            </TabsTrigger>
            <TabsTrigger value="infrastructure" className="text-base">
              Infrastructure
            </TabsTrigger>
            <TabsTrigger value="ai-providers" className="text-base">
              AI Providers
            </TabsTrigger>
            <TabsTrigger value="third-party" className="text-base">
              Third-Party
            </TabsTrigger>
          </TabsList>

          {/* Overview Tab */}
          <TabsContent value="overview" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Cost Breakdown</CardTitle>
                <CardDescription className="text-lg">Monthly costs by category</CardDescription>
              </CardHeader>
              <CardContent>
                {costSummary?.cost_by_category ? (
                  <div className="space-y-2">
                    {Object.entries(costSummary.cost_by_category).map(([category, amount]) => (
                      <div key={category} className="flex justify-between items-center p-3 border rounded-lg">
                        <span className="text-base font-medium capitalize">{category.replace("_", " ")}</span>
                        <span className="text-base font-bold">฿{Number(amount).toLocaleString()}</span>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-base text-muted-foreground">No cost data available</p>
                )}
              </CardContent>
            </Card>

            {costSummary?.upcoming_renewals && costSummary.upcoming_renewals.length > 0 && (
              <Card>
                <CardHeader>
                  <CardTitle className="text-2xl font-bold flex items-center gap-2">
                    <AlertCircle className="h-6 w-6" />
                    Upcoming Renewals
                  </CardTitle>
                  <CardDescription className="text-lg">Renewals in the next 30 days</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-2">
                    {costSummary.upcoming_renewals.map((renewal, index) => (
                      <div key={index} className="flex justify-between items-center p-3 border rounded-lg">
                        <div>
                          <div className="text-base font-medium">{renewal.item}</div>
                          <div className="text-sm text-muted-foreground">
                            {renewal.type} • {renewal.renewal_date}
                          </div>
                        </div>
                        <span className="text-base font-bold">฿{renewal.cost.toLocaleString()}</span>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            )}
          </TabsContent>

          {/* Infrastructure Tab */}
          <TabsContent value="infrastructure" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Infrastructure Items</CardTitle>
                <CardDescription className="text-lg">Domain, Hosting, CDN, Storage</CardDescription>
              </CardHeader>
              <CardContent>
                <p className="text-base text-muted-foreground">Infrastructure items list will be displayed here</p>
              </CardContent>
            </Card>
          </TabsContent>

          {/* AI Providers Tab */}
          <TabsContent value="ai-providers" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">AI Provider Costs</CardTitle>
                <CardDescription className="text-lg">Track AI service costs and usage</CardDescription>
              </CardHeader>
              <CardContent>
                <p className="text-base text-muted-foreground">AI provider costs list will be displayed here</p>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Third-Party Tab */}
          <TabsContent value="third-party" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Third-Party Integrations</CardTitle>
                <CardDescription className="text-lg">Track third-party service costs</CardDescription>
              </CardHeader>
              <CardContent>
                <p className="text-base text-muted-foreground">Third-party integrations list will be displayed here</p>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </AdminLayout>
  );
}

