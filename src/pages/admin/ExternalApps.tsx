import { AdminLayout } from "@/layouts/AdminLayout";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { 
  Smartphone,
  Monitor,
  Globe,
  Key,
  BarChart3,
  Loader2,
  Plus
} from "lucide-react";
import { useState, useEffect } from "react";
import { useToast } from "@/components/ui/use-toast";

interface ExternalApp {
  id: string;
  name: string;
  description: string;
  app_type: string;
  app_url: string;
  app_identifier: string;
  status: string;
  pricing_model: string;
  created_at: string;
}

interface APIKey {
  id: string;
  app_id: string;
  key_prefix: string;
  name: string;
  scopes: string[];
  rate_limit: number;
  status: string;
  created_at: string;
}

export default function ExternalApps() {
  const { toast } = useToast();
  const [loading, setLoading] = useState(true);
  const [apps, setApps] = useState<ExternalApp[]>([]);
  const [selectedApp, setSelectedApp] = useState<ExternalApp | null>(null);
  const [apiKeys, setApiKeys] = useState<APIKey[]>([]);
  const [activeTab, setActiveTab] = useState("apps");

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      
      const appsRes = await fetch("/api/external-apps/apps");
      if (appsRes.ok) {
        const data = await appsRes.json();
        setApps(data);
        if (data.length > 0 && !selectedApp) {
          setSelectedApp(data[0]);
        }
      }
    } catch (error) {
      console.error("Error loading external apps:", error);
      toast({
        title: "Error",
        description: "Failed to load external apps",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const loadApiKeys = async (appId: string) => {
    try {
      const keysRes = await fetch(`/api/external-apps/apps/${appId}/api-keys`);
      if (keysRes.ok) {
        const data = await keysRes.json();
        setApiKeys(data);
      }
    } catch (error) {
      console.error("Error loading API keys:", error);
    }
  };

  useEffect(() => {
    if (selectedApp) {
      loadApiKeys(selectedApp.id);
    }
  }, [selectedApp]);

  if (loading) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center min-h-screen">
          <Loader2 className="h-8 w-8 animate-spin" />
        </div>
      </AdminLayout>
    );
  }

  const getAppTypeIcon = (type: string) => {
    switch (type) {
      case "mobile":
        return Smartphone;
      case "desktop":
        return Monitor;
      case "web":
        return Globe;
      default:
        return Globe;
    }
  };

  return (
    <AdminLayout>
      <div className="container-padding space-y-6">
        <div>
          <h1 className="text-5xl font-bold mb-2">External Applications</h1>
          <p className="text-2xl text-muted-foreground">
            Manage standalone applications that connect to Master V2 via API
          </p>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Total Apps</CardTitle>
              <Globe className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">{apps.length}</div>
              <p className="text-base text-muted-foreground mt-1">
                Registered applications
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Active Apps</CardTitle>
              <Globe className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">
                {apps.filter(a => a.status === "active").length}
              </div>
              <p className="text-base text-muted-foreground mt-1">
                Currently active
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">API Keys</CardTitle>
              <Key className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">{apiKeys.length}</div>
              <p className="text-base text-muted-foreground mt-1">
                Generated keys
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Usage</CardTitle>
              <BarChart3 className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">-</div>
              <p className="text-base text-muted-foreground mt-1">
                API requests
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Main Content Tabs */}
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-3 text-base">
            <TabsTrigger value="apps" className="text-base">
              Applications
            </TabsTrigger>
            <TabsTrigger value="api-keys" className="text-base">
              API Keys
            </TabsTrigger>
            <TabsTrigger value="usage" className="text-base">
              Usage
            </TabsTrigger>
          </TabsList>

          {/* Applications Tab */}
          <TabsContent value="apps" className="space-y-4">
            <Card>
              <CardHeader>
                <div className="flex justify-between items-center">
                  <div>
                    <CardTitle className="text-2xl font-bold">External Applications</CardTitle>
                    <CardDescription className="text-lg">Manage registered applications</CardDescription>
                  </div>
                  <Button>
                    <Plus className="mr-2 h-4 w-4" />
                    Register New App
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {apps.map((app) => {
                    const Icon = getAppTypeIcon(app.app_type);
                    return (
                      <Card key={app.id} className="cursor-pointer hover:bg-accent" onClick={() => setSelectedApp(app)}>
                        <CardContent className="p-4">
                          <div className="flex items-center justify-between">
                            <div className="flex items-center gap-4">
                              <Icon className="h-8 w-8" />
                              <div>
                                <div className="text-xl font-bold">{app.name}</div>
                                <div className="text-base text-muted-foreground">{app.description || app.app_type}</div>
                                <div className="text-sm text-muted-foreground mt-1">
                                  {app.app_identifier} • {app.status}
                                </div>
                              </div>
                            </div>
                            <div className="text-right">
                              <div className="text-base font-semibold capitalize">{app.pricing_model || "free"}</div>
                            </div>
                          </div>
                        </CardContent>
                      </Card>
                    );
                  })}
                  {apps.length === 0 && (
                    <p className="text-base text-muted-foreground text-center py-8">
                      No external applications registered yet
                    </p>
                  )}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* API Keys Tab */}
          <TabsContent value="api-keys" className="space-y-4">
            <Card>
              <CardHeader>
                <div className="flex justify-between items-center">
                  <div>
                    <CardTitle className="text-2xl font-bold">API Keys</CardTitle>
                    <CardDescription className="text-lg">
                      {selectedApp ? `API keys for ${selectedApp.name}` : "Select an application to view API keys"}
                    </CardDescription>
                  </div>
                  {selectedApp && (
                    <Button>
                      <Plus className="mr-2 h-4 w-4" />
                      Generate New Key
                    </Button>
                  )}
                </div>
              </CardHeader>
              <CardContent>
                {selectedApp ? (
                  <div className="space-y-4">
                    {apiKeys.map((key) => (
                      <Card key={key.id}>
                        <CardContent className="p-4">
                          <div className="flex items-center justify-between">
                            <div>
                              <div className="text-lg font-bold">{key.name || "Unnamed Key"}</div>
                              <div className="text-base text-muted-foreground mt-1">
                                {key.key_prefix}...
                              </div>
                              <div className="text-sm text-muted-foreground mt-1">
                                Scopes: {key.scopes.join(", ") || "None"} • Rate Limit: {key.rate_limit}/hour
                              </div>
                            </div>
                            <div className="text-right">
                              <div className="text-base font-semibold capitalize">{key.status}</div>
                              <Button variant="destructive" size="sm" className="mt-2">
                                Revoke
                              </Button>
                            </div>
                          </div>
                        </CardContent>
                      </Card>
                    ))}
                    {apiKeys.length === 0 && (
                      <p className="text-base text-muted-foreground text-center py-8">
                        No API keys generated yet
                      </p>
                    )}
                  </div>
                ) : (
                  <p className="text-base text-muted-foreground text-center py-8">
                    Please select an application first
                  </p>
                )}
              </CardContent>
            </Card>
          </TabsContent>

          {/* Usage Tab */}
          <TabsContent value="usage" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Usage Statistics</CardTitle>
                <CardDescription className="text-lg">
                  {selectedApp ? `Usage for ${selectedApp.name}` : "Select an application to view usage"}
                </CardDescription>
              </CardHeader>
              <CardContent>
                {selectedApp ? (
                  <p className="text-base text-muted-foreground">Usage statistics will be displayed here</p>
                ) : (
                  <p className="text-base text-muted-foreground text-center py-8">
                    Please select an application first
                  </p>
                )}
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </AdminLayout>
  );
}

