import { AdminLayout } from "@/layouts/AdminLayout";
import { RevenueCard } from "@/components/dashboard/RevenueCard";
import { MemberStatsCard } from "@/components/dashboard/MemberStatsCard";
import { TripStatsCard } from "@/components/dashboard/TripStatsCard";
import { QuickActions } from "@/components/dashboard/QuickActions";
import { RevenueChart } from "@/components/dashboard/RevenueChart";
import { ActivityChart } from "@/components/dashboard/ActivityChart";
import { UpcomingTripsTable } from "@/components/dashboard/UpcomingTripsTable";
import { TodayActivitiesTable } from "@/components/dashboard/TodayActivitiesTable";

const Dashboard = () => {
  return (
    <AdminLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-5xl font-bold mb-4">Dashboard</h1>
          <p className="text-lg text-muted-foreground">Welcome back! Here's your overview.</p>
        </div>

        {/* Stats Cards */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          <RevenueCard total={67000} change={12.5} period="vs last month" />
          <MemberStatsCard totalMembers={248} newThisMonth={18} activeToday={142} />
          <TripStatsCard upcomingTrips={8} tripsThisMonth={12} completedTrips={45} />
        </div>

        {/* Quick Actions */}
        <QuickActions />

        {/* Charts */}
        <div className="grid gap-4 grid-cols-1 lg:grid-cols-3">
          <RevenueChart />
          <ActivityChart />
        </div>

        {/* Tables */}
        <div className="grid gap-4">
          <UpcomingTripsTable />
          <TodayActivitiesTable />
        </div>
      </div>
    </AdminLayout>
  );
};

export default Dashboard;
