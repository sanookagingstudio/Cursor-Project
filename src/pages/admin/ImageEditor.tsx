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
  Image as ImageIcon, 
  Wand2, 
  Upload, 
  Download,
  ZoomIn,
  ZoomOut,
  RotateCw,
  Crop,
  Palette,
  Sparkles,
  Loader2,
  CheckCircle
} from "lucide-react";
import { useState } from "react";
import { useToast } from "@/components/ui/use-toast";

export default function ImageEditor() {
  const { toast } = useToast();
  const [activeTab, setActiveTab] = useState("generate");
  const [prompt, setPrompt] = useState("");
  const [width, setWidth] = useState(1024);
  const [height, setHeight] = useState(1024);
  const [style, setStyle] = useState("cute");
  const [isGenerating, setIsGenerating] = useState(false);
  const [generatedImages, setGeneratedImages] = useState<string[]>([]);
  const [selectedImage, setSelectedImage] = useState<string | null>(null);

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
      const response = await fetch("http://localhost:8000/api/image/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          prompt,
          width,
          height,
          style,
          provider: "mock"
        })
      });

      if (!response.ok) throw new Error("Failed to generate image");

      const data = await response.json();
      
      toast({
        title: "Success",
        description: "Image generation started. Check job status."
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to generate image",
        variant: "destructive"
      });
    } finally {
      setIsGenerating(false);
    }
  };

  const handleBatchGenerate = async () => {
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
      const response = await fetch("http://localhost:8000/api/image/batch", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          prompt,
          batch_count: 4,
          width,
          height,
          style,
          provider: "mock"
        })
      });

      if (!response.ok) throw new Error("Failed to batch generate");

      const data = await response.json();
      
      toast({
        title: "Success",
        description: `Batch generation started for ${data.total_count} images`
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to batch generate",
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
            <ImageIcon className="h-10 w-10 text-primary" />
            Image Editor
          </h1>
          <p className="text-lg text-muted-foreground">
            AI-powered image generation and editing. Create, edit, and customize images with AI.
          </p>
        </div>

        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-5 text-base">
            <TabsTrigger value="generate" className="text-base">Generate</TabsTrigger>
            <TabsTrigger value="edit" className="text-base">Edit</TabsTrigger>
            <TabsTrigger value="templates" className="text-base">Templates</TabsTrigger>
            <TabsTrigger value="special" className="text-base">Special</TabsTrigger>
            <TabsTrigger value="batch" className="text-base">Batch</TabsTrigger>
          </TabsList>

          {/* Generate Tab */}
          <TabsContent value="generate" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Generate Image</CardTitle>
                <CardDescription className="text-lg">
                  Create images from text prompts using AI
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Prompt</Label>
                  <Textarea
                    placeholder="Describe the image you want to create... (e.g., 'A cute cat playing with yarn')"
                    value={prompt}
                    onChange={(e) => setPrompt(e.target.value)}
                    className="text-base min-h-[120px]"
                  />
                </div>

                <div className="grid gap-4 md:grid-cols-3">
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Width</Label>
                    <Input
                      type="number"
                      value={width}
                      onChange={(e) => setWidth(parseInt(e.target.value) || 1024)}
                      className="text-base h-12"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Height</Label>
                    <Input
                      type="number"
                      value={height}
                      onChange={(e) => setHeight(parseInt(e.target.value) || 1024)}
                      className="text-base h-12"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Style</Label>
                    <Select value={style} onValueChange={setStyle}>
                      <SelectTrigger className="text-base h-12">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="cute" className="text-base">Cute</SelectItem>
                        <SelectItem value="realistic" className="text-base">Realistic</SelectItem>
                        <SelectItem value="artistic" className="text-base">Artistic</SelectItem>
                        <SelectItem value="minimalist" className="text-base">Minimalist</SelectItem>
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
                      Generate Image
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
                <CardTitle className="text-2xl font-bold">Edit Image</CardTitle>
                <CardDescription className="text-lg">
                  Edit existing images with AI-powered tools
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Upload Image</Label>
                  <div className="border-2 border-dashed rounded-lg p-8 text-center">
                    <Upload className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
                    <p className="text-base text-muted-foreground">
                      Drag and drop an image here, or click to browse
                    </p>
                  </div>
                </div>

                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Edit Instruction</Label>
                  <Textarea
                    placeholder="Describe what you want to change... (e.g., 'Remove the background', 'Add a sunset')"
                    className="text-base min-h-[100px]"
                  />
                </div>

                <Button size="lg" className="text-base px-6 py-3 w-full">
                  <Wand2 className="mr-2 h-5 w-5" />
                  Apply Edit
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Templates Tab */}
          <TabsContent value="templates" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Templates</CardTitle>
                <CardDescription className="text-lg">
                  Use pre-designed templates for quick image creation
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="grid gap-4 md:grid-cols-3 lg:grid-cols-4">
                  {["Poster", "Story", "Infographic", "Social Media"].map((template) => (
                    <Card key={template} className="cursor-pointer hover:border-primary">
                      <CardContent className="p-4">
                        <div className="aspect-video bg-muted rounded-lg mb-2 flex items-center justify-center">
                          <ImageIcon className="h-8 w-8 text-muted-foreground" />
                        </div>
                        <p className="text-base font-semibold text-center">{template}</p>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Special Features Tab */}
          <TabsContent value="special" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Special Features</CardTitle>
                <CardDescription className="text-lg">
                  Generate specialized content for elderly users
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                  {[
                    { name: "Coloring Book", icon: Palette, type: "coloring_book" },
                    { name: "Pattern", icon: Sparkles, type: "pattern" },
                    { name: "Origami", icon: ImageIcon, type: "origami" },
                    { name: "Card Game", icon: ImageIcon, type: "card_game" },
                    { name: "Playing Cards", icon: ImageIcon, type: "playing_cards" },
                    { name: "Board Game", icon: ImageIcon, type: "board_game" },
                    { name: "Emoji & Sticker", icon: Sparkles, type: "emoji" },
                    { name: "Quote 90s", icon: ImageIcon, type: "quote_90s" },
                    { name: "Caption", icon: ImageIcon, type: "caption" },
                  ].map((feature) => (
                    <Card
                      key={feature.type}
                      className="cursor-pointer hover:border-primary"
                    >
                      <CardContent className="p-4">
                        <feature.icon className="h-8 w-8 mb-2 text-primary" />
                        <p className="text-base font-semibold">{feature.name}</p>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Batch Tab */}
          <TabsContent value="batch" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Batch Generate</CardTitle>
                <CardDescription className="text-lg">
                  Generate multiple images at once
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label className="text-lg font-semibold">Prompt</Label>
                  <Textarea
                    placeholder="Describe the images you want to create..."
                    value={prompt}
                    onChange={(e) => setPrompt(e.target.value)}
                    className="text-base min-h-[100px]"
                  />
                </div>

                <div className="grid gap-4 md:grid-cols-2">
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Number of Images</Label>
                    <Select defaultValue="4">
                      <SelectTrigger className="text-base h-12">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="4" className="text-base">4 Images</SelectItem>
                        <SelectItem value="8" className="text-base">8 Images</SelectItem>
                        <SelectItem value="12" className="text-base">12 Images</SelectItem>
                        <SelectItem value="20" className="text-base">20 Images</SelectItem>
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
                        <SelectItem value="cute" className="text-base">Cute</SelectItem>
                        <SelectItem value="realistic" className="text-base">Realistic</SelectItem>
                        <SelectItem value="artistic" className="text-base">Artistic</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <Button
                  onClick={handleBatchGenerate}
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
                      Generate Batch
                    </>
                  )}
                </Button>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </AdminLayout>
  );
}

