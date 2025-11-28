import { PublicLayout } from "@/layouts/PublicLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useTranslation } from "react-i18next";

export default function Gallery() {
  const { t } = useTranslation();

  const categories = [
    { name: t('galleryPage.activities'), count: 24 },
    { name: t('galleryPage.trips'), count: 18 },
    { name: t('galleryPage.events'), count: 12 },
    { name: t('galleryPage.facilities'), count: 8 },
  ];

  const images = Array.from({ length: 12 }, (_, i) => ({
    id: i + 1,
    title: `Memory ${i + 1}`,
    category: categories[i % 4].name,
    date: "2024",
  }));

  return (
    <PublicLayout>
      <div className="section-padding bg-gradient-warm">
        <div className="max-w-7xl mx-auto container-padding">
          <SectionHeader
            title={t('galleryPage.title')}
            description={t('galleryPage.description')}
          />

          <Tabs defaultValue="all" className="mb-8">
            <TabsList>
              <TabsTrigger value="all">{t('galleryPage.allPhotos')}</TabsTrigger>
              {categories.map((cat) => (
                <TabsTrigger key={cat.name} value={cat.name.toLowerCase()}>
                  {cat.name}
                </TabsTrigger>
              ))}
            </TabsList>

            <TabsContent value="all" className="mt-8">
              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                {images.map((img) => (
                  <Card
                    key={img.id}
                    className="overflow-hidden hover:shadow-lg transition-shadow cursor-pointer"
                  >
                    <div className="aspect-square bg-muted flex items-center justify-center">
                      <span className="text-muted-foreground text-sm">{img.title}</span>
                    </div>
                    <div className="p-3">
                      <Badge variant="secondary" className="text-xs">
                        {img.category}
                      </Badge>
                    </div>
                  </Card>
                ))}
              </div>
            </TabsContent>

            {categories.map((cat) => (
              <TabsContent key={cat.name} value={cat.name.toLowerCase()} className="mt-8">
                <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                  {images
                    .filter((img) => img.category === cat.name)
                    .map((img) => (
                      <Card
                        key={img.id}
                        className="overflow-hidden hover:shadow-lg transition-shadow cursor-pointer"
                      >
                        <div className="aspect-square bg-muted flex items-center justify-center">
                          <span className="text-muted-foreground text-sm">{img.title}</span>
                        </div>
                        <div className="p-3">
                          <Badge variant="secondary" className="text-xs">
                            {img.category}
                          </Badge>
                        </div>
                      </Card>
                    ))}
                </div>
              </TabsContent>
            ))}
          </Tabs>
        </div>
      </div>
    </PublicLayout>
  );
}
