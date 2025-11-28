import { PublicLayout } from "@/layouts/PublicLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Calendar } from "@/components/ui/calendar";
import { useState } from "react";
import { Sparkles, CalendarDays, TrendingUp } from "lucide-react";

export default function FUNCalendar() {
  const [date, setDate] = useState<Date | undefined>(new Date());

  const events = [
    {
      date: "2024-03-15",
      title: "เช้า: กิจกรรมโยคะผู้สูงอายุ",
      type: "session",
      time: "09:00 - 11:00",
    },
    {
      date: "2024-03-15",
      title: "บ่าย: ทริปเยี่ยมชมพิพิธภัณฑ์",
      type: "trip",
      time: "14:00 - 17:00",
    },
    {
      date: "2024-03-20",
      title: "วันสงกรานต์",
      type: "holiday-th",
      time: "All Day",
    },
    {
      date: "2024-03-25",
      title: "🌍 Trend: International Day of Happiness",
      type: "trend",
      time: "AI Detected",
    },
  ];

  const getEventColor = (type: string) => {
    switch (type) {
      case "session":
        return "bg-accent/10 text-accent";
      case "trip":
        return "bg-primary/10 text-primary";
      case "holiday-th":
        return "bg-secondary/10 text-secondary";
      case "trend":
        return "bg-purple-500/10 text-purple-600";
      default:
        return "bg-muted";
    }
  };

  return (
    <PublicLayout>
      <div className="container-padding section-padding">
        <SectionHeader
          title="FUN Calendar - ปฏิทินอัจฉริยะ"
          description="ระบบปฏิทินที่ขับเคลื่อนด้วย AI ตรวจจับเทรนด์โลก และวางแผนคอนเทนต์อัตโนมัติ"
        />

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Calendar */}
          <Card className="lg:col-span-2">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <CalendarDays className="h-5 w-5" />
                ปฏิทิน FUN Studio
              </CardTitle>
            </CardHeader>
            <CardContent>
              <Calendar
                mode="single"
                selected={date}
                onSelect={setDate}
                className="rounded-md border"
              />
            </CardContent>
          </Card>

          {/* Events List */}
          <div className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Sparkles className="h-5 w-5 text-primary" />
                  กิจกรรมและเทรนด์
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {events.map((event, idx) => (
                  <div
                    key={idx}
                    className="p-3 rounded-lg border bg-card hover:shadow-soft transition-shadow"
                  >
                    <div className="flex items-start justify-between mb-2">
                      <h4 className="font-medium text-sm">{event.title}</h4>
                      <Badge className={getEventColor(event.type)} variant="outline">
                        {event.type}
                      </Badge>
                    </div>
                    <p className="text-xs text-muted-foreground">{event.time}</p>
                  </div>
                ))}
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <TrendingUp className="h-5 w-5 text-purple-500" />
                  AI Trend Detection
                </CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-muted-foreground mb-3">
                  ระบบ AI ตรวจจับเทรนด์ล่วงหน้า 3-6 เดือน และส่งไปยัง FUN Creator อัตโนมัติ
                </p>
                <Badge className="bg-purple-500/10 text-purple-600">
                  15 เทรนด์ถูกเพิ่มเข้า Calendar
                </Badge>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </PublicLayout>
  );
}
