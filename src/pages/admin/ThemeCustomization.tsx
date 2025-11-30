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
  Loader2,
  Video,
  Image as ImageIcon,
  MousePointer2,
  ExternalLink
} from "lucide-react";
import { useState } from "react";
import { useTheme } from "@/contexts/ThemeContext";
import { useToast } from "@/components/ui/use-toast";
import { useNavigate } from "react-router-dom";

export default function ThemeCustomization() {
  const { toast } = useToast();
  const navigate = useNavigate();
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
        <div className="flex items-start justify-between">
          <div>
            <h1 className="text-5xl font-bold mb-4 flex items-center gap-3">
              <Palette className="h-10 w-10 text-primary" />
              Theme Customization (เทพช้อป)
            </h1>
            <p className="text-lg text-muted-foreground">
              Customize the appearance of your website. Adjust colors, typography, spacing, and layout.
            </p>
          </div>
          <Button
            onClick={() => navigate("/admin/visual-theme-editor")}
            size="lg"
            className="gap-2"
          >
            <MousePointer2 className="h-5 w-5" />
            Visual Editor
            <ExternalLink className="h-4 w-4" />
          </Button>
        </div>

        <Card className="border-primary/20 bg-primary/5">
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <Sparkles className="h-5 w-5 text-primary" />
              <div>
                <div className="font-semibold">Try Visual Theme Editor</div>
                <div className="text-sm text-muted-foreground">
                  Click elements to edit • Real-time preview • Drag to reposition
                </div>
              </div>
              <Button
                onClick={() => navigate("/admin/visual-theme-editor")}
                variant="outline"
                size="sm"
                className="ml-auto gap-2"
              >
                Open Visual Editor
                <ExternalLink className="h-4 w-4" />
              </Button>
            </div>
          </CardContent>
        </Card>

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
          <TabsList className="grid w-full grid-cols-6 text-base">
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
            <TabsTrigger value="banner" className="text-base">
              <Video className="mr-2 h-4 w-4" />
              Banner
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

          {/* Banner Tab */}
          <TabsContent value="banner" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Banner Settings</CardTitle>
                <CardDescription className="text-lg">Configure Hero Section banner (Image or Video)</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <div className="flex items-center gap-2">
                    <input
                      type="checkbox"
                      id="banner-enabled"
                      checked={settings?.banner.enabled || false}
                      onChange={(e) =>
                        updateSettings({
                          banner: {
                            ...settings!.banner,
                            enabled: e.target.checked,
                          },
                        })
                      }
                      className="w-5 h-5"
                    />
                    <Label htmlFor="banner-enabled" className="text-base font-semibold cursor-pointer">
                      Enable Banner
                    </Label>
                  </div>
                </div>

                {settings?.banner.enabled && (
                  <>
                    <div className="space-y-2">
                      <Label className="text-base font-semibold">Banner Type</Label>
                      <Select
                        value={settings.banner.type}
                        onValueChange={(v) =>
                          updateSettings({
                            banner: {
                              ...settings.banner,
                              type: v,
                            },
                          })
                        }
                      >
                        <SelectTrigger className="text-base h-12">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="image" className="text-base">
                            <div className="flex items-center gap-2">
                              <ImageIcon className="h-4 w-4" />
                              Image
                            </div>
                          </SelectItem>
                          <SelectItem value="video" className="text-base">
                            <div className="flex items-center gap-2">
                              <Video className="h-4 w-4" />
                              Video
                            </div>
                          </SelectItem>
                        </SelectContent>
                      </Select>
                    </div>

                    {settings.banner.type === "image" && (
                      <div className="space-y-2">
                        <Label className="text-base font-semibold">Image URL</Label>
                        <Input
                          type="url"
                          value={settings.banner.imageUrl || ""}
                          onChange={(e) =>
                            updateSettings({
                              banner: {
                                ...settings.banner,
                                imageUrl: e.target.value,
                              },
                            })
                          }
                          placeholder="https://example.com/image.jpg"
                          className="text-base h-12"
                        />
                      </div>
                    )}

                    {settings.banner.type === "video" && (
                      <>
                        <div className="space-y-2">
                          <Label className="text-base font-semibold">Video URL</Label>
                          <Input
                            type="url"
                            value={settings.banner.videoUrl || ""}
                            onChange={(e) =>
                              updateSettings({
                                banner: {
                                  ...settings.banner,
                                  videoUrl: e.target.value,
                                },
                              })
                            }
                            placeholder="https://example.com/video.mp4"
                            className="text-base h-12"
                          />
                          <p className="text-sm text-muted-foreground">
                            รองรับ MP4, WebM, OGG
                          </p>
                        </div>

                        <div className="space-y-4 border p-4 rounded-lg">
                          <Label className="text-base font-semibold">Video Settings</Label>
                          
                          <div className="flex items-center gap-2">
                            <input
                              type="checkbox"
                              id="video-autoplay"
                              checked={settings.banner.videoAutoplay}
                              onChange={(e) =>
                                updateSettings({
                                  banner: {
                                    ...settings.banner,
                                    videoAutoplay: e.target.checked,
                                  },
                                })
                              }
                              className="w-5 h-5"
                            />
                            <Label htmlFor="video-autoplay" className="text-base cursor-pointer">
                              Autoplay (เล่นอัตโนมัติ)
                            </Label>
                          </div>

                          <div className="flex items-center gap-2">
                            <input
                              type="checkbox"
                              id="video-loop"
                              checked={settings.banner.videoLoop}
                              onChange={(e) =>
                                updateSettings({
                                  banner: {
                                    ...settings.banner,
                                    videoLoop: e.target.checked,
                                  },
                                })
                              }
                              className="w-5 h-5"
                            />
                            <Label htmlFor="video-loop" className="text-base cursor-pointer">
                              Loop (วนซ้ำ)
                            </Label>
                          </div>

                          <div className="flex items-center gap-2">
                            <input
                              type="checkbox"
                              id="video-muted"
                              checked={settings.banner.videoMuted}
                              onChange={(e) =>
                                updateSettings({
                                  banner: {
                                    ...settings.banner,
                                    videoMuted: e.target.checked,
                                  },
                                })
                              }
                              className="w-5 h-5"
                            />
                            <Label htmlFor="video-muted" className="text-base cursor-pointer">
                              Muted (ปิดเสียง)
                            </Label>
                          </div>
                        </div>
                      </>
                    )}

                    <div className="space-y-2">
                      <Label className="text-base font-semibold">Overlay Color</Label>
                      <div className="flex gap-2">
                        <Input
                          type="color"
                          value={settings.banner.overlayColor}
                          onChange={(e) =>
                            updateSettings({
                              banner: {
                                ...settings.banner,
                                overlayColor: e.target.value,
                              },
                            })
                          }
                          className="w-20 h-12"
                        />
                        <Input
                          type="text"
                          value={settings.banner.overlayColor}
                          onChange={(e) =>
                            updateSettings({
                              banner: {
                                ...settings.banner,
                                overlayColor: e.target.value,
                              },
                            })
                          }
                          className="text-base h-12 flex-1"
                        />
                      </div>
                    </div>

                    <div className="space-y-2">
                      <Label className="text-base font-semibold">
                        Overlay Opacity: {Math.round((settings.banner.overlayOpacity || 0) * 100)}%
                      </Label>
                      <input
                        type="range"
                        min="0"
                        max="1"
                        step="0.1"
                        value={settings.banner.overlayOpacity || 0}
                        onChange={(e) =>
                          updateSettings({
                            banner: {
                              ...settings.banner,
                              overlayOpacity: parseFloat(e.target.value),
                            },
                          })
                        }
                        className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer"
                      />
                    </div>

                    <div className="space-y-2">
                      <Label className="text-base font-semibold">Banner Height</Label>
                      <Select
                        value={settings.banner.height}
                        onValueChange={(v) =>
                          updateSettings({
                            banner: {
                              ...settings.banner,
                              height: v,
                            },
                          })
                        }
                      >
                        <SelectTrigger className="text-base h-12">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="auto" className="text-base">Auto</SelectItem>
                          <SelectItem value="400px" className="text-base">400px</SelectItem>
                          <SelectItem value="600px" className="text-base">600px</SelectItem>
                          <SelectItem value="800px" className="text-base">800px</SelectItem>
                          <SelectItem value="100vh" className="text-base">Full Screen (100vh)</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label className="text-base font-semibold">Content Position</Label>
                      <Select
                        value={settings.banner.position}
                        onValueChange={(v) =>
                          updateSettings({
                            banner: {
                              ...settings.banner,
                              position: v,
                            },
                          })
                        }
                      >
                        <SelectTrigger className="text-base h-12">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="top" className="text-base">Top</SelectItem>
                          <SelectItem value="center" className="text-base">Center</SelectItem>
                          <SelectItem value="bottom" className="text-base">Bottom</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </>
                )}
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </AdminLayout>
  );
}

