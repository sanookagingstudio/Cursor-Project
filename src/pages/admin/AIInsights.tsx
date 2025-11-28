import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { 
  Sparkles, 
  TrendingUp, 
  TrendingDown,
  AlertTriangle,
  Target,
  Brain,
  BarChart3,
  CheckCircle
} from "lucide-react";
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from "recharts";

export default function AIInsights() {
  const trendData = [
    { month: "Jan", members: 180, activities: 145, trips: 12, satisfaction: 4.5 },
    { month: "Feb", members: 195, activities: 160, trips: 15, satisfaction: 4.6 },
    { month: "Mar", members: 212, activities: 172, trips: 14, satisfaction: 4.7 },
    { month: "Apr", members: 228, activities: 188, trips: 16, satisfaction: 4.7 },
    { month: "May", members: 235, activities: 195, trips: 18, satisfaction: 4.8 },
    { month: "Jun", members: 248, activities: 210, trips: 20, satisfaction: 4.8 },
  ];

  const insights = [
    {
      type: "trend",
      severity: "positive",
      title: "Member Growth Accelerating",
      description: "Member registration increased by 18% this month. AI predicts continued growth if current marketing strategies continue.",
      confidence: 92,
      icon: TrendingUp,
    },
    {
      type: "alert",
      severity: "warning",
      title: "Activity Participation Declining",
      description: "Morning exercise participation dropped 12% this week. Consider adjusting schedule or format.",
      confidence: 85,
      icon: AlertTriangle,
    },
    {
      type: "recommendation",
      severity: "info",
      title: "Optimal Trip Timing Identified",
      description: "AI analysis shows trips scheduled on Wednesday-Thursday have 23% higher satisfaction rates.",
      confidence: 88,
      icon: Target,
    },
    {
      type: "prediction",
      severity: "positive",
      title: "Revenue Forecast Looking Strong",
      description: "Based on current trends, projected Q3 revenue: ฿520K (+15% vs Q2)",
      confidence: 78,
      icon: BarChart3,
    },
  ];

  const recommendations = [
    {
      category: "Member Engagement",
      suggestion: "Introduce personalized activity recommendations based on member health profiles and past participation",
      impact: "High",
      effort: "Medium"
    },
    {
      category: "Trip Planning",
      suggestion: "Create multi-day trips based on popular single-day destinations. 65% of members expressed interest in overnight trips",
      impact: "High",
      effort: "High"
    },
    {
      category: "Staff Optimization",
      suggestion: "Adjust staff scheduling - AI detected 23% over-staffing during Tuesday afternoon activities",
      impact: "Medium",
      effort: "Low"
    },
    {
      category: "Marketing",
      suggestion: "Target marketing efforts to seniors aged 65-70 in Sukhumvit area - highest conversion demographic",
      impact: "Medium",
      effort: "Low"
    },
  ];

  const memberBehavior = [
    { category: "Most Active Time", value: "10:00-11:00 AM", trend: "+5%" },
    { category: "Popular Activities", value: "Exercise & Arts", trend: "+12%" },
    { category: "Avg Stay Duration", value: "2.5 hours", trend: "+8%" },
    { category: "Repeat Rate", value: "78%", trend: "+3%" },
  ];

  return (
    <AdminLayout>
      <div className="space-y-6">
        <SectionHeader
          title="AI Insights & Analytics"
          description="Powered by FUN Sentinel - AI-driven intelligence for data-informed decisions"
        />

        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {memberBehavior.map((metric) => (
            <Card key={metric.category}>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">{metric.category}</CardTitle>
                <Brain className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{metric.value}</div>
                <div className="flex items-center gap-1 text-xs text-accent">
                  <TrendingUp className="h-3 w-3" />
                  {metric.trend} vs last period
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        <Tabs defaultValue="insights" className="space-y-4">
          <TabsList>
            <TabsTrigger value="insights">AI Insights</TabsTrigger>
            <TabsTrigger value="trends">Trend Analysis</TabsTrigger>
            <TabsTrigger value="recommendations">Recommendations</TabsTrigger>
          </TabsList>

          <TabsContent value="insights" className="space-y-4">
            <div className="grid gap-4">
              {insights.map((insight, index) => (
                <Card key={index}>
                  <CardHeader>
                    <div className="flex items-start justify-between">
                      <div className="flex items-center gap-3">
                        <div className={`p-2 rounded-lg ${
                          insight.severity === "positive" ? "bg-accent/10" :
                          insight.severity === "warning" ? "bg-orange-500/10" :
                          "bg-blue-500/10"
                        }`}>
                          <insight.icon className={`h-5 w-5 ${
                            insight.severity === "positive" ? "text-accent" :
                            insight.severity === "warning" ? "text-orange-500" :
                            "text-blue-500"
                          }`} />
                        </div>
                        <div>
                          <CardTitle className="text-lg">{insight.title}</CardTitle>
                          <Badge variant="outline" className="mt-1">
                            <Sparkles className="h-3 w-3 mr-1" />
                            {insight.confidence}% confidence
                          </Badge>
                        </div>
                      </div>
                      <Badge variant={
                        insight.severity === "positive" ? "default" :
                        insight.severity === "warning" ? "destructive" :
                        "secondary"
                      }>
                        {insight.type}
                      </Badge>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <p className="text-muted-foreground">{insight.description}</p>
                  </CardContent>
                </Card>
              ))}
            </div>
          </TabsContent>

          <TabsContent value="trends" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Growth Trends (Last 6 Months)</CardTitle>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={400}>
                  <LineChart data={trendData}>
                    <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                    <XAxis dataKey="month" className="text-xs" />
                    <YAxis className="text-xs" />
                    <Tooltip />
                    <Legend />
                    <Line type="monotone" dataKey="members" stroke="hsl(var(--primary))" strokeWidth={2} name="Members" />
                    <Line type="monotone" dataKey="activities" stroke="hsl(var(--accent))" strokeWidth={2} name="Activities" />
                    <Line type="monotone" dataKey="trips" stroke="hsl(var(--secondary))" strokeWidth={2} name="Trips" />
                  </LineChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Satisfaction Score Trend</CardTitle>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart data={trendData}>
                    <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                    <XAxis dataKey="month" className="text-xs" />
                    <YAxis domain={[0, 5]} className="text-xs" />
                    <Tooltip />
                    <Bar dataKey="satisfaction" fill="hsl(var(--accent))" name="Satisfaction (out of 5)" />
                  </BarChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="recommendations" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Target className="h-5 w-5" />
                  AI-Generated Recommendations
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                {recommendations.map((rec, index) => (
                  <div key={index} className="p-4 border rounded-lg space-y-3">
                    <div className="flex items-start justify-between">
                      <div>
                        <Badge variant="outline" className="mb-2">{rec.category}</Badge>
                        <p className="font-medium">{rec.suggestion}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-4 text-sm">
                      <div className="flex items-center gap-2">
                        <span className="text-muted-foreground">Impact:</span>
                        <Badge variant={rec.impact === "High" ? "default" : "secondary"}>
                          {rec.impact}
                        </Badge>
                      </div>
                      <div className="flex items-center gap-2">
                        <span className="text-muted-foreground">Effort:</span>
                        <Badge variant="outline">{rec.effort}</Badge>
                      </div>
                    </div>
                    <div className="flex gap-2">
                      <Button size="sm" className="btn-elderly">
                        <CheckCircle className="h-4 w-4 mr-1" />
                        Implement
                      </Button>
                      <Button size="sm" variant="outline">
                        Details
                      </Button>
                    </div>
                  </div>
                ))}
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </AdminLayout>
  );
}
