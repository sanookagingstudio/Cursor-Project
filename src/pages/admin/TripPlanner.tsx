import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Stepper } from "@/components/ui/stepper";

export default function TripPlanner() {
  const steps = [
    { label: "Basic Info" },
    { label: "Itinerary" },
    { label: "Cost Breakdown" },
    { label: "Staff & Care" },
    { label: "Review" }
  ];

  return (
    <AdminLayout>
      <SectionHeader
        title="Trip Planner"
        description="Plan and organize new trips for members"
      />

      <div className="max-w-4xl">
        <Card className="mb-6">
          <CardContent className="pt-6">
            <Stepper steps={steps} currentStep={0} />
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Basic Trip Information</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label htmlFor="tripName">Trip Name</Label>
              <Input id="tripName" placeholder="e.g., Ayutthaya Heritage Tour" className="text-lg" />
            </div>

            <div className="grid md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="destination">Destination</Label>
                <Input id="destination" placeholder="Location" className="text-lg" />
              </div>
              <div>
                <Label htmlFor="duration">Duration</Label>
                <Select>
                  <SelectTrigger className="text-lg">
                    <SelectValue placeholder="Select duration" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="halfday">Half Day (4 hours)</SelectItem>
                    <SelectItem value="fullday">Full Day (8 hours)</SelectItem>
                    <SelectItem value="2days">2 Days / 1 Night</SelectItem>
                    <SelectItem value="3days">3 Days / 2 Nights</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="grid md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="difficulty">Difficulty Level</Label>
                <Select>
                  <SelectTrigger className="text-lg">
                    <SelectValue placeholder="Select difficulty" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="easy">Easy - Suitable for all</SelectItem>
                    <SelectItem value="moderate">Moderate - Some walking</SelectItem>
                    <SelectItem value="challenging">Challenging - Active</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label htmlFor="capacity">Max Capacity</Label>
                <Input id="capacity" type="number" placeholder="Number of people" className="text-lg" />
              </div>
            </div>

            <div>
              <Label htmlFor="description">Description</Label>
              <Textarea
                id="description"
                placeholder="Describe the trip highlights and what makes it special"
                className="text-lg min-h-32"
              />
            </div>

            <div className="grid md:grid-cols-3 gap-4">
              <div>
                <Label htmlFor="price">Price per Person</Label>
                <Input id="price" placeholder="฿" className="text-lg" />
              </div>
              <div>
                <Label htmlFor="staffRatio">Staff Ratio</Label>
                <Input id="staffRatio" placeholder="e.g., 1:5" className="text-lg" />
              </div>
              <div>
                <Label htmlFor="careLevel">Care Level</Label>
                <Select>
                  <SelectTrigger className="text-lg">
                    <SelectValue placeholder="Select" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="standard">Standard</SelectItem>
                    <SelectItem value="enhanced">Enhanced</SelectItem>
                    <SelectItem value="intensive">Intensive</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="flex justify-between pt-6">
              <Button variant="outline" size="lg">
                Cancel
              </Button>
              <Button size="lg" className="btn-elderly">
                Continue to Itinerary
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </AdminLayout>
  );
}
