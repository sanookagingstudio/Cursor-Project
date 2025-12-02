import { PublicLayout } from "@/layouts/PublicLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { MapPin, Phone, Mail, MessageCircle, Clock } from "lucide-react";
import { useTranslation } from "react-i18next";
import { EditableText, Editable } from "@/components/editor/Editable";

export default function Contact() {
  const { t } = useTranslation();

  return (
    <PublicLayout>
      <div className="section-padding bg-gradient-warm">
        <div className="max-w-6xl mx-auto container-padding">
          <SectionHeader
            idPrefix="contact.header"
            title={t('contactPage.title')}
            description={t('contactPage.description')}
          />

          <div className="grid lg:grid-cols-2 gap-8">
            {/* Contact Form */}
            <Card>
              <CardHeader>
                <EditableText 
                  id="contact.form.title" 
                  as={CardTitle} 
                  text={t('contactPage.formTitle')} 
                />
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <Label htmlFor="name">
                    <EditableText id="contact.form.label.name" text={t('contactPage.name')} />
                  </Label>
                  <Input id="name" placeholder={t('contactPage.namePlaceholder')} className="text-lg" />
                </div>
                <div>
                  <Label htmlFor="email">
                    <EditableText id="contact.form.label.email" text={t('contactPage.email')} />
                  </Label>
                  <Input id="email" type="email" placeholder={t('contactPage.emailPlaceholder')} className="text-lg" />
                </div>
                <div>
                  <Label htmlFor="phone">
                    <EditableText id="contact.form.label.phone" text={t('contactPage.phone')} />
                  </Label>
                  <Input id="phone" type="tel" placeholder={t('contactPage.phonePlaceholder')} className="text-lg" />
                </div>
                <div>
                  <Label htmlFor="subject">
                    <EditableText id="contact.form.label.subject" text={t('contactPage.subject')} />
                  </Label>
                  <Input id="subject" placeholder={t('contactPage.subjectPlaceholder')} className="text-lg" />
                </div>
                <div>
                  <Label htmlFor="message">
                    <EditableText id="contact.form.label.message" text={t('contactPage.message')} />
                  </Label>
                  <Textarea
                    id="message"
                    placeholder={t('contactPage.messagePlaceholder')}
                    className="text-lg min-h-32"
                  />
                </div>
                <Button size="lg" className="w-full btn-elderly">
                  <EditableText id="contact.form.submit" text={t('contactPage.sendButton')} />
                </Button>
              </CardContent>
            </Card>

            {/* Contact Information */}
            <div className="space-y-6">
              <Card>
                <CardContent className="pt-6">
                  <div className="flex items-start gap-4">
                    <Editable id="contact.icon.address" type="icon" className="mt-1">
                      <MapPin className="h-6 w-6 text-primary" />
                    </Editable>
                    <div>
                      <EditableText 
                        id="contact.address.title" 
                        as="h4" 
                        className="font-semibold mb-2" 
                        text={t('contactPage.address')} 
                      />
                      <EditableText 
                        id="contact.address.detail" 
                        as="p" 
                        className="text-muted-foreground whitespace-pre-line" 
                        text={t('contactPage.addressDetail')} 
                      />
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="pt-6">
                  <div className="flex items-start gap-4">
                    <Editable id="contact.icon.phone" type="icon" className="mt-1">
                      <Phone className="h-6 w-6 text-primary" />
                    </Editable>
                    <div>
                      <EditableText 
                        id="contact.phone.title" 
                        as="h4" 
                        className="font-semibold mb-2" 
                        text={t('contactPage.phoneTitle')} 
                      />
                      <EditableText 
                        id="contact.phone.detail" 
                        as="p" 
                        className="text-muted-foreground whitespace-pre-line" 
                        text={t('contactPage.phoneDetail')} 
                      />
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="pt-6">
                  <div className="flex items-start gap-4">
                    <Editable id="contact.icon.email" type="icon" className="mt-1">
                      <Mail className="h-6 w-6 text-primary" />
                    </Editable>
                    <div>
                      <EditableText 
                        id="contact.email.title" 
                        as="h4" 
                        className="font-semibold mb-2" 
                        text={t('contactPage.emailTitle')} 
                      />
                      <EditableText 
                        id="contact.email.detail" 
                        as="p" 
                        className="text-muted-foreground whitespace-pre-line" 
                        text={t('contactPage.emailDetail')} 
                      />
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="pt-6">
                  <div className="flex items-start gap-4">
                    <Editable id="contact.icon.line" type="icon" className="mt-1">
                      <MessageCircle className="h-6 w-6 text-primary" />
                    </Editable>
                    <div>
                      <EditableText 
                        id="contact.line.title" 
                        as="h4" 
                        className="font-semibold mb-2" 
                        text={t('contactPage.lineTitle')} 
                      />
                      <EditableText 
                        id="contact.line.detail" 
                        as="p" 
                        className="text-muted-foreground" 
                        text={t('contactPage.lineDetail')} 
                      />
                      <Button variant="outline" className="mt-2">
                        <EditableText id="contact.line.button" text={t('contactPage.addLineButton')} />
                      </Button>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="pt-6">
                  <div className="flex items-start gap-4">
                    <Editable id="contact.icon.hours" type="icon" className="mt-1">
                      <Clock className="h-6 w-6 text-primary" />
                    </Editable>
                    <div>
                      <EditableText 
                        id="contact.hours.title" 
                        as="h4" 
                        className="font-semibold mb-2" 
                        text={t('contactPage.hoursTitle')} 
                      />
                      <EditableText 
                        id="contact.hours.detail" 
                        as="p" 
                        className="text-muted-foreground whitespace-pre-line" 
                        text={t('contactPage.hoursDetail')} 
                      />
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
