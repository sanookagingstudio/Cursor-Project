import { Star } from "lucide-react";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { cn } from "@/lib/utils";
import { EditableText, Editable } from "@/components/editor/Editable";

interface Testimonial {
  name: string;
  role: string;
  content: string;
  rating: number;
  avatar?: string;
}

interface TestimonialSectionProps {
  title?: string;
  description?: string;
  testimonials: Testimonial[];
  className?: string;
  idPrefix?: string;
}

export function TestimonialSection({
  title,
  description,
  testimonials,
  className,
  idPrefix = "testimonials"
}: TestimonialSectionProps) {
  return (
    <section className={cn("section-padding bg-muted/30", className)}>
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
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {testimonials.map((testimonial, index) => (
            <div
              key={index}
              className="p-6 rounded-xl bg-card border card-shadow"
            >
              <Editable id={`${idPrefix}.item.${index}.rating`} type="container" className="flex gap-1 mb-4">
                {Array.from({ length: 5 }).map((_, i) => (
                  <Star
                    key={i}
                    className={cn(
                      "h-6 w-6",
                      i < testimonial.rating
                        ? "fill-primary text-primary"
                        : "fill-muted text-muted"
                    )}
                  />
                ))}
              </Editable>
              <div className="text-lg text-muted-foreground mb-6 leading-relaxed">
                "<EditableText id={`${idPrefix}.item.${index}.content`} as="span" text={testimonial.content} />"
              </div>
              <div className="flex items-center gap-3">
                <Avatar>
                  <AvatarFallback className="bg-primary/10 text-primary">
                    {testimonial.name.charAt(0)}
                  </AvatarFallback>
                </Avatar>
                <div>
                  <div className="font-semibold text-lg">
                    <EditableText id={`${idPrefix}.item.${index}.name`} as="span" text={testimonial.name} />
                  </div>
                  <div className="text-base text-muted-foreground">
                    <EditableText id={`${idPrefix}.item.${index}.role`} as="span" text={testimonial.role} />
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
