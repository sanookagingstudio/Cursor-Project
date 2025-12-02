import { useState, useEffect } from "react";
import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogDescription } from "@/components/ui/dialog";
import { ScrollArea } from "@/components/ui/scroll-area";
import { DataTable } from "@/components/tables/DataTable";
import { 
  Heart, 
  Activity, 
  MapPin, 
  AlertTriangle, 
  Battery, 
  History, 
  Pill, 
  Brain, 
  Phone,
  User,
  RefreshCw,
  Filter,
  Footprints
} from "lucide-react";
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

// Mock Data for Real-time Monitoring
const ACTIVE_CLIENTS = [
  { id: 1, name: "Somchai Jai-dee", age: 72, status: "Active", location: "Garden Zone A", hr: 78, spo2: 98, bp: "120/80", battery: 85, image: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?q=80&w=200&auto=format&fit=crop" },
  { id: 2, name: "Malee Rak-thai", age: 68, status: "Resting", location: "Lobby", hr: 65, spo2: 97, bp: "118/76", battery: 42, image: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&auto=format&fit=crop" },
  { id: 3, name: "John Smith", age: 75, status: "Walking", location: "Park Trail", hr: 92, spo2: 96, bp: "130/85", battery: 60, image: "https://images.unsplash.com/photo-1566616213894-2dcdcf0dfda6?q=80&w=200&auto=format&fit=crop" },
  { id: 4, name: "Arunee Sooksai", age: 80, status: "SOS", location: "Restroom 2", hr: 110, spo2: 94, bp: "145/90", battery: 15, alert: true, image: "https://images.unsplash.com/photo-1551185253-59878c711002?q=80&w=200&auto=format&fit=crop" },
];

// Mock Historical Data for Charts
const HISTORY_DATA = [
  { time: '08:00', hr: 65 },
  { time: '09:00', hr: 72 },
  { time: '10:00', hr: 85 },
  { time: '11:00', hr: 78 },
  { time: '12:00', hr: 90 }, // Activity peak
  { time: '13:00', hr: 70 },
  { time: '14:00', hr: 68 },
];

export default function ClientMonitoring() {
  const [activeTab, setActiveTab] = useState("dashboard");
  const [selectedClient, setSelectedClient] = useState<any>(null);
  const [currentTime, setCurrentTime] = useState(new Date());

  // Simulate real-time clock
  useEffect(() => {
    const timer = setInterval(() => setCurrentTime(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  return (
    <AdminLayout>
      <div className="flex flex-col space-y-6">
        <div className="flex justify-between items-start">
          <SectionHeader
            title="Smart Client Monitoring"
            description="Real-time health tracking, location services, and AI-powered care insights."
          />
          <div className="flex items-center gap-2 bg-white p-2 rounded-lg shadow-sm border">
            <Badge variant="outline" className="animate-pulse bg-green-50 text-green-700 border-green-200">
              <div className="w-2 h-2 bg-green-500 rounded-full mr-2" />
              System Online
            </Badge>
            <div className="text-sm font-mono text-muted-foreground">
              {currentTime.toLocaleTimeString()}
            </div>
          </div>
        </div>

        <Tabs defaultValue="dashboard" className="space-y-6" onValueChange={setActiveTab}>
          <TabsList className="grid w-full grid-cols-2 max-w-[400px]">
            <TabsTrigger value="dashboard">Real-time Dashboard</TabsTrigger>
            <TabsTrigger value="directory">Client Directory</TabsTrigger>
          </TabsList>

          {/* Real-time Dashboard View */}
          <TabsContent value="dashboard" className="space-y-6">
            {/* Stats Overview */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <Card>
                <CardContent className="pt-6 flex items-center justify-between">
                  <div>
                    <p className="text-sm text-muted-foreground">Active Clients</p>
                    <h3 className="text-3xl font-bold">24</h3>
                  </div>
                  <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center text-blue-600">
                    <User className="h-6 w-6" />
                  </div>
                </CardContent>
              </Card>
              <Card className="bg-red-50 border-red-200">
                <CardContent className="pt-6 flex items-center justify-between">
                  <div>
                    <p className="text-sm text-red-600 font-medium">Active Alerts</p>
                    <h3 className="text-3xl font-bold text-red-700">1</h3>
                  </div>
                  <div className="w-12 h-12 bg-red-200 rounded-full flex items-center justify-center text-red-600 animate-pulse">
                    <AlertTriangle className="h-6 w-6" />
                  </div>
                </CardContent>
              </Card>
              <Card>
                <CardContent className="pt-6 flex items-center justify-between">
                  <div>
                    <p className="text-sm text-muted-foreground">Avg. Heart Rate</p>
                    <h3 className="text-3xl font-bold">76 <span className="text-sm font-normal text-muted-foreground">bpm</span></h3>
                  </div>
                  <div className="w-12 h-12 bg-rose-100 rounded-full flex items-center justify-center text-rose-600">
                    <Heart className="h-6 w-6" />
                  </div>
                </CardContent>
              </Card>
              <Card>
                <CardContent className="pt-6 flex items-center justify-between">
                  <div>
                    <p className="text-sm text-muted-foreground">Avg. Activity</p>
                    <h3 className="text-3xl font-bold">4.2k <span className="text-sm font-normal text-muted-foreground">steps</span></h3>
                  </div>
                  <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center text-green-600">
                    <Footprints className="h-6 w-6" />
                  </div>
                </CardContent>
              </Card>
            </div>

            <div className="grid lg:grid-cols-3 gap-6 h-[600px]">
              {/* Map Simulation Section */}
              <div className="lg:col-span-2 bg-slate-100 rounded-xl border relative overflow-hidden group">
                <div className="absolute inset-0 flex items-center justify-center opacity-10 pointer-events-none">
                  {/* Placeholder for Map - In production this would be Google Maps / Leaflet */}
                  <MapPin className="w-96 h-96" />
                </div>
                
                {/* Simulated Map Markers */}
                <div className="absolute top-1/4 left-1/4 transform -translate-x-1/2 -translate-y-1/2 group-hover:scale-110 transition-transform cursor-pointer">
                  <div className="relative">
                    <div className="w-4 h-4 bg-blue-500 rounded-full border-2 border-white shadow-lg" />
                    <div className="absolute -top-8 left-1/2 -translate-x-1/2 bg-white px-2 py-1 rounded text-xs font-bold shadow whitespace-nowrap">Somchai</div>
                  </div>
                </div>
                <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 group-hover:scale-110 transition-transform cursor-pointer">
                  <div className="relative">
                    <div className="w-4 h-4 bg-green-500 rounded-full border-2 border-white shadow-lg" />
                    <div className="absolute -top-8 left-1/2 -translate-x-1/2 bg-white px-2 py-1 rounded text-xs font-bold shadow whitespace-nowrap">John</div>
                  </div>
                </div>
                {/* SOS Marker */}
                <div className="absolute bottom-1/3 right-1/3 transform -translate-x-1/2 -translate-y-1/2 animate-bounce cursor-pointer">
                  <div className="relative">
                    <div className="w-6 h-6 bg-red-500 rounded-full border-2 border-white shadow-lg flex items-center justify-center">
                      <AlertTriangle className="w-3 h-3 text-white" />
                    </div>
                    <span className="absolute -top-1 -right-1 flex h-3 w-3">
                      <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                      <span className="relative inline-flex rounded-full h-3 w-3 bg-red-500"></span>
                    </span>
                    <div className="absolute -top-8 left-1/2 -translate-x-1/2 bg-red-600 text-white px-2 py-1 rounded text-xs font-bold shadow whitespace-nowrap">SOS: Arunee</div>
                  </div>
                </div>

                <div className="absolute top-4 right-4 bg-white/90 backdrop-blur p-4 rounded-lg shadow border text-sm">
                  <h4 className="font-bold mb-2 flex items-center"><MapPin className="w-4 h-4 mr-2" /> Location Status</h4>
                  <ul className="space-y-1">
                    <li className="flex items-center text-green-600"><span className="w-2 h-2 bg-green-500 rounded-full mr-2" /> Safe Zone: 20</li>
                    <li className="flex items-center text-yellow-600"><span className="w-2 h-2 bg-yellow-500 rounded-full mr-2" /> Warning Area: 3</li>
                    <li className="flex items-center text-red-600"><span className="w-2 h-2 bg-red-500 rounded-full mr-2" /> Out of Bounds: 1</li>
                  </ul>
                </div>
              </div>

              {/* Active Clients List */}
              <div className="lg:col-span-1 bg-white rounded-xl border flex flex-col h-full">
                <div className="p-4 border-b flex items-center justify-between bg-slate-50 rounded-t-xl">
                  <h3 className="font-semibold flex items-center gap-2">
                    <Activity className="w-4 h-4 text-primary" />
                    Live Feeds
                  </h3>
                  <Button variant="ghost" size="icon" className="h-8 w-8">
                    <RefreshCw className="w-4 h-4" />
                  </Button>
                </div>
                <ScrollArea className="flex-1 p-4">
                  <div className="space-y-4">
                    {ACTIVE_CLIENTS.map((client) => (
                      <Dialog key={client.id}>
                        <DialogTrigger asChild>
                          <div 
                            className={`p-4 rounded-xl border cursor-pointer transition-all hover:shadow-md ${client.alert ? 'bg-red-50 border-red-200 ring-2 ring-red-100' : 'bg-white hover:border-primary/50'}`}
                            onClick={() => setSelectedClient(client)}
                          >
                            <div className="flex items-center gap-3 mb-3">
                              <Avatar>
                                <AvatarImage src={client.image} />
                                <AvatarFallback>{client.name.charAt(0)}</AvatarFallback>
                              </Avatar>
                              <div>
                                <div className="font-bold text-sm">{client.name}</div>
                                <div className="text-xs text-muted-foreground flex items-center gap-1">
                                  <MapPin className="w-3 h-3" /> {client.location}
                                </div>
                              </div>
                              {client.alert && (
                                <Badge variant="destructive" className="ml-auto animate-pulse">SOS</Badge>
                              )}
                            </div>
                            
                            <div className="grid grid-cols-3 gap-2 text-center">
                              <div className="bg-slate-50 p-2 rounded-lg">
                                <div className="text-xs text-muted-foreground mb-1 flex items-center justify-center gap-1">
                                  <Heart className="w-3 h-3 text-rose-500" /> HR
                                </div>
                                <div className="font-mono font-bold text-lg">{client.hr}</div>
                              </div>
                              <div className="bg-slate-50 p-2 rounded-lg">
                                <div className="text-xs text-muted-foreground mb-1 flex items-center justify-center gap-1">
                                  <Activity className="w-3 h-3 text-blue-500" /> SpO2
                                </div>
                                <div className="font-mono font-bold text-lg">{client.spo2}%</div>
                              </div>
                              <div className="bg-slate-50 p-2 rounded-lg">
                                <div className="text-xs text-muted-foreground mb-1 flex items-center justify-center gap-1">
                                  <Battery className={`w-3 h-3 ${client.battery < 20 ? 'text-red-500' : 'text-green-500'}`} /> Bat
                                </div>
                                <div className="font-mono font-bold text-lg">{client.battery}%</div>
                              </div>
                            </div>
                          </div>
                        </DialogTrigger>
                        <DialogContent className="max-w-2xl">
                          <DialogHeader>
                            <DialogTitle className="text-2xl flex items-center gap-3">
                              {client.name}
                              {client.alert && <Badge variant="destructive">Emergency Alert</Badge>}
                            </DialogTitle>
                            <DialogDescription>
                              Client ID: #{client.id.toString().padStart(4, '0')} • Age: {client.age}
                            </DialogDescription>
                          </DialogHeader>
                          
                          <div className="grid md:grid-cols-2 gap-6 mt-4">
                            <div className="space-y-6">
                              {/* Vitals Chart */}
                              <div className="space-y-2">
                                <h4 className="font-semibold flex items-center gap-2"><History className="w-4 h-4" /> Heart Rate History (Today)</h4>
                                <div className="h-[200px] w-full bg-slate-50 rounded-lg border p-2">
                                  <ResponsiveContainer width="100%" height="100%">
                                    <AreaChart data={HISTORY_DATA}>
                                      <CartesianGrid strokeDasharray="3 3" vertical={false} />
                                      <XAxis dataKey="time" fontSize={12} tickLine={false} axisLine={false} />
                                      <YAxis domain={[50, 120]} fontSize={12} tickLine={false} axisLine={false} />
                                      <Tooltip />
                                      <Area type="monotone" dataKey="hr" stroke="#F36F21" fill="#F36F21" fillOpacity={0.2} />
                                    </AreaChart>
                                  </ResponsiveContainer>
                                </div>
                              </div>

                              {/* AI Insights */}
                              <div className="bg-indigo-50 border border-indigo-100 p-4 rounded-lg">
                                <h4 className="font-semibold text-indigo-900 flex items-center gap-2 mb-2">
                                  <Brain className="w-4 h-4" /> AI Care Insights
                                </h4>
                                <ul className="text-sm text-indigo-800 space-y-2 list-disc pl-4">
                                  <li>Heart rate elevated slightly above average during morning walk.</li>
                                  <li>Sleep quality index dropped 15% last night - Monitor for fatigue.</li>
                                  <li>Hydration alert: Recommended to drink water in the next 30 mins.</li>
                                </ul>
                              </div>
                            </div>

                            <div className="space-y-6">
                              {/* Medication */}
                              <div className="space-y-3">
                                <h4 className="font-semibold flex items-center gap-2"><Pill className="w-4 h-4" /> Medication Schedule</h4>
                                <div className="space-y-2">
                                  <div className="flex items-center justify-between p-3 bg-green-50 border border-green-100 rounded-lg">
                                    <div className="flex items-center gap-3">
                                      <div className="w-8 h-8 bg-green-200 rounded-full flex items-center justify-center text-green-700">
                                        <CheckIcon />
                                      </div>
                                      <div>
                                        <div className="font-medium text-sm">Blood Pressure Med</div>
                                        <div className="text-xs text-muted-foreground">08:00 AM - Taken</div>
                                      </div>
                                    </div>
                                  </div>
                                  <div className="flex items-center justify-between p-3 bg-white border rounded-lg opacity-60">
                                    <div className="flex items-center gap-3">
                                      <div className="w-8 h-8 bg-slate-100 rounded-full flex items-center justify-center text-slate-500">
                                        <span className="text-xs font-bold">12:00</span>
                                      </div>
                                      <div>
                                        <div className="font-medium text-sm">Vitamin Supplement</div>
                                        <div className="text-xs text-muted-foreground">Scheduled</div>
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>

                              {/* Emergency Actions */}
                              <div className="space-y-3 pt-4 border-t">
                                <Button className="w-full bg-red-600 hover:bg-red-700 text-white" size="lg">
                                  <AlertTriangle className="mr-2 h-4 w-4" /> Initiate Emergency Protocol
                                </Button>
                                <div className="grid grid-cols-2 gap-3">
                                  <Button variant="outline" className="w-full">
                                    <Phone className="mr-2 h-4 w-4" /> Call Family
                                  </Button>
                                  <Button variant="outline" className="w-full">
                                    <User className="mr-2 h-4 w-4" /> View Full Profile
                                  </Button>
                                </div>
                              </div>
                            </div>
                          </div>
                        </DialogContent>
                      </Dialog>
                    ))}
                  </div>
                </ScrollArea>
              </div>
            </div>
          </TabsContent>

          {/* Directory View */}
          <TabsContent value="directory">
            <div className="bg-white p-6 rounded-lg border shadow-sm">
              <div className="flex justify-between items-center mb-6">
                <div className="relative w-72">
                  <Filter className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                  <input 
                    type="text" 
                    placeholder="Filter clients..." 
                    className="pl-9 pr-4 py-2 border rounded-md w-full text-sm"
                  />
                </div>
                <Button>
                  <User className="mr-2 h-4 w-4" /> Add New Client
                </Button>
              </div>
              <DataTable 
                columns={[
                  { key: "name", label: "Client Name" },
                  { key: "age", label: "Age" },
                  { key: "mobility", label: "Mobility" },
                  { key: "condition", label: "Conditions" },
                  { key: "last_check", label: "Last Check-up" },
                  { key: "status", label: "Status" },
                ]} 
                data={[
                  { name: "Somchai Jai-dee", age: 72, mobility: "Independent", condition: "Hypertension", last_check: "Today", status: "Active" },
                  { name: "Malee Rak-thai", age: 68, mobility: "Walking Stick", condition: "Diabetes", last_check: "Today", status: "Active" },
                  { name: "Alice Brown", age: 75, mobility: "Wheelchair", condition: "Dementia (Early)", last_check: "Yesterday", status: "Inactive" },
                ]} 
              />
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </AdminLayout>
  );
}

function CheckIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
      <polyline points="20 6 9 17 4 12" />
    </svg>
  )
}
