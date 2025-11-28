import { MapPin, Calendar, DollarSign, Users } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";

interface TripCardProps {
  title: string;
  description: string;
  image?: string;
  location: string;
  date: string;
  duration: string;
  price: string;
  difficulty?: "Easy" | "Moderate" | "Challenging";
  tags?: string[];
  onBook?: () => void;
  className?: string;
}

export function TripCard({
  title,
  description,
  image,
  location,
  date,
  duration,
  price,
  difficulty,
  tags,
  onBook,
  className,
}: TripCardProps) {
  const difficultyColors = {
    Easy: "bg-secondary/10 text-secondary",
    Moderate: "bg-primary/10 text-primary",
    Challenging: "bg-destructive/10 text-destructive",
  };

  return (
    <div className={cn("rounded-xl bg-card border card-shadow hover:card-shadow-hover transition-all overflow-hidden", className)}>
      {image && (
        <div className="aspect-video overflow-hidden relative">
          <img src={image} alt={title} className="w-full h-full object-cover hover:scale-105 transition-transform" />
          <div className="absolute top-4 right-4 bg-white/95 backdrop-blur px-3 py-1 rounded-full font-semibold text-primary">
            {price}
          </div>
        </div>
      )}
      <div className="p-6 space-y-4">
        <div>
          <h3 className="text-xl font-semibold mb-2">{title}</h3>
          <p className="text-muted-foreground">{description}</p>
        </div>
        
        <div className="space-y-2 text-sm">
          <div className="flex items-center text-muted-foreground">
            <MapPin className="h-4 w-4 mr-2" />
            {location}
          </div>
          <div className="flex items-center text-muted-foreground">
            <Calendar className="h-4 w-4 mr-2" />
            {date} • {duration}
          </div>
        </div>

        {(difficulty || tags) && (
          <div className="flex flex-wrap gap-2">
            {difficulty && (
              <Badge className={difficultyColors[difficulty]}>{difficulty}</Badge>
            )}
            {tags?.map((tag, index) => (
              <Badge key={index} variant="outline">{tag}</Badge>
            ))}
          </div>
        )}

        {onBook && (
          <Button className="w-full btn-elderly" onClick={onBook}>
            View Trip Details
          </Button>
        )}
      </div>
    </div>
  );
}
