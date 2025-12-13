"use client";

import { TrendingUp, TrendingDown } from "lucide-react";
import { cn } from "@/lib/utils";
import type { StatCardProps } from "@/lib/types";

export function StatCard({ label, value, icon: Icon, trend, className }: StatCardProps) {
  return (
    <div className={cn("p-6 rounded-xl bg-card border shadow-sm", className)}>
      <div className="flex items-start justify-between mb-4">
        <div className="text-sm font-medium text-muted-foreground">{label}</div>
        {Icon && (
          <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center">
            <Icon className="h-5 w-5 text-primary" />
          </div>
        )}
      </div>
      <div className="space-y-2">
        <div className="text-3xl font-bold">{value}</div>
        {trend && (
          <div className={cn(
            "flex items-center text-sm font-medium",
            trend.isPositive ? "text-green-600 dark:text-green-400" : "text-red-600 dark:text-red-400"
          )}>
            {trend.isPositive ? (
              <TrendingUp className="h-4 w-4 mr-1" />
            ) : (
              <TrendingDown className="h-4 w-4 mr-1" />
            )}
            {trend.value}%
          </div>
        )}
      </div>
    </div>
  );
}





