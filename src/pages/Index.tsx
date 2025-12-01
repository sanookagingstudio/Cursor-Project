import { PublicLayout } from "@/layouts/PublicLayout";
import { HeroSection } from "@/components/sections/HeroSection";
import { FeatureGrid } from "@/components/sections/FeatureGrid";
import { TestimonialSection } from "@/components/sections/TestimonialSection";
import { CTASection } from "@/components/sections/CTASection";
import { Heart, Shield, Users } from "lucide-react";
import { ActivityCard } from "@/components/cards/ActivityCard";
import { useTranslation } from "react-i18next";
import { useTheme } from "@/contexts/ThemeContext";

const Index = () => {
  const { t } = useTranslation();
  const { settings } = useTheme();

  // Helper to check for theme override content
  const getContent = (key: string) => {
    return settings?.content?.[key] || t(key);
  };

  // Helper to check for banner image override
  const getBannerImage = () => {
    if (settings?.banner?.enabled && settings?.banner?.imageUrl) {
      return settings.banner.imageUrl;
    }
    return "https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=2940&auto=format&fit=crop";
  };

  const features = [
    {
      icon: Heart,
      title: t('features.health.title'),
      description: t('features.health.description'),
    },
    {
      icon: Shield,
      title: t('features.safety.title'),
      description: t('features.safety.description'),
    },
    {
      icon: Users,
      title: t('features.social.title'),
      description: t('features.social.description'),
    },
  ];

  const testimonials = [
    {
      name: t('testimonials.member1.name'),
      role: t('testimonials.member1.role'),
      content: t('testimonials.member1.content'),
      rating: 5,
    },
    {
      name: t('testimonials.member2.name'),
      role: t('testimonials.member2.role'),
      content: t('testimonials.member2.content'),
      rating: 5,
    },
    {
      name: t('testimonials.member3.name'),
      role: t('testimonials.member3.role'),
      content: t('testimonials.member3.content'),
      rating: 5,
    },
  ];

  return (
    <PublicLayout>
      <HeroSection
        subtitle={getContent('hero.subtitle')}
        title={getContent('hero.title')}
        description={t('hero.description')}
        primaryCTA={{ label: t('hero.primaryCTA'), href: "/join-now" }}
        secondaryCTA={{ label: t('hero.secondaryCTA'), href: "/about" }}
        image={getBannerImage()}
      />

      <FeatureGrid
        title={t('features.title')}
        description={t('features.description')}
        features={features}
      />

      <section className="section-padding">
        <div className="container-padding w-full">
          <div className="text-center mb-12 space-y-4">
            <h2 className="text-5xl md:text-6xl font-bold">{t('activities.title')}</h2>
            <p className="text-2xl text-muted-foreground">{t('activities.description')}</p>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            <ActivityCard
              title={t('activities.morning.title')}
              description={t('activities.morning.description')}
              time={t('activities.morning.time')}
              duration={t('activities.morning.duration')}
              capacity={20}
              intensity="Low"
              tags={[t('activities.morning.tag')]}
              image="https://images.unsplash.com/photo-1571019614248-3a83737b12d5?q=80&w=2940&auto=format&fit=crop"
            />
            <ActivityCard
              title={t('activities.art.title')}
              description={t('activities.art.description')}
              time={t('activities.art.time')}
              duration={t('activities.art.duration')}
              capacity={15}
              intensity="Low"
              tags={[t('activities.art.tag')]}
              image="https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?q=80&w=2940&auto=format&fit=crop"
            />
            <ActivityCard
              title={t('activities.brain.title')}
              description={t('activities.brain.description')}
              time={t('activities.brain.time')}
              duration={t('activities.brain.duration')}
              capacity={25}
              intensity="Medium"
              tags={[t('activities.brain.tag')]}
              image="https://images.unsplash.com/photo-1611162617474-5b21e879e113?q=80&w=2940&auto=format&fit=crop"
            />
          </div>
        </div>
      </section>

      <TestimonialSection
        title={t('testimonials.title')}
        testimonials={testimonials}
      />

      <CTASection
        title={t('cta.title')}
        description={t('cta.description')}
        primaryCTA={{ label: t('cta.primaryCTA'), href: "/join-now" }}
        secondaryCTA={{ label: t('cta.secondaryCTA'), href: "/contact" }}
      />
    </PublicLayout>
  );
};

export default Index;
