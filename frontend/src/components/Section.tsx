"use client";

import { cn } from "@/lib/utils";
import type { SectionProps } from "@/lib/types";

export function Section({ title, description, children, className }: SectionProps) {
  return (
    <section className={cn("space-y-4", className)}>
      {(title || description) && (
        <div className="space-y-1 mb-6">
          {title && (
            <h2 className="text-2xl font-bold">{title}</h2>
          )}
          {description && (
            <p className="text-muted-foreground">{description}</p>
          )}
        </div>
      )}
      {children}
    </section>
  );
}


