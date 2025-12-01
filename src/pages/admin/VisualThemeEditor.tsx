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
  Sparkles,
  Eye
} from "lucide-react";
import { cn } from "@/lib/utils";
import Index from "@/pages/Index"; // Import the actual page
import { useTranslation } from "react-i18next";

// Note: In a real app, this would be dynamic or configured
const EDITABLE_PAGES = [
    { id: 'home', name: 'Home Page', component: Index }
];

const THEME_PRESETS = [
  {
    name: "Sanook Default",
    colors: { primary: "#F36F21", secondary: "#D2142C", background: "#FAF5EF" },
    font: "Noto Serif Thai",
    content: { "hero.image": "https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=2940&auto=format&fit=crop" }
  },
  {
    name: "Ocean Breeze",
    colors: { primary: "#0EA5E9", secondary: "#0284C7", background: "#F0F9FF" },
    font: "Kanit",
    content: { "hero.image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=2940&auto=format&fit=crop" }
  },
  {
    name: "Nature Green",
    colors: { primary: "#16A34A", secondary: "#15803D", background: "#F0FDF4" },
    font: "Sarabun",
    content: { "hero.image": "https://images.unsplash.com/photo-1585320806297-11795182c6d7?q=80&w=2940&auto=format&fit=crop" }
  },
  {
    name: "Elegant Dark",
    colors: { primary: "#D4AF37", secondary: "#1A1A1A", background: "#121212" },
    font: "Prompt",
    content: { "hero.image": "https://images.unsplash.com/photo-1545205597-3d9d02c29597?q=80&w=2940&auto=format&fit=crop" }
  }
];

export default function VisualThemeEditor() {
  const { settings, updateSettings, saveTheme, resetTheme, setEditMode, selectedElementId, setSelectedElementId } = useTheme();
  const { toast } = useToast();
  const { t } = useTranslation();
  const [isEditActive, setIsEditActive] = useState(true);
  const [previewMode, setPreviewMode] = useState<'desktop' | 'tablet' | 'mobile'>('desktop');
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Sync local state with context
  useEffect(() => {
    setEditMode(isEditActive);
    return () => setEditMode(false); // Cleanup on unmount
  }, [isEditActive, setEditMode]);

  const handleValueChange = (newValue: any) => {
    if (!selectedElementId) return;

    // Determine type based on ID or usage
    const isImage = selectedElementId.includes('image') || selectedElementId.includes('banner');
    
    updateSettings({
        content: {
            ...settings!.content,
            [selectedElementId]: newValue
        }
    });
  };

  const applyPreset = (preset: typeof THEME_PRESETS[0]) => {
      if (confirm(`Apply "${preset.name}" theme? This will overwrite current settings.`)) {
          updateSettings({
              colors: { ...settings!.colors, ...preset.colors },
              typography: { ...settings!.typography, fontFamily: preset.font },
              content: { ...settings!.content, ...preset.content }
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
        handleValueChange(result);
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

  // Helper to determine editor type based on selected ID
  const getEditorType = () => {
      if (!selectedElementId) return null;
      if (selectedElementId.includes('image') || selectedElementId.includes('banner')) return 'image';
      return 'text';
  };

  const editorType = getEditorType();
  const currentValue = selectedElementId ? (settings?.content?.[selectedElementId] || "") : "";

  return (
    <AdminLayout>
      <div className="flex flex-col h-[calc(100vh-60px)] -m-6">
        {/* Top Toolbar */}
        <div className="bg-card border-b p-4 flex items-center justify-between shadow-sm z-10">
          <div className="flex items-center gap-4">
            <h1 className="text-xl font-bold flex items-center gap-2">
                <Palette className="h-5 w-5 text-primary" />
                Visual Editor
            </h1>
            <div className="h-6 w-px bg-border mx-2" />
            <div className="flex items-center bg-muted rounded-lg p-1">
                <Button
                    variant={previewMode === 'desktop' ? 'default' : 'ghost'}
                    size="sm"
                    onClick={() => setPreviewMode('desktop')}
                    className="h-8 w-8 p-0"
                >
                    <Monitor className="h-4 w-4" />
                </Button>
                <Button
                    variant={previewMode === 'tablet' ? 'default' : 'ghost'}
                    size="sm"
                    onClick={() => setPreviewMode('tablet')}
                    className="h-8 w-8 p-0"
                >
                    <Tablet className="h-4 w-4" />
                </Button>
                <Button
                    variant={previewMode === 'mobile' ? 'default' : 'ghost'}
                    size="sm"
                    onClick={() => setPreviewMode('mobile')}
                    className="h-8 w-8 p-0"
                >
                    <Smartphone className="h-4 w-4" />
                </Button>
            </div>
          </div>

          <div className="flex gap-2">
            <Button
              onClick={() => setIsEditActive(!isEditActive)}
              variant={isEditActive ? "secondary" : "outline"}
              className="gap-2"
            >
              {isEditActive ? <MousePointer2 className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
              {isEditActive ? "Editing" : "Previewing"}
            </Button>
            <Button onClick={handleReset} variant="ghost" size="icon">
              <RotateCcw className="h-4 w-4" />
            </Button>
            <Button onClick={handleSave} className="gap-2 min-w-[100px]">
              <Save className="h-4 w-4" />
              Save
            </Button>
          </div>
        </div>

        <div className="flex flex-1 overflow-hidden">
          {/* Main Preview Area */}
          <div className="flex-1 bg-muted/10 overflow-auto relative flex justify-center p-8">
            <div 
              className={cn(
                "bg-background shadow-2xl transition-all duration-300 ease-in-out origin-top border rounded-sm min-h-full",
                previewMode === 'desktop' && "w-full max-w-[1600px]",
                previewMode === 'tablet' && "w-[768px]",
                previewMode === 'mobile' && "w-[375px]"
              )}
            >
                {/* 
                    Here we render the actual Index page.
                    Because we set `editMode` in context, the Editable components inside Index 
                    will become interactive.
                */}
                <div className={cn(isEditActive ? "pointer-events-auto" : "pointer-events-none")}>
                    <Index />
                </div>
            </div>
          </div>

          {/* Right Sidebar - Controls */}
          <div className="w-80 bg-card border-l flex flex-col shadow-xl z-20">
            
            {/* Contextual Editor (When something is selected) */}
            {selectedElementId ? (
                <div className="p-4 border-b bg-accent/5">
                    <div className="flex items-center justify-between mb-4">
                        <h3 className="font-semibold text-sm flex items-center gap-2">
                            <span className="w-2 h-2 rounded-full bg-primary animate-pulse" />
                            Editing: <span className="font-mono text-xs bg-muted px-1 rounded">{selectedElementId}</span>
                        </h3>
                        <Button variant="ghost" size="icon" className="h-6 w-6" onClick={() => setSelectedElementId(null)}>
                            <X className="h-3 w-3" />
                        </Button>
                    </div>

                    <div className="space-y-4 animate-in slide-in-from-right-5 fade-in duration-200">
                        {editorType === 'text' && (
                            <div className="space-y-2">
                                <Label>Text Content</Label>
                                <Input 
                                    value={settings?.content?.[selectedElementId] || ""} 
                                    placeholder="Start typing..."
                                    onChange={(e) => handleValueChange(e.target.value)}
                                    autoFocus
                                />
                            </div>
                        )}

                        {editorType === 'image' && (
                            <div className="space-y-2">
                                <Label>Image Source</Label>
                                <div className="flex gap-2">
                                    <Input 
                                        value={settings?.content?.[selectedElementId] || ""} 
                                        placeholder="https://..."
                                        onChange={(e) => handleValueChange(e.target.value)}
                                    />
                                    <Button size="icon" variant="outline" onClick={triggerFileUpload}>
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
                                {settings?.content?.[selectedElementId] && (
                                    <img 
                                        src={settings.content[selectedElementId]} 
                                        alt="Preview" 
                                        className="w-full h-32 object-cover rounded border mt-2"
                                    />
                                )}
                            </div>
                        )}
                    </div>
                </div>
            ) : (
                <div className="p-8 text-center text-muted-foreground flex flex-col items-center justify-center min-h-[200px]">
                    <MousePointer2 className="h-8 w-8 mb-2 opacity-20" />
                    <p>Click any element on the preview to edit it</p>
                </div>
            )}

            {/* General Settings */}
            <div className="flex-1 overflow-y-auto p-4 space-y-6">
                <div>
                    <h3 className="font-semibold mb-3 flex items-center gap-2 text-sm text-muted-foreground">
                        <Sparkles className="h-4 w-4" />
                        Theme Presets
                    </h3>
                    <div className="grid grid-cols-2 gap-2">
                        {THEME_PRESETS.map(preset => (
                            <button
                                key={preset.name}
                                onClick={() => applyPreset(preset)}
                                className="flex flex-col items-center p-2 rounded border hover:border-primary hover:bg-primary/5 transition-all text-xs text-center group"
                            >
                                <div className="w-full h-12 rounded mb-2 shadow-sm group-hover:shadow-md transition-shadow" 
                                     style={{ background: `linear-gradient(135deg, ${preset.colors.primary}, ${preset.colors.secondary})` }} />
                                {preset.name}
                            </button>
                        ))}
                    </div>
                </div>

                <div className="border-t pt-4">
                    <h3 className="font-semibold mb-3 text-sm text-muted-foreground">Global Colors</h3>
                    <div className="space-y-3">
                        <div className="space-y-1">
                            <Label className="text-xs">Primary Color</Label>
                            <div className="flex gap-2">
                                <div className="relative w-8 h-8 rounded-full overflow-hidden border shadow-sm shrink-0">
                                    <input
                                        type="color"
                                        value={settings?.colors?.primary}
                                        onChange={(e) => updateSettings({ colors: { ...settings!.colors, primary: e.target.value } })}
                                        className="absolute inset-0 w-[150%] h-[150%] -translate-x-1/4 -translate-y-1/4 cursor-pointer p-0 border-0"
                                    />
                                </div>
                                <Input 
                                    value={settings?.colors?.primary}
                                    onChange={(e) => updateSettings({ colors: { ...settings!.colors, primary: e.target.value } })}
                                    className="h-8 text-xs font-mono"
                                />
                            </div>
                        </div>
                        <div className="space-y-1">
                            <Label className="text-xs">Background Color</Label>
                            <div className="flex gap-2">
                                <div className="relative w-8 h-8 rounded-full overflow-hidden border shadow-sm shrink-0">
                                    <input
                                        type="color"
                                        value={settings?.colors?.background}
                                        onChange={(e) => updateSettings({ colors: { ...settings!.colors, background: e.target.value } })}
                                        className="absolute inset-0 w-[150%] h-[150%] -translate-x-1/4 -translate-y-1/4 cursor-pointer p-0 border-0"
                                    />
                                </div>
                                <Input 
                                    value={settings?.colors?.background}
                                    onChange={(e) => updateSettings({ colors: { ...settings!.colors, background: e.target.value } })}
                                    className="h-8 text-xs font-mono"
                                />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
