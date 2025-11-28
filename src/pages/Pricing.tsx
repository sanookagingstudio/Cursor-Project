import { PublicLayout } from "@/layouts/PublicLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { PricingPlans } from "@/components/sections/PricingPlans";
import { CTASection } from "@/components/sections/CTASection";
import { useTranslation } from "react-i18next";

const Pricing = () => {
  const { t } = useTranslation();

  const plans = [
    {
      name: t('pricingPage.walkIn.name'),
      description: t('pricingPage.walkIn.description'),
      price: t('pricingPage.walkIn.price'),
      period: t('pricingPage.walkIn.period'),
      features: [
        t('pricingPage.walkIn.feature1'),
        t('pricingPage.walkIn.feature2'),
        t('pricingPage.walkIn.feature3'),
        t('pricingPage.walkIn.feature4'),
        t('pricingPage.walkIn.feature5'),
      ],
      ctaLabel: t('pricingPage.walkIn.cta'),
      ctaHref: "/sign-up",
    },
    {
      name: t('pricingPage.monthly.name'),
      description: t('pricingPage.monthly.description'),
      price: t('pricingPage.monthly.price'),
      period: t('pricingPage.monthly.period'),
      featured: true,
      features: [
        t('pricingPage.monthly.feature1'),
        t('pricingPage.monthly.feature2'),
        t('pricingPage.monthly.feature3'),
        t('pricingPage.monthly.feature4'),
        t('pricingPage.monthly.feature5'),
        t('pricingPage.monthly.feature6'),
        t('pricingPage.monthly.feature7'),
        t('pricingPage.monthly.feature8'),
      ],
      ctaLabel: t('pricingPage.monthly.cta'),
      ctaHref: "/sign-up",
    },
    {
      name: t('pricingPage.perTrip.name'),
      description: t('pricingPage.perTrip.description'),
      price: t('pricingPage.perTrip.price'),
      period: t('pricingPage.perTrip.period'),
      features: [
        t('pricingPage.perTrip.feature1'),
        t('pricingPage.perTrip.feature2'),
        t('pricingPage.perTrip.feature3'),
        t('pricingPage.perTrip.feature4'),
        t('pricingPage.perTrip.feature5'),
      ],
      ctaLabel: t('pricingPage.perTrip.cta'),
      ctaHref: "/trips",
    },
  ];

  return (
    <PublicLayout>
      <div className="section-padding">
        <div className="container-padding max-w-7xl mx-auto">
          <SectionHeader
            title={t('pricingPage.title')}
            description={t('pricingPage.description')}
          />

          <PricingPlans plans={plans} />

          <div className="mt-16 p-8 rounded-2xl bg-muted/30 border">
            <h3 className="text-2xl font-bold mb-4 text-center">{t('pricingPage.additionalTitle')}</h3>
            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mt-8">
              <div className="text-center">
                <div className="text-3xl font-bold text-primary mb-2">฿300</div>
                <div className="font-medium">{t('pricingPage.transportation')}</div>
                <div className="text-sm text-muted-foreground">{t('pricingPage.transportationPeriod')}</div>
              </div>
              <div className="text-center">
                <div className="text-3xl font-bold text-primary mb-2">฿500</div>
                <div className="font-medium">{t('pricingPage.personalCare')}</div>
                <div className="text-sm text-muted-foreground">{t('pricingPage.personalCarePeriod')}</div>
              </div>
              <div className="text-center">
                <div className="text-3xl font-bold text-primary mb-2">฿800</div>
                <div className="font-medium">{t('pricingPage.healthAssessment')}</div>
                <div className="text-sm text-muted-foreground">{t('pricingPage.healthAssessmentPeriod')}</div>
              </div>
              <div className="text-center">
                <div className="text-3xl font-bold text-primary mb-2">Custom</div>
                <div className="font-medium">{t('pricingPage.familyPackage')}</div>
                <div className="text-sm text-muted-foreground">{t('pricingPage.familyPackagePeriod')}</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <CTASection
        title={t('pricingPage.ctaTitle')}
        description={t('pricingPage.ctaDescription')}
        primaryCTA={{ label: t('pricingPage.ctaButton'), href: "/contact" }}
        variant="default"
      />
    </PublicLayout>
  );
};

export default Pricing;
