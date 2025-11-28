import { Button } from "@/components/ui/button";
import { useNavigate } from "react-router-dom";
import { ArrowLeft } from "lucide-react";

export default function FontPreview() {
  const navigate = useNavigate();

  const fontPairs = [
    {
      name: "Pridi + Sarabun",
      heading: "Pridi",
      body: "Sarabun",
      description: "หรูหรา เรียบง่าย มีความคลาสสิก เหมาะสำหรับแบรนด์ที่ต้องการความน่าเชื่อถือ",
      thSample: "ฟันเอจิ้ง สตูดิโอ - ผู้นำด้านการท่องเที่ยวเชิงสุขภาพสำหรับผู้สูงอายุ",
      enSample: "FunAging Studio - Leading Active Aging Platform in Asia",
    },
    {
      name: "Charm + Prompt",
      heading: "Charm",
      body: "Prompt",
      description: "มีเอกลักษณ์ ดูอบอุ่น มีกลิ่นอายล้านนาที่ชัดเจน แต่ยังอ่านง่าย",
      thSample: "สนุกกับการใช้ชีวิตวัยทอง ด้วยกิจกรรมและทริปท่องเที่ยวที่ออกแบบมาเป็นพิเศษ",
      enSample: "Enjoy Your Golden Years with Specially Designed Activities and Trips",
    },
    {
      name: "Bai Jamjuree + IBM Plex Sans Thai",
      heading: "Bai Jamjuree",
      body: "IBM Plex Sans Thai",
      description: "ทันสมัย สะอาดตา เป็นมิตรกับผู้ใช้ เหมาะสำหรับแพลตฟอร์มดิจิทัล",
      thSample: "เทคโนโลยี AI ช่วยดูแลสุขภาพและความปลอดภัยของคุณตลอดการเดินทาง",
      enSample: "AI Technology Ensures Your Health and Safety Throughout the Journey",
    },
    {
      name: "Kodchasan + Kanit",
      heading: "Kodchasan",
      body: "Kanit",
      description: "กลมมน อ่านง่าย เป็นมิตร เหมาะสำหรับผู้สูงอายุที่ต้องการความชัดเจน",
      thSample: "ร่วมเดินทางไปกับเราสู่ประสบการณ์ที่น่าจดจำ ปลอดภัย และเต็มไปด้วยความสุข",
      enSample: "Join Us for Memorable, Safe, and Joyful Experiences",
    },
  ];

  return (
    <div className="min-h-screen bg-background">
      <div className="container-padding section-padding max-w-7xl mx-auto">
        <Button
          variant="ghost"
          onClick={() => navigate(-1)}
          className="mb-8"
        >
          <ArrowLeft className="h-4 w-4 mr-2" />
          กลับ
        </Button>

        <div className="text-center mb-16">
          <h1 className="text-4xl font-bold mb-4">ตัวอย่างฟอนต์</h1>
          <p className="text-xl text-muted-foreground">
            เลือกฟอนต์ที่เหมาะสมกับแบรนด์ FunAging Studio
          </p>
        </div>

        <div className="space-y-16">
          {fontPairs.map((pair, index) => (
            <div
              key={index}
              className="border rounded-2xl p-8 bg-card card-shadow"
            >
              <div className="mb-6">
                <h2 className="text-2xl font-bold mb-2">{pair.name}</h2>
                <p className="text-muted-foreground">{pair.description}</p>
                <p className="text-sm text-muted-foreground mt-2">
                  หัวข้อ: {pair.heading} | เนื้อหา: {pair.body}
                </p>
              </div>

              <div className="space-y-8">
                {/* Heading Sample */}
                <div>
                  <p className="text-xs uppercase tracking-wider text-muted-foreground mb-2">
                    ตัวอย่างหัวข้อ (Heading)
                  </p>
                  <h3
                    className="text-4xl md:text-5xl mb-4"
                    style={{ fontFamily: pair.heading }}
                  >
                    FunAging Studio
                  </h3>
                  <h3
                    className="text-4xl md:text-5xl"
                    style={{ fontFamily: pair.heading }}
                  >
                    ฟันเอจิ้ง สตูดิโอ
                  </h3>
                </div>

                {/* Body Sample - Thai */}
                <div>
                  <p className="text-xs uppercase tracking-wider text-muted-foreground mb-2">
                    ตัวอย่างเนื้อหา (Thai)
                  </p>
                  <p
                    className="text-xl leading-relaxed"
                    style={{ fontFamily: pair.body }}
                  >
                    {pair.thSample}
                  </p>
                  <p
                    className="text-base leading-relaxed mt-4 text-muted-foreground"
                    style={{ fontFamily: pair.body }}
                  >
                    เราเชื่อว่าผู้สูงอายุทุกคนสมควรได้รับประสบการณ์ท่องเที่ยวที่มีคุณภาพ
                    ปลอดภัย และเหมาะสมกับสภาพร่างกาย ด้วยทีมงานมืออาชีพและเทคโนโลยี AI
                    ที่ช่วยดูแลสุขภาพตลอดการเดินทาง
                  </p>
                </div>

                {/* Body Sample - English */}
                <div>
                  <p className="text-xs uppercase tracking-wider text-muted-foreground mb-2">
                    ตัวอย่างเนื้อหา (English)
                  </p>
                  <p
                    className="text-xl leading-relaxed"
                    style={{ fontFamily: pair.body }}
                  >
                    {pair.enSample}
                  </p>
                  <p
                    className="text-base leading-relaxed mt-4 text-muted-foreground"
                    style={{ fontFamily: pair.body }}
                  >
                    We believe every elderly person deserves quality travel
                    experiences that are safe and suitable for their physical
                    condition, supported by professional team and AI technology
                    for health monitoring throughout the journey.
                  </p>
                </div>

                {/* Numbers and UI Elements */}
                <div>
                  <p className="text-xs uppercase tracking-wider text-muted-foreground mb-2">
                    ตัวเลขและองค์ประกอบ UI
                  </p>
                  <div
                    className="text-3xl font-bold mb-2"
                    style={{ fontFamily: pair.heading }}
                  >
                    ฿12,500 | 1,234 Members | 98.5%
                  </div>
                  <div className="flex gap-4 mt-4">
                    <Button style={{ fontFamily: pair.body }}>
                      จองทริปตอนนี้
                    </Button>
                    <Button variant="outline" style={{ fontFamily: pair.body }}>
                      ดูรายละเอียด
                    </Button>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        <div className="mt-16 text-center">
          <p className="text-muted-foreground mb-4">
            หลังจากเลือกฟอนต์ที่ต้องการแล้ว กรุณาแจ้งให้ทีมทราบเพื่ออัปเดตในระบบ
          </p>
        </div>
      </div>
    </div>
  );
}
