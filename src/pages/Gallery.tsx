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

  const images = [
    {
      id: 1,
      title: "Morning Yoga",
      category: t('galleryPage.activities'),
      date: "2024",
      url: "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=800&auto=format&fit=crop"
    },
    {
      id: 2,
      title: "Ayutthaya Trip",
      category: t('galleryPage.trips'),
      date: "2024",
      url: "https://images.unsplash.com/photo-1528181304800-259b08848526?q=80&w=800&auto=format&fit=crop"
    },
    {
      id: 3,
      title: "Cooking Class",
      category: t('galleryPage.activities'),
      date: "2024",
      url: "https://images.unsplash.com/photo-1556910103-1c02745a30bf?q=80&w=800&auto=format&fit=crop"
    },
    {
      id: 4,
      title: "Garden Party",
      category: t('galleryPage.events'),
      date: "2024",
      url: "https://images.unsplash.com/photo-1511632765486-a01980e01a18?q=80&w=800&auto=format&fit=crop"
    },
    {
      id: 5,
      title: "Lounge Area",
      category: t('galleryPage.facilities'),
      date: "2024",
      url: "https://images.unsplash.com/photo-1617850687395-0609e3320578?q=80&w=800&auto=format&fit=crop"
    },
    {
      id: 6,
      title: "Art Workshop",
      category: t('galleryPage.activities'),
      date: "2024",
      url: "https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?q=80&w=800&auto=format&fit=crop"
    },
    {
      id: 7,
      title: "Floating Market",
      category: t('galleryPage.trips'),
      date: "2024",
      url: "https://images.unsplash.com/photo-1598232117750-1804c78f4758?q=80&w=800&auto=format&fit=crop"
    },
    {
      id: 8,
      title: "Songkran Festival",
      category: t('galleryPage.events'),
      date: "2024",
      url: "https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?q=80&w=800&auto=format&fit=crop"
    },
    {
      id: 9,
      title: "Gym & Fitness",
      category: t('galleryPage.facilities'),
      date: "2024",
      url: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=800&auto=format&fit=crop"
    },
    {
      id: 10,
      title: "Meditation Room",
      category: t('galleryPage.facilities'),
      date: "2024",
      url: "https://images.unsplash.com/photo-1545205597-3d9d02c29597?q=80&w=800&auto=format&fit=crop"
    },
    {
      id: 11,
      title: "Beach Trip",
      category: t('galleryPage.trips'),
      date: "2024",
      url: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=800&auto=format&fit=crop"
    },
    {
      id: 12,
      title: "Music Therapy",
      category: t('galleryPage.activities'),
      date: "2024",
      url: "https://images.unsplash.com/photo-1507838153414-b4b713384ebd?q=80&w=800&auto=format&fit=crop"
    }
  ];

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
                    className="overflow-hidden hover:shadow-lg transition-shadow cursor-pointer group"
                  >
                    <div className="aspect-square overflow-hidden bg-muted relative">
                      <img 
                        src={img.url} 
                        alt={img.title} 
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                      />
                      <div className="absolute inset-0 bg-black/30 flex items-end p-3 opacity-0 group-hover:opacity-100 transition-opacity">
                        <span className="text-white font-medium text-sm truncate">{img.title}</span>
                      </div>
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
                        className="overflow-hidden hover:shadow-lg transition-shadow cursor-pointer group"
                      >
                        <div className="aspect-square overflow-hidden bg-muted relative">
                          <img 
                            src={img.url} 
                            alt={img.title} 
                            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                          />
                          <div className="absolute inset-0 bg-black/30 flex items-end p-3 opacity-0 group-hover:opacity-100 transition-opacity">
                            <span className="text-white font-medium text-sm truncate">{img.title}</span>
                          </div>
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
