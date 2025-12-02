import { PublicLayout } from "@/layouts/PublicLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { useTranslation } from "react-i18next";
import { Link } from "react-router-dom";
import { Gift, Star, Heart, Award, Sparkles, PartyPopper } from "lucide-react";
import { EditableText, Editable } from "@/components/editor/Editable";

export default function Promotions() {
  const { t } = useTranslation();

  const promotions = [
    {
      icon: Gift,
      badge: t('promotionsPage.newMember'),
      badgeColor: "bg-primary",
      title: t('promotionsPage.promo1.title'),
      description: t('promotionsPage.promo1.description'),
    },
    {
      icon: Star,
      badge: t('promotionsPage.vipMember'),
      badgeColor: "bg-amber-500",
      title: t('promotionsPage.promo2.title'),
      description: t('promotionsPage.promo2.description'),
    },
    {
      icon: Heart,
      badge: t('promotionsPage.monthly'),
      badgeColor: "bg-rose-500",
      title: t('promotionsPage.promo3.title'),
      description: t('promotionsPage.promo3.description'),
    },
    {
      icon: Award,
      badge: t('promotionsPage.vipMember'),
      badgeColor: "bg-amber-500",
      title: t('promotionsPage.promo4.title'),
      description: t('promotionsPage.promo4.description'),
    },
    {
      icon: Sparkles,
      badge: t('promotionsPage.limited'),
      badgeColor: "bg-purple-500",
      title: t('promotionsPage.promo5.title'),
      description: t('promotionsPage.promo5.description'),
    },
    {
      icon: PartyPopper,
      badge: t('promotionsPage.vipMember'),
      badgeColor: "bg-amber-500",
      title: t('promotionsPage.promo6.title'),
      description: t('promotionsPage.promo6.description'),
    },
  ];

  return (
    <PublicLayout>
      <div className="container-padding section-padding max-w-6xl mx-auto">
        <SectionHeader
          idPrefix="promotions.header"
          title={t('promotionsPage.title')}
          description={t('promotionsPage.description')}
        />

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 mb-12">
          {promotions.map((promo, index) => {
            const Icon = promo.icon;
            return (
              <Card key={index} className="hover:shadow-xl transition-all duration-300 border-2">
                <CardHeader>
                  <div className="flex items-start justify-between mb-4">
                    <div className="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center">
                      <Editable id={`promotions.item.${index}.icon`} type="icon">
                        <Icon className="h-6 w-6 text-primary" />
                      </Editable>
                    </div>
                    <Editable id={`promotions.item.${index}.badge`}>
                      <Badge className={`${promo.badgeColor} text-white`}>
                        <EditableText id={`promotions.item.${index}.badgeText`} text={promo.badge} />
                      </Badge>
                    </Editable>
                  </div>
                  <EditableText 
                    id={`promotions.item.${index}.title`} 
                    as={CardTitle} 
                    className="text-xl" 
                    text={promo.title} 
                  />
                </CardHeader>
                <CardContent>
                  <EditableText 
                    id={`promotions.item.${index}.description`} 
                    as={CardDescription} 
                    className="text-base leading-relaxed" 
                    text={promo.description} 
                  />
                </CardContent>
              </Card>
            );
          })}
        </div>

        {/* CTA Section */}
        <Card className="bg-gradient-primary text-white border-0">
          <CardHeader className="text-center">
            <EditableText 
                id="promotions.cta.title"
                as={CardTitle} 
                className="text-3xl text-white mb-4"
                text={t('cta.title')}
            />
            <EditableText 
                id="promotions.cta.description"
                as={CardDescription} 
                className="text-white/90 text-lg"
                text={t('cta.description')}
            />
          </CardHeader>
          <CardContent className="flex justify-center gap-4 pb-8">
            <Link to="/join-now">
              <Button size="lg" variant="secondary" className="text-lg h-14 px-8">
                <EditableText id="promotions.cta.join" text={t('promotionsPage.joinNow')} />
              </Button>
            </Link>
            <Link to="/pricing">
              <Button size="lg" variant="outline" className="text-lg h-14 px-8 bg-white/10 text-white border-white hover:bg-white hover:text-primary">
                <EditableText id="promotions.cta.learnMore" text={t('promotionsPage.learnMore')} />
              </Button>
            </Link>
          </CardContent>
        </Card>
      </div>
    </PublicLayout>
  );
}
