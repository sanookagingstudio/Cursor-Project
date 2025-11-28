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
  Brain, 
  Sparkles, 
  Play, 
  CheckCircle, 
  Loader2,
  Image as ImageIcon,
  Video,
  Music,
  Layers
} from "lucide-react";
import { useState } from "react";
import { useToast } from "@/components/ui/use-toast";
import { getApiUrl } from "@/lib/api";

interface IdeaVersion {
  id: string;
  version_index: number;
  metadata: {
    prompt_variation?: string;
    style?: string;
    confidence?: number;
  };
}

interface WorkflowStep {
  module: string;
  action: string;
  params: Record<string, any>;
}

export default function InputBrain() {
  const { toast } = useToast();
  const [prompt, setPrompt] = useState("");
  const [contentType, setContentType] = useState<"image" | "video" | "music" | "mixed">("image");
  const [isGenerating, setIsGenerating] = useState(false);
  const [currentIdeaId, setCurrentIdeaId] = useState<string | null>(null);
  const [versions, setVersions] = useState<IdeaVersion[]>([]);
  const [selectedVersion, setSelectedVersion] = useState<number | null>(null);
  const [workflowSteps, setWorkflowSteps] = useState<WorkflowStep[]>([]);
  const [workflowDraftId, setWorkflowDraftId] = useState<string | null>(null);

  const handleCreateIdea = async () => {
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
      // Mock API call - will connect to real API later
      const response = await fetch(getApiUrl("/input-brain/ideas"), {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          type: contentType,
          prompt: prompt,
          options: {}
        })
      });

      if (!response.ok) throw new Error("Failed to create idea");

      const idea = await response.json();
      setCurrentIdeaId(idea.id);
      
      // Auto-generate suggestions
      await handleGenerateSuggestions(idea.id);
      
      toast({
        title: "Success",
        description: "Idea created successfully"
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to create idea",
        variant: "destructive"
      });
    } finally {
      setIsGenerating(false);
    }
  };

  const handleGenerateSuggestions = async (ideaId: string) => {
    setIsGenerating(true);
    try {
      const response = await fetch(
        `${getApiUrl(`/input-brain/ideas/${ideaId}/generate-suggestions`)}?num_versions=4`,
        { method: "POST" }
      );

      if (!response.ok) throw new Error("Failed to generate suggestions");

      const data = await response.json();
      setVersions(data.versions);
      
      toast({
        title: "Success",
        description: `${data.versions.length} versions generated`
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to generate suggestions",
        variant: "destructive"
      });
    } finally {
      setIsGenerating(false);
    }
  };

  const handleSelectVersion = async (versionIndex: number) => {
    if (!currentIdeaId) return;

    try {
      const response = await fetch(
        `${getApiUrl(`/input-brain/ideas/${currentIdeaId}/select-version`)}?version_index=${versionIndex}`,
        { method: "POST" }
      );

      if (!response.ok) throw new Error("Failed to select version");

      setSelectedVersion(versionIndex);
      
      toast({
        title: "Success",
        description: `Version ${versionIndex} selected`
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to select version",
        variant: "destructive"
      });
    }
  };

  const handleGenerateWorkflow = async () => {
    if (!currentIdeaId || !selectedVersion) return;

    setIsGenerating(true);
    try {
      const response = await fetch(
        `${getApiUrl(`/input-brain/ideas/${currentIdeaId}/generate-workflow-draft`)}?version_index=${selectedVersion}`,
        { method: "POST" }
      );

      if (!response.ok) throw new Error("Failed to generate workflow");

      const draft = await response.json();
      setWorkflowSteps(draft.steps);
      setWorkflowDraftId(draft.id);
      
      toast({
        title: "Success",
        description: "Workflow draft generated"
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to generate workflow",
        variant: "destructive"
      });
    } finally {
      setIsGenerating(false);
    }
  };

  const handleStartWorkflow = async () => {
    if (!workflowDraftId) return;

    setIsGenerating(true);
    try {
      const response = await fetch(
        getApiUrl(`/input-brain/workflow-drafts/${workflowDraftId}/start`),
        { method: "POST" }
      );

      if (!response.ok) throw new Error("Failed to start workflow");

      toast({
        title: "Success",
        description: "Workflow started successfully"
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to start workflow",
        variant: "destructive"
      });
    } finally {
      setIsGenerating(false);
    }
  };

  const getContentTypeIcon = (type: string) => {
    switch (type) {
      case "image": return <ImageIcon className="h-5 w-5" />;
      case "video": return <Video className="h-5 w-5" />;
      case "music": return <Music className="h-5 w-5" />;
      default: return <Layers className="h-5 w-5" />;
    }
  };

  return (
    <AdminLayout>
      <div className="space-y-8 w-full">
        <div>
          <h1 className="text-5xl font-bold mb-4 flex items-center gap-3">
            <Brain className="h-10 w-10 text-primary" />
            Input Brain
          </h1>
          <p className="text-lg text-muted-foreground">
            Start your content creation journey. Enter your idea and let AI generate suggestions.
          </p>
        </div>

        {/* Step 1: Create Idea */}
        <Card>
          <CardHeader>
            <CardTitle className="text-2xl font-bold">Step 1: Enter Your Idea</CardTitle>
            <CardDescription className="text-lg">
              Describe what you want to create
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label className="text-lg font-semibold">Content Type</Label>
              <Select value={contentType} onValueChange={(v: any) => setContentType(v)}>
                <SelectTrigger className="text-base h-12">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="image" className="text-base">Image</SelectItem>
                  <SelectItem value="video" className="text-base">Video</SelectItem>
                  <SelectItem value="music" className="text-base">Music</SelectItem>
                  <SelectItem value="mixed" className="text-base">Mixed</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label className="text-lg font-semibold">Your Prompt</Label>
              <Textarea
                placeholder="Describe your content idea... (e.g., 'A cute cat playing with yarn')"
                value={prompt}
                onChange={(e) => setPrompt(e.target.value)}
                className="text-base min-h-[120px]"
              />
            </div>

            <Button
              onClick={handleCreateIdea}
              disabled={isGenerating || !prompt.trim()}
              size="lg"
              className="text-base px-6 py-3"
            >
              {isGenerating ? (
                <>
                  <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                  Generating...
                </>
              ) : (
                <>
                  <Sparkles className="mr-2 h-5 w-5" />
                  Generate AI Suggestions
                </>
              )}
            </Button>
          </CardContent>
        </Card>

        {/* Step 2: AI Suggestions */}
        {versions.length > 0 && (
          <Card>
            <CardHeader>
              <CardTitle className="text-2xl font-bold">Step 2: AI Suggestions</CardTitle>
              <CardDescription className="text-lg">
                Choose the best version for your idea
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                {versions.map((version) => (
                  <Card
                    key={version.id}
                    className={`cursor-pointer transition-all ${
                      selectedVersion === version.version_index
                        ? "border-primary border-2"
                        : "hover:border-primary/50"
                    }`}
                    onClick={() => handleSelectVersion(version.version_index)}
                  >
                    <CardHeader>
                      <div className="flex items-center justify-between">
                        <CardTitle className="text-xl font-semibold">
                          Version {version.version_index}
                        </CardTitle>
                        {selectedVersion === version.version_index && (
                          <CheckCircle className="h-6 w-6 text-primary" />
                        )}
                      </div>
                    </CardHeader>
                    <CardContent className="space-y-2">
                      <div>
                        <Label className="text-base font-semibold">Style:</Label>
                        <Badge className="text-base px-3 py-1 ml-2">
                          {version.metadata.style || "default"}
                        </Badge>
                      </div>
                      <div>
                        <Label className="text-base font-semibold">Confidence:</Label>
                        <span className="text-base ml-2">
                          {((version.metadata.confidence || 0) * 100).toFixed(0)}%
                        </span>
                      </div>
                      {version.metadata.prompt_variation && (
                        <p className="text-base text-muted-foreground">
                          {version.metadata.prompt_variation}
                        </p>
                      )}
                    </CardContent>
                  </Card>
                ))}
              </div>
            </CardContent>
          </Card>
        )}

        {/* Step 3: Workflow Draft */}
        {selectedVersion && (
          <Card>
            <CardHeader>
              <CardTitle className="text-2xl font-bold">Step 3: Workflow Draft</CardTitle>
              <CardDescription className="text-lg">
                Review and generate workflow
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              {workflowSteps.length === 0 ? (
                <Button
                  onClick={handleGenerateWorkflow}
                  disabled={isGenerating}
                  size="lg"
                  className="text-base px-6 py-3"
                >
                  {isGenerating ? (
                    <>
                      <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                      Generating...
                    </>
                  ) : (
                    <>
                      <Layers className="mr-2 h-5 w-5" />
                      Generate Workflow Draft
                    </>
                  )}
                </Button>
              ) : (
                <div className="space-y-4">
                  <div className="space-y-2">
                    <Label className="text-lg font-semibold">Workflow Steps</Label>
                    <div className="space-y-2">
                      {workflowSteps.map((step, idx) => (
                        <div
                          key={idx}
                          className="flex items-center gap-3 p-4 border rounded-lg"
                        >
                          <Badge className="text-base px-3 py-1">
                            {step.module}
                          </Badge>
                          <span className="text-base font-semibold">{step.action}</span>
                          <span className="text-base text-muted-foreground">
                            {JSON.stringify(step.params)}
                          </span>
                        </div>
                      ))}
                    </div>
                  </div>

                  <Button
                    onClick={handleStartWorkflow}
                    disabled={isGenerating}
                    size="lg"
                    className="text-base px-6 py-3"
                  >
                    {isGenerating ? (
                      <>
                        <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                        Starting...
                      </>
                    ) : (
                      <>
                        <Play className="mr-2 h-5 w-5" />
                        Start Workflow
                      </>
                    )}
                  </Button>
                </div>
              )}
            </CardContent>
          </Card>
        )}
      </div>
    </AdminLayout>
  );
}

