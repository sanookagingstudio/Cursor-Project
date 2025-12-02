import { PublicLayout } from "@/layouts/PublicLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { MediaCard } from "@/components/cards/MediaCard";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useTranslation } from "react-i18next";
import { EditableText, Editable } from "@/components/editor/Editable";

export default function MediaLibrary() {
  const { t } = useTranslation();

  const videos = [
    { 
      title: "Morning Stretches for Seniors", 
      description: "Gentle exercises to start your day", 
      type: "video" as const, 
      duration: "15 min", 
      category: "Exercise",
      thumbnail: "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=800&auto=format&fit=crop"
    },
    { 
      title: "Cooking Healthy Thai Food", 
      description: "Learn to make nutritious Thai dishes", 
      type: "video" as const, 
      duration: "20 min", 
      category: "Lifestyle",
      thumbnail: "https://images.unsplash.com/photo-1556910103-1c02745a30bf?q=80&w=800&auto=format&fit=crop"
    },
    { 
      title: "Memory Games & Brain Training", 
      description: "Fun activities for cognitive health", 
      type: "video" as const, 
      duration: "12 min", 
      category: "Wellness",
      thumbnail: "https://images.unsplash.com/photo-1611162617474-5b21e879e113?q=80&w=800&auto=format&fit=crop"
    },
    { 
      title: "Traditional Dance Class", 
      description: "Learn Thai dance movements", 
      type: "video" as const, 
      duration: "25 min", 
      category: "Activity",
      thumbnail: "https://images.unsplash.com/photo-1515238152791-8216bfdf89a7?q=80&w=800&auto=format&fit=crop"
    },
  ];

  const podcasts = [
    { 
      title: "Stories from Ayutthaya", 
      description: "Historical tales from ancient Thailand", 
      type: "podcast" as const, 
      duration: "30 min", 
      category: "Culture",
      thumbnail: "https://images.unsplash.com/photo-1528181304800-259b08848526?q=80&w=800&auto=format&fit=crop"
    },
    { 
      title: "Health Tips for Active Aging", 
      description: "Expert advice for healthy living", 
      type: "podcast" as const, 
      duration: "25 min", 
      category: "Health",
      thumbnail: "https://images.unsplash.com/photo-1478737270239-2f02b77ac618?q=80&w=800&auto=format&fit=crop"
    },
    { 
      title: "Thai Wisdom & Life Lessons", 
      description: "Traditional wisdom for modern life", 
      type: "podcast" as const, 
      duration: "35 min", 
      category: "Wisdom",
      thumbnail: "https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?q=80&w=800&auto=format&fit=crop"
    },
  ];

  const articles = [
    { 
      title: "5 Benefits of Daily Walking", 
      description: "Why walking is the best exercise", 
      type: "article" as const, 
      duration: "5 min read", 
      category: "Health",
      thumbnail: "https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?q=80&w=800&auto=format&fit=crop"
    },
    { 
      title: "Understanding Thai Herbal Medicine", 
      description: "Ancient healing practices", 
      type: "article" as const, 
      duration: "8 min read", 
      category: "Wellness",
      thumbnail: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800&auto=format&fit=crop"
    },
    { 
      title: "Social Connection for Healthy Aging", 
      description: "The importance of community", 
      type: "article" as const, 
      duration: "6 min read", 
      category: "Lifestyle",
      thumbnail: "https://images.unsplash.com/photo-1511632765486-a01980e01a18?q=80&w=800&auto=format&fit=crop"
    },
  ];

  return (
    <PublicLayout>
      <div className="section-padding bg-gradient-warm">
        <div className="max-w-7xl mx-auto container-padding">
          <SectionHeader
            idPrefix="media.header"
            title={t('mediaLibraryPage.title')}
            description={t('mediaLibraryPage.description')}
          />

          <Tabs defaultValue="all" className="mb-8">
          <TabsList>
            <TabsTrigger value="all"><EditableText id="media.tab.all" text={t('mediaLibraryPage.allContent')} /></TabsTrigger>
            <TabsTrigger value="videos"><EditableText id="media.tab.videos" text={t('mediaLibraryPage.videos')} /></TabsTrigger>
            <TabsTrigger value="podcasts"><EditableText id="media.tab.podcasts" text={t('mediaLibraryPage.podcasts')} /></TabsTrigger>
            <TabsTrigger value="articles"><EditableText id="media.tab.articles" text={t('mediaLibraryPage.articles')} /></TabsTrigger>
          </TabsList>

            <TabsContent value="all" className="space-y-8 mt-8">
              <div>
                <EditableText id="media.section.videos" as="h3" className="mb-4" text={t('mediaLibraryPage.videos')} />
                <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
                  {videos.map((item, i) => (
                    <MediaCard key={item.title} idPrefix={`media.video.${i}`} {...item} />
                  ))}
                </div>
              </div>

              <div>
                <EditableText id="media.section.podcasts" as="h3" className="mb-4" text={t('mediaLibraryPage.podcasts')} />
                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {podcasts.map((item, i) => (
                    <MediaCard key={item.title} idPrefix={`media.podcast.${i}`} {...item} />
                  ))}
                </div>
              </div>

              <div>
                <EditableText id="media.section.articles" as="h3" className="mb-4" text={t('mediaLibraryPage.articles')} />
                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {articles.map((item, i) => (
                    <MediaCard key={item.title} idPrefix={`media.article.${i}`} {...item} />
                  ))}
                </div>
              </div>
            </TabsContent>

            <TabsContent value="videos" className="mt-8">
              <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
                {videos.map((item, i) => (
                  <MediaCard key={item.title} idPrefix={`media.video.${i}`} {...item} />
                ))}
              </div>
            </TabsContent>

            <TabsContent value="podcasts" className="mt-8">
              <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                {podcasts.map((item, i) => (
                  <MediaCard key={item.title} idPrefix={`media.podcast.${i}`} {...item} />
                ))}
              </div>
            </TabsContent>

            <TabsContent value="articles" className="mt-8">
              <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                {articles.map((item, i) => (
                  <MediaCard key={item.title} idPrefix={`media.article.${i}`} {...item} />
                ))}
              </div>
            </TabsContent>
          </Tabs>
        </div>
      </div>
    </PublicLayout>
  );
}
