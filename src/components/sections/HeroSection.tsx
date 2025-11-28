import { ReactNode } from "react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

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
    <section className={cn("section-padding gradient-warm", className)}>
      <div className="container-padding max-w-7xl mx-auto">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          <div className="space-y-6">
            {subtitle && (
              <div className="inline-block px-4 py-2 bg-primary/10 text-primary rounded-full text-sm font-medium">
                {subtitle}
              </div>
            )}
            <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold leading-tight">
              {title}
            </h1>
            {description && (
              <p className="text-xl text-muted-foreground leading-relaxed">
                {description}
              </p>
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
              <img
                src={image}
                alt={title}
                className="w-full h-full object-cover"
              />
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
