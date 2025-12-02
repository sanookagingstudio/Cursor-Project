import { PublicLayout } from "@/layouts/PublicLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useTranslation } from "react-i18next";
import { Link } from "react-router-dom";
import { Check, Sparkles, Zap, Crown, Coins } from "lucide-react";
import { EditableText, Editable } from "@/components/editor/Editable";

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
          idPrefix="membership.header"
          title={t('membershipPlans.title')}
          description={t('membershipPlans.description')}
        />

        <Tabs defaultValue="premium" className="space-y-8">
          <TabsList className="grid w-full max-w-2xl mx-auto grid-cols-3 h-auto p-2">
            <TabsTrigger value="premium" className="text-base py-3">
              <Crown className="h-5 w-5 mr-2" />
              <EditableText id="membership.tab.premium" text={t('membershipPlans.tabs.premium')} />
            </TabsTrigger>
            <TabsTrigger value="digital" className="text-base py-3">
              <Coins className="h-5 w-5 mr-2" />
              <EditableText id="membership.tab.digital" text={t('membershipPlans.tabs.digital')} />
            </TabsTrigger>
            <TabsTrigger value="free" className="text-base py-3">
              <Sparkles className="h-5 w-5 mr-2" />
              <EditableText id="membership.tab.free" text={t('membershipPlans.tabs.free')} />
            </TabsTrigger>
          </TabsList>

          {/* Premium Members */}
          <TabsContent value="premium" className="space-y-6">
            <div className="text-center mb-8">
              <EditableText 
                id="membership.premium.title"
                as="h3" 
                className="text-2xl font-bold mb-2" 
                text={t('membershipPlans.premium.sectionTitle')} 
              />
              <EditableText 
                id="membership.premium.desc"
                as="p" 
                className="text-muted-foreground text-lg" 
                text={t('membershipPlans.premium.sectionDesc')} 
              />
            </div>
            
            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
              {premiumPlans.map((plan, index) => (
                <Card key={index} className={`relative ${plan.popular ? 'border-primary border-2 shadow-xl' : ''}`}>
                  {plan.badge && (
                    <div className="absolute -top-3 left-1/2 -translate-x-1/2">
                      <Badge className={plan.popular ? 'bg-primary' : 'bg-accent'}>
                        <EditableText id={`membership.premium.plan.${index}.badge`} text={plan.badge} />
                      </Badge>
                    </div>
                  )}
                  <CardHeader>
                    <EditableText 
                        id={`membership.premium.plan.${index}.name`}
                        as={CardTitle} 
                        className="text-xl" 
                        text={plan.name} 
                    />
                    <EditableText 
                        id={`membership.premium.plan.${index}.desc`}
                        as={CardDescription} 
                        text={plan.description} 
                    />
                    <div className="mt-4">
                      <EditableText 
                        id={`membership.premium.plan.${index}.price`}
                        as="div" 
                        className="text-4xl font-bold" 
                        text={plan.price} 
                      />
                      <EditableText 
                        id={`membership.premium.plan.${index}.period`}
                        as="div" 
                        className="text-muted-foreground" 
                        text={plan.period} 
                      />
                    </div>
                  </CardHeader>
                  <CardContent>
                    <ul className="space-y-3">
                      {plan.features.map((feature, i) => (
                        <li key={i} className="flex items-start gap-2">
                          <Check className="h-5 w-5 text-primary shrink-0 mt-0.5" />
                          <EditableText 
                            id={`membership.premium.plan.${index}.feature.${i}`}
                            as="span" 
                            className="text-sm" 
                            text={feature} 
                          />
                        </li>
                      ))}
                    </ul>
                  </CardContent>
                  <CardFooter>
                    <Link to="/join-now" className="w-full">
                      <Button className="w-full" variant={plan.popular ? 'default' : 'outline'} size="lg">
                        <EditableText id={`membership.premium.plan.${index}.btn`} text={t('membershipPlans.selectPlan')} />
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
              <EditableText 
                id="membership.digital.title"
                as="h3" 
                className="text-2xl font-bold mb-2" 
                text={t('membershipPlans.digital.sectionTitle')} 
              />
              <EditableText 
                id="membership.digital.desc"
                as="p" 
                className="text-muted-foreground text-lg" 
                text={t('membershipPlans.digital.sectionDesc')} 
              />
            </div>

            <div className="grid md:grid-cols-3 gap-6 max-w-5xl mx-auto">
              {creditPackages.map((pkg, index) => (
                <Card key={index} className={pkg.badge ? 'border-primary border-2 shadow-xl' : ''}>
                  {pkg.badge && (
                    <div className="absolute -top-3 left-1/2 -translate-x-1/2">
                      <Badge className="bg-primary">
                        <EditableText id={`membership.digital.pkg.${index}.badge`} text={pkg.badge} />
                      </Badge>
                    </div>
                  )}
                  <CardHeader>
                    <EditableText 
                        id={`membership.digital.pkg.${index}.name`}
                        as={CardTitle} 
                        className="text-xl" 
                        text={pkg.name} 
                    />
                    <EditableText 
                        id={`membership.digital.pkg.${index}.desc`}
                        as={CardDescription} 
                        text={pkg.description} 
                    />
                    <div className="mt-4">
                      <EditableText 
                        id={`membership.digital.pkg.${index}.price`}
                        as="div" 
                        className="text-4xl font-bold" 
                        text={pkg.price} 
                      />
                      <div className="text-primary font-semibold text-lg">
                         <EditableText id={`membership.digital.pkg.${index}.credits`} text={`${pkg.credits} ${t('membershipPlans.digital.credits')}`} />
                      </div>
                      {pkg.bonus && (
                        <Badge variant="secondary" className="mt-2">
                            <EditableText id={`membership.digital.pkg.${index}.bonus`} text={pkg.bonus} />
                        </Badge>
                      )}
                    </div>
                  </CardHeader>
                  <CardContent>
                    <ul className="space-y-3">
                      {pkg.features.map((feature, i) => (
                        <li key={i} className="flex items-start gap-2">
                          <Zap className="h-5 w-5 text-amber-500 shrink-0 mt-0.5" />
                          <EditableText 
                            id={`membership.digital.pkg.${index}.feature.${i}`}
                            as="span" 
                            className="text-sm" 
                            text={feature} 
                          />
                        </li>
                      ))}
                    </ul>
                  </CardContent>
                  <CardFooter>
                    <Link to="/join-now" className="w-full">
                      <Button className="w-full" variant={pkg.badge ? 'default' : 'outline'} size="lg">
                        <EditableText id={`membership.digital.pkg.${index}.btn`} text={t('membershipPlans.buyCredits')} />
                      </Button>
                    </Link>
                  </CardFooter>
                </Card>
              ))}
            </div>

            {/* Credit Usage Guide */}
            <Card className="max-w-3xl mx-auto mt-8 bg-muted/30">
              <CardHeader>
                <EditableText 
                    id="membership.usage.title"
                    as={CardTitle} 
                    text={t('membershipPlans.digital.usageTitle')} 
                />
              </CardHeader>
              <CardContent>
                <div className="grid md:grid-cols-2 gap-4">
                  <div className="flex justify-between items-center p-3 bg-background rounded-lg">
                    <EditableText id="membership.usage.item1" as="span" text={t('membershipPlans.digital.usage.aiImage')} />
                    <Badge variant="secondary">
                        <EditableText id="membership.usage.cost1" text={`10 ${t('membershipPlans.digital.credits')}`} />
                    </Badge>
                  </div>
                  <div className="flex justify-between items-center p-3 bg-background rounded-lg">
                    <EditableText id="membership.usage.item2" as="span" text={t('membershipPlans.digital.usage.premiumTemplate')} />
                    <Badge variant="secondary">
                        <EditableText id="membership.usage.cost2" text={`20-50 ${t('membershipPlans.digital.credits')}`} />
                    </Badge>
                  </div>
                  <div className="flex justify-between items-center p-3 bg-background rounded-lg">
                    <EditableText id="membership.usage.item3" as="span" text={t('membershipPlans.digital.usage.digitalDownload')} />
                    <Badge variant="secondary">
                        <EditableText id="membership.usage.cost3" text={`5-30 ${t('membershipPlans.digital.credits')}`} />
                    </Badge>
                  </div>
                  <div className="flex justify-between items-center p-3 bg-background rounded-lg">
                    <EditableText id="membership.usage.item4" as="span" text={t('membershipPlans.digital.usage.premiumArticle')} />
                    <Badge variant="secondary">
                        <EditableText id="membership.usage.cost4" text={`5 ${t('membershipPlans.digital.credits')}`} />
                    </Badge>
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
                  <EditableText 
                    id="membership.free.title"
                    as={CardTitle} 
                    className="text-3xl" 
                    text={t('membershipPlans.free.title')} 
                  />
                  <EditableText 
                    id="membership.free.desc"
                    as={CardDescription} 
                    className="text-lg" 
                    text={t('membershipPlans.free.description')} 
                  />
                </CardHeader>
                <CardContent>
                  <EditableText 
                    id="membership.free.price"
                    as="div" 
                    className="text-5xl font-bold mb-2" 
                    text={t('membershipPlans.free.price')} 
                  />
                  <EditableText 
                    id="membership.free.period"
                    as="p" 
                    className="text-muted-foreground mb-8" 
                    text={t('membershipPlans.free.period')} 
                  />
                  
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
                        <EditableText 
                            id={`membership.free.feature.${i}`}
                            as="span" 
                            text={feature} 
                        />
                      </div>
                    ))}
                  </div>
                </CardContent>
                <CardFooter className="flex-col gap-3">
                  <Link to="/sign-up" className="w-full">
                    <Button size="lg" className="w-full">
                      <EditableText id="membership.free.join" text={t('membershipPlans.free.joinFree')} />
                    </Button>
                  </Link>
                  <EditableText 
                    id="membership.free.note"
                    as="p" 
                    className="text-sm text-muted-foreground" 
                    text={t('membershipPlans.free.upgradeNote')} 
                  />
                </CardFooter>
              </Card>
            </div>
          </TabsContent>
        </Tabs>

        {/* Comparison CTA */}
        <Card className="mt-12 bg-gradient-primary text-white border-0">
          <CardContent className="text-center py-12">
            <EditableText 
                id="membership.cta.title"
                as="h3" 
                className="text-3xl font-bold mb-4 text-white" 
                text={t('membershipPlans.cta.title')} 
            />
            <EditableText 
                id="membership.cta.desc"
                as="p" 
                className="text-white/90 text-lg mb-6" 
                text={t('membershipPlans.cta.description')} 
            />
            <div className="flex justify-center gap-4">
              <Link to="/contact">
                <Button size="lg" variant="secondary">
                  <EditableText id="membership.cta.contact" text={t('membershipPlans.cta.contactUs')} />
                </Button>
              </Link>
              <Link to="/faq">
                <Button size="lg" variant="outline" className="bg-white/10 text-white border-white hover:bg-white hover:text-primary">
                   <EditableText id="membership.cta.faq" text={t('membershipPlans.cta.viewFAQ')} />
                </Button>
              </Link>
            </div>
          </CardContent>
        </Card>
      </div>
    </PublicLayout>
  );
}
