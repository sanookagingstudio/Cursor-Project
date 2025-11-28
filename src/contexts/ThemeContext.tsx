import React, { createContext, useContext, useState, useEffect, ReactNode } from "react";
import { getApiUrl } from "@/lib/api";

interface ThemeSettings {
  colors: {
    primary: string;
    secondary: string;
    accent: string;
    background: string;
    foreground: string;
    muted: string;
    border: string;
    destructive: string;
    success: string;
    warning: string;
  };
  typography: {
    fontFamily: string;
    baseFontSize: string;
    headingSizes: {
      h1: string;
      h2: string;
      h3: string;
      h4: string;
      h5: string;
      h6: string;
    };
    lineHeight: string;
    letterSpacing: string;
    fontWeight: string;
  };
  spacing: {
    base: string;
    cardPadding: string;
    buttonPadding: string;
    inputPadding: string;
    sectionSpacing: string;
  };
  layout: {
    containerMaxWidth: string;
    sidebarWidth: string;
    headerHeight: string;
    footerHeight: string;
    gridGaps: string;
  };
  components: {
    button: { borderRadius: string; shadow: string };
    card: { borderRadius: string; shadow: string };
    input: { borderRadius: string; shadow: string };
    table: { borderRadius: string; shadow: string };
  };
  effects: {
    borderRadius: string;
    shadow: string;
    transition: string;
    hoverEffect: string;
  };
  banner: {
    enabled: boolean;
    type: string;
    imageUrl?: string;
    videoUrl?: string;
    videoAutoplay: boolean;
    videoLoop: boolean;
    videoMuted: boolean;
    overlayColor: string;
    overlayOpacity: number;
    height: string;
    position: string;
  };
}

interface Theme {
  id: string;
  name: string;
  description?: string;
  is_preset: boolean;
  is_active: boolean;
  settings: ThemeSettings;
}

interface ThemeContextType {
  currentTheme: Theme | null;
  settings: ThemeSettings | null;
  applyTheme: (themeId: string) => Promise<void>;
  updateSettings: (settings: Partial<ThemeSettings>) => void;
  saveTheme: (name: string, description?: string) => Promise<void>;
  resetTheme: () => void;
  previewTheme: (settings: ThemeSettings) => void;
  loading: boolean;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

const defaultSettings: ThemeSettings = {
  colors: {
    primary: "#F36F21",
    secondary: "#D2142C",
    accent: "#4CAF50",
    background: "#FAF5EF",
    foreground: "#0D0D0D",
    muted: "#3D3D3D",
    border: "#D3D3D3",
    destructive: "#EF4444",
    success: "#10B981",
    warning: "#F59E0B",
  },
  typography: {
    fontFamily: "Noto Serif Thai",
    baseFontSize: "18px",
    headingSizes: {
      h1: "3rem",
      h2: "2.5rem",
      h3: "2rem",
      h4: "1.5rem",
      h5: "1.25rem",
      h6: "1rem",
    },
    lineHeight: "1.6",
    letterSpacing: "0em",
    fontWeight: "400",
  },
  spacing: {
    base: "1rem",
    cardPadding: "1.5rem",
    buttonPadding: "0.75rem 1.5rem",
    inputPadding: "0.75rem 1rem",
    sectionSpacing: "3rem",
  },
  layout: {
    containerMaxWidth: "100%",
    sidebarWidth: "16rem",
    headerHeight: "5rem",
    footerHeight: "auto",
    gridGaps: "1rem",
  },
  components: {
    button: { borderRadius: "0.5rem", shadow: "0 2px 4px rgba(0,0,0,0.1)" },
    card: { borderRadius: "0.75rem", shadow: "0 4px 6px rgba(0,0,0,0.1)" },
    input: { borderRadius: "0.5rem", shadow: "none" },
    table: { borderRadius: "0.5rem", shadow: "none" },
  },
  effects: {
    borderRadius: "0.75rem",
    shadow: "0 2px 8px rgba(0,0,0,0.1)",
    transition: "0.2s ease",
    hoverEffect: "scale(1.02)",
  },
  banner: {
    enabled: false,
    type: "image",
    imageUrl: undefined,
    videoUrl: undefined,
    videoAutoplay: true,
    videoLoop: true,
    videoMuted: true,
    overlayColor: "#000000",
    overlayOpacity: 0.3,
    height: "auto",
    position: "center",
  },
};

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [currentTheme, setCurrentTheme] = useState<Theme | null>(null);
  const [settings, setSettings] = useState<ThemeSettings>(defaultSettings);
  const [loading, setLoading] = useState(true);

  // Load active theme on mount
  useEffect(() => {
    loadActiveTheme();
  }, []);

  // Apply settings to CSS variables
  useEffect(() => {
    applySettingsToCSS(settings);
  }, [settings]);

  const loadActiveTheme = async () => {
    try {
      const response = await fetch(getApiUrl("/themes/active"));
      if (response.ok) {
        const theme = await response.json();
        setCurrentTheme(theme);
        setSettings(theme.settings || defaultSettings);
      }
    } catch (error) {
      console.error("Failed to load active theme:", error);
    } finally {
      setLoading(false);
    }
  };

  const applySettingsToCSS = (themeSettings: ThemeSettings) => {
    const root = document.documentElement;

    // Colors
    Object.entries(themeSettings.colors).forEach(([key, value]) => {
      root.style.setProperty(`--${key}`, value);
    });

    // Typography
    root.style.setProperty("--font-family", themeSettings.typography.fontFamily);
    root.style.setProperty("--font-size-base", themeSettings.typography.baseFontSize);
    root.style.setProperty("--line-height", themeSettings.typography.lineHeight);
    root.style.setProperty("--letter-spacing", themeSettings.typography.letterSpacing);
    root.style.setProperty("--font-weight", themeSettings.typography.fontWeight);

    // Heading sizes
    Object.entries(themeSettings.typography.headingSizes).forEach(([key, value]) => {
      root.style.setProperty(`--${key}-size`, value);
    });

    // Spacing
    Object.entries(themeSettings.spacing).forEach(([key, value]) => {
      root.style.setProperty(`--spacing-${key}`, value);
    });

    // Layout
    Object.entries(themeSettings.layout).forEach(([key, value]) => {
      root.style.setProperty(`--layout-${key}`, value);
    });

    // Effects
    root.style.setProperty("--border-radius", themeSettings.effects.borderRadius);
    root.style.setProperty("--shadow", themeSettings.effects.shadow);
    root.style.setProperty("--transition", themeSettings.effects.transition);

    // Banner
    if (themeSettings.banner.enabled) {
      root.style.setProperty("--banner-enabled", "1");
      root.style.setProperty("--banner-type", themeSettings.banner.type);
      if (themeSettings.banner.imageUrl) {
        root.style.setProperty("--banner-image", `url(${themeSettings.banner.imageUrl})`);
      }
      if (themeSettings.banner.videoUrl) {
        root.style.setProperty("--banner-video", themeSettings.banner.videoUrl);
      }
      root.style.setProperty("--banner-overlay-color", themeSettings.banner.overlayColor);
      root.style.setProperty("--banner-overlay-opacity", String(themeSettings.banner.overlayOpacity));
      root.style.setProperty("--banner-height", themeSettings.banner.height);
      root.style.setProperty("--banner-position", themeSettings.banner.position);
    } else {
      root.style.setProperty("--banner-enabled", "0");
    }
  };

  const applyTheme = async (themeId: string) => {
    try {
      const response = await fetch(getApiUrl(`/themes/${themeId}/apply`), {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ preview: false }),
      });

      if (response.ok) {
        const theme = await response.json();
        setCurrentTheme(theme);
        await loadActiveTheme();
      }
    } catch (error) {
      console.error("Failed to apply theme:", error);
      throw error;
    }
  };

  const updateSettings = (newSettings: Partial<ThemeSettings>) => {
    setSettings((prev) => ({ ...prev, ...newSettings }));
  };

  const saveTheme = async (name: string, description?: string) => {
    try {
      const response = await fetch(getApiUrl("/themes"), {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name,
          description,
          is_preset: false,
          settings,
        }),
      });

      if (response.ok) {
        const theme = await response.json();
        setCurrentTheme(theme);
      }
    } catch (error) {
      console.error("Failed to save theme:", error);
      throw error;
    }
  };

  const resetTheme = () => {
    setSettings(defaultSettings);
  };

  const previewTheme = (previewSettings: ThemeSettings) => {
    applySettingsToCSS(previewSettings);
  };

  return (
    <ThemeContext.Provider
      value={{
        currentTheme,
        settings,
        applyTheme,
        updateSettings,
        saveTheme,
        resetTheme,
        previewTheme,
        loading,
      }}
    >
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error("useTheme must be used within a ThemeProvider");
  }
  return context;
}

