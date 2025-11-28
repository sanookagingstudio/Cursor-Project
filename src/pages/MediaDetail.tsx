import { PublicLayout } from "@/layouts/PublicLayout";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Play, ExternalLink, Calendar, Eye, ThumbsUp, Share2 } from "lucide-react";
import { useParams } from "react-router-dom";

export default function MediaDetail() {
  const { id } = useParams();

  // Mock data - ในระบบจริงจะดึงจาก API
  const media = {
    id: id || "1",
    title: "สุขภาพดีด้วยโยคะสำหรับผู้สูงอายุ",
    type: "video",
    platform: "YouTube",
    thumbnail: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800",
    embedUrl: "https://www.youtube.com/embed/dQw4w9WgXcQ",
    publishDate: "2025-01-15",
    views: "12.5K",
    likes: "450",
    duration: "15:23",
    description: `ในวิดีโอนี้ เราจะพาคุณไปเรียนรู้ท่าโยคะง่ายๆ ที่เหมาะสำหรับผู้สูงอายุ ช่วยเพิ่มความยืดหยุ่นของร่างกาย ลดอาการปวดเมื่อย และเสริมสร้างสมดุลของร่างกาย

ท่าโยคะในวิดีโอนี้ออกแบบมาเป็นพิเศษเพื่อความปลอดภัยและเหมาะสมกับผู้สูงอายุ สามารถทำได้บนเก้าอี้หรือเสื่อโยคะ

เนื้อหาในวิดีโอ:
- 00:00 Introduction
- 02:30 การอบอุ่นร่างกาย
- 05:00 ท่าโยคะบนเก้าอี้
- 10:00 ท่าโยคะบนเสื่อ
- 14:00 การคลายกล้ามเนื้อ

คำแนะนำ:
- ทำในช่วงเวลาที่ร่างกายพร้อม
- หยุดพักเมื่อรู้สึกเหนื่อย
- หากมีโรคประจำตัวควรปรึกษาแพทย์ก่อน`,
    tags: ["โยคะ", "สุขภาพ", "ออกกำลังกาย", "ผู้สูงอายุ"],
    instructor: "อาจารย์สุดา วงศ์ประทุม",
    relatedMedia: [
      { id: "2", title: "ไทเก็กเพื่อสุขภาพ", type: "video", views: "8.2K" },
      { id: "3", title: "ดนตรีบำบัดสำหรับผู้สูงอายุ", type: "podcast", views: "5.1K" },
      { id: "4", title: "การเต้นแอโรบิคเบาๆ", type: "video", views: "10.3K" }
    ]
  };

  return (
    <PublicLayout>
      <div className="container-padding section-padding max-w-6xl mx-auto">
        {/* Video Player */}
        <div className="aspect-video bg-muted rounded-lg overflow-hidden mb-6">
          <iframe
            src={media.embedUrl}
            className="w-full h-full"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
            title={media.title}
          />
        </div>

        <div className="grid lg:grid-cols-3 gap-6">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-6">
            {/* Title & Meta */}
            <div>
              <div className="flex flex-wrap items-center gap-2 mb-3">
                <Badge>{media.type === "video" ? "Video" : "Podcast"}</Badge>
                <Badge variant="outline">{media.platform}</Badge>
                {media.tags.map((tag, i) => (
                  <Badge key={i} variant="secondary">{tag}</Badge>
                ))}
              </div>
              <h1 className="text-3xl font-bold mb-3">{media.title}</h1>
              <div className="flex flex-wrap items-center gap-4 text-sm text-muted-foreground">
                <span className="flex items-center gap-1">
                  <Calendar className="h-4 w-4" />
                  {new Date(media.publishDate).toLocaleDateString('th-TH', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                  })}
                </span>
                <span className="flex items-center gap-1">
                  <Eye className="h-4 w-4" />
                  {media.views} views
                </span>
                <span className="flex items-center gap-1">
                  <ThumbsUp className="h-4 w-4" />
                  {media.likes} likes
                </span>
                {media.duration && (
                  <span className="flex items-center gap-1">
                    <Play className="h-4 w-4" />
                    {media.duration}
                  </span>
                )}
              </div>
            </div>

            {/* Actions */}
            <div className="flex flex-wrap gap-2">
              <Button size="lg" className="btn-elderly">
                <ExternalLink className="h-5 w-5 mr-2" />
                ดูบน {media.platform}
              </Button>
              <Button size="lg" variant="outline">
                <Share2 className="h-5 w-5 mr-2" />
                แชร์
              </Button>
            </div>

            {/* Instructor */}
            <Card>
              <CardContent className="pt-6">
                <h3 className="font-semibold mb-2">ผู้สอน / ผู้นำเสนอ</h3>
                <p className="text-muted-foreground">{media.instructor}</p>
              </CardContent>
            </Card>

            {/* Description */}
            <Card>
              <CardContent className="pt-6">
                <h3 className="font-semibold mb-3">รายละเอียด</h3>
                <div className="text-muted-foreground whitespace-pre-line">
                  {media.description}
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Sidebar - Related Media */}
          <div>
            <Card>
              <CardContent className="pt-6">
                <h3 className="font-semibold mb-4">สื่ออื่นที่คุณอาจสนใจ</h3>
                <div className="space-y-4">
                  {media.relatedMedia.map((item) => (
                    <a
                      key={item.id}
                      href={`/media/${item.id}`}
                      className="block group"
                    >
                      <div className="aspect-video bg-muted rounded-lg mb-2 flex items-center justify-center group-hover:bg-muted/80 transition-colors">
                        <Play className="h-8 w-8 text-muted-foreground" />
                      </div>
                      <h4 className="font-medium text-sm group-hover:text-primary transition-colors line-clamp-2">
                        {item.title}
                      </h4>
                      <div className="flex items-center gap-2 text-xs text-muted-foreground mt-1">
                        <Badge variant="secondary" className="text-xs">{item.type}</Badge>
                        <span className="flex items-center gap-1">
                          <Eye className="h-3 w-3" />
                          {item.views}
                        </span>
                      </div>
                    </a>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </PublicLayout>
  );
}
