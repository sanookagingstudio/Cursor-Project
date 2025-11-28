import { MemberLayout } from "@/layouts/MemberLayout";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Image, Video, Music, Sparkles, ArrowRight } from "lucide-react";
import { Link } from "react-router-dom";

export default function MediaCreator() {
  const tools = [
    {
      icon: Image,
      title: "Image Editor",
      description: "สร้างและแก้ไขภาพด้วย AI",
      path: "/admin/image-editor",
      features: ["Generate Images", "Edit Images", "Remove Background", "Upscale", "Templates"],
      color: "bg-blue-500",
    },
    {
      icon: Video,
      title: "Video Editor",
      description: "สร้างและแก้ไขวิดีโอด้วย AI",
      path: "/admin/video-editor",
      features: ["Generate Videos", "Edit Videos", "Multi Export", "Subtitle Generation"],
      color: "bg-purple-500",
    },
    {
      icon: Music,
      title: "Music Lab",
      description: "สร้างและแก้ไขเพลงด้วย AI",
      path: "/admin/music-lab",
      features: ["Generate Music", "Stem Separation", "Music Analysis", "Tab Generation", "Remaster"],
      color: "bg-pink-500",
    },
  ];

  return (
    <MemberLayout>
      <div className="container-padding space-y-6">
        <div>
          <h1 className="text-5xl font-bold mb-2">🎨 Media Creator</h1>
          <p className="text-2xl text-muted-foreground">
            สร้างและแก้ไขภาพ, วิดีโอ, และเพลงด้วย AI
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {tools.map((tool) => (
            <Card key={tool.title} className="hover:shadow-lg transition-shadow">
              <CardHeader>
                <div className={`w-16 h-16 rounded-lg ${tool.color} flex items-center justify-center mb-4`}>
                  <tool.icon className="h-8 w-8 text-white" />
                </div>
                <CardTitle className="text-2xl font-bold">{tool.title}</CardTitle>
                <CardDescription className="text-lg">{tool.description}</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <div className="text-base font-semibold">Features:</div>
                  <ul className="list-disc list-inside space-y-1 text-base text-muted-foreground">
                    {tool.features.map((feature, idx) => (
                      <li key={idx}>{feature}</li>
                    ))}
                  </ul>
                </div>
                <Button asChild className="w-full text-base" size="lg">
                  <Link to={tool.path}>
                    เปิดใช้งาน <ArrowRight className="ml-2 h-4 w-4" />
                  </Link>
                </Button>
              </CardContent>
            </Card>
          ))}
        </div>

        <Card className="mt-8">
          <CardHeader>
            <CardTitle className="text-2xl font-bold">💡 วิธีใช้งาน</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4 text-base">
            <div>
              <div className="font-semibold mb-2">1. Image Editor</div>
              <p className="text-muted-foreground">
                - สร้างภาพด้วย AI จากคำอธิบาย (Prompt)
                - แก้ไขภาพ (ลบพื้นหลัง, เพิ่มความละเอียด, ใส่สี)
                - ใช้ Templates สำหรับการออกแบบ
                - ประมวลผลหลายภาพพร้อมกัน (Batch Processing)
              </p>
            </div>
            <div>
              <div className="font-semibold mb-2">2. Video Editor</div>
              <p className="text-muted-foreground">
                - สร้างวิดีโอด้วย AI จากคำอธิบาย
                - แก้ไขวิดีโอ (Auto-edit, เพิ่ม Effects, ตัดต่อ)
                - Export หลายรูปแบบ (YouTube, TikTok, Instagram, Facebook)
                - สร้าง Subtitle อัตโนมัติ
              </p>
            </div>
            <div>
              <div className="font-semibold mb-2">3. Music Lab</div>
              <p className="text-muted-foreground">
                - สร้างเพลงด้วย AI จากคำอธิบาย
                - แยก Stem (Vocals, Drums, Bass, Other Instruments)
                - วิเคราะห์เพลง (BPM, Key, Genre, Mood)
                - สร้าง Tab (Guitar, Piano, etc.)
                - Remaster เพลง
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    </MemberLayout>
  );
}

