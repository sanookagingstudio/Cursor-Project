import { PublicLayout } from "@/layouts/PublicLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useState } from "react";
import { Upload, Camera, Sparkles, QrCode, CheckCircle, Shield, Gift, Edit } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { useTranslation } from "react-i18next";
import { Link } from "react-router-dom";

export default function JoinNow() {
  const { t } = useTranslation();
  const [registrationMethod, setRegistrationMethod] = useState<"ocr" | "manual" | null>(null);
  const [idCardUploaded, setIdCardUploaded] = useState(false);
  const [memberData, setMemberData] = useState({
    memberId: "",
    qrCode: "",
  });

  const handleIdCardUpload = () => {
    // Simulate OCR processing
    setTimeout(() => {
      setIdCardUploaded(true);
      setMemberData({
        memberId: "FUN" + Math.random().toString(36).substr(2, 9).toUpperCase(),
        qrCode: "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=FUN-MEMBER",
      });
    }, 1500);
  };

  return (
    <PublicLayout>
      <div className="container-padding section-padding max-w-5xl mx-auto">
        <SectionHeader
          title={t('joinNowPage.title')}
          description={t('joinNowPage.description')}
        />

        {!registrationMethod ? (
          <>
            {/* Method Selection */}
            <Card className="mb-8">
              <CardHeader className="text-center">
                <CardTitle className="text-2xl">{t('joinNowPage.chooseMethod')}</CardTitle>
              </CardHeader>
              <CardContent className="grid md:grid-cols-2 gap-6">
                {/* OCR Method */}
                <Card 
                  className="cursor-pointer hover:shadow-xl transition-all border-2 hover:border-primary relative overflow-hidden"
                  onClick={() => setRegistrationMethod("ocr")}
                >
                  <div className="absolute top-4 right-4">
                    <Badge className="bg-primary text-white">{t('promotionsPage.newMember')}</Badge>
                  </div>
                  <CardHeader>
                    <div className="w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center mx-auto mb-4">
                      <Camera className="h-8 w-8 text-primary" />
                    </div>
                    <CardTitle className="text-center text-xl">
                      {t('joinNowPage.methodOcr')}
                    </CardTitle>
                    <CardDescription className="text-center text-base">
                      {t('joinNowPage.methodOcrDesc')}
                    </CardDescription>
                  </CardHeader>
                  <CardContent>
                    <Button className="w-full btn-elderly" size="lg">
                      <Camera className="h-5 w-5 mr-2" />
                      {t('joinNowPage.selectFile')}
                    </Button>
                  </CardContent>
                </Card>

                {/* Manual Method */}
                <Card 
                  className="cursor-pointer hover:shadow-xl transition-all border-2 hover:border-primary"
                  onClick={() => setRegistrationMethod("manual")}
                >
                  <CardHeader>
                    <div className="w-16 h-16 rounded-full bg-secondary/10 flex items-center justify-center mx-auto mb-4">
                      <Edit className="h-8 w-8 text-secondary" />
                    </div>
                    <CardTitle className="text-center text-xl">
                      {t('joinNowPage.methodManual')}
                    </CardTitle>
                    <CardDescription className="text-center text-base">
                      {t('joinNowPage.methodManualDesc')}
                    </CardDescription>
                  </CardHeader>
                  <CardContent>
                    <Button variant="secondary" className="w-full" size="lg">
                      <Edit className="h-5 w-5 mr-2" />
                      {t('common.continue')}
                    </Button>
                  </CardContent>
                </Card>
              </CardContent>
            </Card>

            {/* Benefits Section */}
            <Card className="bg-gradient-to-br from-primary/5 to-primary/10 border-primary/20">
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-xl">
                  <Gift className="h-6 w-6 text-primary" />
                  {t('joinNowPage.benefits')}
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid md:grid-cols-2 gap-4 mb-6">
                  {[1, 2, 3, 4, 5, 6].map((num) => (
                    <div key={num} className="flex items-start gap-3">
                      <CheckCircle className="h-5 w-5 text-primary shrink-0 mt-0.5" />
                      <span className="text-base">{t(`joinNowPage.benefit${num}`)}</span>
                    </div>
                  ))}
                </div>
                <Link to="/promotions">
                  <Button variant="outline" className="w-full" size="lg">
                    <Sparkles className="h-5 w-5 mr-2" />
                    {t('joinNowPage.viewPromotions')}
                  </Button>
                </Link>
              </CardContent>
            </Card>

            {/* Privacy Section */}
            <Alert className="mt-8 border-2">
              <Shield className="h-5 w-5" />
              <AlertDescription>
                <div className="font-semibold text-base mb-2">{t('joinNowPage.privacyTitle')}</div>
                <div className="text-sm text-muted-foreground leading-relaxed">
                  {t('joinNowPage.privacyDesc')}
                </div>
              </AlertDescription>
            </Alert>
          </>
        ) : registrationMethod === "ocr" ? (
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle className="flex items-center gap-2">
                  <Camera className="h-5 w-5" />
                  {t('joinNowPage.uploadIdCard')}
                </CardTitle>
                <Button variant="ghost" onClick={() => setRegistrationMethod(null)}>
                  {t('common.back')}
                </Button>
              </div>
            </CardHeader>
            <CardContent className="space-y-6">
            {/* ID Card Upload */}
            <div className="border-2 border-dashed border-muted-foreground/25 rounded-lg p-8 text-center hover:border-primary transition-colors cursor-pointer">
              <Upload className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
              <p className="text-lg mb-2">{t('joinNowPage.uploadArea')}</p>
              <p className="text-sm text-muted-foreground mb-4">
                {t('joinNowPage.ocrNote')}
              </p>
              <Button onClick={handleIdCardUpload} className="btn-elderly">
                <Camera className="h-4 w-4 mr-2" />
                {t('joinNowPage.selectFile')}
              </Button>
            </div>

              {idCardUploaded && (
                <>
                  <div className="p-4 bg-accent/10 rounded-lg border border-accent/20">
                    <div className="flex items-center gap-2 mb-2">
                      <CheckCircle className="h-5 w-5 text-accent" />
                      <span className="font-semibold text-accent">{t('joinNowPage.readSuccess')}</span>
                    </div>
                    <p className="text-sm text-muted-foreground">
                      {t('joinNowPage.verifyNote')}
                    </p>
                  </div>

                  {/* Auto-filled Form */}
                  <div className="space-y-4">
                    <div className="grid md:grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="firstName">{t('joinNowPage.firstName')}</Label>
                        <Input id="firstName" defaultValue="สมชาย" className="text-lg" />
                      </div>
                      <div>
                        <Label htmlFor="lastName">{t('joinNowPage.lastName')}</Label>
                        <Input id="lastName" defaultValue="ใจดี" className="text-lg" />
                      </div>
                    </div>

                    <div className="grid md:grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="idNumber">{t('joinNowPage.idNumber')}</Label>
                        <Input id="idNumber" defaultValue="1-2345-67890-12-3" className="text-lg" />
                      </div>
                      <div>
                        <Label htmlFor="birthDate">{t('joinNowPage.birthDate')}</Label>
                        <Input id="birthDate" defaultValue="01/01/1960" className="text-lg" />
                      </div>
                    </div>

                    <div>
                      <Label htmlFor="address">{t('joinNowPage.address')}</Label>
                      <Input id="address" defaultValue="123 ถนนสุขุมวิท กรุงเทพฯ" className="text-lg" />
                    </div>

                    <div className="grid md:grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="phone">{t('joinNowPage.phone')}</Label>
                        <Input id="phone" placeholder={t('joinNowPage.phonePlaceholder')} className="text-lg" />
                      </div>
                      <div>
                        <Label htmlFor="email">{t('joinNowPage.email')}</Label>
                        <Input id="email" type="email" placeholder={t('joinNowPage.emailPlaceholder')} className="text-lg" />
                      </div>
                    </div>
                  </div>

                  {/* Member ID & QR Code */}
                  <div className="grid md:grid-cols-2 gap-6">
                    <Card className="bg-gradient-primary text-white">
                      <CardHeader>
                        <CardTitle className="text-white flex items-center gap-2">
                          <Sparkles className="h-5 w-5" />
                          {t('joinNowPage.memberId')}
                        </CardTitle>
                      </CardHeader>
                      <CardContent>
                        <Badge className="bg-white/20 text-white text-lg px-4 py-2">
                          {memberData.memberId}
                        </Badge>
                      </CardContent>
                    </Card>

                    <Card>
                      <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                          <QrCode className="h-5 w-5" />
                          {t('joinNowPage.qrCode')}
                        </CardTitle>
                      </CardHeader>
                      <CardContent className="flex justify-center">
                        <img
                          src={memberData.qrCode}
                          alt="Member QR Code"
                          className="w-32 h-32 rounded-lg"
                        />
                      </CardContent>
                    </Card>
                  </div>

                  <Button className="w-full btn-elderly" size="lg">
                    <CheckCircle className="h-5 w-5 mr-2" />
                    {t('joinNowPage.confirmButton')}
                  </Button>
                </>
              )}
            </CardContent>
          </Card>
        ) : (
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle className="flex items-center gap-2">
                  <Edit className="h-5 w-5" />
                  {t('joinNowPage.methodManual')}
                </CardTitle>
                <Button variant="ghost" onClick={() => setRegistrationMethod(null)}>
                  {t('common.back')}
                </Button>
              </div>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="space-y-4">
                <div className="grid md:grid-cols-2 gap-4">
                  <div>
                    <Label htmlFor="firstName">{t('joinNowPage.firstName')}</Label>
                    <Input id="firstName" className="text-lg" />
                  </div>
                  <div>
                    <Label htmlFor="lastName">{t('joinNowPage.lastName')}</Label>
                    <Input id="lastName" className="text-lg" />
                  </div>
                </div>

                <div className="grid md:grid-cols-2 gap-4">
                  <div>
                    <Label htmlFor="birthDate">{t('joinNowPage.birthDate')}</Label>
                    <Input id="birthDate" type="date" className="text-lg" />
                  </div>
                  <div>
                    <Label htmlFor="phone">{t('joinNowPage.phone')}</Label>
                    <Input id="phone" placeholder={t('joinNowPage.phonePlaceholder')} className="text-lg" />
                  </div>
                </div>

                <div>
                  <Label htmlFor="email">{t('joinNowPage.email')}</Label>
                  <Input id="email" type="email" placeholder={t('joinNowPage.emailPlaceholder')} className="text-lg" />
                </div>

                <div>
                  <Label htmlFor="address">{t('joinNowPage.address')}</Label>
                  <Input id="address" className="text-lg" />
                </div>
              </div>

              <Button className="w-full btn-elderly" size="lg">
                <CheckCircle className="h-5 w-5 mr-2" />
                {t('joinNowPage.confirmButton')}
              </Button>
            </CardContent>
          </Card>
        )}
      </div>
    </PublicLayout>
  );
}
