import { ReactNode } from "react";
import { Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";

interface FilterBarProps {
  searchPlaceholder?: string;
  onSearch?: (value: string) => void;
  children?: ReactNode;
  className?: string;
}

export function FilterBar({
  searchPlaceholder = "Search...",
  onSearch,
  children,
  className,
}: FilterBarProps) {
  return (
    <div className={cn("flex flex-col md:flex-row gap-4 p-4 bg-card border rounded-lg", className)}>
      <div className="relative flex-1">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
        <Input
          placeholder={searchPlaceholder}
          onChange={(e) => onSearch?.(e.target.value)}
          className="pl-10 text-base min-h-[48px]"
        />
      </div>
      {children && (
        <div className="flex flex-wrap gap-2">
          {children}
        </div>
      )}
    </div>
  );
}
