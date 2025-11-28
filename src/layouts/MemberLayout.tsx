import { ReactNode } from "react";
import { Link } from "react-router-dom";
import { User, Calendar, MapPin, FileText, LogOut, Settings } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { useAuth } from "@/contexts/AuthContext";

interface MemberLayoutProps {
  children: ReactNode;
}

export function MemberLayout({ children }: MemberLayoutProps) {
  const { user, signOut } = useAuth();
  
  const navItems = [
    { label: "Dashboard", path: "/member/dashboard", icon: User },
    { label: "My Profile", path: "/member/profile", icon: User },
    { label: "My Activities", path: "/member/activities", icon: Calendar },
    { label: "My Trips", path: "/member/trips", icon: MapPin },
    { label: "Media Center", path: "/media", icon: FileText },
    { label: "Documents", path: "/member/documents", icon: FileText },
    { label: "Settings", path: "/member/settings", icon: Settings },
  ];

  const getUserInitials = () => {
    if (!user?.email) return "U";
    return user.email.substring(0, 2).toUpperCase();
  };

  return (
    <div className="min-h-screen flex flex-col bg-background">
      {/* Header */}
      <header className="sticky top-0 z-50 w-full border-b bg-card shadow-sm">
        <div className="container-padding flex h-20 items-center justify-between max-w-7xl mx-auto">
          {/* Logo */}
          <Link to="/" className="flex items-center space-x-2 hover:scale-105 transition-transform">
            <img src="/src/assets/fun-logo-2025.png" alt="FUN Logo" className="h-12 w-auto" />
            <div className="hidden md:block">
              <div className="font-bold text-xl text-foreground">Member Portal</div>
            </div>
          </Link>

          {/* Navigation */}
          <nav className="hidden md:flex items-center space-x-1">
            {navItems.map((item) => (
              <Link key={item.path} to={item.path}>
                <Button variant="ghost" size="lg" className="text-base">
                  <item.icon className="mr-2 h-5 w-5" />
                  {item.label}
                </Button>
              </Link>
            ))}
          </nav>

          {/* Profile Menu */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" className="relative click-target">
                <Avatar className="h-10 w-10">
                  <AvatarFallback className="bg-primary text-primary-foreground">
                    {getUserInitials()}
                  </AvatarFallback>
                </Avatar>
                <span className="hidden md:inline ml-2">{user?.email}</span>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-56">
              <div className="flex items-center justify-start gap-2 p-2">
                <div className="flex flex-col space-y-1">
                  <p className="text-sm font-medium">{user?.email}</p>
                  <p className="text-xs text-muted-foreground">Member</p>
                </div>
              </div>
              <DropdownMenuSeparator />
              {navItems.map((item) => (
                <DropdownMenuItem key={item.path} asChild className="md:hidden">
                  <Link to={item.path} className="flex items-center">
                    <item.icon className="mr-2 h-4 w-4" />
                    {item.label}
                  </Link>
                </DropdownMenuItem>
              ))}
              <DropdownMenuSeparator className="md:hidden" />
              <DropdownMenuItem onClick={signOut}>
                <LogOut className="mr-2 h-4 w-4" />
                Sign Out
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1">
        <div className="container-padding max-w-7xl mx-auto py-8">
          {children}
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t bg-card mt-auto">
        <div className="container-padding max-w-7xl mx-auto py-6 text-center text-sm text-muted-foreground">
          <p>© 2025 FunAging Studio. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
}
