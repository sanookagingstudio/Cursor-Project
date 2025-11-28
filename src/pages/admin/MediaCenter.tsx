import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { ActionBar } from "@/components/ui/action-bar";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Calendar, Play, FileText } from "lucide-react";
import { useTranslation } from "react-i18next";

export default function MediaCenter() {
  const { t } = useTranslation();
  const scheduled = [
    { title: "Morning Exercise Video", type: "Video", date: "2024-03-20", platform: "YouTube" },
    { title: "Healthy Cooking Tips", type: "Article", date: "2024-03-22", platform: "Website" },
  ];

  const drafts = [
    { title: "Thai Wisdom Podcast", type: "Podcast", updated: "2 hours ago" },
    { title: "Trip Highlight Reel", type: "Video", updated: "1 day ago" },
  ];

  const published = [
    { title: "Morning Tai Chi Tutorial", type: "Video", date: "2024-03-15", views: "2.5K" },
    { title: "Health Benefits of Walking", type: "Article", date: "2024-03-10", views: "1.8K" },
  ];

  return (
    <AdminLayout>
      <SectionHeader
        title={t("admin.mediaCenter.title")}
        description={t("admin.mediaCenter.description")}
      />

      <ActionBar
        actions={[
          { type: "add", label: t("admin.mediaCenter.createContent") },
          { type: "import", label: t("admin.mediaCenter.uploadMedia") },
          { type: "refresh" },
        ]}
        className="mb-6"
      />

      <Tabs defaultValue="calendar">
        <TabsList>
          <TabsTrigger value="calendar">{t("admin.mediaCenter.contentCalendar")}</TabsTrigger>
          <TabsTrigger value="drafts">{t("admin.mediaCenter.drafts")}</TabsTrigger>
          <TabsTrigger value="published">{t("admin.mediaCenter.published")}</TabsTrigger>
        </TabsList>

        <TabsContent value="calendar" className="mt-6 space-y-4">
          {scheduled.map((item) => (
            <Card key={item.title}>
              <CardContent className="flex items-center justify-between p-6">
                <div className="flex items-center gap-4">
                  <Play className="h-8 w-8 text-primary" />
                  <div>
                    <h4 className="font-semibold">{item.title}</h4>
                    <p className="text-sm text-muted-foreground">
                      {item.date} • {item.platform}
                    </p>
                  </div>
                </div>
                <Badge>{t("admin.mediaCenter.scheduled")}</Badge>
              </CardContent>
            </Card>
          ))}
        </TabsContent>

        <TabsContent value="drafts" className="mt-6 space-y-4">
          {drafts.map((item) => (
            <Card key={item.title}>
              <CardContent className="flex items-center justify-between p-6">
                <div className="flex items-center gap-4">
                  <FileText className="h-8 w-8 text-muted-foreground" />
                  <div>
                    <h4 className="font-semibold">{item.title}</h4>
                    <p className="text-sm text-muted-foreground">{t("admin.mediaCenter.updated")} {item.updated}</p>
                  </div>
                </div>
                <Badge variant="outline">{t("admin.mediaCenter.draft")}</Badge>
              </CardContent>
            </Card>
          ))}
        </TabsContent>

        <TabsContent value="published" className="mt-6 space-y-4">
          {published.map((item) => (
            <Card key={item.title}>
              <CardContent className="flex items-center justify-between p-6">
                <div className="flex items-center gap-4">
                  <Play className="h-8 w-8 text-secondary" />
                  <div>
                    <h4 className="font-semibold">{item.title}</h4>
                    <p className="text-sm text-muted-foreground">
                      {item.date} • {item.views} {t("admin.mediaCenter.views")}
                    </p>
                  </div>
                </div>
                <Badge variant="secondary">{t("admin.mediaCenter.published")}</Badge>
              </CardContent>
            </Card>
          ))}
        </TabsContent>
      </Tabs>
    </AdminLayout>
  );
}
