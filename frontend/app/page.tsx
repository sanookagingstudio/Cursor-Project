"use client";

import { StatCard } from "@/components/StatCard";
import { FunCard } from "@/components/FunCard";
import { Section } from "@/components/Section";
import { Users, MapPin, Image, BarChart3, TrendingUp, Calendar } from "lucide-react";

export default function Home() {
  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-5xl font-bold mb-4">Dashboard</h1>
        <p className="text-lg text-muted-foreground">
          Welcome back! Here's your overview.
        </p>
      </div>

      {/* Stats Cards */}
      <Section title="Overview">
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <StatCard
            label="Total Members"
            value={248}
            icon={Users}
            trend={{ value: 12.5, isPositive: true }}
          />
          <StatCard
            label="Upcoming Trips"
            value={8}
            icon={MapPin}
            trend={{ value: 5.2, isPositive: true }}
          />
          <StatCard
            label="Media Created"
            value={142}
            icon={Image}
            trend={{ value: 8.1, isPositive: true }}
          />
          <StatCard
            label="Active Today"
            value={67}
            icon={TrendingUp}
            trend={{ value: 3.4, isPositive: true }}
          />
        </div>
      </Section>

      {/* Quick Actions */}
      <Section title="Quick Actions">
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          <FunCard
            title="Trip Planner"
            description="Plan and manage trips for members"
            icon={MapPin}
          />
          <FunCard
            title="Media Creator"
            description="Create images, videos, and music"
            icon={Image}
          />
          <FunCard
            title="Insights & Analytics"
            description="View detailed analytics and reports"
            icon={BarChart3}
          />
          <FunCard
            title="Office Management"
            description="Manage staff, schedules, and operations"
            icon={Calendar}
          />
        </div>
      </Section>
    </div>
  );
}
