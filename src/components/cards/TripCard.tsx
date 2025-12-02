import { MapPin, Calendar, DollarSign, Users } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import { useTranslation } from "react-i18next";
import { EditableText, EditableImage, Editable } from "@/components/editor/Editable";

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
  idPrefix?: string; // Added idPrefix
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
  idPrefix = "trip", // Default prefix
}: TripCardProps) {
  const { t } = useTranslation();
  const difficultyColors = {
    Easy: "bg-secondary/10 text-secondary",
    Moderate: "bg-primary/10 text-primary",
    Challenging: "bg-destructive/10 text-destructive",
  };

  return (
    <div className={cn("rounded-xl bg-card border card-shadow hover:card-shadow-hover transition-all overflow-hidden", className)}>
      {image && (
        <div className="aspect-video overflow-hidden relative">
          <EditableImage 
            id={`${idPrefix}.image`}
            src={image} 
            alt={title} 
            className="w-full h-full object-cover hover:scale-105 transition-transform" 
          />
          <div className="absolute top-4 right-4 bg-white/95 backdrop-blur px-3 py-1 rounded-full font-semibold text-primary">
            <EditableText id={`${idPrefix}.price`} text={price} />
          </div>
        </div>
      )}
      <div className="p-6 space-y-4">
        <div>
          <EditableText 
            id={`${idPrefix}.title`} 
            as="h3" 
            className="text-xl font-semibold mb-2" 
            text={title} 
          />
          <EditableText 
            id={`${idPrefix}.description`} 
            as="p" 
            className="text-muted-foreground" 
            text={description} 
          />
        </div>
        
        <div className="space-y-2 text-sm">
          <div className="flex items-center text-muted-foreground">
            <Editable id={`${idPrefix}.icon.location`} type="icon" className="mr-2">
                <MapPin className="h-4 w-4" />
            </Editable>
            <EditableText id={`${idPrefix}.location`} as="span" text={location} />
          </div>
          <div className="flex items-center text-muted-foreground">
            <Editable id={`${idPrefix}.icon.calendar`} type="icon" className="mr-2">
                <Calendar className="h-4 w-4" />
            </Editable>
            <span className="flex items-center gap-1">
                <EditableText id={`${idPrefix}.date`} as="span" text={date} />
                <span>•</span>
                <EditableText id={`${idPrefix}.duration`} as="span" text={duration} />
            </span>
          </div>
        </div>

        {(difficulty || tags) && (
          <div className="flex flex-wrap gap-2">
            {difficulty && (
              <Editable id={`${idPrefix}.badge.difficulty`} className={cn("badge", difficultyColors[difficulty])}>
                  <Badge className={cn(difficultyColors[difficulty], "bg-transparent hover:bg-transparent shadow-none border-none p-0")}>
                    {t(`tripsPage.${difficulty.toLowerCase()}`)}
                  </Badge>
              </Editable>
            )}
            {tags?.map((tag, index) => (
              <EditableText 
                key={index}
                id={`${idPrefix}.tag.${index}`}
                as={Badge}
                variant="outline"
                text={tag}
              />
            ))}
          </div>
        )}

        {onBook && (
          <Button className="w-full btn-elderly" onClick={onBook}>
            <EditableText id={`${idPrefix}.btn`} text={t('common.viewTrip')} />
          </Button>
        )}
      </div>
    </div>
  );
}
