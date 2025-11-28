import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { TrendingUp, Globe, Calendar, Target, BarChart } from "lucide-react";

export default function FUNSentinel() {
  const trends = [
    {
      country: "🇹🇭 Thailand",
      interest: "Songkran Festival Activities",
      score: 95,
      forecast: "3 months",
      action: "Auto-added to Calendar",
    },
    {
      country: "🇯🇵 Japan",
      interest: "Cherry Blossom Season",
      score: 88,
      forecast: "4 months",
      action: "Content Plan Sent",
    },
    {
      country: "🇰🇷 South Korea",
      interest: "Korean BBQ Experience",
      score: 82,
      forecast: "5 months",
      action: "Pending Review",
    },
    {
      country: "🌍 Global",
      interest: "World Health Day",
      score: 90,
      forecast: "6 months",
      action: "Auto-added to Calendar",
    },
  ];

  const seoMetrics = [
    { label: "Organic Traffic", value: "+34%", change: "up" },
    { label: "Keyword Rankings", value: "127", change: "up" },
    { label: "Backlinks", value: "2,456", change: "up" },
    { label: "Domain Authority", value: "42", change: "stable" },
  ];

  return (
    <AdminLayout>
      <SectionHeader
        title="🟩 FUN SENTINEL - Trend Intelligence"
        description="AI ตรวจจับเทรนด์โลกล่วงหน้า 3-6 เดือน พร้อมวางแผนอัตโนมัติ"
      />

      <div className="grid md:grid-cols-4 gap-6 mb-8">
        {seoMetrics.map((metric, idx) => (
          <Card key={idx}>
            <CardHeader className="pb-3">
              <p className="text-sm text-muted-foreground">{metric.label}</p>
            </CardHeader>
            <CardContent>
              <div className="flex items-center justify-between">
                <p className="text-2xl font-bold">{metric.value}</p>
                <Badge
                  variant={metric.change === "up" ? "default" : "outline"}
                  className={metric.change === "up" ? "bg-accent/10 text-accent" : ""}
                >
                  {metric.change === "up" ? "↑" : "→"}
                </Badge>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      <Card className="mb-8">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Globe className="h-5 w-5 text-primary" />
            Global Trend Detection (AI-Powered)
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {trends.map((trend, idx) => (
              <div key={idx} className="flex items-center justify-between p-4 border rounded-lg">
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-2">
                    <span className="text-2xl">{trend.country.split(" ")[0]}</span>
                    <div>
                      <p className="font-semibold">{trend.interest}</p>
                      <p className="text-sm text-muted-foreground">
                        {trend.country} • Forecast: {trend.forecast}
                      </p>
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <div className="text-right">
                    <p className="text-2xl font-bold text-primary">{trend.score}</p>
                    <p className="text-xs text-muted-foreground">Interest Score</p>
                  </div>
                  <Badge
                    className={
                      trend.action.includes("Auto")
                        ? "bg-accent/10 text-accent"
                        : "bg-orange-500/10 text-orange-600"
                    }
                  >
                    {trend.action}
                  </Badge>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      <div className="grid md:grid-cols-3 gap-6">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Calendar className="h-5 w-5" />
              Calendar Integration
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-2">
              15 เทรนด์ถูกเพิ่มเข้า FUN Calendar
            </p>
            <Badge className="bg-accent/10 text-accent">Active</Badge>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Target className="h-5 w-5" />
              Content Plans Sent
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-2">
              8 แผนคอนเทนต์ส่งไปยัง FUN Creator
            </p>
            <Badge className="bg-primary/10 text-primary">In Progress</Badge>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <BarChart className="h-5 w-5" />
              Insights Dashboard
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-2">สรุปข้อมูลสำหรับ Staff</p>
            <Badge variant="outline">Updated Daily</Badge>
          </CardContent>
        </Card>
      </div>
    </AdminLayout>
  );
}
