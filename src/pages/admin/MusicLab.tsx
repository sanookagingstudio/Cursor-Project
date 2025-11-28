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
  Music, 
  Waves,
  Upload, 
  Download,
  Sparkles,
  Loader2,
  Mic,
  Guitar,
  BarChart3,
  Wand2,
  Volume2
} from "lucide-react";
import { useState } from "react";
import { useToast } from "@/components/ui/use-toast";

export default function MusicLab() {
  const { toast } = useToast();
  const [activeTab, setActiveTab] = useState("generate");
  const [prompt, setPrompt] = useState("");
  const [duration, setDuration] = useState(30);
  const [tempo, setTempo] = useState<number | undefined>(120);
  const [key, setKey] = useState<string | undefined>();
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
      const response = await fetch("http://localhost:8000/api/music/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          prompt,
          duration_seconds: duration,
          tempo,
          key,
          provider: "mock"
        })
      });

      if (!response.ok) throw new Error("Failed to generate music");

      const data = await response.json();
      
      toast({
        title: "Success",
        description: "Music generation started. Check job status."
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to generate music",
        variant: "destructive"
      });
    } finally {
      setIsGenerating(false);
    }
  };

  return (
    <AdminLayout>
      <div className="space-y-8 w-full">
        <div>
          <h1 className="text-5xl font-bold mb-4 flex items-center gap-3">
            <Music className="h-10 w-10 text-primary" />
            Music Lab
          </h1>
          <p className="text-lg text-muted-foreground">
            AI-powered music generation, analysis, and audio processing. Create, analyze, and enhance audio with AI.
          </p>
        </div>

        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-5 text-base">
            <TabsTrigger value="generate" className="text-base">Generate</TabsTrigger>
            <TabsTrigger value="stems" className="text-base">Stems</TabsTrigger>
            <TabsTrigger value="analyze" className="text-base">Analyze</TabsTrigger>
            <TabsTrigger value="tab" className="text-base">Tab</TabsTrigger>
            <TabsTrigger value="remaster" className="text-base">Remaster</TabsTrigger>
          </TabsList>

          {/* Generate Tab */}
          <TabsContent value="generate" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Generate Music</CardTitle>
                <CardDescription className="text-lg">
                  Create music from text prompts using AI
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Prompt</Label>
                  <Textarea
                    placeholder="Describe the music you want to create... (e.g., 'A cheerful acoustic guitar melody in C major')"
                    value={prompt}
                    onChange={(e) => setPrompt(e.target.value)}
                    className="text-base min-h-[120px]"
                  />
                </div>

                <div className="grid gap-4 md:grid-cols-4">
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Duration (seconds)</Label>
                    <Input
                      type="number"
                      value={duration}
                      onChange={(e) => setDuration(parseInt(e.target.value) || 30)}
                      min={5}
                      max={300}
                      className="text-base h-12"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Tempo (BPM)</Label>
                    <Input
                      type="number"
                      value={tempo || ""}
                      onChange={(e) => setTempo(e.target.value ? parseInt(e.target.value) : undefined)}
                      min={60}
                      max={200}
                      placeholder="Auto"
                      className="text-base h-12"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Key</Label>
                    <Select value={key || ""} onValueChange={(v) => setKey(v || undefined)}>
                      <SelectTrigger className="text-base h-12">
                        <SelectValue placeholder="Auto" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="" className="text-base">Auto</SelectItem>
                        <SelectItem value="C:maj" className="text-base">C Major</SelectItem>
                        <SelectItem value="A:min" className="text-base">A Minor</SelectItem>
                        <SelectItem value="G:maj" className="text-base">G Major</SelectItem>
                        <SelectItem value="E:min" className="text-base">E Minor</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Mood</Label>
                    <Select>
                      <SelectTrigger className="text-base h-12">
                        <SelectValue placeholder="Select mood" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="happy" className="text-base">Happy</SelectItem>
                        <SelectItem value="sad" className="text-base">Sad</SelectItem>
                        <SelectItem value="energetic" className="text-base">Energetic</SelectItem>
                        <SelectItem value="calm" className="text-base">Calm</SelectItem>
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
                      Generate Music
                    </>
                  )}
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Stems Tab */}
          <TabsContent value="stems" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Stem Separation</CardTitle>
                <CardDescription className="text-lg">
                  Separate audio into vocal, drums, bass, and other stems
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Upload Audio</Label>
                  <div className="border-2 border-dashed rounded-lg p-8 text-center">
                    <Upload className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
                    <p className="text-base text-muted-foreground">
                      Drag and drop an audio file here, or click to browse
                    </p>
                  </div>
                </div>

                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Stems to Extract</Label>
                  <div className="grid gap-2 md:grid-cols-2">
                    {["vocal", "drums", "bass", "other"].map((stem) => (
                      <div key={stem} className="flex items-center gap-2 p-3 border rounded-lg">
                        <Volume2 className="h-5 w-5 text-primary" />
                        <span className="text-base capitalize">{stem}</span>
                      </div>
                    ))}
                  </div>
                </div>

                <Button size="lg" className="text-base px-6 py-3 w-full">
                  <Waves className="mr-2 h-5 w-5" />
                  Separate Stems
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Analyze Tab */}
          <TabsContent value="analyze" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Music Analysis</CardTitle>
                <CardDescription className="text-lg">
                  Analyze BPM, key, chords, and song structure
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Upload Audio</Label>
                  <div className="border-2 border-dashed rounded-lg p-8 text-center">
                    <Upload className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
                    <p className="text-base text-muted-foreground">
                      Drag and drop an audio file here
                    </p>
                  </div>
                </div>

                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Analysis Tasks</Label>
                  <div className="grid gap-2 md:grid-cols-2">
                    {["BPM", "Key", "Chords", "Sections", "Energy"].map((task) => (
                      <div key={task} className="flex items-center gap-2 p-3 border rounded-lg">
                        <BarChart3 className="h-5 w-5 text-primary" />
                        <span className="text-base">{task}</span>
                      </div>
                    ))}
                  </div>
                </div>

                <Button size="lg" className="text-base px-6 py-3 w-full">
                  <BarChart3 className="mr-2 h-5 w-5" />
                  Analyze Music
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Tab Tab */}
          <TabsContent value="tab" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Tab Generator</CardTitle>
                <CardDescription className="text-lg">
                  Generate tabs for guitar, bass, or ukulele
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Upload Audio</Label>
                  <div className="border-2 border-dashed rounded-lg p-8 text-center">
                    <Upload className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
                    <p className="text-base text-muted-foreground">
                      Drag and drop an audio file here
                    </p>
                  </div>
                </div>

                <div className="grid gap-4 md:grid-cols-3">
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Instrument</Label>
                    <Select defaultValue="guitar">
                      <SelectTrigger className="text-base h-12">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="guitar" className="text-base">Guitar</SelectItem>
                        <SelectItem value="bass" className="text-base">Bass</SelectItem>
                        <SelectItem value="ukulele" className="text-base">Ukulele</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Difficulty</Label>
                    <Select defaultValue="original">
                      <SelectTrigger className="text-base h-12">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="easy" className="text-base">Easy</SelectItem>
                        <SelectItem value="original" className="text-base">Original</SelectItem>
                        <SelectItem value="advanced" className="text-base">Advanced</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Format</Label>
                    <Select defaultValue="text">
                      <SelectTrigger className="text-base h-12">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="text" className="text-base">Text</SelectItem>
                        <SelectItem value="gp5" className="text-base">Guitar Pro</SelectItem>
                        <SelectItem value="musicxml" className="text-base">MusicXML</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <Button size="lg" className="text-base px-6 py-3 w-full">
                  <Guitar className="mr-2 h-5 w-5" />
                  Generate Tab
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Remaster Tab */}
          <TabsContent value="remaster" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Audio Remaster</CardTitle>
                <CardDescription className="text-lg">
                  Enhance audio with noise reduction, EQ, and normalization
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Upload Audio</Label>
                  <div className="border-2 border-dashed rounded-lg p-8 text-center">
                    <Upload className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
                    <p className="text-base text-muted-foreground">
                      Drag and drop an audio file here
                    </p>
                  </div>
                </div>

                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Remaster Operations</Label>
                  <div className="space-y-2">
                    {[
                      { name: "Noise Reduction", icon: Mic },
                      { name: "EQ (Warm)", icon: Volume2 },
                      { name: "Normalize", icon: Waves },
                      { name: "Stereo Widen", icon: Music }
                    ].map((op) => (
                      <div key={op.name} className="flex items-center gap-2 p-3 border rounded-lg">
                        <op.icon className="h-5 w-5 text-primary" />
                        <span className="text-base">{op.name}</span>
                      </div>
                    ))}
                  </div>
                </div>

                <Button size="lg" className="text-base px-6 py-3 w-full">
                  <Wand2 className="mr-2 h-5 w-5" />
                  Remaster Audio
                </Button>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </AdminLayout>
  );
}

