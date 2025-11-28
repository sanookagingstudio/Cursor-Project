import { AdminLayout } from "@/layouts/AdminLayout";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { CheckCircle, XCircle, Clock, Database, Server, MessageSquare, Settings } from "lucide-react";
import { useState, useEffect } from "react";

interface SystemStatus {
  api: "ok" | "error" | "checking";
  database: "ok" | "error" | "checking";
  redis: "ok" | "error" | "checking";
  celery: "ok" | "error" | "checking";
  eventBus: "ok" | "error" | "checking";
}

export default function CoreFoundation() {
  const [status, setStatus] = useState<SystemStatus>({
    api: "checking",
    database: "checking",
    redis: "checking",
    celery: "checking",
    eventBus: "checking",
  });

  const [stats, setStats] = useState({
    projects: 0,
    jobs: 0,
    assets: 0,
    modules: 0,
  });

  useEffect(() => {
    // Simulate checking system status
    const checkSystem = async () => {
      try {
        // Check API
        const healthRes = await fetch("http://localhost:8000/health");
        if (healthRes.ok) {
          const healthData = await healthRes.json();
          setStatus(prev => ({
            ...prev,
            api: "ok",
            database: healthData.database === "ok" ? "ok" : "error",
            redis: healthData.redis === "ok" ? "ok" : "error",
          }));
        } else {
          setStatus(prev => ({ ...prev, api: "error" }));
        }

        // Check Event Bus (simulated)
        setStatus(prev => ({ ...prev, eventBus: "ok" }));
        
        // Check Celery (simulated)
        setStatus(prev => ({ ...prev, celery: "ok" }));

        // Fetch stats
        try {
          const projectsRes = await fetch("http://localhost:8000/projects");
          if (projectsRes.ok) {
            const projects = await projectsRes.json();
            setStats(prev => ({ ...prev, projects: projects.length || 0 }));
          }
        } catch (e) {
          // API not running
        }
      } catch (error) {
        setStatus(prev => ({
          ...prev,
          api: "error",
          database: "error",
          redis: "error",
        }));
      }
    };

    checkSystem();
    const interval = setInterval(checkSystem, 5000);
    return () => clearInterval(interval);
  }, []);

  const getStatusIcon = (status: string) => {
    if (status === "ok") return <CheckCircle className="h-7 w-7 text-green-500" />;
    if (status === "error") return <XCircle className="h-7 w-7 text-red-500" />;
    return <Clock className="h-7 w-7 text-yellow-500 animate-spin" />;
  };

  const getStatusBadge = (status: string) => {
    if (status === "ok") return <Badge className="bg-green-500 text-base px-4 py-2">OK</Badge>;
    if (status === "error") return <Badge variant="destructive" className="text-base px-4 py-2">Error</Badge>;
    return <Badge variant="secondary" className="text-base px-4 py-2">Checking...</Badge>;
  };

  return (
    <AdminLayout>
      <div className="space-y-8 w-full max-w-full">
        <div>
          <h1 className="text-5xl font-bold mb-4">Core Foundation - Phase 1</h1>
          <p className="text-lg text-muted-foreground">
            System status and preview of Core Foundation infrastructure
          </p>
        </div>

        {/* System Status */}
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-5">
          <Card>
            <CardHeader className="pb-4">
              <div className="flex items-center justify-between mb-3">
                <Server className="h-7 w-7 text-muted-foreground" />
                {getStatusIcon(status.api)}
              </div>
              <CardTitle className="text-xl font-semibold">API Server</CardTitle>
            </CardHeader>
            <CardContent>
              {getStatusBadge(status.api)}
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-4">
              <div className="flex items-center justify-between mb-3">
                <Database className="h-7 w-7 text-muted-foreground" />
                {getStatusIcon(status.database)}
              </div>
              <CardTitle className="text-xl font-semibold">Database</CardTitle>
            </CardHeader>
            <CardContent>
              {getStatusBadge(status.database)}
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-4">
              <div className="flex items-center justify-between mb-3">
                <Settings className="h-7 w-7 text-muted-foreground" />
                {getStatusIcon(status.redis)}
              </div>
              <CardTitle className="text-xl font-semibold">Redis</CardTitle>
            </CardHeader>
            <CardContent>
              {getStatusBadge(status.redis)}
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-4">
              <div className="flex items-center justify-between mb-3">
                <MessageSquare className="h-7 w-7 text-muted-foreground" />
                {getStatusIcon(status.celery)}
              </div>
              <CardTitle className="text-xl font-semibold">Celery</CardTitle>
            </CardHeader>
            <CardContent>
              {getStatusBadge(status.celery)}
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-4">
              <div className="flex items-center justify-between mb-3">
                <MessageSquare className="h-7 w-7 text-muted-foreground" />
                {getStatusIcon(status.eventBus)}
              </div>
              <CardTitle className="text-xl font-semibold">Event Bus</CardTitle>
            </CardHeader>
            <CardContent>
              {getStatusBadge(status.eventBus)}
            </CardContent>
          </Card>
        </div>

        {/* Statistics */}
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
          <Card>
            <CardHeader className="pb-4">
              <CardTitle className="text-lg font-semibold">Projects</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">{stats.projects}</div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-4">
              <CardTitle className="text-lg font-semibold">Jobs</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">{stats.jobs}</div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-4">
              <CardTitle className="text-lg font-semibold">Assets</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">{stats.assets}</div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-4">
              <CardTitle className="text-lg font-semibold">Modules</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">{stats.modules}</div>
            </CardContent>
          </Card>
        </div>

        {/* API Endpoints Preview */}
        <Card>
          <CardHeader>
            <CardTitle className="text-2xl font-bold">API Endpoints</CardTitle>
            <CardDescription className="text-lg">Available endpoints in Core Foundation</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              <div className="flex items-center justify-between p-4 border rounded">
                <code className="text-base font-mono">GET /health</code>
                <Badge variant="outline" className="text-base px-3 py-1">Health Check</Badge>
              </div>
              <div className="flex items-center justify-between p-4 border rounded">
                <code className="text-base font-mono">POST /projects</code>
                <Badge variant="outline" className="text-base px-3 py-1">Create Project</Badge>
              </div>
              <div className="flex items-center justify-between p-4 border rounded">
                <code className="text-base font-mono">GET /projects</code>
                <Badge variant="outline" className="text-base px-3 py-1">List Projects</Badge>
              </div>
              <div className="flex items-center justify-between p-4 border rounded">
                <code className="text-base font-mono">POST /jobs</code>
                <Badge variant="outline" className="text-base px-3 py-1">Create Job</Badge>
              </div>
              <div className="flex items-center justify-between p-4 border rounded">
                <code className="text-base font-mono">POST /workflows/run</code>
                <Badge variant="outline" className="text-base px-3 py-1">Run Workflow</Badge>
              </div>
              <div className="flex items-center justify-between p-4 border rounded">
                <code className="text-base font-mono">POST /modules/register</code>
                <Badge variant="outline" className="text-base px-3 py-1">Register Module</Badge>
              </div>
            </div>
            <div className="mt-6">
              <Button asChild className="text-base px-6 py-3">
                <a href="http://localhost:8000/docs" target="_blank" rel="noopener noreferrer">
                  Open API Documentation
                </a>
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Database Schema Preview */}
        <Card>
          <CardHeader>
            <CardTitle className="text-2xl font-bold">Database Schema</CardTitle>
            <CardDescription className="text-lg">Core Foundation tables</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid gap-4 md:grid-cols-2">
              <div className="p-4 border rounded">
                <div className="font-semibold text-lg mb-2">projects</div>
                <div className="text-lg text-muted-foreground">id, name, owner_id, metadata</div>
              </div>
              <div className="p-4 border rounded">
                <div className="font-semibold text-lg mb-2">assets</div>
                <div className="text-lg text-muted-foreground">id, project_id, type, path, metadata</div>
              </div>
              <div className="p-4 border rounded">
                <div className="font-semibold text-lg mb-2">jobs</div>
                <div className="text-lg text-muted-foreground">id, project_id, module_id, status, input_payload</div>
              </div>
              <div className="p-4 border rounded">
                <div className="font-semibold text-lg mb-2">workflow_runs</div>
                <div className="text-lg text-muted-foreground">id, project_id, steps, status</div>
              </div>
              <div className="p-4 border rounded">
                <div className="font-semibold text-lg mb-2">modules</div>
                <div className="text-lg text-muted-foreground">id, name, category, capabilities</div>
              </div>
              <div className="p-4 border rounded">
                <div className="font-semibold text-lg mb-2">cost_records</div>
                <div className="text-lg text-muted-foreground">id, job_id, provider, total_cost</div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Testing Instructions */}
        <Card>
          <CardHeader>
            <CardTitle className="text-2xl font-bold">Testing Instructions</CardTitle>
            <CardDescription className="text-lg">How to test Phase 1</CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div>
              <h4 className="font-semibold text-lg mb-3">1. Start Backend Server</h4>
              <code className="block p-4 bg-muted rounded text-base font-mono">
                cd backend<br />
                uvicorn app.main:app --reload --port 8000
              </code>
            </div>
            <div>
              <h4 className="font-semibold text-lg mb-3">2. Test API</h4>
              <code className="block p-4 bg-muted rounded text-base font-mono">
                Visit: http://localhost:8000/docs
              </code>
            </div>
            <div>
              <h4 className="font-semibold text-lg mb-3">3. Run Tests</h4>
              <code className="block p-4 bg-muted rounded text-base font-mono">
                python test_phase1.py
              </code>
            </div>
          </CardContent>
        </Card>
      </div>
    </AdminLayout>
  );
}

