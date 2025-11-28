import { ReactNode } from "react";
import { Button } from "@/components/ui/button";
import { Plus, Save, X, Trash2, RefreshCw, Download, Upload, Printer, Home, ArrowLeft } from "lucide-react";
import { cn } from "@/lib/utils";

interface ActionBarProps {
  title?: string;
  children?: ReactNode;
  className?: string;
  actions?: {
    type: "add" | "save" | "cancel" | "delete" | "refresh" | "export" | "import" | "print" | "home" | "back";
    label?: string;
    onClick?: () => void;
    variant?: "default" | "destructive" | "outline" | "ghost";
  }[];
}

const actionIcons = {
  add: Plus,
  save: Save,
  cancel: X,
  delete: Trash2,
  refresh: RefreshCw,
  export: Download,
  import: Upload,
  print: Printer,
  home: Home,
  back: ArrowLeft,
};

const actionLabels = {
  add: "Add New",
  save: "Save",
  cancel: "Cancel",
  delete: "Delete",
  refresh: "Refresh",
  export: "Export",
  import: "Import",
  print: "Print",
  home: "Home",
  back: "Back",
};

export function ActionBar({ title, children, className, actions }: ActionBarProps) {
  return (
    <div className={cn(
      "flex flex-col md:flex-row md:items-center justify-between gap-4 p-4 bg-card border rounded-lg",
      className
    )}>
      {title && (
        <h2 className="text-2xl font-semibold">{title}</h2>
      )}
      {children}
      {actions && actions.length > 0 && (
        <div className="flex flex-wrap gap-2">
          {actions.map((action, index) => {
            const Icon = actionIcons[action.type];
            return (
              <Button
                key={index}
                variant={action.variant || (action.type === "delete" ? "destructive" : "default")}
                onClick={action.onClick}
                className={cn(action.type === "add" && "btn-elderly")}
              >
                <Icon className="h-4 w-4 mr-2" />
                {action.label || actionLabels[action.type]}
              </Button>
            );
          })}
        </div>
      )}
    </div>
  );
}
