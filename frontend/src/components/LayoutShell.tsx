"use client";

import { ReactNode } from "react";
import { cn } from "@/lib/utils";

interface LayoutShellProps {
  children: ReactNode;
  className?: string;
}

export function LayoutShell({ children, className }: LayoutShellProps) {
  return (
    <div className={cn("min-h-screen flex flex-col bg-background", className)}>
      {children}
    </div>
  );
}





