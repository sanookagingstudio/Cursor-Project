import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Heart, Activity, Thermometer, Droplet, TrendingUp, AlertTriangle } from "lucide-react";
import { StatCard } from "@/components/cards/StatCard";

export default function FUNHealth() {
  const vitalSigns = [
    {
      icon: Heart,
      label: "Heart Rate",
      value: "72 bpm",
      status: "normal",
      color: "text-accent",
    },
    {
      icon: Activity,
      label: "Blood Pressure",
      value: "120/80",
      status: "normal",
      color: "text-accent",
    },
    {
      icon: Droplet,
      label: "O2 Saturation",
      value: "98%",
      status: "normal",
      color: "text-accent",
    },
    {
      icon: Thermometer,
      label: "Temperature",
      value: "36.8°C",
      status: "normal",
      color: "text-accent",
    },
  ];

  const healthAlerts = [
    {
      severity: "warning",
      member: "คุณสมชาย ใจดี",
      issue: "ความดันโลหิตสูงเล็กน้อย",
      value: "145/90",
      time: "2 ชม. ที่แล้ว",
    },
    {
      severity: "info",
      member: "คุณสุดา รักสุขภาพ",
      issue: "ต้องตรวจน้ำตาลในเลือด",
      value: "Due today",
      time: "วันนี้",
    },
  ];

  return (
    <AdminLayout>
      <SectionHeader
        title="🟩 FUN HEALTH - Health Intelligence"
        description="ระบบติดตามสุขภาพอัจฉริยะ รองรับ Smart Devices"
      />

      <div className="grid md:grid-cols-4 gap-6 mb-8">
        {vitalSigns.map((vital, idx) => {
          const Icon = vital.icon;
          return (
            <Card key={idx}>
              <CardHeader className="pb-3">
                <div className="flex items-center justify-between">
                  <Icon className={`h-5 w-5 ${vital.color}`} />
                  <Badge variant="outline" className="bg-accent/10 text-accent">
                    {vital.status}
                  </Badge>
                </div>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-muted-foreground mb-1">{vital.label}</p>
                <p className="text-2xl font-bold">{vital.value}</p>
              </CardContent>
            </Card>
          );
        })}
      </div>

      <div className="grid lg:grid-cols-2 gap-6 mb-8">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <TrendingUp className="h-5 w-5 text-primary" />
              AI Health Risk Detection
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              <div className="p-3 bg-accent/10 rounded-lg">
                <p className="text-sm font-medium text-accent">✓ No Critical Risks Detected</p>
                <p className="text-xs text-muted-foreground mt-1">
                  AI วิเคราะห์ว่าผู้สูงอายุทั้งหมดอยู่ในสภาวะปกติ
                </p>
              </div>
              <div className="p-3 bg-orange-500/10 rounded-lg">
                <p className="text-sm font-medium text-orange-600">⚠ 2 Members Need Attention</p>
                <p className="text-xs text-muted-foreground mt-1">
                  มีสมาชิก 2 คนต้องติดตามอาการเพิ่มเติม
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <AlertTriangle className="h-5 w-5 text-orange-500" />
              Health Alerts
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {healthAlerts.map((alert, idx) => (
                <div key={idx} className="p-3 border rounded-lg">
                  <div className="flex items-start justify-between mb-2">
                    <div>
                      <p className="font-medium text-sm">{alert.member}</p>
                      <p className="text-sm text-muted-foreground">{alert.issue}</p>
                    </div>
                    <Badge
                      variant={alert.severity === "warning" ? "destructive" : "outline"}
                      className="shrink-0"
                    >
                      {alert.value}
                    </Badge>
                  </div>
                  <p className="text-xs text-muted-foreground">{alert.time}</p>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Smart Device Integration</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid md:grid-cols-4 gap-4">
            <div className="p-4 border rounded-lg text-center">
              <p className="font-medium mb-1">Smart Watch</p>
              <Badge className="bg-accent/10 text-accent">5 Connected</Badge>
            </div>
            <div className="p-4 border rounded-lg text-center">
              <p className="font-medium mb-1">Oximeter</p>
              <Badge className="bg-accent/10 text-accent">8 Connected</Badge>
            </div>
            <div className="p-4 border rounded-lg text-center">
              <p className="font-medium mb-1">BP Cuff</p>
              <Badge className="bg-accent/10 text-accent">6 Connected</Badge>
            </div>
            <div className="p-4 border rounded-lg text-center">
              <p className="font-medium mb-1">Thermometer</p>
              <Badge className="bg-accent/10 text-accent">4 Connected</Badge>
            </div>
          </div>
        </CardContent>
      </Card>
    </AdminLayout>
  );
}
