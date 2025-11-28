import { PublicLayout } from "@/layouts/PublicLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { MediaCard } from "@/components/cards/MediaCard";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useTranslation } from "react-i18next";

export default function MediaLibrary() {
  const { t } = useTranslation();

  const videos = [
    { title: "Morning Stretches for Seniors", description: "Gentle exercises to start your day", type: "video" as const, duration: "15 min", category: "Exercise" },
    { title: "Cooking Healthy Thai Food", description: "Learn to make nutritious Thai dishes", type: "video" as const, duration: "20 min", category: "Lifestyle" },
    { title: "Memory Games & Brain Training", description: "Fun activities for cognitive health", type: "video" as const, duration: "12 min", category: "Wellness" },
    { title: "Traditional Dance Class", description: "Learn Thai dance movements", type: "video" as const, duration: "25 min", category: "Activity" },
  ];

  const podcasts = [
    { title: "Stories from Ayutthaya", description: "Historical tales from ancient Thailand", type: "podcast" as const, duration: "30 min", category: "Culture" },
    { title: "Health Tips for Active Aging", description: "Expert advice for healthy living", type: "podcast" as const, duration: "25 min", category: "Health" },
    { title: "Thai Wisdom & Life Lessons", description: "Traditional wisdom for modern life", type: "podcast" as const, duration: "35 min", category: "Wisdom" },
  ];

  const articles = [
    { title: "5 Benefits of Daily Walking", description: "Why walking is the best exercise", type: "article" as const, duration: "5 min read", category: "Health" },
    { title: "Understanding Thai Herbal Medicine", description: "Ancient healing practices", type: "article" as const, duration: "8 min read", category: "Wellness" },
    { title: "Social Connection for Healthy Aging", description: "The importance of community", type: "article" as const, duration: "6 min read", category: "Lifestyle" },
  ];

  return (
    <PublicLayout>
      <div className="section-padding bg-gradient-warm">
        <div className="max-w-7xl mx-auto container-padding">
          <SectionHeader
            title={t('mediaLibraryPage.title')}
            description={t('mediaLibraryPage.description')}
          />

          <Tabs defaultValue="all" className="mb-8">
            <TabsList>
              <TabsTrigger value="all">{t('mediaLibraryPage.allContent')}</TabsTrigger>
              <TabsTrigger value="videos">{t('mediaLibraryPage.videos')}</TabsTrigger>
              <TabsTrigger value="podcasts">{t('mediaLibraryPage.podcasts')}</TabsTrigger>
              <TabsTrigger value="articles">{t('mediaLibraryPage.articles')}</TabsTrigger>
            </TabsList>

            <TabsContent value="all" className="space-y-8 mt-8">
              <div>
                <h3 className="mb-4">{t('mediaLibraryPage.videos')}</h3>
                <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
                  {videos.map((item) => (
                    <MediaCard key={item.title} {...item} />
                  ))}
                </div>
              </div>

              <div>
                <h3 className="mb-4">{t('mediaLibraryPage.podcasts')}</h3>
                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {podcasts.map((item) => (
                    <MediaCard key={item.title} {...item} />
                  ))}
                </div>
              </div>

              <div>
                <h3 className="mb-4">{t('mediaLibraryPage.articles')}</h3>
                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {articles.map((item) => (
                    <MediaCard key={item.title} {...item} />
                  ))}
                </div>
              </div>
            </TabsContent>

            <TabsContent value="videos" className="mt-8">
              <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
                {videos.map((item) => (
                  <MediaCard key={item.title} {...item} />
                ))}
              </div>
            </TabsContent>

            <TabsContent value="podcasts" className="mt-8">
              <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                {podcasts.map((item) => (
                  <MediaCard key={item.title} {...item} />
                ))}
              </div>
            </TabsContent>

            <TabsContent value="articles" className="mt-8">
              <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                {articles.map((item) => (
                  <MediaCard key={item.title} {...item} />
                ))}
              </div>
            </TabsContent>
          </Tabs>
        </div>
      </div>
    </PublicLayout>
  );
}
