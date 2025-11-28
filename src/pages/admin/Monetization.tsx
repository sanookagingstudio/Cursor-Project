import { AdminLayout } from "@/layouts/AdminLayout";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { 
  DollarSign,
  CreditCard,
  Download,
  TrendingUp,
  Users,
  Package,
  Settings,
  Loader2
} from "lucide-react";
import { useState, useEffect } from "react";
import { useToast } from "@/components/ui/use-toast";

interface RevenueSummary {
  total_revenue: number;
  revenue_by_type: Record<string, number>;
  transaction_count: number;
}

interface SubscriptionPlan {
  id: string;
  name: string;
  description: string;
  price_monthly: number | null;
  price_yearly: number | null;
  features: Record<string, any>;
  credit_included: number;
  status: string;
}

export default function Monetization() {
  const { toast } = useToast();
  const [loading, setLoading] = useState(true);
  const [revenue, setRevenue] = useState<RevenueSummary | null>(null);
  const [plans, setPlans] = useState<SubscriptionPlan[]>([]);
  const [activeTab, setActiveTab] = useState("overview");

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      
      // Load revenue summary
      const revenueRes = await fetch("/api/monetization/revenue");
      if (revenueRes.ok) {
        const revenueData = await revenueRes.json();
        setRevenue(revenueData);
      }

      // Load subscription plans
      const plansRes = await fetch("/api/monetization/plans");
      if (plansRes.ok) {
        const plansData = await plansRes.json();
        setPlans(plansData);
      }
    } catch (error) {
      console.error("Error loading data:", error);
      toast({
        title: "Error",
        description: "Failed to load monetization data",
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
          <h1 className="text-5xl font-bold mb-2">Monetization & Payment</h1>
          <p className="text-2xl text-muted-foreground">
            Manage subscriptions, credits, payments, and revenue
          </p>
        </div>

        {/* Revenue Overview Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Total Revenue</CardTitle>
              <DollarSign className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">
                ฿{revenue?.total_revenue?.toLocaleString() || "0"}
              </div>
              <p className="text-base text-muted-foreground mt-1">
                All time revenue
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Transactions</CardTitle>
              <CreditCard className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">
                {revenue?.transaction_count || 0}
              </div>
              <p className="text-base text-muted-foreground mt-1">
                Total transactions
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Subscriptions</CardTitle>
              <Users className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">
                {plans.filter(p => p.status === "active").length}
              </div>
              <p className="text-base text-muted-foreground mt-1">
                Active plans
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Revenue Trend</CardTitle>
              <TrendingUp className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">+12%</div>
              <p className="text-base text-muted-foreground mt-1">
                This month
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
            <TabsTrigger value="subscriptions" className="text-base">
              Subscriptions
            </TabsTrigger>
            <TabsTrigger value="credits" className="text-base">
              Credits
            </TabsTrigger>
            <TabsTrigger value="payments" className="text-base">
              Payments
            </TabsTrigger>
            <TabsTrigger value="settings" className="text-base">
              Settings
            </TabsTrigger>
          </TabsList>

          {/* Overview Tab */}
          <TabsContent value="overview" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Revenue Breakdown</CardTitle>
                <CardDescription className="text-lg">Revenue by type</CardDescription>
              </CardHeader>
              <CardContent>
                {revenue?.revenue_by_type ? (
                  <div className="space-y-2">
                    {Object.entries(revenue.revenue_by_type).map(([type, amount]) => (
                      <div key={type} className="flex justify-between items-center p-3 border rounded-lg">
                        <span className="text-base font-medium capitalize">{type.replace("_", " ")}</span>
                        <span className="text-base font-bold">฿{Number(amount).toLocaleString()}</span>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-base text-muted-foreground">No revenue data available</p>
                )}
              </CardContent>
            </Card>
          </TabsContent>

          {/* Subscriptions Tab */}
          <TabsContent value="subscriptions" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Subscription Plans</CardTitle>
                <CardDescription className="text-lg">Manage subscription plans</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {plans.map((plan) => (
                    <Card key={plan.id}>
                      <CardHeader>
                        <div className="flex justify-between items-start">
                          <div>
                            <CardTitle className="text-xl font-bold">{plan.name}</CardTitle>
                            <CardDescription className="text-base">{plan.description}</CardDescription>
                          </div>
                          <div className="text-right">
                            {plan.price_monthly && (
                              <div className="text-xl font-bold">฿{plan.price_monthly}/month</div>
                            )}
                            {plan.price_yearly && (
                              <div className="text-base text-muted-foreground">฿{plan.price_yearly}/year</div>
                            )}
                          </div>
                        </div>
                      </CardHeader>
                      <CardContent>
                        <div className="space-y-2">
                          <div className="text-base">
                            <strong>Features:</strong> {JSON.stringify(plan.features)}
                          </div>
                          <div className="text-base">
                            <strong>Credits Included:</strong> {plan.credit_included}
                          </div>
                          <div className="text-base">
                            <strong>Status:</strong> {plan.status}
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Credits Tab */}
          <TabsContent value="credits" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Credit System</CardTitle>
                <CardDescription className="text-lg">Manage credit packages and pricing</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <Card>
                      <CardHeader>
                        <CardTitle className="text-lg font-semibold">100 Credits</CardTitle>
                      </CardHeader>
                      <CardContent>
                        <div className="text-3xl font-bold mb-2">฿50</div>
                        <Button className="w-full">Purchase</Button>
                      </CardContent>
                    </Card>
                    <Card>
                      <CardHeader>
                        <CardTitle className="text-lg font-semibold">500 Credits</CardTitle>
                      </CardHeader>
                      <CardContent>
                        <div className="text-3xl font-bold mb-2">฿200</div>
                        <div className="text-base text-muted-foreground mb-2">20% off</div>
                        <Button className="w-full">Purchase</Button>
                      </CardContent>
                    </Card>
                    <Card>
                      <CardHeader>
                        <CardTitle className="text-lg font-semibold">1000 Credits</CardTitle>
                      </CardHeader>
                      <CardContent>
                        <div className="text-3xl font-bold mb-2">฿350</div>
                        <div className="text-base text-muted-foreground mb-2">30% off</div>
                        <Button className="w-full">Purchase</Button>
                      </CardContent>
                    </Card>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Payments Tab */}
          <TabsContent value="payments" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Payment Transactions</CardTitle>
                <CardDescription className="text-lg">View and manage payment transactions</CardDescription>
              </CardHeader>
              <CardContent>
                <p className="text-base text-muted-foreground">Payment transaction list will be displayed here</p>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Settings Tab */}
          <TabsContent value="settings" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Payment Settings</CardTitle>
                <CardDescription className="text-lg">Configure payment providers and settings</CardDescription>
              </CardHeader>
              <CardContent>
                <p className="text-base text-muted-foreground">Payment settings will be displayed here</p>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </AdminLayout>
  );
}

