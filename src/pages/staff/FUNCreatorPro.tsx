import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Image, Video, Music, Type, Sparkles, Calendar, Globe } from "lucide-react";
import { Badge } from "@/components/ui/badge";

export default function FUNCreatorPro() {
  const tools = [
    {
      icon: Image,
      title: "AI Photo Editor",
      description: "แก้ไขรูปภาพด้วย AI",
      features: ["Auto Enhancement", "Background Removal", "Style Transfer"],
    },
    {
      icon: Video,
      title: "AI Video Editor",
      description: "ตัดต่อวิดีโอ พากย์เสียง",
      features: ["Auto Cut", "AI Caption", "Transition Effects"],
    },
    {
      icon: Music,
      title: "AI Music & Podcast",
      description: "สร้างเพลงและพอดแคสต์",
      features: ["Beat Generation", "Voice Clone", "Audio Mix"],
    },
    {
      icon: Type,
      title: "AI Script Generator",
      description: "สร้างสคริปต์และโปรมต์",
      features: ["Content Ideas", "SEO Optimize", "Multi-Language"],
    },
  ];

  return (
    <AdminLayout>
      <SectionHeader
        title="🟩 FUN CREATOR PRO"
        description="เครื่องมือสร้างคอนเทนต์ระดับมืออาชีพ ขับเคลื่อนด้วย AI"
      />

      <div className="grid md:grid-cols-2 gap-6 mb-8">
        {tools.map((tool, idx) => {
          const Icon = tool.icon;
          return (
            <Card key={idx} className="card-shadow hover:card-shadow-hover transition-all">
              <CardHeader>
                <div className="flex items-center gap-3 mb-2">
                  <div className="p-3 bg-primary/10 rounded-lg">
                    <Icon className="h-6 w-6 text-primary" />
                  </div>
                  <div>
                    <CardTitle className="text-lg">{tool.title}</CardTitle>
                    <p className="text-sm text-muted-foreground">{tool.description}</p>
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                <div className="space-y-2 mb-4">
                  {tool.features.map((feature, fIdx) => (
                    <Badge key={fIdx} variant="outline" className="mr-2">
                      {feature}
                    </Badge>
                  ))}
                </div>
                <Button className="w-full btn-elderly">
                  <Sparkles className="h-4 w-4 mr-2" />
                  เปิดใช้งาน
                </Button>
              </CardContent>
            </Card>
          );
        })}
      </div>

      <div className="grid md:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Calendar className="h-5 w-5" />
              Content Calendar Sync
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-4">
              เชื่อมต่อกับ FUN Calendar เพื่อรับแผนคอนเทนต์อัตโนมัติ
            </p>
            <Button variant="outline" className="w-full">
              ดูปฏิทินคอนเทนต์
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Globe className="h-5 w-5" />
              Auto Cross-Platform Posting
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-4">
              โพสต์ไปหลายแพลตฟอร์มพร้อมกันอัตโนมัติ
            </p>
            <div className="flex gap-2">
              <Badge>Facebook</Badge>
              <Badge>Instagram</Badge>
              <Badge>YouTube</Badge>
              <Badge>TikTok</Badge>
            </div>
          </CardContent>
        </Card>
      </div>
    </AdminLayout>
  );
}
