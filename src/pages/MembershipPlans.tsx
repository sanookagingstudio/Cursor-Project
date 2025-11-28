import { PublicLayout } from "@/layouts/PublicLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useTranslation } from "react-i18next";
import { Link } from "react-router-dom";
import { Check, Sparkles, Zap, Crown, Coins } from "lucide-react";

export default function MembershipPlans() {
  const { t } = useTranslation();

  const premiumPlans = [
    {
      name: t('membershipPlans.premium.weekly.name'),
      price: "฿2,500",
      period: t('membershipPlans.premium.weekly.period'),
      description: t('membershipPlans.premium.weekly.description'),
      features: [
        t('membershipPlans.premium.features.activities'),
        t('membershipPlans.premium.features.healthCheck'),
        t('membershipPlans.premium.features.mediaCenter'),
        t('membershipPlans.premium.features.tripDiscount15'),
        t('membershipPlans.premium.features.storeDiscount10'),
      ],
      badge: null,
      popular: false,
    },
    {
      name: t('membershipPlans.premium.monthly.name'),
      price: "฿8,000",
      period: t('membershipPlans.premium.monthly.period'),
      description: t('membershipPlans.premium.monthly.description'),
      features: [
        t('membershipPlans.premium.features.unlimitedActivities'),
        t('membershipPlans.premium.features.freeHealthCheck'),
        t('membershipPlans.premium.features.fullMediaCenter'),
        t('membershipPlans.premium.features.tripDiscount20'),
        t('membershipPlans.premium.features.storeDiscount15'),
        t('membershipPlans.premium.features.priorityBooking'),
      ],
      badge: t('membershipPlans.badges.popular'),
      popular: true,
    },
    {
      name: t('membershipPlans.premium.halfYearly.name'),
      price: "฿42,000",
      period: t('membershipPlans.premium.halfYearly.period'),
      description: t('membershipPlans.premium.halfYearly.description'),
      features: [
        t('membershipPlans.premium.features.allMonthly'),
        t('membershipPlans.premium.features.save20'),
        t('membershipPlans.premium.features.tripDiscount25'),
        t('membershipPlans.premium.features.storeDiscount20'),
        t('membershipPlans.premium.features.exclusiveEvents'),
        t('membershipPlans.premium.features.personalCoach'),
      ],
      badge: t('membershipPlans.badges.save20'),
      popular: false,
    },
    {
      name: t('membershipPlans.premium.yearly.name'),
      price: "฿75,000",
      period: t('membershipPlans.premium.yearly.period'),
      description: t('membershipPlans.premium.yearly.description'),
      features: [
        t('membershipPlans.premium.features.allMonthly'),
        t('membershipPlans.premium.features.save30'),
        t('membershipPlans.premium.features.tripDiscount30'),
        t('membershipPlans.premium.features.storeDiscount25'),
        t('membershipPlans.premium.features.vipEvents'),
        t('membershipPlans.premium.features.dedicatedCoach'),
        t('membershipPlans.premium.features.birthdayGift'),
      ],
      badge: t('membershipPlans.badges.bestValue'),
      popular: false,
    },
  ];

  const creditPackages = [
    {
      name: t('membershipPlans.digital.starter.name'),
      price: "฿500",
      credits: 100,
      description: t('membershipPlans.digital.starter.description'),
      features: [
        t('membershipPlans.digital.features.aiImages10'),
        t('membershipPlans.digital.features.basicTemplates'),
        t('membershipPlans.digital.features.premiumArticles'),
        t('membershipPlans.digital.features.validityMonth'),
      ],
    },
    {
      name: t('membershipPlans.digital.popular.name'),
      price: "฿1,000",
      credits: 220,
      bonus: "+20 " + t('membershipPlans.digital.bonus'),
      description: t('membershipPlans.digital.popular.description'),
      features: [
        t('membershipPlans.digital.features.aiImages22'),
        t('membershipPlans.digital.features.premiumTemplates'),
        t('membershipPlans.digital.features.digitalDownloads'),
        t('membershipPlans.digital.features.validityMonths3'),
      ],
      badge: t('membershipPlans.badges.popular'),
    },
    {
      name: t('membershipPlans.digital.pro.name'),
      price: "฿2,500",
      credits: 600,
      bonus: "+100 " + t('membershipPlans.digital.bonus'),
      description: t('membershipPlans.digital.pro.description'),
      features: [
        t('membershipPlans.digital.features.aiImages60'),
        t('membershipPlans.digital.features.allTemplates'),
        t('membershipPlans.digital.features.unlimitedDownloads'),
        t('membershipPlans.digital.features.prioritySupport'),
        t('membershipPlans.digital.features.validityMonths6'),
      ],
      badge: t('membershipPlans.badges.bestValue'),
    },
  ];

  return (
    <PublicLayout>
      <div className="container-padding section-padding max-w-7xl mx-auto">
        <SectionHeader
          title={t('membershipPlans.title')}
          description={t('membershipPlans.description')}
        />

        <Tabs defaultValue="premium" className="space-y-8">
          <TabsList className="grid w-full max-w-2xl mx-auto grid-cols-3 h-auto p-2">
            <TabsTrigger value="premium" className="text-base py-3">
              <Crown className="h-5 w-5 mr-2" />
              {t('membershipPlans.tabs.premium')}
            </TabsTrigger>
            <TabsTrigger value="digital" className="text-base py-3">
              <Coins className="h-5 w-5 mr-2" />
              {t('membershipPlans.tabs.digital')}
            </TabsTrigger>
            <TabsTrigger value="free" className="text-base py-3">
              <Sparkles className="h-5 w-5 mr-2" />
              {t('membershipPlans.tabs.free')}
            </TabsTrigger>
          </TabsList>

          {/* Premium Members */}
          <TabsContent value="premium" className="space-y-6">
            <div className="text-center mb-8">
              <h3 className="text-2xl font-bold mb-2">{t('membershipPlans.premium.sectionTitle')}</h3>
              <p className="text-muted-foreground text-lg">{t('membershipPlans.premium.sectionDesc')}</p>
            </div>
            
            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
              {premiumPlans.map((plan, index) => (
                <Card key={index} className={`relative ${plan.popular ? 'border-primary border-2 shadow-xl' : ''}`}>
                  {plan.badge && (
                    <div className="absolute -top-3 left-1/2 -translate-x-1/2">
                      <Badge className={plan.popular ? 'bg-primary' : 'bg-accent'}>{plan.badge}</Badge>
                    </div>
                  )}
                  <CardHeader>
                    <CardTitle className="text-xl">{plan.name}</CardTitle>
                    <CardDescription>{plan.description}</CardDescription>
                    <div className="mt-4">
                      <div className="text-4xl font-bold">{plan.price}</div>
                      <div className="text-muted-foreground">{plan.period}</div>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <ul className="space-y-3">
                      {plan.features.map((feature, i) => (
                        <li key={i} className="flex items-start gap-2">
                          <Check className="h-5 w-5 text-primary shrink-0 mt-0.5" />
                          <span className="text-sm">{feature}</span>
                        </li>
                      ))}
                    </ul>
                  </CardContent>
                  <CardFooter>
                    <Link to="/join-now" className="w-full">
                      <Button className="w-full" variant={plan.popular ? 'default' : 'outline'} size="lg">
                        {t('membershipPlans.selectPlan')}
                      </Button>
                    </Link>
                  </CardFooter>
                </Card>
              ))}
            </div>
          </TabsContent>

          {/* Digital Members */}
          <TabsContent value="digital" className="space-y-6">
            <div className="text-center mb-8">
              <h3 className="text-2xl font-bold mb-2">{t('membershipPlans.digital.sectionTitle')}</h3>
              <p className="text-muted-foreground text-lg">{t('membershipPlans.digital.sectionDesc')}</p>
            </div>

            <div className="grid md:grid-cols-3 gap-6 max-w-5xl mx-auto">
              {creditPackages.map((pkg, index) => (
                <Card key={index} className={pkg.badge ? 'border-primary border-2 shadow-xl' : ''}>
                  {pkg.badge && (
                    <div className="absolute -top-3 left-1/2 -translate-x-1/2">
                      <Badge className="bg-primary">{pkg.badge}</Badge>
                    </div>
                  )}
                  <CardHeader>
                    <CardTitle className="text-xl">{pkg.name}</CardTitle>
                    <CardDescription>{pkg.description}</CardDescription>
                    <div className="mt-4">
                      <div className="text-4xl font-bold">{pkg.price}</div>
                      <div className="text-primary font-semibold text-lg">{pkg.credits} {t('membershipPlans.digital.credits')}</div>
                      {pkg.bonus && (
                        <Badge variant="secondary" className="mt-2">{pkg.bonus}</Badge>
                      )}
                    </div>
                  </CardHeader>
                  <CardContent>
                    <ul className="space-y-3">
                      {pkg.features.map((feature, i) => (
                        <li key={i} className="flex items-start gap-2">
                          <Zap className="h-5 w-5 text-amber-500 shrink-0 mt-0.5" />
                          <span className="text-sm">{feature}</span>
                        </li>
                      ))}
                    </ul>
                  </CardContent>
                  <CardFooter>
                    <Link to="/join-now" className="w-full">
                      <Button className="w-full" variant={pkg.badge ? 'default' : 'outline'} size="lg">
                        {t('membershipPlans.buyCredits')}
                      </Button>
                    </Link>
                  </CardFooter>
                </Card>
              ))}
            </div>

            {/* Credit Usage Guide */}
            <Card className="max-w-3xl mx-auto mt-8 bg-muted/30">
              <CardHeader>
                <CardTitle>{t('membershipPlans.digital.usageTitle')}</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid md:grid-cols-2 gap-4">
                  <div className="flex justify-between items-center p-3 bg-background rounded-lg">
                    <span>{t('membershipPlans.digital.usage.aiImage')}</span>
                    <Badge variant="secondary">10 {t('membershipPlans.digital.credits')}</Badge>
                  </div>
                  <div className="flex justify-between items-center p-3 bg-background rounded-lg">
                    <span>{t('membershipPlans.digital.usage.premiumTemplate')}</span>
                    <Badge variant="secondary">20-50 {t('membershipPlans.digital.credits')}</Badge>
                  </div>
                  <div className="flex justify-between items-center p-3 bg-background rounded-lg">
                    <span>{t('membershipPlans.digital.usage.digitalDownload')}</span>
                    <Badge variant="secondary">5-30 {t('membershipPlans.digital.credits')}</Badge>
                  </div>
                  <div className="flex justify-between items-center p-3 bg-background rounded-lg">
                    <span>{t('membershipPlans.digital.usage.premiumArticle')}</span>
                    <Badge variant="secondary">5 {t('membershipPlans.digital.credits')}</Badge>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Free Members */}
          <TabsContent value="free" className="space-y-6">
            <div className="max-w-3xl mx-auto">
              <Card className="text-center">
                <CardHeader>
                  <div className="w-20 h-20 rounded-full bg-primary/10 flex items-center justify-center mx-auto mb-4">
                    <Sparkles className="h-10 w-10 text-primary" />
                  </div>
                  <CardTitle className="text-3xl">{t('membershipPlans.free.title')}</CardTitle>
                  <CardDescription className="text-lg">{t('membershipPlans.free.description')}</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="text-5xl font-bold mb-2">{t('membershipPlans.free.price')}</div>
                  <p className="text-muted-foreground mb-8">{t('membershipPlans.free.period')}</p>
                  
                  <div className="grid md:grid-cols-2 gap-4 text-left">
                    {[
                      t('membershipPlans.free.features.browseContent'),
                      t('membershipPlans.free.features.viewPublicMedia'),
                      t('membershipPlans.free.features.readBasicArticles'),
                      t('membershipPlans.free.features.viewEvents'),
                      t('membershipPlans.free.features.viewPricing'),
                      t('membershipPlans.free.features.communityForum'),
                    ].map((feature, i) => (
                      <div key={i} className="flex items-start gap-2">
                        <Check className="h-5 w-5 text-primary shrink-0 mt-0.5" />
                        <span>{feature}</span>
                      </div>
                    ))}
                  </div>
                </CardContent>
                <CardFooter className="flex-col gap-3">
                  <Link to="/sign-up" className="w-full">
                    <Button size="lg" className="w-full">
                      {t('membershipPlans.free.joinFree')}
                    </Button>
                  </Link>
                  <p className="text-sm text-muted-foreground">
                    {t('membershipPlans.free.upgradeNote')}
                  </p>
                </CardFooter>
              </Card>
            </div>
          </TabsContent>
        </Tabs>

        {/* Comparison CTA */}
        <Card className="mt-12 bg-gradient-primary text-white border-0">
          <CardContent className="text-center py-12">
            <h3 className="text-3xl font-bold mb-4 text-white">{t('membershipPlans.cta.title')}</h3>
            <p className="text-white/90 text-lg mb-6">{t('membershipPlans.cta.description')}</p>
            <div className="flex justify-center gap-4">
              <Link to="/contact">
                <Button size="lg" variant="secondary">
                  {t('membershipPlans.cta.contactUs')}
                </Button>
              </Link>
              <Link to="/faq">
                <Button size="lg" variant="outline" className="bg-white/10 text-white border-white hover:bg-white hover:text-primary">
                  {t('membershipPlans.cta.viewFAQ')}
                </Button>
              </Link>
            </div>
          </CardContent>
        </Card>
      </div>
    </PublicLayout>
  );
}
