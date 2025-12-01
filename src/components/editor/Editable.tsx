import React from "react";
import { cn } from "@/lib/utils";
import { useTheme } from "@/contexts/ThemeContext";

interface EditableProps {
  id: string;
  className?: string;
  children?: React.ReactNode;
  as?: any;
  type?: "text" | "image" | "container";
}

export function Editable({ id, className, children, as: Component = "div", type = "text" }: EditableProps) {
  const { editMode, selectedElementId, setSelectedElementId } = useTheme();
  
  const isSelected = selectedElementId === id;
  
  const handleClick = (e: React.MouseEvent) => {
    if (editMode) {
      e.stopPropagation();
      e.preventDefault();
      setSelectedElementId(id);
    }
  };

  if (!editMode) {
    return <Component className={className}>{children}</Component>;
  }

  return (
    <Component
      className={cn(
        className,
        "relative transition-all duration-200 outline-none",
        editMode && "cursor-pointer hover:ring-2 hover:ring-primary/50 hover:ring-offset-2",
        isSelected && "ring-2 ring-primary ring-offset-2 z-10"
      )}
      onClick={handleClick}
      data-editable-id={id}
      data-editable-type={type}
    >
      {children}
      {editMode && isSelected && (
        <div className="absolute -top-6 left-0 bg-primary text-primary-foreground text-xs px-2 py-0.5 rounded-t shadow-sm pointer-events-none whitespace-nowrap z-20">
          Editing: {id}
        </div>
      )}
    </Component>
  );
}

interface EditableTextProps extends Omit<EditableProps, "type"> {
  text?: string;
  defaultValue?: string;
}

export function EditableText({ id, text, defaultValue, as = "span", className, children }: EditableTextProps) {
  const { settings } = useTheme();
  
  // Determine content: 
  // 1. Check theme settings overrides first
  // 2. Use provided text prop (usually from translation)
  // 3. Fallback to defaultValue or children
  
  const content = settings?.content?.[id] || text || defaultValue || children;

  return (
    <Editable id={id} as={as} className={className} type="text">
      {content}
    </Editable>
  );
}

interface EditableImageProps extends React.ImgHTMLAttributes<HTMLImageElement> {
  id: string;
}

export function EditableImage({ id, src, alt, className, ...props }: EditableImageProps) {
  const { settings } = useTheme();
  
  const imageSrc = settings?.content?.[id] || src;

  return (
    <Editable id={id} as="div" className={cn("relative inline-block", className)} type="image">
      <img src={imageSrc} alt={alt} className="block w-full h-full object-cover" {...props} />
    </Editable>
  );
}

