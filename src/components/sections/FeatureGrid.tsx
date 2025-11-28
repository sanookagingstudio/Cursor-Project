import { ReactNode } from "react";
import { LucideIcon } from "lucide-react";
import { cn } from "@/lib/utils";

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
}

export function FeatureGrid({
  title,
  description,
  features,
  columns = 3,
  className,
}: FeatureGridProps) {
  const gridCols = {
    2: "md:grid-cols-2",
    3: "md:grid-cols-2 lg:grid-cols-3",
    4: "md:grid-cols-2 lg:grid-cols-4",
  };

  return (
    <section className={cn("section-padding", className)}>
      <div className="container-padding max-w-7xl mx-auto">
        {(title || description) && (
          <div className="text-center mb-16 space-y-4">
            {title && <h2 className="text-3xl md:text-4xl font-bold">{title}</h2>}
            {description && (
              <p className="text-xl text-muted-foreground max-w-3xl mx-auto">
                {description}
              </p>
            )}
          </div>
        )}
        <div className={cn("grid grid-cols-1 gap-8", gridCols[columns])}>
          {features.map((feature, index) => (
            <div
              key={index}
              className="p-6 rounded-xl bg-card border card-shadow hover:card-shadow-hover transition-shadow"
            >
              <div className="w-14 h-14 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                <feature.icon className="h-7 w-7 text-primary" />
              </div>
              <h3 className="text-xl font-semibold mb-3">{feature.title}</h3>
              <p className="text-muted-foreground leading-relaxed">
                {feature.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
