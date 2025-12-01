import { ReactNode } from "react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { EditableText, EditableImage } from "@/components/editor/Editable";

interface HeroSectionProps {
  title: string;
  subtitle?: string;
  description?: string;
  primaryCTA?: { label: string; href: string };
  secondaryCTA?: { label: string; href: string };
  image?: string;
  className?: string;
  children?: ReactNode;
}

export function HeroSection({
  title,
  subtitle,
  description,
  primaryCTA,
  secondaryCTA,
  image,
  className,
  children,
}: HeroSectionProps) {
  
  return (
    <section className={cn("section-padding gradient-warm relative overflow-hidden", className)}>
      <div className="container-padding w-full relative z-10">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          <div className="space-y-6">
            {subtitle && (
              <EditableText 
                id="hero.subtitle" 
                as="div" 
                className="inline-block px-4 py-2 bg-primary/10 text-primary rounded-full text-base font-medium"
                text={subtitle}
              />
            )}
            <EditableText 
                id="hero.title"
                as="h1"
                className="text-5xl md:text-6xl lg:text-7xl font-bold leading-tight"
                text={title}
            />
            {description && (
              <EditableText
                id="hero.description"
                as="p"
                className="text-2xl text-muted-foreground leading-relaxed"
                text={description}
              />
            )}
            <div className="flex flex-col sm:flex-row gap-4 pt-4">
              {primaryCTA && (
                <Button size="lg" className="btn-elderly text-lg" asChild>
                  <a href={primaryCTA.href}>{primaryCTA.label}</a>
                </Button>
              )}
              {secondaryCTA && (
                <Button size="lg" variant="outline" className="btn-elderly text-lg" asChild>
                  <a href={secondaryCTA.href}>{secondaryCTA.label}</a>
                </Button>
              )}
            </div>
            {children}
          </div>
          {image && (
            <div className="relative aspect-square lg:aspect-auto lg:h-[500px] rounded-2xl overflow-hidden shadow-large">
              <EditableImage
                id="hero.image"
                src={image}
                alt={title}
                className="w-full h-full object-cover rounded-2xl"
              />
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
