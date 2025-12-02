import { useState, useEffect } from "react";
import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogDescription, DialogFooter } from "@/components/ui/dialog";
import { ScrollArea } from "@/components/ui/scroll-area";
import { DataTable } from "@/components/tables/DataTable";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
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
  Footprints,
  PlusCircle,
  Thermometer,
  Weight,
  FileEdit
} from "lucide-react";
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

// Mock Data for Real-time Monitoring
const INITIAL_ACTIVE_CLIENTS = [
  { id: 1, name: "Somchai Jai-dee", age: 72, status: "Active", location: "Garden Zone A", hr: 78, spo2: 98, bp: "120/80", battery: 85, source: "device", lastUpdate: new Date().toISOString(), image: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?q=80&w=200&auto=format&fit=crop" },
  { id: 2, name: "Malee Rak-thai", age: 68, status: "Resting", location: "Lobby", hr: 65, spo2: 97, bp: "118/76", battery: 42, source: "device", lastUpdate: new Date().toISOString(), image: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&auto=format&fit=crop" },
  { id: 3, name: "John Smith", age: 75, status: "Walking", location: "Park Trail", hr: 92, spo2: 96, bp: "130/85", battery: 60, source: "device", lastUpdate: new Date().toISOString(), image: "https://images.unsplash.com/photo-1566616213894-2dcdcf0dfda6?q=80&w=200&auto=format&fit=crop" },
  { id: 4, name: "Arunee Sooksai", age: 80, status: "SOS", location: "Restroom 2", hr: 110, spo2: 94, bp: "145/90", battery: 15, alert: true, source: "device", lastUpdate: new Date().toISOString(), image: "https://images.unsplash.com/photo-1551185253-59878c711002?q=80&w=200&auto=format&fit=crop" },
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
  const [activeClients, setActiveClients] = useState(INITIAL_ACTIVE_CLIENTS);
  const [manualDialogOpen, setManualDialogOpen] = useState(false);

  // Manual Entry Form State
  const [manualEntry, setManualEntry] = useState({
    name: "",
    isParticipating: true,
    hr: "",
    spo2: "",
    bp: "",
    temp: "",
    weight: "",
    location: "Lobby",
    notes: ""
  });

  // Simulate real-time clock
  useEffect(() => {
    const timer = setInterval(() => setCurrentTime(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  const handleManualSubmit = () => {
    const newClient = {
      id: Date.now(),
      name: manualEntry.name || "New Guest",
      age: 70, // Default for mock
      status: manualEntry.isParticipating ? "Active (Manual)" : "Inactive",
      location: manualEntry.location,
      hr: parseInt(manualEntry.hr) || 0,
      spo2: parseInt(manualEntry.spo2) || 0,
      bp: manualEntry.bp || "-",
      source: "manual",
      lastUpdate: new Date().toISOString(),
      alert: false,
      battery: 0, // Manual entries don't have battery
      image: null // Default avatar
    };

    setActiveClients(prev => [newClient, ...prev]);
    setManualDialogOpen(false);
    // Reset form
    setManualEntry({
      name: "",
      isParticipating: true,
      hr: "",
      spo2: "",
      bp: "",
      temp: "",
      weight: "",
      location: "Lobby",
      notes: ""
    });
  };

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
                    <h3 className="text-3xl font-bold">{activeClients.length}</h3>
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
                    <h3 className="text-3xl font-bold text-red-700">{activeClients.filter(c => c.alert).length}</h3>
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
                    <h3 className="text-3xl font-bold">
                      {Math.round(activeClients.reduce((acc, curr) => acc + (curr.hr || 0), 0) / activeClients.length)} 
                      <span className="text-sm font-normal text-muted-foreground"> bpm</span>
                    </h3>
                  </div>
                  <div className="w-12 h-12 bg-rose-100 rounded-full flex items-center justify-center text-rose-600">
                    <Heart className="h-6 w-6" />
                  </div>
                </CardContent>
              </Card>
              <Card>
                <CardContent className="pt-6 flex items-center justify-between">
                  <div>
                    <p className="text-sm text-muted-foreground">Manual Entries</p>
                    <h3 className="text-3xl font-bold">
                      {activeClients.filter(c => c.source === 'manual').length}
                    </h3>
                  </div>
                  <div className="w-12 h-12 bg-orange-100 rounded-full flex items-center justify-center text-orange-600">
                    <FileEdit className="h-6 w-6" />
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
                {activeClients.filter(c => c.source === 'device').map((client, index) => (
                  <div 
                    key={client.id}
                    className={`absolute transform -translate-x-1/2 -translate-y-1/2 group-hover:scale-110 transition-transform cursor-pointer`}
                    style={{ 
                      top: `${30 + (index * 15)}%`, 
                      left: `${30 + (index * 20)}%` 
                    }}
                  >
                    <div className="relative">
                      <div className={`w-4 h-4 ${client.alert ? 'bg-red-500 animate-ping' : 'bg-blue-500'} rounded-full border-2 border-white shadow-lg`} />
                      <div className={`absolute -top-8 left-1/2 -translate-x-1/2 bg-white px-2 py-1 rounded text-xs font-bold shadow whitespace-nowrap ${client.alert ? 'text-red-600' : ''}`}>
                        {client.name}
                      </div>
                    </div>
                  </div>
                ))}

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
                  
                  {/* Manual Entry Dialog */}
                  <Dialog open={manualDialogOpen} onOpenChange={setManualDialogOpen}>
                    <DialogTrigger asChild>
                      <Button variant="outline" size="sm" className="gap-2">
                        <PlusCircle className="w-4 h-4" /> Manual Entry
                      </Button>
                    </DialogTrigger>
                    <DialogContent className="sm:max-w-[500px]">
                      <DialogHeader>
                        <DialogTitle>Manual Vitals Entry</DialogTitle>
                        <DialogDescription>
                          Record vital signs for clients without monitoring devices.
                        </DialogDescription>
                      </DialogHeader>
                      <div className="grid gap-4 py-4">
                        <div className="grid grid-cols-4 items-center gap-4">
                          <Label htmlFor="name" className="text-right">Client</Label>
                          <Input 
                            id="name" 
                            value={manualEntry.name}
                            onChange={(e) => setManualEntry({...manualEntry, name: e.target.value})}
                            placeholder="Select or type name"
                            className="col-span-3" 
                          />
                        </div>
                        
                        <div className="grid grid-cols-4 items-center gap-4">
                          <Label className="text-right">Status</Label>
                          <div className="col-span-3 flex items-center space-x-2">
                            <Switch 
                              id="participating" 
                              checked={manualEntry.isParticipating}
                              onCheckedChange={(checked) => setManualEntry({...manualEntry, isParticipating: checked})}
                            />
                            <Label htmlFor="participating">Participating in Activity today?</Label>
                          </div>
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                          <div className="space-y-2">
                            <Label>Heart Rate (bpm)</Label>
                            <div className="relative">
                              <Heart className="absolute left-2 top-2.5 h-4 w-4 text-rose-500" />
                              <Input 
                                type="number" 
                                className="pl-8" 
                                value={manualEntry.hr}
                                onChange={(e) => setManualEntry({...manualEntry, hr: e.target.value})}
                              />
                            </div>
                          </div>
                          <div className="space-y-2">
                            <Label>Blood Pressure</Label>
                            <div className="relative">
                              <Activity className="absolute left-2 top-2.5 h-4 w-4 text-blue-500" />
                              <Input 
                                placeholder="120/80" 
                                className="pl-8"
                                value={manualEntry.bp}
                                onChange={(e) => setManualEntry({...manualEntry, bp: e.target.value})}
                              />
                            </div>
                          </div>
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                          <div className="space-y-2">
                            <Label>SpO2 (%)</Label>
                            <div className="relative">
                              <Activity className="absolute left-2 top-2.5 h-4 w-4 text-cyan-500" />
                              <Input 
                                type="number" 
                                className="pl-8"
                                value={manualEntry.spo2}
                                onChange={(e) => setManualEntry({...manualEntry, spo2: e.target.value})}
                              />
                            </div>
                          </div>
                          <div className="space-y-2">
                            <Label>Temp (°C)</Label>
                            <div className="relative">
                              <Thermometer className="absolute left-2 top-2.5 h-4 w-4 text-orange-500" />
                              <Input 
                                type="number" 
                                className="pl-8"
                                value={manualEntry.temp}
                                onChange={(e) => setManualEntry({...manualEntry, temp: e.target.value})}
                              />
                            </div>
                          </div>
                        </div>

                        <div className="grid grid-cols-4 items-center gap-4">
                          <Label className="text-right">Weight (kg)</Label>
                          <div className="col-span-3 relative">
                            <Weight className="absolute left-2 top-2.5 h-4 w-4 text-slate-500" />
                            <Input 
                              type="number" 
                              className="pl-8"
                              value={manualEntry.weight}
                              onChange={(e) => setManualEntry({...manualEntry, weight: e.target.value})}
                            />
                          </div>
                        </div>

                        <div className="grid grid-cols-4 items-center gap-4">
                          <Label className="text-right">Location</Label>
                          <Select 
                            value={manualEntry.location}
                            onValueChange={(v) => setManualEntry({...manualEntry, location: v})}
                          >
                            <SelectTrigger className="col-span-3">
                              <SelectValue placeholder="Select location" />
                            </SelectTrigger>
                            <SelectContent>
                              <SelectItem value="Lobby">Lobby</SelectItem>
                              <SelectItem value="Garden Zone A">Garden Zone A</SelectItem>
                              <SelectItem value="Park Trail">Park Trail</SelectItem>
                              <SelectItem value="Activity Room">Activity Room</SelectItem>
                            </SelectContent>
                          </Select>
                        </div>
                      </div>
                      <DialogFooter>
                        <Button variant="outline" onClick={() => setManualDialogOpen(false)}>Cancel</Button>
                        <Button onClick={handleManualSubmit}>Save Entry</Button>
                      </DialogFooter>
                    </DialogContent>
                  </Dialog>
                </div>
                <ScrollArea className="flex-1 p-4">
                  <div className="space-y-4">
                    {activeClients.map((client) => (
                      <Dialog key={client.id}>
                        <DialogTrigger asChild>
                          <div 
                            className={`p-4 rounded-xl border cursor-pointer transition-all hover:shadow-md relative overflow-hidden
                              ${client.alert ? 'bg-red-50 border-red-200 ring-2 ring-red-100' : 'bg-white hover:border-primary/50'}
                              ${client.source === 'manual' ? 'border-l-4 border-l-orange-400' : ''}
                            `}
                            onClick={() => setSelectedClient(client)}
                          >
                            {/* Manual Indicator */}
                            {client.source === 'manual' && (
                              <div className="absolute top-0 right-0 bg-orange-100 text-orange-700 text-[10px] px-2 py-0.5 rounded-bl">
                                Manual Entry
                              </div>
                            )}

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
                                {client.source === 'manual' ? (
                                  <>
                                    <div className="text-xs text-muted-foreground mb-1 flex items-center justify-center gap-1">
                                      <History className="w-3 h-3 text-slate-500" /> Updated
                                    </div>
                                    <div className="font-mono text-xs font-medium pt-1">
                                      {new Date(client.lastUpdate).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}
                                    </div>
                                  </>
                                ) : (
                                  <>
                                    <div className="text-xs text-muted-foreground mb-1 flex items-center justify-center gap-1">
                                      <Battery className={`w-3 h-3 ${client.battery < 20 ? 'text-red-500' : 'text-green-500'}`} /> Bat
                                    </div>
                                    <div className="font-mono font-bold text-lg">{client.battery}%</div>
                                  </>
                                )}
                              </div>
                            </div>
                          </div>
                        </DialogTrigger>
                        <DialogContent className="max-w-2xl">
                          <DialogHeader>
                            <DialogTitle className="text-2xl flex items-center gap-3">
                              {client.name}
                              {client.alert && <Badge variant="destructive">Emergency Alert</Badge>}
                              {client.source === 'manual' && <Badge variant="outline" className="bg-orange-50 text-orange-700 border-orange-200">Manual Data</Badge>}
                            </DialogTitle>
                            <DialogDescription>
                              Client ID: #{client.id.toString().padStart(4, '0')} • Age: {client.age}
                              {client.source === 'manual' && (
                                <span className="block mt-1 text-xs text-muted-foreground">
                                  Last Manual Check: {new Date(client.lastUpdate).toLocaleString()}
                                </span>
                              )}
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
