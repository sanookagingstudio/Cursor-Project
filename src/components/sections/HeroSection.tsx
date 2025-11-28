import { ReactNode } from "react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { useTheme } from "@/contexts/ThemeContext";

interface HeroSectionProps {
  title: string;
  subtitle?: string;
  description?: string;
  primaryCTA?: { label: string; href: string };
  secondaryCTA?: { label: string; href: string };
  image?: string;
  className?: string;
  children?: ReactNode;
}

export function HeroSection({
  title,
  subtitle,
  description,
  primaryCTA,
  secondaryCTA,
  image,
  className,
  children,
}: HeroSectionProps) {
  const { settings } = useTheme();
  
  // Get banner settings from CSS variables
  const bannerEnabled = getComputedStyle(document.documentElement)
    .getPropertyValue("--banner-enabled")?.trim() === "1";
  const bannerType = getComputedStyle(document.documentElement)
    .getPropertyValue("--banner-type")?.trim() || "image";
  const bannerImage = getComputedStyle(document.documentElement)
    .getPropertyValue("--banner-image")?.trim();
  const bannerVideo = getComputedStyle(document.documentElement)
    .getPropertyValue("--banner-video")?.trim();
  const bannerOverlayColor = getComputedStyle(document.documentElement)
    .getPropertyValue("--banner-overlay-color")?.trim() || "#000000";
  const bannerOverlayOpacity = parseFloat(
    getComputedStyle(document.documentElement)
      .getPropertyValue("--banner-overlay-opacity")?.trim() || "0.3"
  );
  const bannerHeight = getComputedStyle(document.documentElement)
    .getPropertyValue("--banner-height")?.trim() || "auto";
  const bannerPosition = getComputedStyle(document.documentElement)
    .getPropertyValue("--banner-position")?.trim() || "center";

  const hasBanner = bannerEnabled && (bannerImage || bannerVideo);

  return (
    <section className={cn("section-padding gradient-warm relative overflow-hidden", className)}>
      {/* Banner Background */}
      {hasBanner && (
        <div
          className="absolute inset-0 z-0"
          style={{
            height: bannerHeight !== "auto" ? bannerHeight : undefined,
            minHeight: bannerHeight === "auto" ? "400px" : undefined,
          }}
        >
          {bannerType === "video" && bannerVideo ? (
            <video
              autoPlay
              loop
              muted
              playsInline
              className="w-full h-full object-cover"
              style={{ objectFit: "cover" }}
            >
              <source src={bannerVideo} type="video/mp4" />
              <source src={bannerVideo} type="video/webm" />
            </video>
          ) : bannerImage ? (
            <div
              className="w-full h-full bg-cover bg-center"
              style={{
                backgroundImage: bannerImage,
              }}
            />
          ) : null}
          
          {/* Overlay */}
          <div
            className="absolute inset-0"
            style={{
              backgroundColor: bannerOverlayColor,
              opacity: bannerOverlayOpacity,
            }}
          />
        </div>
      )}

      <div className={cn("container-padding w-full relative z-10", hasBanner && (bannerPosition === "center" ? "flex items-center" : bannerPosition === "top" ? "flex items-start" : "flex items-end"))}>
        <div className={cn("grid lg:grid-cols-2 gap-12 items-center", hasBanner && "w-full")}>
          <div className="space-y-6">
            {subtitle && (
              <div className="inline-block px-4 py-2 bg-primary/10 text-primary rounded-full text-base font-medium">
                {subtitle}
              </div>
            )}
            <h1 className="text-5xl md:text-6xl lg:text-7xl font-bold leading-tight">
              {title}
            </h1>
            {description && (
              <p className="text-2xl text-muted-foreground leading-relaxed">
                {description}
              </p>
            )}
            <div className="flex flex-col sm:flex-row gap-4 pt-4">
              {primaryCTA && (
                <Button size="lg" className="btn-elderly text-lg" asChild>
                  <a href={primaryCTA.href}>{primaryCTA.label}</a>
                </Button>
              )}
              {secondaryCTA && (
                <Button size="lg" variant="outline" className="btn-elderly text-lg" asChild>
                  <a href={secondaryCTA.href}>{secondaryCTA.label}</a>
                </Button>
              )}
            </div>
            {children}
          </div>
          {image && (
            <div className="relative aspect-square lg:aspect-auto lg:h-[500px] rounded-2xl overflow-hidden shadow-large">
              <img
                src={image}
                alt={title}
                className="w-full h-full object-cover"
              />
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
