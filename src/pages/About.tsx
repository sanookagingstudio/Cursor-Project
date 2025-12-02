import { PublicLayout } from "@/layouts/PublicLayout";
import { HeroSection } from "@/components/sections/HeroSection";
import { FeatureGrid } from "@/components/sections/FeatureGrid";
import { Heart, Award, Users, Shield, Sparkles, Target } from "lucide-react";
import { useTranslation } from "react-i18next";
import { EditableText, Editable } from "@/components/editor/Editable";

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
        idPrefix="about.hero"
        subtitle={t('about.subtitle')}
        title={t('about.title')}
        description={t('about.description')}
        image="https://images.unsplash.com/photo-1516307365426-bea591f05011?q=80&w=2940&auto=format&fit=crop"
      />

      <section className="section-padding">
        <div className="container-padding max-w-4xl mx-auto space-y-8">
          <div className="prose prose-lg max-w-none">
            <EditableText 
              id="about.mission.title" 
              as="h2" 
              className="text-3xl font-bold mb-6" 
              text={t('about.mission.title')} 
            />
            <EditableText 
              id="about.mission.p1" 
              as="p" 
              className="text-lg text-muted-foreground leading-relaxed" 
              text={t('about.mission.p1')} 
            />
            <EditableText 
              id="about.mission.p2" 
              as="p" 
              className="text-lg text-muted-foreground leading-relaxed" 
              text={t('about.mission.p2')} 
            />
          </div>

          <div className="prose prose-lg max-w-none">
            <EditableText 
              id="about.different.title" 
              as="h2" 
              className="text-3xl font-bold mb-6" 
              text={t('about.different.title')} 
            />
            <ul className="space-y-4 text-lg text-muted-foreground">
              <li className="flex gap-2">
                <EditableText id="about.different.point1" as="span" text={t('about.different.point1')} />
              </li>
              <li className="flex gap-2">
                <EditableText id="about.different.point2" as="span" text={t('about.different.point2')} />
              </li>
              <li className="flex gap-2">
                <EditableText id="about.different.point3" as="span" text={t('about.different.point3')} />
              </li>
              <li className="flex gap-2">
                <EditableText id="about.different.point4" as="span" text={t('about.different.point4')} />
              </li>
            </ul>
          </div>
        </div>
      </section>

      <FeatureGrid
        idPrefix="about.values"
        title={t('about.values.title')}
        description={t('about.values.description')}
        features={values}
        columns={3}
      />

      <section className="section-padding bg-muted/30">
        <div className="container-padding max-w-4xl mx-auto text-center space-y-6">
          <EditableText 
            id="about.certification.title" 
            as="h2" 
            className="text-3xl font-bold" 
            text={t('about.certification.title')} 
          />
          <EditableText 
            id="about.certification.description" 
            as="p" 
            className="text-lg text-muted-foreground" 
            text={t('about.certification.description')} 
          />
          <div className="flex flex-wrap justify-center gap-8 pt-8">
            <div className="text-center">
              <EditableText 
                id="about.certification.stat1" 
                as="div" 
                className="text-4xl font-bold text-primary" 
                text={t('about.certification.stat1')} 
              />
              <EditableText 
                id="about.certification.stat1Label" 
                as="div" 
                className="text-muted-foreground" 
                text={t('about.certification.stat1Label')} 
              />
            </div>
            <div className="text-center">
              <EditableText 
                id="about.certification.stat2" 
                as="div" 
                className="text-4xl font-bold text-primary" 
                text={t('about.certification.stat2')} 
              />
              <EditableText 
                id="about.certification.stat2Label" 
                as="div" 
                className="text-muted-foreground" 
                text={t('about.certification.stat2Label')} 
              />
            </div>
            <div className="text-center">
              <EditableText 
                id="about.certification.stat3" 
                as="div" 
                className="text-4xl font-bold text-primary" 
                text={t('about.certification.stat3')} 
              />
              <EditableText 
                id="about.certification.stat3Label" 
                as="div" 
                className="text-muted-foreground" 
                text={t('about.certification.stat3Label')} 
              />
            </div>
          </div>
        </div>
      </section>
    </PublicLayout>
  );
};

export default About;
