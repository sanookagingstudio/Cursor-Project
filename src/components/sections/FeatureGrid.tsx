import { ReactNode } from "react";
import { LucideIcon } from "lucide-react";
import { cn } from "@/lib/utils";
import { EditableText } from "@/components/editor/Editable";

interface Feature {
  icon: LucideIcon;
  title: string;
  description: string;
}

interface FeatureGridProps {
  title?: string;
  description?: string;
  features: Feature[];
  columns?: 2 | 3 | 4;
  className?: string;
  idPrefix?: string;
}

export function FeatureGrid({
  title,
  description,
  features,
  columns = 3,
  className,
  idPrefix = "features"
}: FeatureGridProps) {
  const gridCols = {
    2: "md:grid-cols-2",
    3: "md:grid-cols-2 lg:grid-cols-3",
    4: "md:grid-cols-2 lg:grid-cols-4",
  };

  return (
    <section className={cn("section-padding", className)}>
      <div className="container-padding w-full">
        {(title || description) && (
          <div className="text-center mb-16 space-y-4">
            {title && <EditableText id={`${idPrefix}.title`} as="h2" className="text-5xl md:text-6xl font-bold" text={title} />}
            {description && (
              <EditableText 
                id={`${idPrefix}.description`} 
                as="p" 
                className="text-2xl text-muted-foreground max-w-3xl mx-auto" 
                text={description} 
              />
            )}
          </div>
        )}
        <div className={cn("grid grid-cols-1 gap-8", gridCols[columns])}>
          {features.map((feature, index) => (
            <div
              key={index}
              className="p-6 rounded-xl bg-card border card-shadow hover:card-shadow-hover transition-shadow"
            >
              <div className="w-16 h-16 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                <feature.icon className="h-8 w-8 text-primary" />
              </div>
              <EditableText 
                id={`${idPrefix}.item.${index}.title`} 
                as="h3" 
                className="text-2xl font-semibold mb-3" 
                text={feature.title} 
              />
              <EditableText 
                id={`${idPrefix}.item.${index}.description`} 
                as="p" 
                className="text-lg text-muted-foreground leading-relaxed" 
                text={feature.description} 
              />
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
