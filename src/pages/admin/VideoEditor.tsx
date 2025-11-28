import { AdminLayout } from "@/layouts/AdminLayout";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { 
  Video, 
  Wand2, 
  Upload, 
  Download,
  Film,
  Subtitles,
  AspectRatio,
  Loader2,
  Sparkles,
  Play,
  Pause
} from "lucide-react";
import { useState } from "react";
import { useToast } from "@/components/ui/use-toast";
import { getApiUrl } from "@/lib/api";

export default function VideoEditor() {
  const { toast } = useToast();
  const [activeTab, setActiveTab] = useState("generate");
  const [prompt, setPrompt] = useState("");
  const [duration, setDuration] = useState(15);
  const [aspectRatio, setAspectRatio] = useState("16:9");
  const [style, setStyle] = useState("cinematic");
  const [isGenerating, setIsGenerating] = useState(false);

  const handleGenerate = async () => {
    if (!prompt.trim()) {
      toast({
        title: "Error",
        description: "Please enter a prompt",
        variant: "destructive"
      });
      return;
    }

    setIsGenerating(true);
    try {
      const response = await fetch(getApiUrl("/video/generate"), {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          prompt,
          duration_seconds: duration,
          aspect_ratio: aspectRatio,
          style,
          provider: "mock"
        })
      });

      if (!response.ok) throw new Error("Failed to generate video");

      const data = await response.json();
      
      toast({
        title: "Success",
        description: "Video generation started. Check job status."
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to generate video",
        variant: "destructive"
      });
    } finally {
      setIsGenerating(false);
    }
  };

  const handleMultiExport = async () => {
    toast({
      title: "Info",
      description: "Multi-export feature - upload a video first"
    });
  };

  const handleGenerateSubtitle = async () => {
    toast({
      title: "Info",
      description: "Subtitle generation - upload a video first"
    });
  };

  return (
    <AdminLayout>
      <div className="space-y-8 w-full">
        <div>
          <h1 className="text-5xl font-bold mb-4 flex items-center gap-3">
            <Video className="h-10 w-10 text-primary" />
            Video Editor
          </h1>
          <p className="text-lg text-muted-foreground">
            AI-powered video generation and editing. Create, edit, and customize videos with AI.
          </p>
        </div>

        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-6 text-base">
            <TabsTrigger value="generate" className="text-base">Generate</TabsTrigger>
            <TabsTrigger value="edit" className="text-base">Edit</TabsTrigger>
            <TabsTrigger value="multi-export" className="text-base">Multi Export</TabsTrigger>
            <TabsTrigger value="subtitle" className="text-base">Subtitle</TabsTrigger>
            <TabsTrigger value="shorts" className="text-base">Shorts</TabsTrigger>
            <TabsTrigger value="special" className="text-base">Special</TabsTrigger>
          </TabsList>

          {/* Generate Tab */}
          <TabsContent value="generate" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Generate Video</CardTitle>
                <CardDescription className="text-lg">
                  Create videos from text prompts using AI
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Prompt</Label>
                  <Textarea
                    placeholder="Describe the video you want to create... (e.g., 'A cat playing with yarn in slow motion')"
                    value={prompt}
                    onChange={(e) => setPrompt(e.target.value)}
                    className="text-base min-h-[120px]"
                  />
                </div>

                <div className="grid gap-4 md:grid-cols-3">
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Duration (seconds)</Label>
                    <Input
                      type="number"
                      value={duration}
                      onChange={(e) => setDuration(parseInt(e.target.value) || 15)}
                      min={5}
                      max={300}
                      className="text-base h-12"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Aspect Ratio</Label>
                    <Select value={aspectRatio} onValueChange={setAspectRatio}>
                      <SelectTrigger className="text-base h-12">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="16:9" className="text-base">16:9 (YouTube)</SelectItem>
                        <SelectItem value="9:16" className="text-base">9:16 (TikTok/Reels)</SelectItem>
                        <SelectItem value="4:5" className="text-base">4:5 (Facebook)</SelectItem>
                        <SelectItem value="1:1" className="text-base">1:1 (Square)</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Style</Label>
                    <Select value={style} onValueChange={setStyle}>
                      <SelectTrigger className="text-base h-12">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="cinematic" className="text-base">Cinematic</SelectItem>
                        <SelectItem value="documentary" className="text-base">Documentary</SelectItem>
                        <SelectItem value="vlog" className="text-base">Vlog</SelectItem>
                        <SelectItem value="animated" className="text-base">Animated</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <Button
                  onClick={handleGenerate}
                  disabled={isGenerating || !prompt.trim()}
                  size="lg"
                  className="text-base px-6 py-3 w-full"
                >
                  {isGenerating ? (
                    <>
                      <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                      Generating...
                    </>
                  ) : (
                    <>
                      <Sparkles className="mr-2 h-5 w-5" />
                      Generate Video
                    </>
                  )}
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Edit Tab */}
          <TabsContent value="edit" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Edit Video</CardTitle>
                <CardDescription className="text-lg">
                  AI-powered video editing with auto-cut, reframe, and transitions
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Upload Video</Label>
                  <div className="border-2 border-dashed rounded-lg p-8 text-center">
                    <Upload className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
                    <p className="text-base text-muted-foreground">
                      Drag and drop a video here, or click to browse
                    </p>
                  </div>
                </div>

                <div className="space-y-4">
                  <Label className="text-lg font-semibold">Edit Operations</Label>
                  <div className="space-y-2">
                    <div className="flex items-center gap-2 p-4 border rounded-lg">
                      <Badge className="text-base px-3 py-1">Auto Cut Silence</Badge>
                      <span className="text-base text-muted-foreground">
                        Remove silent parts automatically
                      </span>
                    </div>
                    <div className="flex items-center gap-2 p-4 border rounded-lg">
                      <Badge className="text-base px-3 py-1">Auto Reframe</Badge>
                      <span className="text-base text-muted-foreground">
                        Adjust aspect ratio automatically
                      </span>
                    </div>
                    <div className="flex items-center gap-2 p-4 border rounded-lg">
                      <Badge className="text-base px-3 py-1">Auto Transition</Badge>
                      <span className="text-base text-muted-foreground">
                        Add smooth transitions between scenes
                      </span>
                    </div>
                  </div>
                </div>

                <Button size="lg" className="text-base px-6 py-3 w-full">
                  <Wand2 className="mr-2 h-5 w-5" />
                  Apply Edits
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Multi Export Tab */}
          <TabsContent value="multi-export" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Multi Format Export</CardTitle>
                <CardDescription className="text-lg">
                  Export video in multiple aspect ratios for different platforms
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Upload Video</Label>
                  <div className="border-2 border-dashed rounded-lg p-8 text-center">
                    <Upload className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
                    <p className="text-base text-muted-foreground">
                      Drag and drop a video here
                    </p>
                  </div>
                </div>

                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Export Formats</Label>
                  <div className="grid gap-2 md:grid-cols-2">
                    {["16:9 (YouTube)", "9:16 (TikTok/Reels)", "4:5 (Facebook)", "1:1 (Square)"].map((format) => (
                      <div key={format} className="flex items-center gap-2 p-3 border rounded-lg">
                        <AspectRatio className="h-5 w-5 text-primary" />
                        <span className="text-base">{format}</span>
                      </div>
                    ))}
                  </div>
                </div>

                <Button
                  onClick={handleMultiExport}
                  size="lg"
                  className="text-base px-6 py-3 w-full"
                >
                  <Film className="mr-2 h-5 w-5" />
                  Export All Formats
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Subtitle Tab */}
          <TabsContent value="subtitle" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Generate Subtitles</CardTitle>
                <CardDescription className="text-lg">
                  Auto-generate subtitles with translation support
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Upload Video</Label>
                  <div className="border-2 border-dashed rounded-lg p-8 text-center">
                    <Upload className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
                    <p className="text-base text-muted-foreground">
                      Drag and drop a video here
                    </p>
                  </div>
                </div>

                <div className="grid gap-4 md:grid-cols-2">
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Source Language</Label>
                    <Select defaultValue="auto">
                      <SelectTrigger className="text-base h-12">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="auto" className="text-base">Auto Detect</SelectItem>
                        <SelectItem value="th" className="text-base">Thai</SelectItem>
                        <SelectItem value="en" className="text-base">English</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Subtitle Style</Label>
                    <Select defaultValue="default">
                      <SelectTrigger className="text-base h-12">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="default" className="text-base">Default</SelectItem>
                        <SelectItem value="tiktok" className="text-base">TikTok Style</SelectItem>
                        <SelectItem value="youtube" className="text-base">YouTube Style</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <Button
                  onClick={handleGenerateSubtitle}
                  size="lg"
                  className="text-base px-6 py-3 w-full"
                >
                  <Subtitles className="mr-2 h-5 w-5" />
                  Generate Subtitles
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Shorts Generator Tab */}
          <TabsContent value="shorts" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Shorts Generator</CardTitle>
                <CardDescription className="text-lg">
                  Create viral shorts for TikTok, YouTube Shorts, and Instagram Reels
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Upload Video</Label>
                  <div className="border-2 border-dashed rounded-lg p-8 text-center">
                    <Upload className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
                    <p className="text-base text-muted-foreground">
                      Drag and drop a video here, or click to browse
                    </p>
                  </div>
                </div>

                <div className="grid gap-4 md:grid-cols-2">
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Platform</Label>
                    <Select defaultValue="tiktok">
                      <SelectTrigger className="text-base h-12">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="tiktok" className="text-base">TikTok (9:16)</SelectItem>
                        <SelectItem value="youtube" className="text-base">YouTube Shorts (9:16)</SelectItem>
                        <SelectItem value="instagram" className="text-base">Instagram Reels (9:16)</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Auto Features</Label>
                    <div className="space-y-2">
                      <div className="flex items-center gap-2">
                        <Badge className="text-base px-3 py-1">Auto Caption</Badge>
                        <span className="text-base text-muted-foreground">Add captions automatically</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <Badge className="text-base px-3 py-1">Auto Cut</Badge>
                        <span className="text-base text-muted-foreground">Remove silent parts</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <Badge className="text-base px-3 py-1">Trending Music</Badge>
                        <span className="text-base text-muted-foreground">Add trending music</span>
                      </div>
                    </div>
                  </div>
                </div>

                <Button size="lg" className="text-base px-6 py-3 w-full">
                  <Film className="mr-2 h-5 w-5" />
                  Generate Shorts
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Special Features Tab */}
          <TabsContent value="special" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Special Features</CardTitle>
                <CardDescription className="text-lg">
                  Advanced video tools - Meme Videos, Time-lapse, Slow Motion, and more!
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-6">
                  {/* Popular Features */}
                  <div>
                    <h3 className="text-xl font-bold mb-4">🌟 Popular Features</h3>
                    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                      {[
                        { name: "Meme Video Generator", icon: Video, type: "meme_video", badge: "NEW" },
                        { name: "Reaction Video Creator", icon: Video, type: "reaction", badge: "NEW" },
                        { name: "Video to GIF", icon: Film, type: "video_to_gif", badge: "NEW" },
                        { name: "Time-lapse Creator", icon: Video, type: "timelapse", badge: "NEW" },
                        { name: "Slow Motion", icon: Video, type: "slow_motion", badge: "NEW" },
                        { name: "Fast Motion", icon: Video, type: "fast_motion", badge: "NEW" },
                        { name: "Video Stabilization", icon: Video, type: "stabilization", badge: "NEW" },
                        { name: "Background Removal", icon: Video, type: "bg_removal", badge: "NEW" },
                      ].map((feature) => (
                        <Card
                          key={feature.type}
                          className="cursor-pointer hover:border-primary hover:shadow-lg transition-all"
                        >
                          <CardContent className="p-4">
                            <div className="flex items-center justify-between mb-2">
                              <feature.icon className="h-8 w-8 text-primary" />
                              {feature.badge && (
                                <Badge className="bg-primary text-primary-foreground text-xs">{feature.badge}</Badge>
                              )}
                            </div>
                            <p className="text-base font-semibold">{feature.name}</p>
                          </CardContent>
                        </Card>
                      ))}
                    </div>
                  </div>

                  {/* Editing Tools */}
                  <div>
                    <h3 className="text-xl font-bold mb-4">✂️ Editing Tools</h3>
                    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                      {[
                        { name: "Video Filters", icon: Video, type: "filters" },
                        { name: "Video Montage", icon: Film, type: "montage" },
                        { name: "Video Looper", icon: Video, type: "looper" },
                        { name: "Video Merger", icon: Video, type: "merger" },
                        { name: "Video Cropper", icon: Video, type: "cropper" },
                        { name: "Video Compressor", icon: Video, type: "compressor" },
                      ].map((feature) => (
                        <Card
                          key={feature.type}
                          className="cursor-pointer hover:border-primary hover:shadow-lg transition-all"
                        >
                          <CardContent className="p-4">
                            <feature.icon className="h-8 w-8 mb-2 text-primary" />
                            <p className="text-base font-semibold">{feature.name}</p>
                          </CardContent>
                        </Card>
                      ))}
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </AdminLayout>
  );
}

