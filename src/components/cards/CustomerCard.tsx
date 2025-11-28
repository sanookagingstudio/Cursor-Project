import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Mail, Phone, Calendar, Edit, Eye, MapPin } from "lucide-react";

interface CustomerCardProps {
  customer: {
    id: number | string;
    name: string;
    memberID: string;
    email: string;
    phone: string;
    plan: string;
    status: "active" | "inactive";
    joinDate: string;
    location?: string;
    avatar?: string;
  };
  onView?: () => void;
  onEdit?: () => void;
}

export function CustomerCard({ customer, onView, onEdit }: CustomerCardProps) {
  const initials = customer.name
    .split(' ')
    .map(n => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);

  return (
    <Card className="hover:shadow-md transition-shadow">
      <CardContent className="pt-6">
        <div className="flex items-start gap-4">
          <Avatar className="h-16 w-16">
            <AvatarImage src={customer.avatar} />
            <AvatarFallback className="text-lg">{initials}</AvatarFallback>
          </Avatar>
          
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between gap-2 mb-2">
              <div>
                <h3 className="font-semibold text-lg truncate">{customer.name}</h3>
                <Badge variant="outline" className="text-xs">
                  {customer.memberID}
                </Badge>
              </div>
              <Badge variant={customer.status === "active" ? "default" : "secondary"}>
                {customer.status}
              </Badge>
            </div>

            <div className="space-y-2 text-sm text-muted-foreground">
              <div className="flex items-center gap-2">
                <Mail className="h-3 w-3 flex-shrink-0" />
                <span className="truncate">{customer.email}</span>
              </div>
              <div className="flex items-center gap-2">
                <Phone className="h-3 w-3 flex-shrink-0" />
                <span>{customer.phone}</span>
              </div>
              {customer.location && (
                <div className="flex items-center gap-2">
                  <MapPin className="h-3 w-3 flex-shrink-0" />
                  <span className="truncate">{customer.location}</span>
                </div>
              )}
              <div className="flex items-center gap-2">
                <Calendar className="h-3 w-3 flex-shrink-0" />
                <span>Member since {customer.joinDate}</span>
              </div>
            </div>

            <div className="flex items-center gap-2 mt-3">
              <Badge variant="secondary">{customer.plan}</Badge>
            </div>

            <div className="flex gap-2 mt-4">
              <Button variant="outline" size="sm" onClick={onView} className="flex-1">
                <Eye className="h-3 w-3 mr-1" />
                View
              </Button>
              <Button variant="outline" size="sm" onClick={onEdit} className="flex-1">
                <Edit className="h-3 w-3 mr-1" />
                Edit
              </Button>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
