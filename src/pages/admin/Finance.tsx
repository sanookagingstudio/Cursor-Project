import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { StatCard } from "@/components/cards/StatCard";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { DataTable } from "@/components/tables/DataTable";
import { ActionBar } from "@/components/ui/action-bar";
import { useTranslation } from "react-i18next";

export default function Finance() {
  const { t } = useTranslation();
  
  const columns = [
    { key: "date", label: t("admin.finance.date") },
    { key: "category", label: t("admin.finance.category") },
    { key: "description", label: t("admin.finance.description") },
    { key: "amount", label: t("admin.finance.amount") },
    { key: "type", label: t("admin.finance.type") },
  ];

  const transactions = [
    { date: "2024-03-01", category: "Membership", description: "Monthly Fees", amount: "฿45,000", type: "Income" },
    { date: "2024-03-05", category: "Trips", description: "Ayutthaya Tour", amount: "฿18,000", type: "Income" },
    { date: "2024-03-10", category: "Supplies", description: "Activity Materials", amount: "฿8,500", type: "Expense" },
    { date: "2024-03-15", category: "Staff", description: "Salaries", amount: "฿120,000", type: "Expense" },
  ];

  return (
    <AdminLayout>
      <SectionHeader
        title={t("admin.finance.title")}
        description={t("admin.finance.description")}
      />

      <ActionBar
        actions={[
          { type: "export", label: t("admin.finance.exportReport") },
          { type: "print", label: t("admin.finance.printReport") },
        ]}
        className="mb-6"
      />

      <div className="grid md:grid-cols-4 gap-6 mb-8">
        <StatCard label={t("admin.finance.totalRevenue")} value="฿185,000" trend={{ value: 12, isPositive: true }} />
        <StatCard label={t("admin.finance.totalExpenses")} value="฿128,500" trend={{ value: 5, isPositive: false }} />
        <StatCard label={t("admin.finance.netProfit")} value="฿56,500" trend={{ value: 8, isPositive: true }} />
        <StatCard label={t("admin.finance.profitMargin")} value="31%" trend={{ value: 3, isPositive: true }} />
      </div>

      <Card className="mb-8">
        <CardHeader>
          <CardTitle>{t("admin.finance.revenueBreakdown")}</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">{t("admin.finance.membershipFees")}</span>
              <span className="font-semibold">฿45,000 (24%)</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">{t("admin.finance.tripBookings")}</span>
              <span className="font-semibold">฿85,000 (46%)</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">{t("admin.finance.activityFees")}</span>
              <span className="font-semibold">฿35,000 (19%)</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">{t("admin.finance.otherIncome")}</span>
              <span className="font-semibold">฿20,000 (11%)</span>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>{t("admin.finance.recentTransactions")}</CardTitle>
        </CardHeader>
        <CardContent>
          <DataTable columns={columns} data={transactions} />
        </CardContent>
      </Card>
    </AdminLayout>
  );
}
