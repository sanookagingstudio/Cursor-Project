import { PublicLayout } from "@/layouts/PublicLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Stepper } from "@/components/ui/stepper";
import { useState } from "react";
import { MapPin, Users, Calendar, DollarSign, Car, Utensils, Sparkles } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { useTranslation } from "react-i18next";

export default function CustomTripBuilder() {
  const { t } = useTranslation();
  const [currentStep, setCurrentStep] = useState(0);

  const steps = [
    { label: t('customTripPage.step1') },
    { label: t('customTripPage.step2') },
    { label: t('customTripPage.step3') },
    { label: t('customTripPage.step4') },
    { label: t('customTripPage.step5') },
  ];

  return (
    <PublicLayout>
      <div className="container-padding section-padding max-w-5xl mx-auto">
        <SectionHeader
          title={t('customTripPage.title')}
          description={t('customTripPage.description')}
        />

        <Card className="mb-6">
          <CardContent className="pt-6">
            <Stepper steps={steps} currentStep={currentStep} />
          </CardContent>
        </Card>

        {/* Step 1: Date and People */}
        {currentStep === 0 && (
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Calendar className="h-5 w-5" />
                {t('customTripPage.step1')}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="startDate">{t('customTripPage.startDate')}</Label>
                  <Input id="startDate" type="date" className="text-lg" />
                </div>
                <div>
                  <Label htmlFor="endDate">{t('customTripPage.endDate')}</Label>
                  <Input id="endDate" type="date" className="text-lg" />
                </div>
              </div>

              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="departTime">{t('customTripPage.departTime')}</Label>
                  <Input id="departTime" type="time" className="text-lg" />
                </div>
                <div>
                  <Label htmlFor="numPeople">{t('customTripPage.numPeople')}</Label>
                  <Input id="numPeople" type="number" min="1" placeholder={t('customTripPage.numPeoplePlaceholder')} className="text-lg" />
                </div>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Step 2: Participant Details */}
        {currentStep === 1 && (
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Users className="h-5 w-5" />
                {t('customTripPage.participantInfo')}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="p-4 bg-muted rounded-lg">
                <h4 className="font-semibold mb-3">{t('customTripPage.participant')} #1</h4>
                <div className="grid md:grid-cols-3 gap-4">
                  <div>
                    <Label htmlFor="age1">{t('customTripPage.age')}</Label>
                    <Input id="age1" type="number" placeholder={t('customTripPage.agePlaceholder')} className="text-lg" />
                  </div>
                  <div>
                    <Label htmlFor="gender1">{t('customTripPage.gender')}</Label>
                    <Select>
                      <SelectTrigger className="text-lg">
                        <SelectValue placeholder={t('customTripPage.genderSelect')} />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="male">{t('customTripPage.male')}</SelectItem>
                        <SelectItem value="female">{t('customTripPage.female')}</SelectItem>
                        <SelectItem value="other">{t('customTripPage.other')}</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div>
                    <Label htmlFor="mobility1">{t('customTripPage.mobility')}</Label>
                    <Select>
                      <SelectTrigger className="text-lg">
                        <SelectValue placeholder={t('customTripPage.mobilitySelect')} />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="good">{t('customTripPage.mobilityGood')}</SelectItem>
                        <SelectItem value="moderate">{t('customTripPage.mobilityModerate')}</SelectItem>
                        <SelectItem value="limited">{t('customTripPage.mobilityLimited')}</SelectItem>
                        <SelectItem value="wheelchair">{t('customTripPage.mobilityWheelchair')}</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              </div>

              <Button variant="outline" className="w-full">
                {t('customTripPage.addParticipant')}
              </Button>
            </CardContent>
          </Card>
        )}

        {/* Step 3: Destinations */}
        {currentStep === 2 && (
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <MapPin className="h-5 w-5" />
                {t('customTripPage.selectDestinations')}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label htmlFor="destination1">{t('customTripPage.destination')} 1</Label>
                <Input id="destination1" placeholder={t('customTripPage.searchDestination')} className="text-lg mb-2" />
                <Badge variant="outline" className="mr-2">
                  <Sparkles className="h-3 w-3 mr-1" />
                  {t('customTripPage.aiRouteNote')}
                </Badge>
              </div>

              <div>
                <Label htmlFor="destination2">{t('customTripPage.destination')} 2</Label>
                <Input id="destination2" placeholder={t('customTripPage.searchDestination')} className="text-lg" />
              </div>

              <Button variant="outline" className="w-full">
                {t('customTripPage.addDestination')}
              </Button>

              <div className="p-4 bg-accent/10 rounded-lg border border-accent/20">
                <p className="text-sm text-accent-foreground flex items-center gap-2">
                  <Sparkles className="h-4 w-4" />
                  {t('customTripPage.aiDistanceNote')}
                </p>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Step 4: Accommodation & Food */}
        {currentStep === 3 && (
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Utensils className="h-5 w-5" />
                {t('customTripPage.accommodationFood')}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="rooms">{t('customTripPage.rooms')}</Label>
                  <Input id="rooms" type="number" min="0" placeholder={t('customTripPage.roomsPlaceholder')} className="text-lg" />
                </div>
                <div>
                  <Label htmlFor="roomType">{t('customTripPage.roomType')}</Label>
                  <Select>
                    <SelectTrigger className="text-lg">
                      <SelectValue placeholder={t('customTripPage.roomTypeSelect')} />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="standard">{t('customTripPage.standard')}</SelectItem>
                      <SelectItem value="deluxe">{t('customTripPage.deluxe')}</SelectItem>
                      <SelectItem value="suite">{t('customTripPage.suite')}</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <div>
                <Label htmlFor="meals">{t('customTripPage.meals')}</Label>
                <Select>
                  <SelectTrigger className="text-lg">
                    <SelectValue placeholder={t('customTripPage.mealsSelect')} />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="0">{t('customTripPage.noMeals')}</SelectItem>
                    <SelectItem value="1">{t('customTripPage.oneMeal')}</SelectItem>
                    <SelectItem value="2">{t('customTripPage.twoMeals')}</SelectItem>
                    <SelectItem value="3">{t('customTripPage.threeMeals')}</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div>
                <Label htmlFor="vehicle">{t('customTripPage.vehicle')}</Label>
                <Select>
                  <SelectTrigger className="text-lg">
                    <SelectValue placeholder={t('customTripPage.vehicleSelect')} />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="van">{t('customTripPage.van')}</SelectItem>
                    <SelectItem value="minibus">{t('customTripPage.minibus')}</SelectItem>
                    <SelectItem value="bus">{t('customTripPage.bus')}</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Step 5: Special Requirements */}
        {currentStep === 4 && (
          <Card>
            <CardHeader>
              <CardTitle>{t('customTripPage.specialRequirements')}</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label htmlFor="dietary">{t('customTripPage.dietary')}</Label>
                <Textarea
                  id="dietary"
                  placeholder={t('customTripPage.dietaryPlaceholder')}
                  className="text-lg min-h-24"
                />
              </div>

              <div>
                <Label htmlFor="medical">{t('customTripPage.medical')}</Label>
                <Textarea
                  id="medical"
                  placeholder={t('customTripPage.medicalPlaceholder')}
                  className="text-lg min-h-24"
                />
              </div>

              <div>
                <Label htmlFor="other">{t('customTripPage.otherRequirements')}</Label>
                <Textarea
                  id="other"
                  placeholder={t('customTripPage.otherPlaceholder')}
                  className="text-lg min-h-24"
                />
              </div>

              <div className="p-4 bg-primary/10 rounded-lg border border-primary/20">
                <h4 className="font-semibold mb-2 flex items-center gap-2">
                  <DollarSign className="h-5 w-5 text-primary" />
                  {t('customTripPage.estimatedPrice')}
                </h4>
                <div className="space-y-1">
                  <p className="text-2xl font-bold text-primary">฿15,800</p>
                  <p className="text-sm text-muted-foreground">
                    {t('customTripPage.distance')}: 285 กม. | {t('customTripPage.travelTime')}: 4 ชม. 30 นาที
                  </p>
                  <Badge className="bg-accent/10 text-accent">
                    {t('customTripPage.cost')}: ฿12,500 ({t('customTripPage.staffOnly')})
                  </Badge>
                </div>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Navigation */}
        <div className="flex justify-between mt-6">
          <Button
            variant="outline"
            size="lg"
            onClick={() => setCurrentStep(Math.max(0, currentStep - 1))}
            disabled={currentStep === 0}
          >
            {t('customTripPage.backButton')}
          </Button>
          {currentStep < steps.length - 1 ? (
            <Button
              size="lg"
              className="btn-elderly"
              onClick={() => setCurrentStep(Math.min(steps.length - 1, currentStep + 1))}
            >
              {t('customTripPage.nextButton')}
            </Button>
          ) : (
            <Button size="lg" className="btn-elderly">
              <Sparkles className="h-5 w-5 mr-2" />
              {t('customTripPage.createTripButton')}
            </Button>
          )}
        </div>
      </div>
    </PublicLayout>
  );
}
