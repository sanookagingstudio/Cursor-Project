import { ReactNode } from "react";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { cn } from "@/lib/utils";

interface FormField {
  name: string;
  label: string;
  type?: "text" | "email" | "number" | "date" | "textarea" | "select";
  placeholder?: string;
  required?: boolean;
  options?: { value: string; label: string }[];
  helpText?: string;
}

interface FormSectionProps {
  title?: string;
  description?: string;
  fields: FormField[];
  className?: string;
  columns?: 1 | 2;
}

export function FormSection({
  title,
  description,
  fields,
  className,
  columns = 1,
}: FormSectionProps) {
  const gridCols = columns === 2 ? "md:grid-cols-2" : "md:grid-cols-1";

  return (
    <div className={cn("space-y-6 p-6 rounded-lg bg-card border", className)}>
      {(title || description) && (
        <div className="space-y-2">
          {title && <h3 className="text-xl font-semibold">{title}</h3>}
          {description && (
            <p className="text-sm text-muted-foreground">{description}</p>
          )}
        </div>
      )}
      <div className={cn("grid grid-cols-1 gap-6", gridCols)}>
        {fields.map((field) => (
          <div key={field.name} className="space-y-2">
            <Label htmlFor={field.name} className="text-base">
              {field.label}
              {field.required && <span className="text-destructive ml-1">*</span>}
            </Label>
            {field.type === "textarea" ? (
              <Textarea
                id={field.name}
                name={field.name}
                placeholder={field.placeholder}
                required={field.required}
                className="min-h-[120px] text-base"
              />
            ) : field.type === "select" ? (
              <Select name={field.name} required={field.required}>
                <SelectTrigger className="text-base min-h-[48px]">
                  <SelectValue placeholder={field.placeholder} />
                </SelectTrigger>
                <SelectContent>
                  {field.options?.map((option) => (
                    <SelectItem key={option.value} value={option.value}>
                      {option.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            ) : (
              <Input
                id={field.name}
                name={field.name}
                type={field.type || "text"}
                placeholder={field.placeholder}
                required={field.required}
                className="text-base min-h-[48px]"
              />
            )}
            {field.helpText && (
              <p className="text-sm text-muted-foreground">{field.helpText}</p>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
