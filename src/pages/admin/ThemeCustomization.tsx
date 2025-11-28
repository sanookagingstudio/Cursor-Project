import { AdminLayout } from "@/layouts/AdminLayout";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { 
  Palette,
  Type,
  Layout,
  Sparkles,
  Save,
  RotateCcw,
  Download,
  Upload,
  Eye,
  Loader2
} from "lucide-react";
import { useState } from "react";
import { useTheme } from "@/contexts/ThemeContext";
import { useToast } from "@/components/ui/use-toast";

export default function ThemeCustomization() {
  const { toast } = useToast();
  const { settings, updateSettings, saveTheme, resetTheme, applyTheme, loading } = useTheme();
  const [activeTab, setActiveTab] = useState("colors");
  const [themeName, setThemeName] = useState("");
  const [saving, setSaving] = useState(false);

  const handleColorChange = (key: string, value: string) => {
    updateSettings({
      colors: {
        ...settings!.colors,
        [key]: value,
      },
    });
  };

  const handleTypographyChange = (key: string, value: string) => {
    updateSettings({
      typography: {
        ...settings!.typography,
        [key]: value,
      },
    });
  };

  const handleSave = async () => {
    if (!themeName.trim()) {
      toast({
        title: "Error",
        description: "Please enter a theme name",
        variant: "destructive",
      });
      return;
    }

    setSaving(true);
    try {
      await saveTheme(themeName);
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
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center min-h-screen">
          <Loader2 className="h-8 w-8 animate-spin" />
        </div>
      </AdminLayout>
    );
  }

  return (
    <AdminLayout>
      <div className="space-y-8 w-full">
        <div>
          <h1 className="text-5xl font-bold mb-4 flex items-center gap-3">
            <Palette className="h-10 w-10 text-primary" />
            Theme Customization (เทพช้อป)
          </h1>
          <p className="text-lg text-muted-foreground">
            Customize the appearance of your website. Adjust colors, typography, spacing, and layout.
          </p>
        </div>

        <div className="grid gap-4 md:grid-cols-3">
          <Card>
            <CardHeader>
              <CardTitle className="text-lg font-semibold">Save Theme</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label className="text-base font-semibold">Theme Name</Label>
                <Input
                  value={themeName}
                  onChange={(e) => setThemeName(e.target.value)}
                  placeholder="Enter theme name"
                  className="text-base h-12"
                />
              </div>
              <Button
                onClick={handleSave}
                disabled={saving || !themeName.trim()}
                size="lg"
                className="text-base w-full"
              >
                {saving ? (
                  <>
                    <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                    Saving...
                  </>
                ) : (
                  <>
                    <Save className="mr-2 h-5 w-5" />
                    Save Theme
                  </>
                )}
              </Button>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="text-lg font-semibold">Actions</CardTitle>
            </CardHeader>
            <CardContent className="space-y-2">
              <Button
                onClick={resetTheme}
                variant="outline"
                size="lg"
                className="text-base w-full"
              >
                <RotateCcw className="mr-2 h-5 w-5" />
                Reset to Default
              </Button>
              <Button
                variant="outline"
                size="lg"
                className="text-base w-full"
              >
                <Download className="mr-2 h-5 w-5" />
                Export Theme
              </Button>
              <Button
                variant="outline"
                size="lg"
                className="text-base w-full"
              >
                <Upload className="mr-2 h-5 w-5" />
                Import Theme
              </Button>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="text-lg font-semibold">Preview</CardTitle>
            </CardHeader>
            <CardContent>
              <Button
                variant="outline"
                size="lg"
                className="text-base w-full"
              >
                <Eye className="mr-2 h-5 w-5" />
                Live Preview
              </Button>
            </CardContent>
          </Card>
        </div>

        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-5 text-base">
            <TabsTrigger value="colors" className="text-base">
              <Palette className="mr-2 h-4 w-4" />
              Colors
            </TabsTrigger>
            <TabsTrigger value="typography" className="text-base">
              <Type className="mr-2 h-4 w-4" />
              Typography
            </TabsTrigger>
            <TabsTrigger value="spacing" className="text-base">
              <Layout className="mr-2 h-4 w-4" />
              Spacing
            </TabsTrigger>
            <TabsTrigger value="layout" className="text-base">
              <Layout className="mr-2 h-4 w-4" />
              Layout
            </TabsTrigger>
            <TabsTrigger value="components" className="text-base">
              <Sparkles className="mr-2 h-4 w-4" />
              Components
            </TabsTrigger>
          </TabsList>

          {/* Colors Tab */}
          <TabsContent value="colors" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Colors</CardTitle>
                <CardDescription className="text-lg">Customize color scheme</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                {Object.entries(settings?.colors || {}).map(([key, value]) => (
                  <div key={key} className="space-y-2">
                    <Label className="text-base font-semibold capitalize">{key}</Label>
                    <div className="flex gap-2">
                      <Input
                        type="color"
                        value={value}
                        onChange={(e) => handleColorChange(key, e.target.value)}
                        className="w-20 h-12"
                      />
                      <Input
                        type="text"
                        value={value}
                        onChange={(e) => handleColorChange(key, e.target.value)}
                        className="text-base h-12 flex-1"
                      />
                    </div>
                  </div>
                ))}
              </CardContent>
            </Card>
          </TabsContent>

          {/* Typography Tab */}
          <TabsContent value="typography" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Typography</CardTitle>
                <CardDescription className="text-lg">Customize fonts and text styles</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label className="text-base font-semibold">Font Family</Label>
                  <Select
                    value={settings?.typography.fontFamily}
                    onValueChange={(v) => handleTypographyChange("fontFamily", v)}
                  >
                    <SelectTrigger className="text-base h-12">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Noto Serif Thai" className="text-base">Noto Serif Thai</SelectItem>
                      <SelectItem value="Roboto" className="text-base">Roboto</SelectItem>
                      <SelectItem value="Inter" className="text-base">Inter</SelectItem>
                      <SelectItem value="Arial" className="text-base">Arial</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label className="text-base font-semibold">Base Font Size</Label>
                  <Input
                    type="text"
                    value={settings?.typography.baseFontSize}
                    onChange={(e) => handleTypographyChange("baseFontSize", e.target.value)}
                    className="text-base h-12"
                  />
                </div>
                <div className="space-y-2">
                  <Label className="text-base font-semibold">Line Height</Label>
                  <Input
                    type="text"
                    value={settings?.typography.lineHeight}
                    onChange={(e) => handleTypographyChange("lineHeight", e.target.value)}
                    className="text-base h-12"
                  />
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Spacing Tab */}
          <TabsContent value="spacing" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Spacing</CardTitle>
                <CardDescription className="text-lg">Adjust spacing and padding</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                {Object.entries(settings?.spacing || {}).map(([key, value]) => (
                  <div key={key} className="space-y-2">
                    <Label className="text-base font-semibold capitalize">{key}</Label>
                    <Input
                      type="text"
                      value={value}
                      onChange={(e) =>
                        updateSettings({
                          spacing: {
                            ...settings!.spacing,
                            [key]: e.target.value,
                          },
                        })
                      }
                      className="text-base h-12"
                    />
                  </div>
                ))}
              </CardContent>
            </Card>
          </TabsContent>

          {/* Layout Tab */}
          <TabsContent value="layout" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Layout</CardTitle>
                <CardDescription className="text-lg">Configure layout dimensions</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                {Object.entries(settings?.layout || {}).map(([key, value]) => (
                  <div key={key} className="space-y-2">
                    <Label className="text-base font-semibold capitalize">{key}</Label>
                    <Input
                      type="text"
                      value={value}
                      onChange={(e) =>
                        updateSettings({
                          layout: {
                            ...settings!.layout,
                            [key]: e.target.value,
                          },
                        })
                      }
                      className="text-base h-12"
                    />
                  </div>
                ))}
              </CardContent>
            </Card>
          </TabsContent>

          {/* Components Tab */}
          <TabsContent value="components" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Components</CardTitle>
                <CardDescription className="text-lg">Customize component styles</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                {Object.entries(settings?.components || {}).map(([component, styles]) => (
                  <div key={component} className="space-y-2 border p-4 rounded-lg">
                    <Label className="text-base font-semibold capitalize">{component}</Label>
                    {Object.entries(styles).map(([key, value]) => (
                      <div key={key} className="space-y-1">
                        <Label className="text-sm capitalize">{key}</Label>
                        <Input
                          type="text"
                          value={value}
                          onChange={(e) =>
                            updateSettings({
                              components: {
                                ...settings!.components,
                                [component]: {
                                  ...styles,
                                  [key]: e.target.value,
                                },
                              },
                            })
                          }
                          className="text-base h-10"
                        />
                      </div>
                    ))}
                  </div>
                ))}
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </AdminLayout>
  );
}

