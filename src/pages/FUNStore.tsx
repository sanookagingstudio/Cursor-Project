import { PublicLayout } from "@/layouts/PublicLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { ShoppingCart, Download, Image, Music, FileText, BookOpen } from "lucide-react";

export default function FUNStore() {
  const products = [
    {
      id: 1,
      title: "ชุดกิจกรรมผู้สูงอายุ - Basic",
      category: "Activity Pack",
      price: "฿299",
      icon: FileText,
      type: "digital",
    },
    {
      id: 2,
      title: "ชุดเพลงบำบัดเพื่อสุขภาพ",
      category: "Music Pack",
      price: "฿499",
      icon: Music,
      type: "digital",
    },
    {
      id: 3,
      title: "Stock Photos - Active Aging",
      category: "Photos",
      price: "฿599",
      icon: Image,
      type: "digital",
    },
    {
      id: 4,
      title: "คอร์สดูแลผู้สูงอายุเบื้องต้น",
      category: "Course",
      price: "฿1,990",
      icon: BookOpen,
      type: "course",
    },
  ];

  return (
    <PublicLayout>
      <div className="container-padding section-padding">
        <SectionHeader
          title="FUN Store"
          description="ดิจิทัลคอนเทนต์คุณภาพสูง สำหรับทุกคน"
        />

        <Tabs defaultValue="all" className="mb-8">
          <TabsList className="grid w-full max-w-xl mx-auto grid-cols-5">
            <TabsTrigger value="all">ทั้งหมด</TabsTrigger>
            <TabsTrigger value="digital">Digital</TabsTrigger>
            <TabsTrigger value="pod">POD</TabsTrigger>
            <TabsTrigger value="music">Music</TabsTrigger>
            <TabsTrigger value="course">Course</TabsTrigger>
          </TabsList>

          <TabsContent value="all" className="mt-8">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {products.map((product) => (
                <Card key={product.id} className="card-shadow hover:card-shadow-hover transition-all">
                  <CardHeader>
                    <div className="h-40 bg-muted rounded-lg flex items-center justify-center mb-4">
                      <product.icon className="h-16 w-16 text-muted-foreground" />
                    </div>
                    <CardTitle className="text-lg">{product.title}</CardTitle>
                    <Badge variant="outline" className="w-fit">
                      {product.category}
                    </Badge>
                  </CardHeader>
                  <CardContent>
                    <p className="text-2xl font-bold text-primary">{product.price}</p>
                  </CardContent>
                  <CardFooter className="flex gap-2">
                    <Button className="flex-1 btn-elderly">
                      <ShoppingCart className="h-4 w-4 mr-2" />
                      เพิ่มลงตะกร้า
                    </Button>
                    <Button variant="outline" size="icon">
                      <Download className="h-4 w-4" />
                    </Button>
                  </CardFooter>
                </Card>
              ))}
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </PublicLayout>
  );
}
