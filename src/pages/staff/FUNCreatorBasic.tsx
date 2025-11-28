import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Badge } from "@/components/ui/badge";
import { 
  Sparkles, 
  FileText, 
  Calendar, 
  Users, 
  Image, 
  Video,
  Plus,
  Save,
  Eye,
  Wand2
} from "lucide-react";
import { useState } from "react";

export default function FUNCreatorBasic() {
  const [contentType, setContentType] = useState("activity");

  return (
    <AdminLayout>
      <div className="space-y-6">
        <SectionHeader
          title="FUN Creator Basic"
          description="Create activities, content, and events for members"
        />

        <Tabs value={contentType} onValueChange={setContentType} className="space-y-6">
          <TabsList className="grid w-full grid-cols-4">
            <TabsTrigger value="activity">
              <Calendar className="h-4 w-4 mr-2" />
              Activity
            </TabsTrigger>
            <TabsTrigger value="trip">
              <Users className="h-4 w-4 mr-2" />
              Trip
            </TabsTrigger>
            <TabsTrigger value="content">
              <FileText className="h-4 w-4 mr-2" />
              Content
            </TabsTrigger>
            <TabsTrigger value="media">
              <Video className="h-4 w-4 mr-2" />
              Media
            </TabsTrigger>
          </TabsList>

          {/* Create Activity */}
          <TabsContent value="activity" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Sparkles className="h-5 w-5" />
                  Create New Activity
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid md:grid-cols-2 gap-4">
                  <div>
                    <Label htmlFor="activityName">Activity Name</Label>
                    <Input id="activityName" placeholder="e.g., Morning Yoga" />
                  </div>
                  <div>
                    <Label htmlFor="activityCategory">Category</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select category" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="wellness">Wellness</SelectItem>
                        <SelectItem value="creative">Creative</SelectItem>
                        <SelectItem value="social">Social</SelectItem>
                        <SelectItem value="cognitive">Cognitive</SelectItem>
                        <SelectItem value="outdoor">Outdoor</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div>
                  <Label htmlFor="description">Description</Label>
                  <Textarea 
                    id="description" 
                    placeholder="Describe the activity..."
                    className="min-h-24"
                  />
                </div>

                <div className="grid md:grid-cols-3 gap-4">
                  <div>
                    <Label htmlFor="schedule">Schedule</Label>
                    <Input id="schedule" type="datetime-local" />
                  </div>
                  <div>
                    <Label htmlFor="duration">Duration (hours)</Label>
                    <Input id="duration" type="number" placeholder="1.5" />
                  </div>
                  <div>
                    <Label htmlFor="capacity">Max Capacity</Label>
                    <Input id="capacity" type="number" placeholder="20" />
                  </div>
                </div>

                <div className="grid md:grid-cols-2 gap-4">
                  <div>
                    <Label htmlFor="intensity">Intensity Level</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select intensity" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="low">Low</SelectItem>
                        <SelectItem value="medium">Medium</SelectItem>
                        <SelectItem value="high">High</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div>
                    <Label htmlFor="instructor">Instructor</Label>
                    <Input id="instructor" placeholder="Instructor name" />
                  </div>
                </div>

                <div>
                  <Label htmlFor="image">Cover Image</Label>
                  <Input id="image" type="file" accept="image/*" />
                </div>

                <div className="flex gap-2">
                  <Button className="flex-1">
                    <Save className="h-4 w-4 mr-2" />
                    Save Activity
                  </Button>
                  <Button variant="outline">
                    <Eye className="h-4 w-4 mr-2" />
                    Preview
                  </Button>
                  <Button variant="secondary">
                    <Wand2 className="h-4 w-4 mr-2" />
                    AI Enhance
                  </Button>
                </div>
              </CardContent>
            </Card>

            {/* Recent Activities */}
            <Card>
              <CardHeader>
                <CardTitle>Recent Activities</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {[
                    { name: "Morning Exercise", date: "Every Mon & Wed, 8:00 AM", status: "active" },
                    { name: "Art & Craft", date: "Tue & Thu, 2:00 PM", status: "active" },
                    { name: "Brain Games", date: "Friday, 10:00 AM", status: "draft" },
                  ].map((activity, idx) => (
                    <div key={idx} className="flex items-center justify-between p-3 border rounded-lg">
                      <div>
                        <p className="font-medium">{activity.name}</p>
                        <p className="text-sm text-muted-foreground">{activity.date}</p>
                      </div>
                      <div className="flex items-center gap-2">
                        <Badge variant={activity.status === "active" ? "default" : "secondary"}>
                          {activity.status}
                        </Badge>
                        <Button variant="ghost" size="sm">Edit</Button>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Create Trip */}
          <TabsContent value="trip" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Sparkles className="h-5 w-5" />
                  Create New Trip
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid md:grid-cols-2 gap-4">
                  <div>
                    <Label htmlFor="tripName">Trip Name</Label>
                    <Input id="tripName" placeholder="e.g., Ayutthaya Heritage" />
                  </div>
                  <div>
                    <Label htmlFor="destination">Destination</Label>
                    <Input id="destination" placeholder="Location" />
                  </div>
                </div>

                <div>
                  <Label htmlFor="tripDescription">Description</Label>
                  <Textarea 
                    id="tripDescription" 
                    placeholder="Describe the trip itinerary..."
                    className="min-h-24"
                  />
                </div>

                <div className="grid md:grid-cols-3 gap-4">
                  <div>
                    <Label htmlFor="tripDate">Trip Date</Label>
                    <Input id="tripDate" type="date" />
                  </div>
                  <div>
                    <Label htmlFor="tripDuration">Duration</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="half">Half Day</SelectItem>
                        <SelectItem value="full">Full Day</SelectItem>
                        <SelectItem value="2days">2 Days</SelectItem>
                        <SelectItem value="3days">3+ Days</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div>
                    <Label htmlFor="tripCapacity">Max Participants</Label>
                    <Input id="tripCapacity" type="number" placeholder="30" />
                  </div>
                </div>

                <div className="grid md:grid-cols-3 gap-4">
                  <div>
                    <Label htmlFor="price">Price per Person (฿)</Label>
                    <Input id="price" type="number" placeholder="1500" />
                  </div>
                  <div>
                    <Label htmlFor="difficulty">Difficulty</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="easy">Easy</SelectItem>
                        <SelectItem value="moderate">Moderate</SelectItem>
                        <SelectItem value="challenging">Challenging</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div>
                    <Label htmlFor="vehicle">Vehicle Type</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="van">Van</SelectItem>
                        <SelectItem value="minibus">Minibus</SelectItem>
                        <SelectItem value="bus">Bus</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div>
                  <Label htmlFor="tripImage">Cover Image</Label>
                  <Input id="tripImage" type="file" accept="image/*" />
                </div>

                <div className="flex gap-2">
                  <Button className="flex-1">
                    <Save className="h-4 w-4 mr-2" />
                    Save Trip
                  </Button>
                  <Button variant="outline">
                    <Eye className="h-4 w-4 mr-2" />
                    Preview
                  </Button>
                  <Button variant="secondary">
                    <Wand2 className="h-4 w-4 mr-2" />
                    AI Enhance
                  </Button>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Create Content */}
          <TabsContent value="content" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <FileText className="h-5 w-5" />
                  Create Content Article
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <Label htmlFor="contentTitle">Article Title</Label>
                  <Input id="contentTitle" placeholder="e.g., 5 Benefits of Daily Walking" />
                </div>

                <div>
                  <Label htmlFor="contentCategory">Content Type</Label>
                  <Select>
                    <SelectTrigger>
                      <SelectValue placeholder="Select type" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="health">Health Tips</SelectItem>
                      <SelectItem value="lifestyle">Lifestyle</SelectItem>
                      <SelectItem value="wellness">Wellness</SelectItem>
                      <SelectItem value="nutrition">Nutrition</SelectItem>
                      <SelectItem value="exercise">Exercise</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div>
                  <Label htmlFor="contentBody">Content</Label>
                  <Textarea 
                    id="contentBody" 
                    placeholder="Write your article content..."
                    className="min-h-48"
                  />
                </div>

                <div>
                  <Label htmlFor="contentTags">Tags (comma-separated)</Label>
                  <Input id="contentTags" placeholder="walking, health, seniors, exercise" />
                </div>

                <div>
                  <Label htmlFor="contentImage">Featured Image</Label>
                  <Input id="contentImage" type="file" accept="image/*" />
                </div>

                <div className="flex gap-2">
                  <Button className="flex-1">
                    <Save className="h-4 w-4 mr-2" />
                    Publish Article
                  </Button>
                  <Button variant="outline">Save as Draft</Button>
                  <Button variant="secondary">
                    <Wand2 className="h-4 w-4 mr-2" />
                    AI Write
                  </Button>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Upload Media */}
          <TabsContent value="media" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Video className="h-5 w-5" />
                  Upload Media
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <Label htmlFor="mediaType">Media Type</Label>
                  <Select>
                    <SelectTrigger>
                      <SelectValue placeholder="Select type" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="video">Video</SelectItem>
                      <SelectItem value="podcast">Podcast</SelectItem>
                      <SelectItem value="image">Image Gallery</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div>
                  <Label htmlFor="mediaTitle">Title</Label>
                  <Input id="mediaTitle" placeholder="Media title" />
                </div>

                <div>
                  <Label htmlFor="mediaDescription">Description</Label>
                  <Textarea 
                    id="mediaDescription" 
                    placeholder="Describe this media..."
                    className="min-h-24"
                  />
                </div>

                <div>
                  <Label htmlFor="mediaFile">Upload File</Label>
                  <Input id="mediaFile" type="file" accept="video/*,audio/*,image/*" />
                  <p className="text-xs text-muted-foreground mt-1">
                    Supported: MP4, MOV, MP3, WAV, JPG, PNG (Max 50MB)
                  </p>
                </div>

                <div className="grid md:grid-cols-2 gap-4">
                  <div>
                    <Label htmlFor="mediaDuration">Duration</Label>
                    <Input id="mediaDuration" placeholder="15 min" />
                  </div>
                  <div>
                    <Label htmlFor="mediaCategory">Category</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="exercise">Exercise</SelectItem>
                        <SelectItem value="cooking">Cooking</SelectItem>
                        <SelectItem value="culture">Culture</SelectItem>
                        <SelectItem value="wellness">Wellness</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="flex gap-2">
                  <Button className="flex-1">
                    <Plus className="h-4 w-4 mr-2" />
                    Upload Media
                  </Button>
                  <Button variant="outline">
                    <Eye className="h-4 w-4 mr-2" />
                    Preview
                  </Button>
                </div>
              </CardContent>
            </Card>

            {/* Media Library */}
            <Card>
              <CardHeader>
                <CardTitle>Recent Uploads</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {[
                    { title: "Morning Stretches", type: "video", duration: "15 min" },
                    { title: "Cooking Thai Food", type: "video", duration: "20 min" },
                    { title: "Health Tips Podcast", type: "podcast", duration: "30 min" },
                  ].map((media, idx) => (
                    <div key={idx} className="border rounded-lg p-4">
                      <div className="aspect-video bg-muted rounded mb-3 flex items-center justify-center">
                        <Video className="h-8 w-8 text-muted-foreground" />
                      </div>
                      <p className="font-medium">{media.title}</p>
                      <div className="flex items-center justify-between mt-2">
                        <Badge variant="secondary">{media.type}</Badge>
                        <span className="text-xs text-muted-foreground">{media.duration}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </AdminLayout>
  );
}
