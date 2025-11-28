import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { DollarSign, TrendingUp, TrendingDown } from "lucide-react";
import { Badge } from "@/components/ui/badge";

interface RevenueCardProps {
  total: number;
  change: number;
  period: string;
}

export function RevenueCard({ total, change, period }: RevenueCardProps) {
  const isPositive = change >= 0;
  
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-lg font-semibold">Total Revenue</CardTitle>
        <DollarSign className="h-6 w-6 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div className="text-4xl font-bold">฿{total.toLocaleString()}</div>
        <div className="flex items-center gap-2 mt-2">
          <Badge variant={isPositive ? "default" : "destructive"} className="flex items-center gap-1 text-base px-3 py-1">
            {isPositive ? (
              <TrendingUp className="h-4 w-4" />
            ) : (
              <TrendingDown className="h-4 w-4" />
            )}
            {Math.abs(change)}%
          </Badge>
          <p className="text-base text-muted-foreground">{period}</p>
        </div>
      </CardContent>
    </Card>
  );
}
