import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { EditableText } from "@/components/editor/Editable";

interface CTASectionProps {
  title: string;
  description?: string;
  primaryCTA?: {
    label: string;
    href: string;
  };
  secondaryCTA?: {
    label: string;
    href: string;
  };
  variant?: "default" | "gradient" | "outline";
  className?: string;
  idPrefix?: string;
}

export function CTASection({
  title,
  description,
  primaryCTA,
  secondaryCTA,
  variant = "gradient",
  className,
  idPrefix = "cta"
}: CTASectionProps) {
  const variants = {
    default: "bg-card border",
    gradient: "gradient-primary text-white",
    outline: "bg-background border-2 border-primary"
  };
  return <section className={cn("section-padding", className)}>
      <div className="container-padding w-full">
        <div className={cn("rounded-2xl p-12 text-center space-y-6", variants[variant])}>
          <EditableText 
            id={`${idPrefix}.title`} 
            as="h2" 
            className={cn("text-5xl md:text-6xl font-bold", variant === "gradient" && "text-white")} 
            text={title} 
          />
          {description && (
            <EditableText 
                id={`${idPrefix}.description`} 
                as="p" 
                className={cn("text-2xl max-w-2xl mx-auto", variant === "gradient" ? "text-white/90" : "text-muted-foreground")} 
                text={description} 
            />
          )}
          <div className="flex flex-col sm:flex-row gap-4 justify-center pt-4">
            {primaryCTA && <Button size="lg" className="btn-elderly text-lg" variant={variant === "gradient" ? "secondary" : "default"} asChild>
                <a href={primaryCTA.href}>
                    <EditableText id={`${idPrefix}.primaryCTA`} as="span" text={primaryCTA.label} />
                </a>
              </Button>}
            {secondaryCTA && <Button size="lg" variant="outline" className={cn("btn-elderly text-lg", variant === "gradient" && "border-white text-white hover:bg-white/10")} asChild>
                <a href={secondaryCTA.href}>
                    <EditableText id={`${idPrefix}.secondaryCTA`} as="span" text={secondaryCTA.label} />
                </a>
              </Button>}
          </div>
        </div>
      </div>
    </section>;
}
