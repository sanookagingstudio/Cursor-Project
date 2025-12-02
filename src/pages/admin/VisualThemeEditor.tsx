import { AdminLayout } from "@/layouts/AdminLayout";
import { useState, useRef, useEffect } from "react";
import { useTheme } from "@/contexts/ThemeContext";
import { useToast } from "@/components/ui/use-toast";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Slider } from "@/components/ui/slider";
import { Switch } from "@/components/ui/switch";
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
  Eye,
  Layout,
  Move,
  Bold,
  Italic,
  Underline,
  AlignLeft,
  AlignCenter,
  AlignRight,
  Video
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useTranslation } from "react-i18next";

// Import Pages for preview
import Index from "@/pages/Index";
import About from "@/pages/About";
import Activities from "@/pages/Activities";
import Trips from "@/pages/Trips";
import Contact from "@/pages/Contact";
import MediaLibrary from "@/pages/MediaLibrary";
import FUNStore from "@/pages/FUNStore";
import Promotions from "@/pages/Promotions";
import MembershipPlans from "@/pages/MembershipPlans";
import CustomTripBuilder from "@/pages/CustomTripBuilder";
import FUNCalendar from "@/pages/FUNCalendar";

const PAGES = [
    { id: 'home', name: 'Home Page', component: Index },
    { id: 'about', name: 'About Us', component: About },
    { id: 'activities', name: 'Activities', component: Activities },
    { id: 'trips', name: 'Trips', component: Trips },
    { id: 'contact', name: 'Contact', component: Contact },
    { id: 'media', name: 'Media Library', component: MediaLibrary },
    { id: 'store', name: 'FUN Store', component: FUNStore },
    { id: 'promotions', name: 'Promotions', component: Promotions },
    { id: 'membership', name: 'Membership', component: MembershipPlans },
    { id: 'custom-trip', name: 'Custom Trip', component: CustomTripBuilder },
    { id: 'calendar', name: 'Calendar', component: FUNCalendar },
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
  const [selectedPageId, setSelectedPageId] = useState('home');
  const [isVideoMode, setIsVideoMode] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    setEditMode(isEditActive);
    return () => setEditMode(false);
  }, [isEditActive, setEditMode]);

  const handleContentChange = (newValue: any) => {
    if (!selectedElementId) return;
    updateSettings({
        content: {
            ...settings!.content,
            [selectedElementId]: newValue
        }
    });
  };

  const handleStyleChange = (property: keyof React.CSSProperties, value: any) => {
    if (!selectedElementId) return;
    const currentStyles = settings?.styles?.[selectedElementId] || {};
    updateSettings({
        styles: {
            ...settings!.styles,
            [selectedElementId]: {
                ...currentStyles,
                [property]: value
            }
        }
    });
  };

  const applyPreset = (preset: typeof THEME_PRESETS[0]) => {
      if (confirm(`Apply "${preset.name}" theme?`)) {
          updateSettings({
              colors: { ...settings!.colors, ...preset.colors },
              typography: { ...settings!.typography, fontFamily: preset.font },
              content: { ...settings!.content, ...preset.content }
          });
      }
  };

  const handleFileUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (e) => {
        handleContentChange(e.target?.result as string);
    };
    reader.readAsDataURL(file);
  };

  const getEditorType = () => {
      if (!selectedElementId) return null;
      if (selectedElementId.includes('image') || selectedElementId.includes('banner') || selectedElementId.includes('logo')) return 'image';
      return 'text';
  };

  const editorType = getEditorType();
  const currentStyles = selectedElementId ? settings?.styles?.[selectedElementId] || {} : {};
  const SelectedPageComponent = PAGES.find(p => p.id === selectedPageId)?.component || Index;

  return (
    <AdminLayout>
      {/* Admin Theme Reset Wrapper */}
      <div 
        className="flex flex-col h-[calc(100vh-60px)] -m-6 admin-theme-reset" 
        style={{ 
            '--background': '0 0% 100%',
            '--foreground': '240 10% 3.9%',
            '--card': '0 0% 100%',
            '--card-foreground': '240 10% 3.9%',
            '--popover': '0 0% 100%',
            '--popover-foreground': '240 10% 3.9%',
            '--primary': '240 5.9% 10%',
            '--primary-foreground': '0 0% 98%',
            '--secondary': '240 4.8% 95.9%',
            '--secondary-foreground': '240 5.9% 10%',
            '--muted': '240 4.8% 95.9%',
            '--muted-foreground': '240 3.8% 46.1%',
            '--accent': '240 4.8% 95.9%',
            '--accent-foreground': '240 5.9% 10%',
            '--destructive': '0 84.2% 60.2%',
            '--destructive-foreground': '0 0% 98%',
            '--border': '240 5.9% 90%',
            '--input': '240 5.9% 90%',
            '--ring': '240 10% 3.9%',
            '--radius': '0.5rem'
        } as React.CSSProperties}
      >
        {/* Top Toolbar */}
        <div className="bg-card border-b p-4 flex items-center justify-between shadow-sm z-10">
          <div className="flex items-center gap-4">
            <h1 className="text-xl font-bold flex items-center gap-2">
                <Palette className="h-5 w-5 text-primary" />
                Visual Editor
            </h1>
            <div className="h-6 w-px bg-border mx-2" />
            
            {/* Page Selector */}
            <Select value={selectedPageId} onValueChange={setSelectedPageId}>
                <SelectTrigger className="w-[200px] h-8">
                    <SelectValue placeholder="Select Page" />
                </SelectTrigger>
                <SelectContent>
                    {PAGES.map(page => (
                        <SelectItem key={page.id} value={page.id}>{page.name}</SelectItem>
                    ))}
                </SelectContent>
            </Select>

            <div className="h-6 w-px bg-border mx-2" />

            {/* Device Toggles */}
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
            <Button onClick={() => { if(confirm('Reset all?')) resetTheme() }} variant="ghost" size="icon">
              <RotateCcw className="h-4 w-4" />
            </Button>
            <Button onClick={saveTheme} className="gap-2 min-w-[100px]">
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
                <div className={cn(isEditActive ? "pointer-events-auto" : "pointer-events-none")}>
                    <SelectedPageComponent />
                </div>
            </div>
          </div>

          {/* Right Sidebar - Controls */}
          <div className="w-80 bg-card border-l flex flex-col shadow-xl z-20">
            {selectedElementId ? (
                <div className="flex flex-col h-full">
                    <div className="p-4 border-b bg-accent/5 flex items-center justify-between">
                        <h3 className="font-semibold text-sm flex items-center gap-2">
                            Editing: <span className="font-mono text-xs bg-muted px-1 rounded truncate max-w-[120px]">{selectedElementId}</span>
                        </h3>
                        <Button variant="ghost" size="icon" className="h-6 w-6" onClick={() => setSelectedElementId(null)}>
                            <X className="h-3 w-3" />
                        </Button>
                    </div>

                    <Tabs defaultValue="content" className="flex-1 flex flex-col">
                        <TabsList className="w-full justify-start rounded-none border-b px-4 h-12">
                            <TabsTrigger value="content" className="data-[state=active]:bg-transparent data-[state=active]:border-b-2 data-[state=active]:border-primary rounded-none">Content</TabsTrigger>
                            <TabsTrigger value="style" className="data-[state=active]:bg-transparent data-[state=active]:border-b-2 data-[state=active]:border-primary rounded-none">Style</TabsTrigger>
                        </TabsList>

                        <TabsContent value="content" className="flex-1 p-4 overflow-y-auto space-y-4">
                            {editorType === 'text' && (
                                <div className="space-y-2">
                                    <Label>Text</Label>
                                    <Input 
                                        value={settings?.content?.[selectedElementId] || ""} 
                                        placeholder="Type here..."
                                        onChange={(e) => handleContentChange(e.target.value)}
                                    />
                                </div>
                            )}
                            {editorType === 'image' && (
                                <div className="space-y-4">
                                    <div className="flex items-center justify-between">
                                        <Label>Media Type</Label>
                                        <div className="flex items-center gap-2">
                                            <span className={cn("text-xs", !isVideoMode && "font-bold")}>Image</span>
                                            <Switch 
                                                checked={isVideoMode}
                                                onCheckedChange={setIsVideoMode}
                                            />
                                            <span className={cn("text-xs", isVideoMode && "font-bold")}>Video</span>
                                        </div>
                                    </div>

                                    <div className="space-y-2">
                                        <Label>{isVideoMode ? "Video Source" : "Image Source"}</Label>
                                        <div className="flex gap-2">
                                            <Input 
                                                value={settings?.content?.[selectedElementId] || ""} 
                                                placeholder={isVideoMode ? "https://.../video.mp4" : "https://.../image.jpg"}
                                                onChange={(e) => handleContentChange(e.target.value)}
                                            />
                                            <Button size="icon" variant="outline" onClick={() => fileInputRef.current?.click()}>
                                                <Upload className="h-4 w-4" />
                                            </Button>
                                            <input 
                                                type="file" 
                                                ref={fileInputRef} 
                                                className="hidden" 
                                                accept={isVideoMode ? "video/*" : "image/*"} 
                                                onChange={handleFileUpload} 
                                            />
                                        </div>
                                    </div>

                                    {settings?.content?.[selectedElementId] && (
                                        <div className="rounded border overflow-hidden bg-black/5">
                                            {isVideoMode || settings.content[selectedElementId].endsWith('.mp4') ? (
                                                <video 
                                                    src={settings.content[selectedElementId]} 
                                                    className="w-full h-32 object-cover" 
                                                    controls 
                                                />
                                            ) : (
                                                <img 
                                                    src={settings.content[selectedElementId]} 
                                                    alt="Preview" 
                                                    className="w-full h-32 object-cover" 
                                                />
                                            )}
                                        </div>
                                    )}
                                    
                                    <div className="text-xs text-muted-foreground">
                                        {isVideoMode 
                                            ? "Supported formats: MP4, WebM. Enter a URL or upload." 
                                            : "Supported formats: JPG, PNG, WEBP. Enter a URL or upload."}
                                    </div>
                                </div>
                            )}
                        </TabsContent>

                        <TabsContent value="style" className="flex-1 p-4 overflow-y-auto space-y-6">
                            {/* Typography Controls */}
                            {editorType === 'text' && (
                                <div className="space-y-4">
                                    <h4 className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Typography</h4>
                                    <div className="grid grid-cols-2 gap-2">
                                        <div className="space-y-1">
                                            <Label className="text-xs">Font Size</Label>
                                            <div className="flex items-center gap-2">
                                                <Input 
                                                    type="number" 
                                                    value={parseInt(String(currentStyles.fontSize || '16'))} 
                                                    onChange={(e) => handleStyleChange('fontSize', `${e.target.value}px`)}
                                                    className="h-8"
                                                />
                                                <span className="text-xs text-muted-foreground">px</span>
                                            </div>
                                        </div>
                                        <div className="space-y-1">
                                            <Label className="text-xs">Color</Label>
                                            <div className="flex gap-2">
                                                <input 
                                                    type="color" 
                                                    value={String(currentStyles.color || '#000000')}
                                                    onChange={(e) => handleStyleChange('color', e.target.value)}
                                                    className="w-8 h-8 rounded border cursor-pointer"
                                                />
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div className="space-y-1">
                                        <Label className="text-xs">Font Weight</Label>
                                        <Select 
                                            value={String(currentStyles.fontWeight || 'normal')}
                                            onValueChange={(v) => handleStyleChange('fontWeight', v)}
                                        >
                                            <SelectTrigger className="h-8"><SelectValue /></SelectTrigger>
                                            <SelectContent>
                                                <SelectItem value="300">Light</SelectItem>
                                                <SelectItem value="normal">Regular</SelectItem>
                                                <SelectItem value="500">Medium</SelectItem>
                                                <SelectItem value="bold">Bold</SelectItem>
                                                <SelectItem value="900">Black</SelectItem>
                                            </SelectContent>
                                        </Select>
                                    </div>

                                    <div className="flex gap-1 bg-muted p-1 rounded">
                                        <Button variant={currentStyles.textAlign === 'left' ? 'default' : 'ghost'} size="icon" className="h-7 w-7" onClick={() => handleStyleChange('textAlign', 'left')}><AlignLeft className="h-3 w-3" /></Button>
                                        <Button variant={currentStyles.textAlign === 'center' ? 'default' : 'ghost'} size="icon" className="h-7 w-7" onClick={() => handleStyleChange('textAlign', 'center')}><AlignCenter className="h-3 w-3" /></Button>
                                        <Button variant={currentStyles.textAlign === 'right' ? 'default' : 'ghost'} size="icon" className="h-7 w-7" onClick={() => handleStyleChange('textAlign', 'right')}><AlignRight className="h-3 w-3" /></Button>
                                    </div>
                                </div>
                            )}

                            {/* Dimensions & Spacing */}
                            <div className="space-y-4 pt-4 border-t">
                                <h4 className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Layout</h4>
                                <div className="space-y-2">
                                    <Label className="text-xs">Margin (Top/Bottom)</Label>
                                    <Slider 
                                        defaultValue={[parseInt(String(currentStyles.marginTop || '0'))]} 
                                        max={100} 
                                        step={1} 
                                        onValueChange={(v) => {
                                            handleStyleChange('marginTop', `${v[0]}px`);
                                            handleStyleChange('marginBottom', `${v[0]}px`);
                                        }}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label className="text-xs">Padding</Label>
                                    <Slider 
                                        defaultValue={[parseInt(String(currentStyles.padding || '0'))]} 
                                        max={50} 
                                        step={1} 
                                        onValueChange={(v) => handleStyleChange('padding', `${v[0]}px`)}
                                    />
                                </div>
                            </div>

                            {/* Effects */}
                            <div className="space-y-4 pt-4 border-t">
                                <h4 className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Effects</h4>
                                <div className="space-y-2">
                                    <Label className="text-xs">Opacity</Label>
                                    <Slider 
                                        defaultValue={[parseFloat(String(currentStyles.opacity || '1')) * 100]} 
                                        max={100} 
                                        step={1} 
                                        onValueChange={(v) => handleStyleChange('opacity', v[0] / 100)}
                                    />
                                </div>
                                {editorType === 'image' && (
                                    <div className="space-y-2">
                                        <Label className="text-xs">Rounded Corners</Label>
                                        <Slider 
                                            defaultValue={[parseInt(String(currentStyles.borderRadius || '0'))]} 
                                            max={50} 
                                            step={1} 
                                            onValueChange={(v) => handleStyleChange('borderRadius', `${v[0]}px`)}
                                        />
                                    </div>
                                )}
                            </div>
                        </TabsContent>
                    </Tabs>
                </div>
            ) : (
                <div className="flex-1 p-4 overflow-y-auto space-y-6">
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
                                    <input
                                        type="color"
                                        value={settings?.colors?.primary}
                                        onChange={(e) => updateSettings({ colors: { ...settings!.colors, primary: e.target.value } })}
                                        className="w-8 h-8 rounded border cursor-pointer"
                                    />
                                    <Input 
                                        value={settings?.colors?.primary}
                                        onChange={(e) => updateSettings({ colors: { ...settings!.colors, primary: e.target.value } })}
                                        className="h-8 text-xs font-mono"
                                    />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            )}
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
