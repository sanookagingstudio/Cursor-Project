import { PublicLayout } from "@/layouts/PublicLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox } from "@/components/ui/checkbox";
import { Heart, Activity, User } from "lucide-react";
import { useTranslation } from "react-i18next";

export default function HealthCheck() {
  const { t } = useTranslation();

  return (
    <PublicLayout>
      <div className="section-padding bg-gradient-warm">
        <div className="max-w-3xl mx-auto container-padding">
          <SectionHeader
            title={t('healthCheckPage.title')}
            description={t('healthCheckPage.description')}
          />

          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <User className="h-5 w-5 text-primary" />
                {t('healthCheckPage.basicInfo')}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="age">{t('healthCheckPage.age')}</Label>
                  <Input id="age" type="number" placeholder={t('healthCheckPage.agePlaceholder')} className="text-lg" />
                </div>
                <div>
                  <Label htmlFor="gender">{t('healthCheckPage.gender')}</Label>
                  <Select>
                    <SelectTrigger className="text-lg">
                      <SelectValue placeholder={t('healthCheckPage.genderSelect')} />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="male">{t('healthCheckPage.male')}</SelectItem>
                      <SelectItem value="female">{t('healthCheckPage.female')}</SelectItem>
                      <SelectItem value="other">{t('healthCheckPage.other')}</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Heart className="h-5 w-5 text-primary" />
                {t('healthCheckPage.healthStatus')}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label htmlFor="mobility">{t('healthCheckPage.mobility')}</Label>
                <Select>
                  <SelectTrigger className="text-lg">
                    <SelectValue placeholder={t('healthCheckPage.mobilitySelect')} />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="independent">{t('healthCheckPage.independent')}</SelectItem>
                    <SelectItem value="assistance">{t('healthCheckPage.assistance')}</SelectItem>
                    <SelectItem value="wheelchair">{t('healthCheckPage.wheelchair')}</SelectItem>
                    <SelectItem value="walker">{t('healthCheckPage.walker')}</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div>
                <Label className="mb-3 block">{t('healthCheckPage.conditions')}</Label>
                <div className="space-y-3">
                  {[
                    { id: "diabetes", label: t('healthCheckPage.diabetes') },
                    { id: "heart", label: t('healthCheckPage.heartDisease') },
                    { id: "bp", label: t('healthCheckPage.highBloodPressure') },
                    { id: "arthritis", label: t('healthCheckPage.arthritis') },
                    { id: "vision", label: t('healthCheckPage.visionImpairment') },
                    { id: "hearing", label: t('healthCheckPage.hearingImpairment') },
                  ].map((condition) => (
                    <div key={condition.id} className="flex items-center space-x-2">
                      <Checkbox id={condition.id} />
                      <Label htmlFor={condition.id} className="text-base font-normal cursor-pointer">
                        {condition.label}
                      </Label>
                    </div>
                  ))}
                </div>
              </div>

              <div>
                <Label htmlFor="medications">{t('healthCheckPage.medications')}</Label>
                <Textarea
                  id="medications"
                  placeholder={t('healthCheckPage.medicationsPlaceholder')}
                  className="text-lg min-h-24"
                />
              </div>
            </CardContent>
          </Card>

          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Activity className="h-5 w-5 text-primary" />
                {t('healthCheckPage.activityPreferences')}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label className="mb-3 block">{t('healthCheckPage.interestedIn')}</Label>
                <div className="space-y-3">
                  {[
                    { id: "exercise", label: t('healthCheckPage.exerciseFitness') },
                    { id: "arts", label: t('healthCheckPage.artsCrafts') },
                    { id: "music", label: t('healthCheckPage.musicDance') },
                    { id: "brain", label: t('healthCheckPage.brainGames') },
                    { id: "trips", label: t('healthCheckPage.dayTrips') },
                    { id: "social", label: t('healthCheckPage.socialEvents') },
                  ].map((interest) => (
                    <div key={interest.id} className="flex items-center space-x-2">
                      <Checkbox id={interest.id} />
                      <Label htmlFor={interest.id} className="text-base font-normal cursor-pointer">
                        {interest.label}
                      </Label>
                    </div>
                  ))}
                </div>
              </div>

              <div>
                <Label htmlFor="notes">{t('healthCheckPage.additionalNotes')}</Label>
                <Textarea
                  id="notes"
                  placeholder={t('healthCheckPage.notesPlaceholder')}
                  className="text-lg min-h-24"
                />
              </div>
            </CardContent>
          </Card>

          <div className="flex gap-4">
            <Button size="lg" className="btn-elderly flex-1">
              {t('healthCheckPage.submitButton')}
            </Button>
            <Button variant="outline" size="lg" className="btn-elderly">
              {t('healthCheckPage.saveDraft')}
            </Button>
          </div>
        </div>
      </div>
    </PublicLayout>
  );
}
