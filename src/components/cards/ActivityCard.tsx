import { Calendar, Clock, Users } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";

interface ActivityCardProps {
  title: string;
  description: string;
  image?: string;
  time: string;
  duration: string;
  capacity?: number;
  intensity?: "Low" | "Medium" | "High";
  tags?: string[];
  onBook?: () => void;
  className?: string;
}

export function ActivityCard({
  title,
  description,
  image,
  time,
  duration,
  capacity,
  intensity,
  tags,
  onBook,
  className,
}: ActivityCardProps) {
  const intensityColors = {
    Low: "bg-secondary/10 text-secondary",
    Medium: "bg-primary/10 text-primary",
    High: "bg-destructive/10 text-destructive",
  };

  return (
    <div className={cn("rounded-xl bg-card border card-shadow hover:card-shadow-hover transition-all overflow-hidden", className)}>
      {image && (
        <div className="aspect-video overflow-hidden">
          <img src={image} alt={title} className="w-full h-full object-cover hover:scale-105 transition-transform" />
        </div>
      )}
      <div className="p-6 space-y-4">
        <div>
          <h3 className="text-2xl font-semibold mb-2">{title}</h3>
          <p className="text-lg text-muted-foreground">{description}</p>
        </div>
        
        <div className="space-y-2 text-base">
          <div className="flex items-center text-muted-foreground">
            <Calendar className="h-5 w-5 mr-2" />
            {time}
          </div>
          <div className="flex items-center text-muted-foreground">
            <Clock className="h-5 w-5 mr-2" />
            {duration}
          </div>
          {capacity && (
            <div className="flex items-center text-muted-foreground">
              <Users className="h-5 w-5 mr-2" />
              Up to {capacity} people
            </div>
          )}
        </div>

        {(intensity || tags) && (
          <div className="flex flex-wrap gap-2">
            {intensity && (
              <Badge className={intensityColors[intensity]}>{intensity} Intensity</Badge>
            )}
            {tags?.map((tag, index) => (
              <Badge key={index} variant="outline">{tag}</Badge>
            ))}
          </div>
        )}

        {onBook && (
          <Button className="w-full btn-elderly" onClick={onBook}>
            Book This Activity
          </Button>
        )}
      </div>
    </div>
  );
}
