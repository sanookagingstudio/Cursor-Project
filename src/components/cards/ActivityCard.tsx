import { Calendar, Clock, Users } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import { useTranslation } from "react-i18next";
import { EditableText, EditableImage, Editable } from "@/components/editor/Editable";

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
  idPrefix?: string;
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
  idPrefix = "activity"
}: ActivityCardProps) {
  const { t } = useTranslation();
  const intensityColors = {
    Low: "bg-secondary/10 text-secondary",
    Medium: "bg-primary/10 text-primary",
    High: "bg-destructive/10 text-destructive",
  };

  return (
    <div className={cn("rounded-xl bg-card border card-shadow hover:card-shadow-hover transition-all overflow-hidden", className)}>
      {image && (
        <div className="aspect-video overflow-hidden">
          <EditableImage 
            id={`${idPrefix}.image`}
            src={image} 
            alt={title} 
            className="w-full h-full object-cover hover:scale-105 transition-transform" 
          />
        </div>
      )}
      <div className="p-6 space-y-4">
        <div>
          <EditableText 
            id={`${idPrefix}.title`} 
            as="h3" 
            className="text-2xl font-semibold mb-2" 
            text={title} 
          />
          <EditableText 
            id={`${idPrefix}.description`} 
            as="p" 
            className="text-lg text-muted-foreground" 
            text={description} 
          />
        </div>
        
        <div className="space-y-2 text-base">
          <div className="flex items-center text-muted-foreground">
            <Editable id={`${idPrefix}.icon.time`} type="icon" className="mr-2">
              <Calendar className="h-5 w-5" />
            </Editable>
            <EditableText id={`${idPrefix}.time`} as="span" text={time} />
          </div>
          <div className="flex items-center text-muted-foreground">
            <Editable id={`${idPrefix}.icon.duration`} type="icon" className="mr-2">
              <Clock className="h-5 w-5" />
            </Editable>
            <EditableText id={`${idPrefix}.duration`} as="span" text={duration} />
          </div>
          {capacity && (
            <div className="flex items-center text-muted-foreground">
              <Editable id={`${idPrefix}.icon.capacity`} type="icon" className="mr-2">
                <Users className="h-5 w-5" />
              </Editable>
              <EditableText 
                id={`${idPrefix}.capacity`} 
                as="span" 
                text={`${t('common.upTo', { count: capacity })} ${t('common.people')}`}
              />
            </div>
          )}
        </div>

        {(intensity || tags) && (
          <div className="flex flex-wrap gap-2">
            {intensity && (
              <Editable id={`${idPrefix}.badge.intensity`} className={cn("badge", intensityColors[intensity])}>
                <Badge className={cn(intensityColors[intensity], "bg-transparent hover:bg-transparent shadow-none border-none p-0")}>
                   {t(`activitiesPage.${intensity.toLowerCase()}`)} {t('common.intensity')}
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
            <EditableText id={`${idPrefix}.btn`} text={t('common.bookActivity')} />
          </Button>
        )}
      </div>
    </div>
  );
}
