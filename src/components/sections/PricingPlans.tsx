import { Check } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";

interface PricingPlan {
  name: string;
  description: string;
  price: string;
  period?: string;
  features: string[];
  featured?: boolean;
  ctaLabel?: string;
  ctaHref?: string;
}

interface PricingPlansProps {
  title?: string;
  description?: string;
  plans: PricingPlan[];
  className?: string;
}

export function PricingPlans({
  title,
  description,
  plans,
  className,
}: PricingPlansProps) {
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
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {plans.map((plan, index) => (
            <div
              key={index}
              className={cn(
                "p-8 rounded-xl border transition-all relative",
                plan.featured
                  ? "bg-primary text-primary-foreground shadow-glow scale-105"
                  : "bg-card card-shadow hover:card-shadow-hover"
              )}
            >
              {plan.featured && (
                <Badge className="absolute -top-3 left-1/2 -translate-x-1/2 bg-secondary">
                  Most Popular
                </Badge>
              )}
              <div className="mb-6">
                <h3 className="text-2xl font-bold mb-2">{plan.name}</h3>
                <p className={cn(
                  "text-sm",
                  plan.featured ? "text-primary-foreground/80" : "text-muted-foreground"
                )}>
                  {plan.description}
                </p>
              </div>
              <div className="mb-6">
                <div className="flex items-baseline gap-2">
                  <span className="text-4xl font-bold">{plan.price}</span>
                  {plan.period && (
                    <span className={cn(
                      plan.featured ? "text-primary-foreground/70" : "text-muted-foreground"
                    )}>
                      / {plan.period}
                    </span>
                  )}
                </div>
              </div>
              <ul className="space-y-3 mb-8">
                {plan.features.map((feature, idx) => (
                  <li key={idx} className="flex items-start gap-2">
                    <Check className={cn(
                      "h-5 w-5 shrink-0 mt-0.5",
                      plan.featured ? "text-primary-foreground" : "text-secondary"
                    )} />
                    <span className="text-sm leading-relaxed">{feature}</span>
                  </li>
                ))}
              </ul>
              <Button
                className={cn(
                  "w-full btn-elderly",
                  plan.featured && "bg-white text-primary hover:bg-white/90"
                )}
                variant={plan.featured ? "secondary" : "default"}
                asChild
              >
                <a href={plan.ctaHref || "#"}>
                  {plan.ctaLabel || "Get Started"}
                </a>
              </Button>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
