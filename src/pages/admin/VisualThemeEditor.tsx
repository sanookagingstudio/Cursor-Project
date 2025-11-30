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
  Move,
  Maximize2
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
}

export default function VisualThemeEditor() {
  const { settings, updateSettings, saveTheme } = useTheme();
  const { toast } = useToast();
  const { t } = useTranslation();
  const [editMode, setEditMode] = useState(true);
  const [selectedElement, setSelectedElement] = useState<string | null>(null);
  const [hoveredElement, setHoveredElement] = useState<string | null>(null);
  const [previewMode, setPreviewMode] = useState<'desktop' | 'tablet' | 'mobile'>('desktop');

  // Get current values from settings
  const editableElements: EditableElement[] = [
    { 
      id: 'hero-title', 
      type: 'text', 
      label: 'Hero Title', 
      value: t('hero.title') || 'Welcome to FunAging Studio',
      previewSelector: '.hero-title'
    },
    { 
      id: 'hero-subtitle', 
      type: 'text', 
      label: 'Hero Subtitle', 
      value: t('hero.subtitle') || 'Active Aging Ecosystem',
      previewSelector: '.hero-subtitle'
    },
    { 
      id: 'primary-color', 
      type: 'color', 
      label: 'Primary Color', 
      value: settings?.colors?.primary || '#F36F21'
    },
    { 
      id: 'secondary-color', 
      type: 'color', 
      label: 'Secondary Color', 
      value: settings?.colors?.secondary || '#8B4513'
    },
    { 
      id: 'banner-image', 
      type: 'image', 
      label: 'Hero Banner Image', 
      value: settings?.banner?.imageUrl || '/placeholder.svg'
    },
    { 
      id: 'font-family', 
      type: 'font', 
      label: 'Font Family', 
      value: settings?.typography?.fontFamily || 'Noto Serif Thai'
    },
  ];

  const handleElementClick = (elementId: string) => {
    if (!editMode) return;
    setSelectedElement(elementId);
  };

  const handleValueChange = (elementId: string, newValue: any) => {
    const element = editableElements.find(e => e.id === elementId);
    if (!element) return;

    switch (element.type) {
      case 'color':
        if (elementId === 'primary-color') {
          updateSettings({
            colors: {
              ...settings!.colors,
              primary: newValue,
            },
          });
        } else if (elementId === 'secondary-color') {
          updateSettings({
            colors: {
              ...settings!.colors,
              secondary: newValue,
            },
          });
        }
        break;
      case 'image':
        updateSettings({
          banner: {
            ...settings!.banner,
            imageUrl: newValue,
            enabled: true,
          },
        });
        break;
      case 'font':
        updateSettings({
          typography: {
            ...settings!.typography,
            fontFamily: newValue,
          },
        });
        break;
      case 'text':
        // For text, we'd need to update translations or create a custom override
        // For now, just show a toast
        toast({
          title: "Text Editing",
          description: "Text editing requires translation updates. Use the Theme Customization page for text changes.",
        });
        break;
    }
  };

  const handleSave = async () => {
    try {
      await saveTheme("Visual Theme");
      toast({
        title: "Success",
        description: "Theme saved successfully",
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to save theme",
        variant: "destructive",
      });
    }
  };

  const getCurrentElement = () => {
    return editableElements.find(e => e.id === selectedElement);
  };

  return (
    <AdminLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-5xl font-bold mb-2">Visual Theme Editor</h1>
            <p className="text-lg text-muted-foreground">
              Click elements to edit • Real-time preview • Drag to reposition
            </p>
          </div>
          <div className="flex gap-2">
            <Button
              onClick={() => setEditMode(!editMode)}
              variant={editMode ? "default" : "outline"}
              className="gap-2"
            >
              <MousePointer2 className="h-4 w-4" />
              {editMode ? "Edit Mode ON" : "Edit Mode OFF"}
            </Button>
            <Button onClick={handleSave} className="gap-2">
              <Save className="h-4 w-4" />
              Save Theme
            </Button>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
          {/* Preview Area - Takes 3 columns */}
          <div className="lg:col-span-3">
            <Card className="relative">
              <div className="p-4 border-b flex items-center justify-between">
                <div className="flex gap-2">
                  <Button
                    variant={previewMode === 'desktop' ? 'default' : 'outline'}
                    size="sm"
                    onClick={() => setPreviewMode('desktop')}
                  >
                    Desktop
                  </Button>
                  <Button
                    variant={previewMode === 'tablet' ? 'default' : 'outline'}
                    size="sm"
                    onClick={() => setPreviewMode('tablet')}
                  >
                    Tablet
                  </Button>
                  <Button
                    variant={previewMode === 'mobile' ? 'default' : 'outline'}
                    size="sm"
                    onClick={() => setPreviewMode('mobile')}
                  >
                    Mobile
                  </Button>
                </div>
                {editMode && (
                  <div className="text-sm text-muted-foreground">
                    Click elements to edit
                  </div>
                )}
              </div>
              <CardContent className="p-0">
                <div 
                  className={cn(
                    "relative bg-background overflow-auto transition-all",
                    previewMode === 'desktop' && "w-full",
                    previewMode === 'tablet' && "max-w-3xl mx-auto",
                    previewMode === 'mobile' && "max-w-sm mx-auto"
                  )}
                  style={{ 
                    minHeight: '600px',
                    maxHeight: '800px'
                  }}
                >
                  {/* Real-time Preview */}
                  <div className="relative">
                    <HeroSection
                      subtitle={editableElements.find(e => e.id === 'hero-subtitle')?.value || ''}
                      title={editableElements.find(e => e.id === 'hero-title')?.value || ''}
                      description={t('hero.description')}
                      primaryCTA={{ label: t('hero.primaryCTA'), href: "/join-now" }}
                      secondaryCTA={{ label: t('hero.secondaryCTA'), href: "/about" }}
                      image={editableElements.find(e => e.id === 'banner-image')?.value || '/placeholder.svg'}
                    />
                    
                    {/* Overlay for edit mode */}
                    {editMode && (
                      <div className="absolute inset-0 pointer-events-none">
                        {/* Highlight hovered elements */}
                        {hoveredElement && (
                          <div className="absolute inset-0 border-4 border-primary border-dashed rounded-lg m-2 pointer-events-none animate-pulse" />
                        )}
                      </div>
                    )}
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Editor Panel - Takes 1 column */}
          <div className="space-y-4">
            {/* Element List */}
            <Card>
              <CardContent className="p-4">
                <h3 className="font-semibold mb-4 flex items-center gap-2">
                  <MousePointer2 className="h-4 w-4" />
                  Editable Elements
                </h3>
                <div className="space-y-2">
                  {editableElements.map((element) => (
                    <div
                      key={element.id}
                      onClick={() => handleElementClick(element.id)}
                      onMouseEnter={() => setHoveredElement(element.id)}
                      onMouseLeave={() => setHoveredElement(null)}
                      className={cn(
                        "p-3 rounded-lg border cursor-pointer transition-all",
                        selectedElement === element.id
                          ? "border-primary bg-primary text-primary-foreground shadow-md"
                          : hoveredElement === element.id
                          ? "border-primary/50 bg-primary/5"
                          : "border-border hover:border-primary/30"
                      )}
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-2">
                          {element.type === 'color' && <Palette className="h-4 w-4" />}
                          {element.type === 'text' && <Type className="h-4 w-4" />}
                          {element.type === 'image' && <ImageIcon className="h-4 w-4" />}
                          {element.type === 'font' && <Type className="h-4 w-4" />}
                          <div>
                            <div className={cn(
                              "font-medium text-sm",
                              selectedElement === element.id && "text-primary-foreground"
                            )}>
                              {element.label}
                            </div>
                            <div className={cn(
                              "text-xs",
                              selectedElement === element.id ? "text-primary-foreground/80" : "text-muted-foreground"
                            )}>
                              {element.type}
                            </div>
                          </div>
                        </div>
                        {selectedElement === element.id && (
                          <Check className="h-4 w-4" />
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            {/* Property Editor */}
            {selectedElement && getCurrentElement() && (
              <Card>
                <CardContent className="p-4">
                  <div className="flex items-center justify-between mb-4">
                    <h3 className="font-semibold">Edit Properties</h3>
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => setSelectedElement(null)}
                    >
                      <X className="h-4 w-4" />
                    </Button>
                  </div>
                  
                  {(() => {
                    const element = getCurrentElement()!;

                    switch (element.type) {
                      case 'color':
                        return (
                          <div className="space-y-3">
                            <Label>Color Value</Label>
                            <div className="flex gap-2">
                              <input
                                type="color"
                                value={element.value}
                                onChange={(e) => handleValueChange(selectedElement, e.target.value)}
                                className="w-16 h-10 rounded border cursor-pointer"
                              />
                              <Input
                                type="text"
                                value={element.value}
                                onChange={(e) => handleValueChange(selectedElement, e.target.value)}
                                placeholder="#F36F21"
                              />
                            </div>
                            <div 
                              className="w-full h-20 rounded border-2"
                              style={{ backgroundColor: element.value }}
                            />
                          </div>
                        );
                      case 'image':
                        return (
                          <div className="space-y-3">
                            <Label>Image URL</Label>
                            <Input
                              type="url"
                              value={element.value}
                              onChange={(e) => handleValueChange(selectedElement, e.target.value)}
                              placeholder="https://example.com/image.jpg"
                            />
                            {element.value && (
                              <div className="w-full h-32 rounded border overflow-hidden">
                                <img 
                                  src={element.value} 
                                  alt="Preview" 
                                  className="w-full h-full object-cover"
                                  onError={(e) => {
                                    (e.target as HTMLImageElement).src = '/placeholder.svg';
                                  }}
                                />
                              </div>
                            )}
                          </div>
                        );
                      case 'font':
                        return (
                          <div className="space-y-3">
                            <Label>Font Family</Label>
                            <select
                              value={element.value}
                              onChange={(e) => handleValueChange(selectedElement, e.target.value)}
                              className="w-full px-3 py-2 border rounded bg-background"
                            >
                              <option value="Noto Serif Thai">Noto Serif Thai</option>
                              <option value="Prompt">Prompt</option>
                              <option value="Kanit">Kanit</option>
                              <option value="Sarabun">Sarabun</option>
                              <option value="Sarabun">Mitr</option>
                            </select>
                            <div 
                              className="p-4 border rounded"
                              style={{ fontFamily: element.value }}
                            >
                              Preview: The quick brown fox jumps over the lazy dog
                            </div>
                          </div>
                        );
                      case 'text':
                        return (
                          <div className="space-y-3">
                            <Label>Text Content</Label>
                            <Input
                              type="text"
                              value={element.value}
                              onChange={(e) => handleValueChange(selectedElement, e.target.value)}
                              disabled
                            />
                            <p className="text-xs text-muted-foreground">
                              Text editing requires translation updates. Use Theme Customization for text changes.
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
