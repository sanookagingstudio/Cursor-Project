import { MemberLayout } from "@/layouts/MemberLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { User, Mail, Phone, MapPin, Heart, Edit } from "lucide-react";
import { UserRolesBadge } from "@/components/UserRolesBadge";
import { useAuth } from "@/contexts/AuthContext";

export default function Profile() {
  const { user } = useAuth();
  
  return (
    <MemberLayout>
      <SectionHeader
        title="My Profile"
        description="Manage your personal information and preferences"
        actions={
          <Button size="lg" className="btn-elderly">
            <Edit className="mr-2 h-5 w-5" />
            Edit Profile
          </Button>
        }
      />

      <div className="grid lg:grid-cols-3 gap-6">
        <Card>
          <CardContent className="pt-6 text-center">
            <Avatar className="h-32 w-32 mx-auto mb-4">
              <AvatarFallback className="bg-primary text-primary-foreground text-4xl">
                {user?.email?.substring(0, 2).toUpperCase() || 'U'}
              </AvatarFallback>
            </Avatar>
            <h3 className="mb-2">{user?.email}</h3>
            <div className="mb-4 flex justify-center">
              <UserRolesBadge />
            </div>
            <p className="text-muted-foreground">Member since Jan 2024</p>
          </CardContent>
        </Card>

        <div className="lg:col-span-2 space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <User className="h-5 w-5 text-primary" />
                Personal Information
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <Label>First Name</Label>
                  <Input value="John" disabled className="text-lg" />
                </div>
                <div>
                  <Label>Last Name</Label>
                  <Input value="Doe" disabled className="text-lg" />
                </div>
              </div>
              <div>
                <Label className="flex items-center gap-2">
                  <Mail className="h-4 w-4" />
                  Email
                </Label>
                <Input value="john@example.com" disabled className="text-lg" />
              </div>
              <div>
                <Label className="flex items-center gap-2">
                  <Phone className="h-4 w-4" />
                  Phone
                </Label>
                <Input value="+66 8X XXX XXXX" disabled className="text-lg" />
              </div>
              <div>
                <Label className="flex items-center gap-2">
                  <MapPin className="h-4 w-4" />
                  Address
                </Label>
                <Textarea
                  value="123 Wellness Street, Sukhumvit, Bangkok 10110"
                  disabled
                  className="text-lg"
                />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Heart className="h-5 w-5 text-primary" />
                Health Information
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <Label>Age</Label>
                  <Input value="68" disabled className="text-lg" />
                </div>
                <div>
                  <Label>Mobility Level</Label>
                  <Input value="Fully Independent" disabled className="text-lg" />
                </div>
              </div>
              <div>
                <Label>Health Conditions</Label>
                <div className="flex gap-2 mt-2">
                  <Badge>High Blood Pressure</Badge>
                  <Badge>Arthritis</Badge>
                </div>
              </div>
              <div>
                <Label>Emergency Contact</Label>
                <Input value="Jane Doe - +66 9X XXX XXXX" disabled className="text-lg" />
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </MemberLayout>
  );
}
