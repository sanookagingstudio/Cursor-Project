import { PublicLayout } from "@/layouts/PublicLayout";
import { HeroSection } from "@/components/sections/HeroSection";
import { FeatureGrid } from "@/components/sections/FeatureGrid";
import { Heart, Award, Users, Shield, Sparkles, Target } from "lucide-react";
import { useTranslation } from "react-i18next";

const About = () => {
  const { t } = useTranslation();

  const values = [
    {
      icon: Heart,
      title: t('about.values.care.title'),
      description: t('about.values.care.description'),
    },
    {
      icon: Shield,
      title: t('about.values.safety.title'),
      description: t('about.values.safety.description'),
    },
    {
      icon: Users,
      title: t('about.values.community.title'),
      description: t('about.values.community.description'),
    },
    {
      icon: Award,
      title: t('about.values.excellence.title'),
      description: t('about.values.excellence.description'),
    },
    {
      icon: Sparkles,
      title: t('about.values.joy.title'),
      description: t('about.values.joy.description'),
    },
    {
      icon: Target,
      title: t('about.values.wellness.title'),
      description: t('about.values.wellness.description'),
    },
  ];

  return (
    <PublicLayout>
      <HeroSection
        subtitle={t('about.subtitle')}
        title={t('about.title')}
        description={t('about.description')}
        image="/placeholder.svg"
      />

      <section className="section-padding">
        <div className="container-padding max-w-4xl mx-auto space-y-8">
          <div className="prose prose-lg max-w-none">
            <h2 className="text-3xl font-bold mb-6">{t('about.mission.title')}</h2>
            <p className="text-lg text-muted-foreground leading-relaxed">
              {t('about.mission.p1')}
            </p>
            <p className="text-lg text-muted-foreground leading-relaxed">
              {t('about.mission.p2')}
            </p>
          </div>

          <div className="prose prose-lg max-w-none">
            <h2 className="text-3xl font-bold mb-6">{t('about.different.title')}</h2>
            <ul className="space-y-4 text-lg text-muted-foreground">
              <li dangerouslySetInnerHTML={{ __html: t('about.different.point1') }} />
              <li dangerouslySetInnerHTML={{ __html: t('about.different.point2') }} />
              <li dangerouslySetInnerHTML={{ __html: t('about.different.point3') }} />
              <li dangerouslySetInnerHTML={{ __html: t('about.different.point4') }} />
            </ul>
          </div>
        </div>
      </section>

      <FeatureGrid
        title={t('about.values.title')}
        description={t('about.values.description')}
        features={values}
        columns={3}
      />

      <section className="section-padding bg-muted/30">
        <div className="container-padding max-w-4xl mx-auto text-center space-y-6">
          <h2 className="text-3xl font-bold">{t('about.certification.title')}</h2>
          <p className="text-lg text-muted-foreground">
            {t('about.certification.description')}
          </p>
          <div className="flex flex-wrap justify-center gap-8 pt-8">
            <div className="text-center">
              <div className="text-4xl font-bold text-primary">{t('about.certification.stat1')}</div>
              <div className="text-muted-foreground">{t('about.certification.stat1Label')}</div>
            </div>
            <div className="text-center">
              <div className="text-4xl font-bold text-primary">{t('about.certification.stat2')}</div>
              <div className="text-muted-foreground">{t('about.certification.stat2Label')}</div>
            </div>
            <div className="text-center">
              <div className="text-4xl font-bold text-primary">{t('about.certification.stat3')}</div>
              <div className="text-muted-foreground">{t('about.certification.stat3Label')}</div>
            </div>
          </div>
        </div>
      </section>
    </PublicLayout>
  );
};

export default About;
