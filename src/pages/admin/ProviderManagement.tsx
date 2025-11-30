import { AdminLayout } from "@/layouts/AdminLayout";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { 
  Image, 
  Video, 
  Music, 
  Sparkles, 
  DollarSign, 
  Zap, 
  CheckCircle, 
  AlertCircle,
  TrendingUp,
  TrendingDown,
  Info
} from "lucide-react";
import { useState, useEffect } from "react";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";

interface Provider {
  id: string;
  name: string;
  category: "image" | "video" | "audio" | "music";
  status: "active" | "inactive" | "error";
  costPerUnit: number;
  unit: string;
  quality: "high" | "medium" | "low";
  speed: "fast" | "medium" | "slow";
  features: string[];
  recommended?: boolean;
  costReason?: string;
}

interface CostComparison {
  provider: string;
  estimatedCost: number;
  quality: string;
  speed: string;
  recommendation: "best" | "good" | "ok";
}

export default function ProviderManagement() {
  const [providers, setProviders] = useState<Provider[]>([]);
  const [selectedProviders, setSelectedProviders] = useState({
    image: "flux",
    video: "runway",
    audio: "demucs",
    music: "musicgen"
  });
  const [costComparison, setCostComparison] = useState<CostComparison[]>([]);
  const [jarvisRecommendation, setJarvisRecommendation] = useState<string>("");

  useEffect(() => {
    // Mock data - จะเชื่อมต่อ API จริงในอนาคต
    setProviders([
      {
        id: "flux",
        name: "Flux",
        category: "image",
        status: "active",
        costPerUnit: 0.04,
        unit: "per image",
        quality: "high",
        speed: "fast",
        features: ["High quality", "Fast generation", "Good for photos"],
        recommended: true,
        costReason: "Best quality/price ratio"
      },
      {
        id: "dalle",
        name: "DALL-E 3",
        category: "image",
        status: "active",
        costPerUnit: 0.08,
        unit: "per image",
        quality: "high",
        speed: "medium",
        features: ["Very high quality", "Good for art"],
      },
      {
        id: "midjourney",
        name: "Midjourney",
        category: "image",
        status: "inactive",
        costPerUnit: 0.10,
        unit: "per image",
        quality: "high",
        speed: "slow",
        features: ["Artistic style", "High quality"],
      },
      {
        id: "runway",
        name: "Runway ML",
        category: "video",
        status: "active",
        costPerUnit: 0.05,
        unit: "per second",
        quality: "high",
        speed: "fast",
        features: ["High quality", "Fast generation"],
        recommended: true,
        costReason: "Best for video generation"
      },
      {
        id: "pika",
        name: "Pika",
        category: "video",
        status: "active",
        costPerUnit: 0.03,
        unit: "per second",
        quality: "medium",
        speed: "fast",
        features: ["Fast generation", "Good quality"],
      },
      {
        id: "demucs",
        name: "Demucs",
        category: "audio",
        status: "active",
        costPerUnit: 0.01,
        unit: "per minute",
        quality: "high",
        speed: "medium",
        features: ["Stem separation", "High quality"],
        recommended: true,
        costReason: "Best stem separation quality"
      },
      {
        id: "musicgen",
        name: "MusicGen",
        category: "music",
        status: "active",
        costPerUnit: 0.02,
        unit: "per minute",
        quality: "high",
        speed: "medium",
        features: ["Music generation", "Good quality"],
        recommended: true,
        costReason: "Best for music generation"
      },
    ]);

    // Mock Jarvis recommendation
    setJarvisRecommendation("Based on your usage patterns, I recommend using Flux for images (best quality/price), Runway for videos (fastest), and Demucs for audio (best quality). This combination will save approximately 30% compared to premium providers while maintaining high quality.");
  }, []);

  const handleProviderChange = (category: string, providerId: string) => {
    setSelectedProviders(prev => ({
      ...prev,
      [category]: providerId
    }));
  };

  const getCategoryProviders = (category: string) => {
    return providers.filter(p => p.category === category);
  };

  const getStatusBadge = (status: string) => {
    if (status === "active") return <Badge className="bg-green-500 text-base px-3 py-1">Active</Badge>;
    if (status === "error") return <Badge variant="destructive" className="text-base px-3 py-1">Error</Badge>;
    return <Badge variant="secondary" className="text-base px-3 py-1">Inactive</Badge>;
  };

  const getQualityBadge = (quality: string) => {
    const colors = {
      high: "bg-green-500",
      medium: "bg-yellow-500",
      low: "bg-orange-500"
    };
    return <Badge className={`${colors[quality]} text-base px-3 py-1`}>{quality.toUpperCase()}</Badge>;
  };

  const getSpeedBadge = (speed: string) => {
    const icons = {
      fast: <Zap className="h-4 w-4" />,
      medium: <TrendingUp className="h-4 w-4" />,
      slow: <TrendingDown className="h-4 w-4" />
    };
    return (
      <div className="flex items-center gap-1 text-base">
        {icons[speed]}
        <span>{speed}</span>
      </div>
    );
  };

  return (
    <AdminLayout>
      <div className="space-y-8 w-full">
        <div>
          <h1 className="text-5xl font-bold mb-4">Provider Management</h1>
          <p className="text-lg text-muted-foreground">
            Manage AI providers and API settings. Switch providers without code changes.
          </p>
        </div>

        {/* Jarvis Recommendation */}
        <Alert className="bg-primary/10 border-primary">
          <Sparkles className="h-6 w-6 text-primary" />
          <AlertTitle className="text-xl font-semibold mb-2">Jarvis AI Recommendation</AlertTitle>
          <AlertDescription className="text-base">
            {jarvisRecommendation}
          </AlertDescription>
        </Alert>

        {/* Current Selection */}
        <Card>
          <CardHeader>
            <CardTitle className="text-2xl font-bold">Current Provider Selection</CardTitle>
            <CardDescription className="text-lg">Active providers for each category</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
              <div className="space-y-2">
                <Label className="text-lg font-semibold flex items-center gap-2">
                  <Image className="h-5 w-5" />
                  Image Provider
                </Label>
                <Select 
                  value={selectedProviders.image} 
                  onValueChange={(value) => handleProviderChange("image", value)}
                >
                  <SelectTrigger className="text-base h-12">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {getCategoryProviders("image").filter(p => p.id && p.id !== "").map(provider => (
                      <SelectItem key={provider.id} value={provider.id} className="text-base">
                        {provider.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label className="text-lg font-semibold flex items-center gap-2">
                  <Video className="h-5 w-5" />
                  Video Provider
                </Label>
                <Select 
                  value={selectedProviders.video} 
                  onValueChange={(value) => handleProviderChange("video", value)}
                >
                  <SelectTrigger className="text-base h-12">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {getCategoryProviders("video").filter(p => p.id && p.id !== "").map(provider => (
                      <SelectItem key={provider.id} value={provider.id} className="text-base">
                        {provider.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label className="text-lg font-semibold flex items-center gap-2">
                  <Music className="h-5 w-5" />
                  Audio Provider
                </Label>
                <Select 
                  value={selectedProviders.audio} 
                  onValueChange={(value) => handleProviderChange("audio", value)}
                >
                  <SelectTrigger className="text-base h-12">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {getCategoryProviders("audio").filter(p => p.id && p.id !== "").map(provider => (
                      <SelectItem key={provider.id} value={provider.id} className="text-base">
                        {provider.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label className="text-lg font-semibold flex items-center gap-2">
                  <Sparkles className="h-5 w-5" />
                  Music Provider
                </Label>
                <Select 
                  value={selectedProviders.music} 
                  onValueChange={(value) => handleProviderChange("music", value)}
                >
                  <SelectTrigger className="text-base h-12">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {getCategoryProviders("music").filter(p => p.id && p.id !== "").map(provider => (
                      <SelectItem key={provider.id} value={provider.id} className="text-base">
                        {provider.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="mt-6">
              <Button size="lg" className="text-base px-6 py-3">
                Save Provider Settings
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Provider Details */}
        <Tabs defaultValue="image" className="w-full">
          <TabsList className="grid w-full grid-cols-4 text-base">
            <TabsTrigger value="image" className="text-base">Image</TabsTrigger>
            <TabsTrigger value="video" className="text-base">Video</TabsTrigger>
            <TabsTrigger value="audio" className="text-base">Audio</TabsTrigger>
            <TabsTrigger value="music" className="text-base">Music</TabsTrigger>
          </TabsList>

          {(["image", "video", "audio", "music"] as const).map(category => (
            <TabsContent key={category} value={category} className="space-y-4">
              <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                {getCategoryProviders(category).map(provider => (
                  <Card 
                    key={provider.id} 
                    className={selectedProviders[category] === provider.id ? "border-primary border-2" : ""}
                  >
                    <CardHeader>
                      <div className="flex items-center justify-between">
                        <CardTitle className="text-xl font-semibold">{provider.name}</CardTitle>
                        {provider.recommended && (
                          <Badge className="bg-primary text-base px-3 py-1">
                            <Sparkles className="h-4 w-4 mr-1" />
                            Recommended
                          </Badge>
                        )}
                      </div>
                      <CardDescription className="text-base">
                        {provider.costReason}
                      </CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-4">
                      <div className="flex items-center justify-between">
                        <span className="text-base">Status:</span>
                        {getStatusBadge(provider.status)}
                      </div>
                      
                      <div className="flex items-center justify-between">
                        <span className="text-base">Cost:</span>
                        <span className="text-lg font-semibold">
                          ${provider.costPerUnit.toFixed(2)} / {provider.unit}
                        </span>
                      </div>

                      <div className="flex items-center justify-between">
                        <span className="text-base">Quality:</span>
                        {getQualityBadge(provider.quality)}
                      </div>

                      <div className="flex items-center justify-between">
                        <span className="text-base">Speed:</span>
                        {getSpeedBadge(provider.speed)}
                      </div>

                      <div>
                        <Label className="text-base font-semibold mb-2 block">Features:</Label>
                        <ul className="space-y-1">
                          {provider.features.map((feature, idx) => (
                            <li key={idx} className="text-base text-muted-foreground flex items-center gap-2">
                              <CheckCircle className="h-4 w-4 text-green-500" />
                              {feature}
                            </li>
                          ))}
                        </ul>
                      </div>

                      {selectedProviders[category] === provider.id && (
                        <Badge className="w-full justify-center bg-primary text-base py-2">
                          Currently Active
                        </Badge>
                      )}

                      <Button 
                        variant={selectedProviders[category] === provider.id ? "default" : "outline"}
                        className="w-full text-base"
                        onClick={() => handleProviderChange(category, provider.id)}
                      >
                        {selectedProviders[category] === provider.id ? "Active" : "Switch to This"}
                      </Button>
                    </CardContent>
                  </Card>
                ))}
              </div>
            </TabsContent>
          ))}
        </Tabs>

        {/* Cost Comparison */}
        <Card>
          <CardHeader>
            <CardTitle className="text-2xl font-bold flex items-center gap-2">
              <DollarSign className="h-6 w-6" />
              Cost Comparison
            </CardTitle>
            <CardDescription className="text-lg">
              Compare costs across providers for your typical usage
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="grid gap-4 md:grid-cols-3">
                <div>
                  <Label className="text-lg font-semibold">Estimated Usage</Label>
                  <Input 
                    type="number" 
                    placeholder="100" 
                    className="text-base h-12 mt-2"
                  />
                  <p className="text-sm text-muted-foreground mt-1">images/videos per month</p>
                </div>
                <div>
                  <Label className="text-lg font-semibold">Quality Priority</Label>
                  <Select defaultValue="high">
                    <SelectTrigger className="text-base h-12 mt-2">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="high" className="text-base">High Quality</SelectItem>
                      <SelectItem value="medium" className="text-base">Medium Quality</SelectItem>
                      <SelectItem value="low" className="text-base">Low Quality (Cost Saving)</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div>
                  <Label className="text-lg font-semibold">Speed Priority</Label>
                  <Select defaultValue="fast">
                    <SelectTrigger className="text-base h-12 mt-2">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="fast" className="text-base">Fast</SelectItem>
                      <SelectItem value="medium" className="text-base">Medium</SelectItem>
                      <SelectItem value="slow" className="text-base">Slow (Cost Saving)</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <Button size="lg" className="text-base px-6 py-3">
                Calculate Cost Comparison
              </Button>

              <div className="mt-6 p-4 bg-muted rounded-lg">
                <p className="text-base text-muted-foreground">
                  <Info className="h-5 w-5 inline mr-2" />
                  Cost comparison will show estimated monthly costs for each provider based on your usage patterns.
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* API Keys Management */}
        <Card>
          <CardHeader>
            <CardTitle className="text-2xl font-bold">API Keys Management</CardTitle>
            <CardDescription className="text-lg">
              Configure API keys for each provider
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Tabs defaultValue="image" className="w-full">
              <TabsList className="grid w-full grid-cols-4 text-base">
                <TabsTrigger value="image" className="text-base">Image</TabsTrigger>
                <TabsTrigger value="video" className="text-base">Video</TabsTrigger>
                <TabsTrigger value="audio" className="text-base">Audio</TabsTrigger>
                <TabsTrigger value="music" className="text-base">Music</TabsTrigger>
              </TabsList>

              {(["image", "video", "audio", "music"] as const).map(category => (
                <TabsContent key={category} value={category} className="space-y-4">
                  {getCategoryProviders(category).map(provider => (
                    <div key={provider.id} className="space-y-2 p-4 border rounded-lg">
                      <Label className="text-lg font-semibold">{provider.name} API Key</Label>
                      <Input 
                        type="password" 
                        placeholder={`Enter ${provider.name} API key`}
                        className="text-base h-12"
                      />
                      <Button variant="outline" size="sm" className="text-base">
                        Test Connection
                      </Button>
                    </div>
                  ))}
                </TabsContent>
              ))}

              <div className="mt-6">
                <Button size="lg" className="text-base px-6 py-3">
                  Save All API Keys
                </Button>
              </div>
            </Tabs>
          </CardContent>
        </Card>
      </div>
    </AdminLayout>
  );
}

