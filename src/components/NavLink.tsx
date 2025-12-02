import { NavLink as RouterNavLink, NavLinkProps } from "react-router-dom";
import { forwardRef } from "react";
import { cn } from "@/lib/utils";
import { useTheme } from "@/contexts/ThemeContext";

// Mapping of paths to page IDs in VisualThemeEditor
const PATH_TO_ID: Record<string, string> = {
  "/": "home",
  "/about": "about",
  "/activities": "activities",
  "/trips": "trips",
  "/contact": "contact",
  "/media": "media",
  "/fun-store": "store",
  "/promotions": "promotions",
  "/membership": "membership",
  "/custom-trip-builder": "custom-trip",
  "/fun-calendar": "calendar",
};

interface NavLinkCompatProps extends Omit<NavLinkProps, "className"> {
  className?: string;
  activeClassName?: string;
  pendingClassName?: string;
}

const NavLink = forwardRef<HTMLAnchorElement, NavLinkCompatProps>(
  ({ className, activeClassName, pendingClassName, to, onClick, ...props }, ref) => {
    const { editMode, setSelectedPageId, selectedPageId } = useTheme();

    const handleClick = (e: React.MouseEvent<HTMLAnchorElement>) => {
      // Check if we are in edit mode and if the target path is one of our editable pages
      if (editMode && typeof to === 'string' && PATH_TO_ID[to]) {
        e.preventDefault();
        e.stopPropagation();
        setSelectedPageId(PATH_TO_ID[to]);
        return;
      }
      
      if (onClick) {
        onClick(e);
      }
    };

    // In edit mode, determine active state manually based on selectedPageId
    const isManualActive = editMode && typeof to === 'string' && PATH_TO_ID[to] === selectedPageId;

    return (
      <RouterNavLink
        ref={ref}
        to={to}
        onClick={handleClick}
        className={({ isActive, isPending }) =>
          cn(
            className, 
            (isActive || isManualActive) && activeClassName, 
            isPending && pendingClassName
          )
        }
        {...props}
      />
    );
  },
);

NavLink.displayName = "NavLink";

export { NavLink };
