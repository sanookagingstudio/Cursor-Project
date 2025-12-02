import React from "react";
import { cn } from "@/lib/utils";
import { useTheme } from "@/contexts/ThemeContext";

interface EditableProps {
  id: string;
  className?: string;
  children?: React.ReactNode;
  as?: any;
  type?: "text" | "image" | "container" | "icon";
  style?: React.CSSProperties; // Allow passing default styles
}

export function Editable({ id, className, children, as: Component = "div", type = "text", style }: EditableProps) {
  const { editMode, selectedElementId, setSelectedElementId, settings } = useTheme();
  
  const isSelected = selectedElementId === id;
  
  const handleClick = (e: React.MouseEvent) => {
    if (editMode) {
      e.stopPropagation();
      e.preventDefault();
      setSelectedElementId(id);
    }
  };

  // Merge styles from props and theme settings
  const mergedStyle = {
    ...style,
    ...settings?.styles?.[id] // Apply style overrides from theme settings
  };

  if (!editMode) {
    return <Component className={className} style={mergedStyle}>{children}</Component>;
  }

  return (
    <Component
      className={cn(
        className,
        "relative transition-all duration-200 outline-none",
        editMode && "cursor-pointer hover:ring-2 hover:ring-primary/50 hover:ring-offset-2",
        isSelected && "ring-2 ring-primary ring-offset-2 z-10"
      )}
      style={mergedStyle}
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

export function EditableText({ id, text, defaultValue, as = "span", className, children, ...props }: EditableTextProps) {
  const { settings } = useTheme();
  
  const content = settings?.content?.[id] || text || defaultValue || children;

  return (
    <Editable id={id} as={as} className={className} type="text" {...props}>
      {content}
    </Editable>
  );
}

interface EditableImageProps extends React.ImgHTMLAttributes<HTMLImageElement> {
  id: string;
}

export function EditableImage({ id, src, alt, className, style, ...props }: EditableImageProps) {
  const { settings } = useTheme();
  
  const imageSrc = settings?.content?.[id] || src;
  
  // For images, we wrap them in a div to handle the ring/selection correctly
  // and pass the style to the image itself if it's about dimensions, or the wrapper
  // But to keep it simple with the current Editable pattern, we use the Editable as the wrapper 
  // and render the img inside.
  
  return (
    <Editable id={id} as="div" className={cn("relative inline-block", className)} type="image" style={style}>
      <img 
        src={imageSrc} 
        alt={alt} 
        className="block w-full h-full object-cover" 
        {...props} 
        // Apply styles from settings to the image tag directly if needed, 
        // but Editable wrapper usually handles positioning/sizing styles better for selection UI
      />
    </Editable>
  );
}
