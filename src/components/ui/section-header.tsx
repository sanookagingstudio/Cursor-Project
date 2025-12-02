import { ReactNode } from "react";
import { cn } from "@/lib/utils";
import { EditableText } from "@/components/editor/Editable";

interface SectionHeaderProps {
  title: string;
  description?: string;
  actions?: ReactNode;
  className?: string;
  idPrefix?: string;
}

export function SectionHeader({
  title,
  description,
  actions,
  className,
  idPrefix = "section",
}: SectionHeaderProps) {
  return (
    <div className={cn("flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8", className)}>
      <div className="space-y-1">
        <EditableText 
            id={`${idPrefix}.title`}
            as="h1" 
            className="text-5xl font-bold mb-4" 
            text={title}
        />
        {description && (
          <EditableText 
            id={`${idPrefix}.description`}
            as="p" 
            className="text-lg text-muted-foreground" 
            text={description}
          />
        )}
      </div>
      {actions && <div className="flex gap-2">{actions}</div>}
    </div>
  );
}
