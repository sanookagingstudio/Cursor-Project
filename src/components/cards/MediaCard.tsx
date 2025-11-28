import { Play, Headphones, FileText, Clock } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";

interface MediaCardProps {
  title: string;
  description: string;
  thumbnail?: string;
  type: "video" | "podcast" | "article";
  duration?: string;
  category?: string;
  onView?: () => void;
  className?: string;
}

export function MediaCard({
  title,
  description,
  thumbnail,
  type,
  duration,
  category,
  onView,
  className,
}: MediaCardProps) {
  const typeIcons = {
    video: Play,
    podcast: Headphones,
    article: FileText,
  };

  const typeLabels = {
    video: "Video",
    podcast: "Podcast",
    article: "Article",
  };

  const Icon = typeIcons[type];

  return (
    <div className={cn("rounded-xl bg-card border card-shadow hover:card-shadow-hover transition-all overflow-hidden", className)}>
      {thumbnail && (
        <div className="aspect-video overflow-hidden relative group">
          <img src={thumbnail} alt={title} className="w-full h-full object-cover group-hover:scale-105 transition-transform" />
          <div className="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
            <div className="w-16 h-16 rounded-full bg-white/90 flex items-center justify-center">
              <Icon className="h-8 w-8 text-primary" />
            </div>
          </div>
          {duration && (
            <div className="absolute bottom-4 right-4 bg-black/80 text-white px-2 py-1 rounded text-sm flex items-center">
              <Clock className="h-3 w-3 mr-1" />
              {duration}
            </div>
          )}
        </div>
      )}
      <div className="p-6 space-y-4">
        <div className="flex items-center gap-2">
          <Badge variant="outline">
            <Icon className="h-3 w-3 mr-1" />
            {typeLabels[type]}
          </Badge>
          {category && <Badge variant="secondary">{category}</Badge>}
        </div>
        
        <div>
          <h3 className="text-xl font-semibold mb-2">{title}</h3>
          <p className="text-muted-foreground line-clamp-2">{description}</p>
        </div>

        {onView && (
          <Button variant="outline" className="w-full" onClick={onView}>
            View {typeLabels[type]}
          </Button>
        )}
      </div>
    </div>
  );
}
