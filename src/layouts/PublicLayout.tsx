import { ReactNode } from "react";
import { Link } from "react-router-dom";
import { NavLink } from "@/components/NavLink";
import { Home, Calendar, MapPin, Image, User, Menu } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { FloatingJarvis } from "@/components/FloatingJarvis";
import { LanguageSwitcher } from "@/components/LanguageSwitcher";
import { useTranslation } from "react-i18next";

import funLogo from "@/assets/fun-logo-2025.png";

interface PublicLayoutProps {
  children: ReactNode;
}

export function PublicLayout({ children }: PublicLayoutProps) {
  const { t } = useTranslation();
  
  const navItems = [
    { label: t('nav.home'), path: "/" },
    { label: t('nav.activities'), path: "/activities" },
    { label: t('nav.trips'), path: "/trips" },
    { label: t('nav.customTripBuilder'), path: "/custom-trip-builder" },
    { label: t('nav.funCalendar'), path: "/fun-calendar" },
    { label: t('nav.media'), path: "/media" },
    { label: t('nav.funStore'), path: "/fun-store" },
    { label: t('nav.promotions'), path: "/promotions" },
    { label: t('nav.membership'), path: "/membership" },
    { label: t('nav.about'), path: "/about" },
    { label: t('nav.contact'), path: "/contact" },
  ];

  const mobileNavItems = [
    { label: t('nav.home'), path: "/", icon: Home },
    { label: t('nav.activities'), path: "/activities", icon: Calendar },
    { label: t('nav.trips'), path: "/trips", icon: MapPin },
    { label: t('nav.media'), path: "/media", icon: Image },
    { label: t('nav.account'), path: "/sign-in", icon: User },
  ];

  return (
    <div className="min-h-screen flex flex-col bg-background">
      {/* Header */}
      <header className="sticky top-0 z-50 w-full border-b bg-card shadow-sm">
        <div className="container-padding flex h-20 items-center justify-between w-full">
                {/* Logo */}
                <Link to="/" className="flex items-center space-x-3 hover:scale-105 transition-transform">
                  <img src={funLogo} alt="FUN Logo" className="h-14 w-auto" />
                  <div className="hidden md:block">
                    <div className="font-bold text-2xl text-foreground">{t('brand.name')}</div>
                    <div className="text-sm text-muted-foreground">{t('brand.tagline')}</div>
                  </div>
                </Link>

          {/* Desktop Navigation */}
          <nav className="hidden md:flex items-center space-x-1">
            {navItems.map((item) => (
              <Button key={item.path} asChild variant="ghost" size="lg" className="text-base font-medium">
                <NavLink 
                  to={item.path}
                  activeClassName="bg-[#F36F21] text-white hover:bg-[#D85F1A] hover:text-white shadow-md"
                >
                  {item.label}
                </NavLink>
              </Button>
            ))}
          </nav>

          {/* Desktop CTA */}
          <div className="hidden md:flex items-center space-x-2">
            <LanguageSwitcher />
            <Link to="/sign-in">
              <Button variant="ghost" size="lg">{t('nav.signIn')}</Button>
            </Link>
            <Link to="/join-now">
              <Button size="lg" className="btn-elderly">{t('nav.joinNow')}</Button>
            </Link>
          </div>

          {/* Mobile Menu */}
          <Sheet>
            <SheetTrigger asChild className="md:hidden">
              <Button variant="ghost" size="icon" className="click-target">
                <Menu className="h-6 w-6" />
              </Button>
            </SheetTrigger>
            <SheetContent side="right" className="w-80">
              <nav className="flex flex-col space-y-4 mt-8">
                {navItems.map((item) => (
                  <Button key={item.path} asChild variant="ghost" size="lg" className="w-full justify-start text-lg">
                    <NavLink 
                      to={item.path}
                      activeClassName="bg-[#F36F21] text-white hover:bg-[#D85F1A] hover:text-white"
                    >
                      {item.label}
                    </NavLink>
                  </Button>
                ))}
                <div className="pt-4 border-t space-y-2">
                  <Link to="/sign-in">
                    <Button variant="outline" size="lg" className="w-full btn-elderly">
                      {t('nav.signIn')}
                    </Button>
                  </Link>
                  <Link to="/join-now">
                    <Button size="lg" className="w-full btn-elderly">
                      {t('nav.joinNow')}
                    </Button>
                  </Link>
                </div>
              </nav>
            </SheetContent>
          </Sheet>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 pb-20 md:pb-0">
        {children}
      </main>

      {/* Mobile Bottom Navigation */}
      <nav className="md:hidden fixed bottom-0 left-0 right-0 z-40 bg-card border-t shadow-large">
        <div className="flex items-center justify-around h-20">
          {mobileNavItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              className="flex flex-col items-center justify-center flex-1 click-target transition-colors text-muted-foreground hover:text-[#F36F21]"
              activeClassName="text-[#F36F21] font-bold"
            >
              <item.icon className="h-6 w-6 mb-1" />
              <span className="text-sm font-medium">{item.label}</span>
            </NavLink>
          ))}
        </div>
      </nav>

              {/* Footer */}
              <footer className="hidden md:block border-t bg-card mt-auto">
                <div className="container-padding w-full py-12">
                  <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
                    <div>
                      <div className="font-bold text-xl mb-4">{t('brand.name')}</div>
                      <p className="text-muted-foreground">
                        {t('footer.tagline')}
                      </p>
                    </div>
            <div>
              <h4 className="font-semibold mb-4">{t('footer.quickLinks')}</h4>
              <div className="space-y-2">
                <Link to="/about" className="block text-muted-foreground hover:text-primary">{t('footer.aboutUs')}</Link>
                <Link to="/activities" className="block text-muted-foreground hover:text-primary">{t('nav.activities')}</Link>
                <Link to="/trips" className="block text-muted-foreground hover:text-primary">{t('nav.trips')}</Link>
                <Link to="/pricing" className="block text-muted-foreground hover:text-primary">{t('footer.pricing')}</Link>
              </div>
            </div>
            <div>
              <h4 className="font-semibold mb-4">{t('footer.support')}</h4>
              <div className="space-y-2">
                <Link to="/faq" className="block text-muted-foreground hover:text-primary">{t('footer.faq')}</Link>
                <Link to="/contact" className="block text-muted-foreground hover:text-primary">{t('footer.contact')}</Link>
                <Link to="/health-check" className="block text-muted-foreground hover:text-primary">{t('footer.healthCheck')}</Link>
              </div>
            </div>
            <div>
              <h4 className="font-semibold mb-4">{t('footer.contact')}</h4>
              <div className="space-y-2 text-muted-foreground">
                <p>{t('footer.phone')}: +66 XX XXX XXXX</p>
                <p>{t('footer.email')}: info@funaging.com</p>
                <p>LINE: @funagingstudio</p>
              </div>
            </div>
          </div>
          <div className="mt-8 pt-8 border-t text-center text-muted-foreground">
            <p>{t('footer.rights')}</p>
          </div>
        </div>
      </footer>

      {/* Floating FUN Jarvis */}
      <FloatingJarvis />
    </div>
  );
}
