import { AdminLayout } from "@/layouts/AdminLayout";
import { useState, useRef, useEffect } from "react";
import { useTheme } from "@/contexts/ThemeContext";
import { useToast } from "@/components/ui/use-toast";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { 
  Save, 
  MousePointer2, 
  Type, 
  Palette,
  Image as ImageIcon,
  X,
  Check,
  Upload,
  RotateCcw,
  Smartphone,
  Tablet,
  Monitor,
  Sparkles
} from "lucide-react";
import { cn } from "@/lib/utils";
import { HeroSection } from "@/components/sections/HeroSection";
import { useTranslation } from "react-i18next";

interface EditableElement {
  id: string;
  type: 'text' | 'color' | 'image' | 'font' | 'spacing';
  label: string;
  value: any;
  previewSelector?: string;
  settingsKey?: string; // Path to setting in ThemeSettings
}

const THEME_PRESETS = [
  {
    name: "Sanook Default",
    colors: { primary: "#F36F21", secondary: "#D2142C", background: "#FAF5EF" },
    font: "Noto Serif Thai",
    image: "https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=2940&auto=format&fit=crop"
  },
  {
    name: "Ocean Breeze",
    colors: { primary: "#0EA5E9", secondary: "#0284C7", background: "#F0F9FF" },
    font: "Kanit",
    image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=2940&auto=format&fit=crop"
  },
  {
    name: "Nature Green",
    colors: { primary: "#16A34A", secondary: "#15803D", background: "#F0FDF4" },
    font: "Sarabun",
    image: "https://images.unsplash.com/photo-1585320806297-11795182c6d7?q=80&w=2940&auto=format&fit=crop"
  },
  {
    name: "Elegant Dark",
    colors: { primary: "#D4AF37", secondary: "#1A1A1A", background: "#121212" },
    font: "Prompt",
    image: "https://images.unsplash.com/photo-1545205597-3d9d02c29597?q=80&w=2940&auto=format&fit=crop"
  }
];

export default function VisualThemeEditor() {
  const { settings, updateSettings, saveTheme, resetTheme } = useTheme();
  const { toast } = useToast();
  const { t } = useTranslation();
  const [editMode, setEditMode] = useState(true);
  const [selectedElement, setSelectedElement] = useState<string | null>(null);
  const [hoveredElement, setHoveredElement] = useState<string | null>(null);
  const [previewMode, setPreviewMode] = useState<'desktop' | 'tablet' | 'mobile'>('desktop');
  const fileInputRef = useRef<HTMLInputElement>(null);
  const previewRef = useRef<HTMLDivElement>(null);

  // Get current values from settings, with fallbacks to translations
  const editableElements: EditableElement[] = [
    { 
      id: 'hero-title', 
      type: 'text', 
      label: 'Hero Title', 
      value: settings?.content?.['hero.title'] ?? t('hero.title') ?? 'Welcome to FunAging Studio',
      settingsKey: 'hero.title',
      previewSelector: '.hero-title'
    },
    { 
      id: 'hero-subtitle', 
      type: 'text', 
      label: 'Hero Subtitle', 
      value: settings?.content?.['hero.subtitle'] ?? t('hero.subtitle') ?? 'Active Aging Ecosystem',
      settingsKey: 'hero.subtitle',
      previewSelector: '.hero-subtitle'
    },
    { 
      id: 'primary-color', 
      type: 'color', 
      label: 'Primary Color', 
      value: settings?.colors?.primary || '#F36F21',
      settingsKey: 'colors.primary'
    },
    { 
      id: 'secondary-color', 
      type: 'color', 
      label: 'Secondary Color', 
      value: settings?.colors?.secondary || '#8B4513',
      settingsKey: 'colors.secondary'
    },
    { 
      id: 'banner-image', 
      type: 'image', 
      label: 'Hero Banner Image', 
      value: settings?.banner?.imageUrl || '/placeholder.svg',
      settingsKey: 'banner.imageUrl',
      previewSelector: 'img[data-theme-key="banner.imageUrl"]'
    },
    { 
      id: 'font-family', 
      type: 'font', 
      label: 'Font Family', 
      value: settings?.typography?.fontFamily || 'Noto Serif Thai',
      settingsKey: 'typography.fontFamily'
    },
  ];

  const handleElementClick = (elementId: string) => {
    if (!editMode) return;
    setSelectedElement(elementId);
  };

  // Interactive click handler for the preview area
  const handlePreviewClick = (e: React.MouseEvent) => {
    if (!editMode) return;
    
    const target = e.target as HTMLElement;
    
    // Check if clicked element maps to a setting
    const themeKey = target.getAttribute('data-theme-key') || 
                     target.closest('[data-theme-key]')?.getAttribute('data-theme-key');
    
    if (themeKey) {
        e.stopPropagation(); // Prevent bubbling
        const element = editableElements.find(el => el.settingsKey === themeKey);
        if (element) {
            setSelectedElement(element.id);
            toast({
                title: `Editing ${element.label}`,
                description: "Use the panel on the right to modify.",
                duration: 1500
            });
        }
    }
  };

  const handlePreviewMouseMove = (e: React.MouseEvent) => {
    if (!editMode) return;
    const target = e.target as HTMLElement;
    const themeKey = target.getAttribute('data-theme-key') || 
                     target.closest('[data-theme-key]')?.getAttribute('data-theme-key');
                     
    if (themeKey) {
        const element = editableElements.find(el => el.settingsKey === themeKey);
        if (element) setHoveredElement(element.id);
    } else {
        setHoveredElement(null);
    }
  };

  const handleValueChange = (elementId: string, newValue: any) => {
    const element = editableElements.find(e => e.id === elementId);
    if (!element) return;

    // Update settings based on element type/id
    if (element.type === 'text') {
        updateSettings({
            content: {
                ...settings!.content,
                [element.settingsKey!]: newValue
            }
        });
    } else if (elementId === 'primary-color') {
        updateSettings({
            colors: { ...settings!.colors, primary: newValue }
        });
    } else if (elementId === 'secondary-color') {
        updateSettings({
            colors: { ...settings!.colors, secondary: newValue }
        });
    } else if (elementId === 'banner-image') {
        updateSettings({
            banner: { ...settings!.banner, imageUrl: newValue, enabled: true }
        });
    } else if (elementId === 'font-family') {
        updateSettings({
            typography: { ...settings!.typography, fontFamily: newValue }
        });
    }
  };

  const applyPreset = (preset: typeof THEME_PRESETS[0]) => {
      if (confirm(`Apply "${preset.name}" theme? This will overwrite current settings.`)) {
          updateSettings({
              colors: { ...settings!.colors, ...preset.colors },
              typography: { ...settings!.typography, fontFamily: preset.font },
              banner: { ...settings!.banner, imageUrl: preset.image, enabled: true }
          });
          toast({
              title: "Theme Applied",
              description: `${preset.name} theme active.`,
          });
      }
  };

  const handleFileUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (e) => {
        const result = e.target?.result as string;
        if (selectedElement === 'banner-image') {
            handleValueChange('banner-image', result);
        }
    };
    reader.readAsDataURL(file);
  };

  const triggerFileUpload = () => {
    fileInputRef.current?.click();
  };

  const handleSave = async () => {
    try {
      await saveTheme("Visual Theme Custom");
      toast({
        title: "Success",
        description: "Theme saved successfully! Changes are now live.",
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to save theme. Please try again.",
        variant: "destructive",
      });
    }
  };

  const handleReset = () => {
    if (confirm("Are you sure you want to reset all changes to default?")) {
        resetTheme();
        toast({
            title: "Reset Complete",
            description: "Theme has been reset to defaults.",
        });
    }
  };

  const getCurrentElement = () => {
    return editableElements.find(e => e.id === selectedElement);
  };

  return (
    <AdminLayout>
      <div className="space-y-6 h-[calc(100vh-100px)] flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between shrink-0">
          <div>
            <h1 className="text-4xl font-bold mb-1">Visual Theme Editor</h1>
            <p className="text-muted-foreground">
              Interactive WYSIWYG Editor - Click any element to edit
            </p>
          </div>
          <div className="flex gap-2">
            <Button
              onClick={() => setEditMode(!editMode)}
              variant={editMode ? "secondary" : "outline"}
              className="gap-2"
            >
              <MousePointer2 className="h-4 w-4" />
              {editMode ? "Edit Mode ON" : "Preview Mode"}
            </Button>
            <Button onClick={handleReset} variant="outline" className="gap-2">
              <RotateCcw className="h-4 w-4" />
              Reset
            </Button>
            <Button onClick={handleSave} className="gap-2 bg-primary text-white hover:bg-primary/90">
              <Save className="h-4 w-4" />
              Save Changes
            </Button>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-4 gap-6 flex-1 overflow-hidden">
          {/* Preview Area */}
          <div className="lg:col-span-3 flex flex-col h-full">
            <Card className="flex-1 flex flex-col overflow-hidden border-2 border-muted/20 shadow-sm">
              <div className="p-2 border-b bg-muted/10 flex items-center justify-between px-4">
                  <div className="flex items-center gap-2">
                      <Button
                        variant={previewMode === 'desktop' ? 'default' : 'ghost'}
                        size="icon"
                        onClick={() => setPreviewMode('desktop')}
                        title="Desktop View"
                      >
                        <Monitor className="h-4 w-4" />
                      </Button>
                      <Button
                        variant={previewMode === 'tablet' ? 'default' : 'ghost'}
                        size="icon"
                        onClick={() => setPreviewMode('tablet')}
                        title="Tablet View"
                      >
                        <Tablet className="h-4 w-4" />
                      </Button>
                      <Button
                        variant={previewMode === 'mobile' ? 'default' : 'ghost'}
                        size="icon"
                        onClick={() => setPreviewMode('mobile')}
                        title="Mobile View"
                      >
                        <Smartphone className="h-4 w-4" />
                      </Button>
                  </div>
                  <div className="text-sm text-muted-foreground">
                      {editMode ? "👆 Click elements to edit" : "👀 Preview Mode"}
                  </div>
              </div>
              
              <div className="flex-1 bg-muted/5 overflow-auto p-4 relative">
                <div 
                  ref={previewRef}
                  className={cn(
                    "bg-background shadow-2xl transition-all mx-auto relative min-h-full border rounded-lg overflow-hidden origin-top",
                    previewMode === 'desktop' && "w-full",
                    previewMode === 'tablet' && "w-[768px]",
                    previewMode === 'mobile' && "w-[375px]"
                  )}
                  onClick={handlePreviewClick}
                  onMouseMove={handlePreviewMouseMove}
                >
                  {/* Real-time Preview Component */}
                  <HeroSection
                    subtitle={editableElements.find(e => e.id === 'hero-subtitle')?.value}
                    title={editableElements.find(e => e.id === 'hero-title')?.value}
                    description={t('hero.description')}
                    primaryCTA={{ label: t('hero.primaryCTA'), href: "/join-now" }}
                    secondaryCTA={{ label: t('hero.secondaryCTA'), href: "/about" }}
                    image={editableElements.find(e => e.id === 'banner-image')?.value}
                  />
                  
                  {/* Hover Highlighting Overlay */}
                  {editMode && hoveredElement && (
                      (() => {
                          // Find element in preview to get coordinates (this is a simplified simulation)
                          // In a full iframe solution we would use getBoundingClientRect
                          const el = editableElements.find(e => e.id === hoveredElement);
                          if (el?.type === 'text' && el.id === 'hero-title') {
                             return <div className="absolute top-[25%] left-[5%] w-[45%] h-[150px] border-2 border-primary border-dashed pointer-events-none animate-pulse rounded-md" />;
                          }
                          if (el?.type === 'text' && el.id === 'hero-subtitle') {
                             return <div className="absolute top-[15%] left-[5%] w-[20%] h-[40px] border-2 border-primary border-dashed pointer-events-none animate-pulse rounded-md" />;
                          }
                          if (el?.type === 'image') {
                             return <div className="absolute top-0 right-0 w-[50%] h-full border-2 border-primary border-dashed pointer-events-none animate-pulse rounded-md" />;
                          }
                          return null;
                      })()
                  )}
                </div>
              </div>
            </Card>
          </div>

          {/* Sidebar */}
          <div className="flex flex-col gap-4 h-full overflow-hidden">
             {/* Theme Presets Panel */}
             <Card className="shrink-0">
                 <CardContent className="p-4">
                     <h3 className="font-semibold mb-3 flex items-center gap-2 text-sm">
                         <Sparkles className="h-4 w-4 text-yellow-500" />
                         Instant Themes (Canva Style)
                     </h3>
                     <div className="grid grid-cols-2 gap-2">
                         {THEME_PRESETS.map(preset => (
                             <button
                                 key={preset.name}
                                 onClick={() => applyPreset(preset)}
                                 className="flex flex-col items-center p-2 rounded border hover:border-primary hover:bg-primary/5 transition-colors text-xs text-center"
                             >
                                 <div className="w-full h-8 rounded mb-1" style={{ background: `linear-gradient(135deg, ${preset.colors.primary}, ${preset.colors.secondary})` }} />
                                 {preset.name}
                             </button>
                         ))}
                     </div>
                 </CardContent>
             </Card>

            <Card className="flex-1 flex flex-col overflow-hidden">
              <CardContent className="p-4 flex-1 overflow-y-auto">
                <h3 className="font-semibold mb-4 flex items-center gap-2 text-lg">
                  <Palette className="h-5 w-5" />
                  Manual Controls
                </h3>
                
                <div className="space-y-3">
                  {editableElements.map((element) => (
                    <div
                      key={element.id}
                      onClick={() => handleElementClick(element.id)}
                      onMouseEnter={() => setHoveredElement(element.id)}
                      onMouseLeave={() => setHoveredElement(null)}
                      className={cn(
                        "p-3 rounded-lg border cursor-pointer transition-all hover:shadow-md group",
                        selectedElement === element.id
                          ? "border-primary bg-primary/5 shadow-sm"
                          : "border-border hover:border-primary/50"
                      )}
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <div className={cn(
                            "p-2 rounded-full bg-muted group-hover:bg-background transition-colors",
                            element.type === 'color' && "p-1"
                          )}>
                             {element.type === 'color' && (
                               <div className="w-6 h-6 rounded-full border" style={{ backgroundColor: element.value }} />
                             )}
                             {element.type === 'text' && <Type className="h-4 w-4" />}
                             {element.type === 'image' && <ImageIcon className="h-4 w-4" />}
                             {element.type === 'font' && <Type className="h-4 w-4" />}
                          </div>
                          <div>
                            <div className="font-medium text-sm">{element.label}</div>
                            <div className="text-xs text-muted-foreground capitalize">{element.type}</div>
                          </div>
                        </div>
                        {selectedElement === element.id && <Check className="h-4 w-4 text-primary" />}
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            {/* Edit Panel (Slide up/in or Conditional) */}
            {selectedElement && getCurrentElement() && (
              <Card className="border-primary/20 shadow-lg animate-in slide-in-from-bottom-10 fade-in">
                <CardContent className="p-4">
                  <div className="flex items-center justify-between mb-4 pb-2 border-b">
                    <h3 className="font-semibold">Edit {getCurrentElement()?.label}</h3>
                    <Button variant="ghost" size="icon" onClick={() => setSelectedElement(null)} className="h-8 w-8">
                      <X className="h-4 w-4" />
                    </Button>
                  </div>
                  
                  {(() => {
                    const element = getCurrentElement()!;

                    switch (element.type) {
                      case 'color':
                        return (
                          <div className="space-y-3">
                            <Label>Pick Color</Label>
                            <div className="flex gap-2">
                              <div className="relative overflow-hidden w-10 h-10 rounded-full border shadow-sm">
                                <input
                                  type="color"
                                  value={element.value}
                                  onChange={(e) => handleValueChange(selectedElement, e.target.value)}
                                  className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-[150%] h-[150%] p-0 border-0 cursor-pointer"
                                />
                              </div>
                              <Input
                                type="text"
                                value={element.value}
                                onChange={(e) => handleValueChange(selectedElement, e.target.value)}
                                className="font-mono"
                              />
                            </div>
                          </div>
                        );
                      case 'image':
                        return (
                          <div className="space-y-3">
                            <Label>Image Source</Label>
                            <div className="flex gap-2">
                                <Input
                                  value={element.value}
                                  onChange={(e) => handleValueChange(selectedElement, e.target.value)}
                                  placeholder="https://..."
                                />
                                <Button size="icon" variant="outline" onClick={triggerFileUpload} title="Upload Image">
                                    <Upload className="h-4 w-4" />
                                </Button>
                                <input 
                                    type="file" 
                                    ref={fileInputRef} 
                                    className="hidden" 
                                    accept="image/*" 
                                    onChange={handleFileUpload}
                                />
                            </div>
                            <div className="text-xs text-muted-foreground">
                                Enter URL or upload a file.
                            </div>
                          </div>
                        );
                      case 'font':
                        return (
                          <div className="space-y-3">
                            <Label>Font Family</Label>
                            <select
                              value={element.value}
                              onChange={(e) => handleValueChange(selectedElement, e.target.value)}
                              className="w-full px-3 py-2 border rounded-md bg-background"
                            >
                              <option value="Noto Serif Thai">Noto Serif Thai (Default)</option>
                              <option value="Prompt">Prompt</option>
                              <option value="Kanit">Kanit</option>
                              <option value="Sarabun">Sarabun</option>
                              <option value="Mitr">Mitr</option>
                            </select>
                          </div>
                        );
                      case 'text':
                        return (
                          <div className="space-y-3">
                            <Label>Content</Label>
                            <Input
                              value={element.value}
                              onChange={(e) => handleValueChange(selectedElement, e.target.value)}
                              className="text-lg"
                            />
                            <p className="text-xs text-muted-foreground">
                              Changes apply instantly to preview. Save to persist.
                            </p>
                          </div>
                        );
                      default:
                        return null;
                    }
                  })()}
                </CardContent>
              </Card>
            )}
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
