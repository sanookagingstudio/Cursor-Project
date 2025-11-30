import { ReactNode, useState, useMemo } from "react";
import { Link, NavLink, useLocation } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { useTranslation } from "react-i18next";
import {
  LayoutDashboard,
  Users,
  Calendar,
  DollarSign,
  FileText,
  UsersRound,
  MapPin,
  Image,
  Video,
  Music,
  Sparkles,
  Settings,
  Brain,
  Palette,
  BarChart3,
  Globe,
  Tag,
  ChevronDown,
  Menu,
  X,
  MousePointer2,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from "@/components/ui/collapsible";
import { LanguageSwitcher } from "@/components/LanguageSwitcher";

interface AdminLayoutProps {
  children: ReactNode;
}

export function AdminLayout({ children }: AdminLayoutProps) {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const location = useLocation();
  const { signOut, user } = useAuth();
  const { t, i18n } = useTranslation();

  const menuItems = useMemo(() => [
    { label: t("admin.nav.dashboard"), path: "/admin/dashboard", icon: LayoutDashboard },
    {
      label: t("admin.nav.sasOffice"),
      icon: Users,
      children: [
        { label: t("admin.nav.staffManagement"), path: "/admin/staff", icon: Users },
        { label: t("admin.nav.scheduling"), path: "/admin/scheduling", icon: Calendar },
        { label: t("admin.nav.finance"), path: "/admin/finance", icon: DollarSign },
        { label: t("admin.nav.billing"), path: "/admin/billing", icon: FileText },
      ],
    },
    { label: t("admin.nav.clientMonitoring"), path: "/admin/clients", icon: UsersRound },
    { label: t("admin.nav.roleManagement"), path: "/admin/role-management", icon: Users },
    { label: t("admin.nav.tripPlanner"), path: "/admin/trip-planner", icon: MapPin },
    { label: t("admin.nav.mediaCenter"), path: "/admin/media", icon: Image },
    
    // Media Creator Group (Highlighted) - Always Open
    {
      label: "🎨 Media Creator",
      icon: Sparkles,
      children: [
        { label: "Image Editor", path: "/admin/image-editor", icon: Image },
        { label: "Video Editor", path: "/admin/video-editor", icon: Video },
        { label: "Music Lab", path: "/admin/music-lab", icon: Music },
        { label: "Input Brain", path: "/admin/input-brain", icon: Brain },
        { label: "Dashboard & Publishing", path: "/admin/dashboard-publishing", icon: LayoutDashboard },
      ],
    },
    
    // System Management
    {
      label: "⚙️ System Management",
      icon: Settings,
      children: [
        { label: "Core Foundation", path: "/admin/core-foundation", icon: Settings },
        { label: "Provider Management", path: "/admin/provider-management", icon: Settings },
        { label: "Theme Customization", path: "/admin/theme-customization", icon: Palette },
        { label: "Visual Theme Editor", path: "/admin/visual-theme-editor", icon: MousePointer2 },
        { label: t("admin.nav.settings"), path: "/admin/settings", icon: Settings },
      ],
    },
    
    // Business & Analytics
    {
      label: "📊 Business & Analytics",
      icon: BarChart3,
      children: [
        { label: "Monetization & Payment", path: "/admin/monetization", icon: DollarSign },
        { label: "Discount & Promotion", path: "/admin/discount-management", icon: Tag },
        { label: "Analytics & Statistics", path: "/admin/analytics", icon: BarChart3 },
        { label: "Cost & Infrastructure", path: "/admin/cost-management", icon: DollarSign },
      ],
    },
    
    // Integration
    {
      label: "🔗 Integration",
      icon: Globe,
      children: [
        { label: "External Apps", path: "/admin/external-apps", icon: Globe },
        { label: t("admin.nav.aiInsights"), path: "/admin/ai-insights", icon: Sparkles },
      ],
    },
    
    // Staff Tools (for reference)
    {
      label: "👥 Staff Tools",
      icon: Users,
      children: [
        { label: "FUN Creator Basic", path: "/staff/fun-creator-basic", icon: Image },
        { label: "FUN Creator Pro", path: "/staff/fun-creator-pro", icon: Sparkles },
        { label: "FUN Health", path: "/staff/fun-health", icon: Users },
        { label: "FUN Sentinel", path: "/staff/fun-sentinel", icon: Sparkles },
      ],
    },
  ], [t, i18n.language]);

  const isActive = (path: string) => {
    const currentPath = location.pathname;
    const active = currentPath === path || currentPath.startsWith(path + '/');
    // Debug: log active state
    if (active) {
      console.log('✅ Active menu:', path, 'Current:', currentPath);
    }
    return active;
  };

  const SidebarContent = () => (
    <div className="flex flex-col h-full">
      {/* Logo */}
      <div className="p-6 border-b">
        <Link to="/admin/dashboard" className="flex items-center space-x-2 hover:scale-105 transition-transform">
          <img src="/src/assets/kai-icon.png" alt="KAI Icon" className="h-10 w-10" />
          <div>
            <div className="font-bold text-lg">{t("admin.nav.adminPanel")}</div>
            <div className="text-xs text-muted-foreground">{t("admin.nav.controlPanel")}</div>
          </div>
        </Link>
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto p-4 space-y-2">
        {menuItems.map((item) =>
          item.children ? (
            <Collapsible 
              key={item.label} 
              defaultOpen={
                item.label.includes("Media Creator") || 
                item.children.some((child) => isActive(child.path))
              }
            >
              <CollapsibleTrigger asChild>
                <Button
                  variant="ghost"
                  className="w-full justify-start text-base font-medium"
                >
                  <item.icon className="mr-3 h-5 w-5" />
                  {item.label}
                  <ChevronDown className="ml-auto h-4 w-4" />
                </Button>
              </CollapsibleTrigger>
              <CollapsibleContent className="ml-8 mt-2 space-y-2">
                {item.children.map((child) => {
                  return (
                    <NavLink 
                      key={child.path} 
                      to={child.path}
                      className={({ isActive }) => cn(
                        "w-full justify-start text-base transition-all relative rounded-md px-3 py-2 flex items-center block",
                        isActive 
                          ? "bg-[#F36F21] text-white font-bold shadow-2xl border-4 border-[#E55A10]" 
                          : "hover:bg-accent hover:text-accent-foreground text-foreground bg-transparent border-0"
                      )}
                      style={({ isActive }) => isActive ? { 
                        backgroundColor: '#F36F21',
                        color: '#FFFFFF',
                        fontWeight: '700',
                        borderColor: '#E55A10',
                        borderWidth: '4px',
                        borderStyle: 'solid',
                        boxShadow: '0 4px 12px rgba(243, 111, 33, 0.5)'
                      } : { 
                        color: 'inherit',
                        backgroundColor: 'transparent'
                      }}
                    >
                      {({ isActive }) => (
                        <>
                          <child.icon 
                            className="mr-3 h-4 w-4"
                            style={isActive ? { color: '#FFFFFF' } : {}}
                          />
                          <span 
                            className={isActive ? "font-bold" : ""}
                            style={isActive ? { 
                              color: '#FFFFFF', 
                              fontWeight: '700',
                              display: 'block',
                              width: '100%'
                            } : { 
                              color: 'inherit'
                            }}
                          >
                            {child.label}
                          </span>
                        </>
                      )}
                    </NavLink>
                  );
                })}
              </CollapsibleContent>
            </Collapsible>
          ) : (
            <NavLink 
              key={item.path} 
              to={item.path}
              className={({ isActive }) => cn(
                "w-full justify-start text-base transition-all relative rounded-md px-3 py-2 flex items-center block",
                isActive 
                  ? "bg-[#F36F21] text-white font-bold shadow-2xl border-4 border-[#E55A10]" 
                  : "hover:bg-accent hover:text-accent-foreground text-foreground bg-transparent border-0"
              )}
              style={({ isActive }) => isActive ? { 
                backgroundColor: '#F36F21',
                color: '#FFFFFF',
                fontWeight: '700',
                borderColor: '#E55A10',
                borderWidth: '4px',
                borderStyle: 'solid',
                boxShadow: '0 4px 12px rgba(243, 111, 33, 0.5)'
              } : { 
                color: 'inherit',
                backgroundColor: 'transparent'
              }}
            >
              {({ isActive }) => (
                <>
                  <item.icon 
                    className="mr-3 h-5 w-5"
                    style={isActive ? { color: '#FFFFFF' } : {}}
                  />
                  <span 
                    className={isActive ? "font-bold" : ""}
                    style={isActive ? { 
                      color: '#FFFFFF', 
                      fontWeight: '700',
                      display: 'block',
                      width: '100%'
                    } : { 
                      color: 'inherit'
                    }}
                  >
                    {item.label}
                  </span>
                </>
              )}
            </NavLink>
          )
        )}
      </nav>
    </div>
  );

  return (
    <div className="min-h-screen flex w-full bg-background">
      {/* Desktop Sidebar */}
      <aside className="hidden lg:block w-64 border-r bg-card">
        <SidebarContent />
      </aside>

      {/* Mobile Sidebar */}
      {sidebarOpen && (
        <div className="lg:hidden fixed inset-0 z-50 bg-background/80 backdrop-blur-sm">
          <aside className="fixed inset-y-0 left-0 w-64 border-r bg-card shadow-xl">
            <div className="absolute right-4 top-4">
              <Button
                variant="ghost"
                size="icon"
                onClick={() => setSidebarOpen(false)}
              >
                <X className="h-6 w-6" />
              </Button>
            </div>
            <SidebarContent />
          </aside>
        </div>
      )}

      {/* Main Content */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Top Bar */}
        <header className="sticky top-0 z-40 border-b bg-card">
          <div className="flex h-16 items-center px-4 gap-4">
            <Button
              variant="ghost"
              size="icon"
              className="lg:hidden"
              onClick={() => setSidebarOpen(true)}
            >
              <Menu className="h-6 w-6" />
            </Button>
            <div className="flex-1" />
            <div className="flex items-center gap-2">
              <LanguageSwitcher />
              <span className="text-sm text-muted-foreground hidden md:inline">
                {user?.email}
              </span>
              <Button variant="outline" onClick={signOut}>
                {t("admin.common.signOut")}
              </Button>
            </div>
          </div>
        </header>

        {/* Page Content */}
        <main className="flex-1 overflow-y-auto p-4 md:p-6 lg:p-8 xl:p-10">
          <div className="w-full">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
}
