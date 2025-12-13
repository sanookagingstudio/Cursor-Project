"use client";

import { cn } from "@/lib/utils";
import type { FunCardProps } from "@/lib/types";

export function FunCard({ title, description, icon: Icon, onClick, className }: FunCardProps) {
  return (
    <div
      onClick={onClick}
      className={cn(
        "p-6 rounded-xl bg-card border shadow-sm transition-all hover:shadow-md cursor-pointer",
        onClick && "hover:border-primary/50",
        className
      )}
    >
      <div className="flex items-start gap-4">
        {Icon && (
          <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center flex-shrink-0">
            <Icon className="h-6 w-6 text-primary" />
          </div>
        )}
        <div className="flex-1 min-w-0">
          <h3 className="text-lg font-semibold mb-2">{title}</h3>
          {description && (
            <p className="text-sm text-muted-foreground">{description}</p>
          )}
        </div>
      </div>
    </div>
  );
}





