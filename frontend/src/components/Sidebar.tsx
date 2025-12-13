"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  LayoutDashboard,
  MapPin,
  Building2,
  Image,
  BarChart3,
} from "lucide-react";
import { cn } from "@/lib/utils";

interface SidebarProps {
  className?: string;
}

export function Sidebar({ className }: SidebarProps) {
  const pathname = usePathname();

  const menuItems = [
    { label: "Dashboard", path: "/", icon: LayoutDashboard },
    { label: "Trip Planner", path: "/trip", icon: MapPin },
    { label: "Office", path: "/office", icon: Building2 },
    { label: "Media Creator", path: "/media", icon: Image },
    { label: "Insights", path: "/insights", icon: BarChart3 },
  ];

  const isActive = (path: string) => {
    if (path === "/") {
      return pathname === "/";
    }
    return pathname?.startsWith(path);
  };

  return (
    <aside className={cn("w-64 border-r bg-card flex flex-col", className)}>
      {/* Logo */}
      <div className="p-6 border-b">
        <Link href="/" className="flex items-center space-x-2 hover:scale-105 transition-transform">
          <div>
            <div className="font-bold text-lg">FunAging</div>
            <div className="text-xs text-muted-foreground">Control Panel</div>
          </div>
        </Link>
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto p-4 space-y-2">
        {menuItems.map((item) => {
          const active = isActive(item.path);
          return (
            <Link
              key={item.path}
              href={item.path}
              className={cn(
                "w-full flex items-center px-3 py-2 rounded-md text-base transition-all relative",
                active
                  ? "bg-[#F36F21] text-white font-bold shadow-lg border-2 border-[#E55A10]"
                  : "hover:bg-accent hover:text-accent-foreground text-foreground"
              )}
            >
              <item.icon className="mr-3 h-5 w-5" />
              <span>{item.label}</span>
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}





