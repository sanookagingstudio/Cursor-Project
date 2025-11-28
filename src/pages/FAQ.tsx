import { PublicLayout } from "@/layouts/PublicLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Search } from "lucide-react";
import { useTranslation } from "react-i18next";

export default function FAQ() {
  const { t } = useTranslation();

  const faqs = [
    {
      category: t('faqPage.general'),
      questions: [
        {
          q: "What is FunAging Studio?",
          a: "FunAging Studio is a comprehensive elderly care and wellness center focused on helping seniors age with joy, health, and dignity.",
        },
        {
          q: "Who can join?",
          a: "Our programs are designed for adults aged 60 and above.",
        },
      ],
    },
    {
      category: t('faqPage.activitiesPrograms'),
      questions: [
        {
          q: "What types of activities do you offer?",
          a: "We offer morning exercise, Tai Chi, art classes, music therapy, brain games, cooking classes, and social events.",
        },
      ],
    },
    {
      category: t('faqPage.tripsOutings'),
      questions: [
        {
          q: "How often do you organize trips?",
          a: "We organize day trips every week and longer trips once a month.",
        },
      ],
    },
    {
      category: t('faqPage.healthSafety'),
      questions: [
        {
          q: "Do you have medical staff on-site?",
          a: "Yes, we have trained care staff and nurses available during all activities and trips.",
        },
      ],
    },
    {
      category: t('faqPage.pricingMembership'),
      questions: [
        {
          q: "What are your pricing options?",
          a: "We offer walk-in daily rates, monthly memberships, and per-trip pricing.",
        },
      ],
    },
  ];

  return (
    <PublicLayout>
      <div className="section-padding bg-gradient-warm">
        <div className="max-w-4xl mx-auto container-padding">
          <SectionHeader
            title={t('faqPage.title')}
            description={t('faqPage.description')}
          />

          <Card className="p-4 mb-8">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-5 w-5" />
              <Input
                placeholder={t('faqPage.searchPlaceholder')}
                className="pl-10 text-lg"
              />
            </div>
          </Card>

          <div className="space-y-8">
            {faqs.map((section) => (
              <div key={section.category}>
                <h2 className="mb-4">{section.category}</h2>
                <Accordion type="single" collapsible className="space-y-2">
                  {section.questions.map((item, idx) => (
                    <AccordionItem key={idx} value={`${section.category}-${idx}`} className="border rounded-lg px-4">
                      <AccordionTrigger className="text-left text-lg hover:no-underline">
                        {item.q}
                      </AccordionTrigger>
                      <AccordionContent className="text-base text-muted-foreground leading-relaxed">
                        {item.a}
                      </AccordionContent>
                    </AccordionItem>
                  ))}
                </Accordion>
              </div>
            ))}
          </div>
        </div>
      </div>
    </PublicLayout>
  );
}
