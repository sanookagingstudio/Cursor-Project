import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { 
  MapPin, 
  Calendar, 
  Clock, 
  Users, 
  DollarSign, 
  Car,
  Utensils,
  Bed,
  AlertCircle
} from "lucide-react";

interface TripSummaryModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  trip: {
    name: string;
    destination: string;
    date: string;
    duration: string;
    participants: number;
    price: string;
    vehicle: string;
    accommodation?: string;
    meals: string;
    specialRequests?: string;
    difficulty: string;
  };
}

export function TripSummaryModal({ open, onOpenChange, trip }: TripSummaryModalProps) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[600px] max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="text-2xl">Trip Summary</DialogTitle>
          <DialogDescription>
            Review your trip details before confirmation
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6 py-4">
          {/* Trip Header */}
          <div className="space-y-2">
            <h3 className="text-xl font-bold">{trip.name}</h3>
            <div className="flex items-center gap-2 text-muted-foreground">
              <MapPin className="h-4 w-4" />
              <span>{trip.destination}</span>
            </div>
            <div className="flex gap-2">
              <Badge variant="secondary">{trip.difficulty}</Badge>
              <Badge>{trip.duration}</Badge>
            </div>
          </div>

          <Separator />

          {/* Trip Details Grid */}
          <div className="grid md:grid-cols-2 gap-4">
            <div className="flex items-start gap-3">
              <Calendar className="h-5 w-5 text-primary mt-0.5" />
              <div>
                <p className="font-medium">Date</p>
                <p className="text-sm text-muted-foreground">{trip.date}</p>
              </div>
            </div>

            <div className="flex items-start gap-3">
              <Clock className="h-5 w-5 text-primary mt-0.5" />
              <div>
                <p className="font-medium">Duration</p>
                <p className="text-sm text-muted-foreground">{trip.duration}</p>
              </div>
            </div>

            <div className="flex items-start gap-3">
              <Users className="h-5 w-5 text-primary mt-0.5" />
              <div>
                <p className="font-medium">Participants</p>
                <p className="text-sm text-muted-foreground">{trip.participants} people</p>
              </div>
            </div>

            <div className="flex items-start gap-3">
              <Car className="h-5 w-5 text-primary mt-0.5" />
              <div>
                <p className="font-medium">Vehicle</p>
                <p className="text-sm text-muted-foreground">{trip.vehicle}</p>
              </div>
            </div>

            {trip.accommodation && (
              <div className="flex items-start gap-3">
                <Bed className="h-5 w-5 text-primary mt-0.5" />
                <div>
                  <p className="font-medium">Accommodation</p>
                  <p className="text-sm text-muted-foreground">{trip.accommodation}</p>
                </div>
              </div>
            )}

            <div className="flex items-start gap-3">
              <Utensils className="h-5 w-5 text-primary mt-0.5" />
              <div>
                <p className="font-medium">Meals</p>
                <p className="text-sm text-muted-foreground">{trip.meals}</p>
              </div>
            </div>
          </div>

          {trip.specialRequests && (
            <>
              <Separator />
              <div className="flex items-start gap-3">
                <AlertCircle className="h-5 w-5 text-primary mt-0.5" />
                <div>
                  <p className="font-medium mb-1">Special Requests</p>
                  <p className="text-sm text-muted-foreground">{trip.specialRequests}</p>
                </div>
              </div>
            </>
          )}

          <Separator />

          {/* Price Breakdown */}
          <div className="bg-primary/5 p-4 rounded-lg space-y-3">
            <div className="flex justify-between items-center">
              <span className="text-sm text-muted-foreground">Base Price</span>
              <span className="font-medium">฿{parseInt(trip.price.replace(/[^\d]/g, ''))}</span>
            </div>
            {trip.accommodation && (
              <div className="flex justify-between items-center">
                <span className="text-sm text-muted-foreground">Accommodation</span>
                <span className="font-medium">฿2,000</span>
              </div>
            )}
            <Separator />
            <div className="flex justify-between items-center">
              <span className="font-semibold text-lg">Total</span>
              <span className="text-2xl font-bold text-primary flex items-center gap-1">
                <DollarSign className="h-5 w-5" />
                {trip.price}
              </span>
            </div>
          </div>
        </div>

        <div className="flex gap-2">
          <Button variant="outline" onClick={() => onOpenChange(false)} className="flex-1">
            Edit Details
          </Button>
          <Button onClick={() => {
            // Handle confirmation
            onOpenChange(false);
          }} className="flex-1">
            Confirm & Pay
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}
