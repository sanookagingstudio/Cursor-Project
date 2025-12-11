"use client";

import { useEffect, useState } from "react";
import { fetchHealth, type ApiHealth } from "@/lib/api";
import { cn } from "@/lib/utils";
import { CheckCircle2, XCircle, Loader2 } from "lucide-react";

export function BackendStatusBadge() {
  const [status, setStatus] = useState<"checking" | "online" | "offline">("checking");
  const [health, setHealth] = useState<ApiHealth | null>(null);

  useEffect(() => {
    let mounted = true;

    const checkHealth = async () => {
      const result = await fetchHealth();
      if (!mounted) return;

      if (result) {
        setStatus("online");
        setHealth(result);
      } else {
        setStatus("offline");
        setHealth(null);
      }
    };

    // Initial check
    checkHealth();

    // Poll every 10 seconds
    const interval = setInterval(checkHealth, 10000);

    return () => {
      mounted = false;
      clearInterval(interval);
    };
  }, []);

  const getStatusConfig = () => {
    switch (status) {
      case "checking":
        return {
          icon: Loader2,
          text: "Checking...",
          className: "text-muted-foreground",
          bgClassName: "bg-muted/50",
        };
      case "online":
        return {
          icon: CheckCircle2,
          text: "Backend Online",
          className: "text-green-600 dark:text-green-400",
          bgClassName: "bg-green-50 dark:bg-green-950/20",
        };
      case "offline":
        return {
          icon: XCircle,
          text: "Backend Offline",
          className: "text-red-600 dark:text-red-400",
          bgClassName: "bg-red-50 dark:bg-red-950/20",
        };
    }
  };

  const config = getStatusConfig();
  const Icon = config.icon;

  return (
    <div
      className={cn(
        "flex items-center gap-2 px-3 py-1.5 rounded-md text-xs font-medium border transition-colors",
        config.bgClassName,
        config.className
      )}
      title={health?.detail || `Backend status: ${status}`}
    >
      <Icon
        className={cn(
          "h-3.5 w-3.5",
          status === "checking" && "animate-spin"
        )}
      />
      <span className="hidden sm:inline">{config.text}</span>
    </div>
  );
}


