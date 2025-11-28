import { PublicLayout } from "@/layouts/PublicLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { MapPin, Phone, Mail, MessageCircle, Clock } from "lucide-react";
import { useTranslation } from "react-i18next";

export default function Contact() {
  const { t } = useTranslation();

  return (
    <PublicLayout>
      <div className="section-padding bg-gradient-warm">
        <div className="max-w-6xl mx-auto container-padding">
          <SectionHeader
            title={t('contactPage.title')}
            description={t('contactPage.description')}
          />

          <div className="grid lg:grid-cols-2 gap-8">
            {/* Contact Form */}
            <Card>
              <CardHeader>
                <CardTitle>{t('contactPage.formTitle')}</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <Label htmlFor="name">{t('contactPage.name')}</Label>
                  <Input id="name" placeholder={t('contactPage.namePlaceholder')} className="text-lg" />
                </div>
                <div>
                  <Label htmlFor="email">{t('contactPage.email')}</Label>
                  <Input id="email" type="email" placeholder={t('contactPage.emailPlaceholder')} className="text-lg" />
                </div>
                <div>
                  <Label htmlFor="phone">{t('contactPage.phone')}</Label>
                  <Input id="phone" type="tel" placeholder={t('contactPage.phonePlaceholder')} className="text-lg" />
                </div>
                <div>
                  <Label htmlFor="subject">{t('contactPage.subject')}</Label>
                  <Input id="subject" placeholder={t('contactPage.subjectPlaceholder')} className="text-lg" />
                </div>
                <div>
                  <Label htmlFor="message">{t('contactPage.message')}</Label>
                  <Textarea
                    id="message"
                    placeholder={t('contactPage.messagePlaceholder')}
                    className="text-lg min-h-32"
                  />
                </div>
                <Button size="lg" className="w-full btn-elderly">
                  {t('contactPage.sendButton')}
                </Button>
              </CardContent>
            </Card>

            {/* Contact Information */}
            <div className="space-y-6">
              <Card>
                <CardContent className="pt-6">
                  <div className="flex items-start gap-4">
                    <MapPin className="h-6 w-6 text-primary mt-1 flex-shrink-0" />
                    <div>
                      <h4 className="font-semibold mb-2">{t('contactPage.address')}</h4>
                      <p className="text-muted-foreground whitespace-pre-line">
                        {t('contactPage.addressDetail')}
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="pt-6">
                  <div className="flex items-start gap-4">
                    <Phone className="h-6 w-6 text-primary mt-1 flex-shrink-0" />
                    <div>
                      <h4 className="font-semibold mb-2">{t('contactPage.phoneTitle')}</h4>
                      <p className="text-muted-foreground whitespace-pre-line">
                        {t('contactPage.phoneDetail')}
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="pt-6">
                  <div className="flex items-start gap-4">
                    <Mail className="h-6 w-6 text-primary mt-1 flex-shrink-0" />
                    <div>
                      <h4 className="font-semibold mb-2">{t('contactPage.emailTitle')}</h4>
                      <p className="text-muted-foreground whitespace-pre-line">
                        {t('contactPage.emailDetail')}
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="pt-6">
                  <div className="flex items-start gap-4">
                    <MessageCircle className="h-6 w-6 text-primary mt-1 flex-shrink-0" />
                    <div>
                      <h4 className="font-semibold mb-2">{t('contactPage.lineTitle')}</h4>
                      <p className="text-muted-foreground">{t('contactPage.lineDetail')}</p>
                      <Button variant="outline" className="mt-2">
                        {t('contactPage.addLineButton')}
                      </Button>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="pt-6">
                  <div className="flex items-start gap-4">
                    <Clock className="h-6 w-6 text-primary mt-1 flex-shrink-0" />
                    <div>
                      <h4 className="font-semibold mb-2">{t('contactPage.hoursTitle')}</h4>
                      <p className="text-muted-foreground whitespace-pre-line">
                        {t('contactPage.hoursDetail')}
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </div>
    </PublicLayout>
  );
}
