import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Calendar, Users, DollarSign, MapPin, Clock } from "lucide-react";

interface BookingModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  item: {
    type: "activity" | "trip";
    name: string;
    date: string;
    time?: string;
    duration: string;
    capacity?: number;
    price?: string;
    location?: string;
  };
}

export function BookingModal({ open, onOpenChange, item }: BookingModalProps) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle className="text-2xl">
            {item.type === "activity" ? "Book Activity" : "Book Trip"}
          </DialogTitle>
          <DialogDescription>
            Complete your booking for {item.name}
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 py-4">
          {/* Booking Details */}
          <div className="p-4 bg-muted rounded-lg space-y-3">
            <h3 className="font-semibold text-lg">{item.name}</h3>
            <div className="grid grid-cols-2 gap-3 text-sm">
              <div className="flex items-center gap-2">
                <Calendar className="h-4 w-4 text-muted-foreground" />
                <span>{item.date}</span>
              </div>
              {item.time && (
                <div className="flex items-center gap-2">
                  <Clock className="h-4 w-4 text-muted-foreground" />
                  <span>{item.time}</span>
                </div>
              )}
              <div className="flex items-center gap-2">
                <Clock className="h-4 w-4 text-muted-foreground" />
                <span>{item.duration}</span>
              </div>
              {item.capacity && (
                <div className="flex items-center gap-2">
                  <Users className="h-4 w-4 text-muted-foreground" />
                  <span>{item.capacity} max</span>
                </div>
              )}
              {item.location && (
                <div className="flex items-center gap-2 col-span-2">
                  <MapPin className="h-4 w-4 text-muted-foreground" />
                  <span>{item.location}</span>
                </div>
              )}
            </div>
            {item.price && (
              <div className="pt-2 border-t">
                <div className="flex items-center justify-between">
                  <span className="font-medium">Price:</span>
                  <span className="text-2xl font-bold text-primary">{item.price}</span>
                </div>
              </div>
            )}
          </div>

          {/* Booking Form */}
          <div className="space-y-4">
            <div>
              <Label htmlFor="participants">Number of Participants</Label>
              <Input 
                id="participants" 
                type="number" 
                min="1" 
                defaultValue="1" 
                className="text-lg"
              />
            </div>

            <div>
              <Label htmlFor="specialRequests">Special Requests (Optional)</Label>
              <Textarea
                id="specialRequests"
                placeholder="Dietary restrictions, accessibility needs, etc."
                className="min-h-20"
              />
            </div>

            <div>
              <Label htmlFor="emergencyContact">Emergency Contact</Label>
              <Input 
                id="emergencyContact" 
                placeholder="Name and phone number"
                className="text-lg"
              />
            </div>
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button onClick={() => {
            // Handle booking submission
            onOpenChange(false);
          }}>
            Confirm Booking
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
