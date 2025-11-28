import { AdminLayout } from "@/layouts/AdminLayout";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { 
  Tag,
  Plus,
  TrendingDown,
  BarChart3,
  Loader2,
  CheckCircle,
  XCircle,
  Calendar
} from "lucide-react";
import { useState, useEffect } from "react";
import { useToast } from "@/components/ui/use-toast";

interface DiscountCode {
  id: string;
  code: string;
  name: string;
  description: string;
  discount_type: string;
  discount_value: number;
  min_purchase_amount: number | null;
  max_discount_amount: number | null;
  applicable_to: string;
  valid_from: string;
  valid_until: string;
  usage_limit: number | null;
  usage_count: number;
  user_limit: number;
  first_time_only: boolean;
  user_group: string;
  status: string;
  auto_apply: boolean;
  stackable: boolean;
  created_at: string;
}

export default function DiscountManagement() {
  const { toast } = useToast();
  const [loading, setLoading] = useState(true);
  const [discounts, setDiscounts] = useState<DiscountCode[]>([]);
  const [activeTab, setActiveTab] = useState("codes");
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [selectedDiscount, setSelectedDiscount] = useState<DiscountCode | null>(null);

  // Form state
  const [formData, setFormData] = useState({
    code: "",
    name: "",
    description: "",
    discount_type: "percentage",
    discount_value: 10,
    min_purchase_amount: "",
    max_discount_amount: "",
    applicable_to: "all",
    valid_from: "",
    valid_until: "",
    usage_limit: "",
    user_limit: 1,
    first_time_only: false,
    user_group: "all",
    auto_apply: false,
    stackable: false,
  });

  useEffect(() => {
    loadDiscounts();
  }, []);

  const loadDiscounts = async () => {
    try {
      setLoading(true);
      const res = await fetch("/api/discount/codes");
      if (res.ok) {
        const data = await res.json();
        setDiscounts(data);
      }
    } catch (error) {
      console.error("Error loading discounts:", error);
      toast({
        title: "Error",
        description: "Failed to load discount codes",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const handleCreateDiscount = async () => {
    try {
      const payload = {
        ...formData,
        discount_value: parseFloat(formData.discount_value.toString()),
        min_purchase_amount: formData.min_purchase_amount ? parseFloat(formData.min_purchase_amount) : null,
        max_discount_amount: formData.max_discount_amount ? parseFloat(formData.max_discount_amount) : null,
        usage_limit: formData.usage_limit ? parseInt(formData.usage_limit) : null,
        valid_from: new Date(formData.valid_from).toISOString(),
        valid_until: new Date(formData.valid_until).toISOString(),
      };

      const res = await fetch("/api/discount/codes", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      if (res.ok) {
        toast({
          title: "Success",
          description: "Discount code created successfully",
        });
        setShowCreateForm(false);
        resetForm();
        loadDiscounts();
      } else {
        const error = await res.json();
        throw new Error(error.detail || "Failed to create discount code");
      }
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message || "Failed to create discount code",
        variant: "destructive",
      });
    }
  };

  const resetForm = () => {
    setFormData({
      code: "",
      name: "",
      description: "",
      discount_type: "percentage",
      discount_value: 10,
      min_purchase_amount: "",
      max_discount_amount: "",
      applicable_to: "all",
      valid_from: "",
      valid_until: "",
      usage_limit: "",
      user_limit: 1,
      first_time_only: false,
      user_group: "all",
      auto_apply: false,
      stackable: false,
    });
  };

  const getStatusBadge = (status: string) => {
    if (status === "active") {
      return <span className="px-2 py-1 bg-green-100 text-green-800 rounded text-sm">Active</span>;
    } else if (status === "inactive") {
      return <span className="px-2 py-1 bg-gray-100 text-gray-800 rounded text-sm">Inactive</span>;
    } else {
      return <span className="px-2 py-1 bg-red-100 text-red-800 rounded text-sm">Expired</span>;
    }
  };

  const formatDiscountValue = (type: string, value: number) => {
    if (type === "percentage") {
      return `${value}%`;
    } else if (type === "fixed_amount") {
      return `฿${value}`;
    } else {
      return type;
    }
  };

  if (loading) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center min-h-screen">
          <Loader2 className="h-8 w-8 animate-spin" />
        </div>
      </AdminLayout>
    );
  }

  return (
    <AdminLayout>
      <div className="container-padding space-y-6">
        <div>
          <h1 className="text-5xl font-bold mb-2">Discount & Promotion Management</h1>
          <p className="text-2xl text-muted-foreground">
            Create and manage discount codes for trips, activities, media services, and more
          </p>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Total Codes</CardTitle>
              <Tag className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">{discounts.length}</div>
              <p className="text-base text-muted-foreground mt-1">
                Discount codes
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Active Codes</CardTitle>
              <CheckCircle className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">
                {discounts.filter(d => d.status === "active").length}
              </div>
              <p className="text-base text-muted-foreground mt-1">
                Currently active
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Total Usage</CardTitle>
              <TrendingDown className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">
                {discounts.reduce((sum, d) => sum + d.usage_count, 0)}
              </div>
              <p className="text-base text-muted-foreground mt-1">
                Times used
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-lg font-semibold">Auto-Apply</CardTitle>
              <Tag className="h-6 w-6 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-bold">
                {discounts.filter(d => d.auto_apply).length}
              </div>
              <p className="text-base text-muted-foreground mt-1">
                Auto-apply codes
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Main Content Tabs */}
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-3 text-base">
            <TabsTrigger value="codes" className="text-base">
              Discount Codes
            </TabsTrigger>
            <TabsTrigger value="create" className="text-base">
              Create Code
            </TabsTrigger>
            <TabsTrigger value="analytics" className="text-base">
              Analytics
            </TabsTrigger>
          </TabsList>

          {/* Discount Codes Tab */}
          <TabsContent value="codes" className="space-y-4">
            <Card>
              <CardHeader>
                <div className="flex justify-between items-center">
                  <div>
                    <CardTitle className="text-2xl font-bold">Discount Codes</CardTitle>
                    <CardDescription className="text-lg">Manage all discount codes</CardDescription>
                  </div>
                  <Button onClick={() => setActiveTab("create")}>
                    <Plus className="mr-2 h-4 w-4" />
                    Create New Code
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {discounts.map((discount) => (
                    <Card key={discount.id} className="cursor-pointer hover:bg-accent" onClick={() => setSelectedDiscount(discount)}>
                      <CardContent className="p-4">
                        <div className="flex items-center justify-between">
                          <div className="flex-1">
                            <div className="flex items-center gap-3 mb-2">
                              <div className="text-2xl font-bold">{discount.code}</div>
                              {getStatusBadge(discount.status)}
                              {discount.auto_apply && (
                                <span className="px-2 py-1 bg-blue-100 text-blue-800 rounded text-sm">Auto-Apply</span>
                              )}
                              {discount.first_time_only && (
                                <span className="px-2 py-1 bg-purple-100 text-purple-800 rounded text-sm">First Time Only</span>
                              )}
                            </div>
                            <div className="text-xl font-semibold mb-1">{discount.name}</div>
                            {discount.description && (
                              <div className="text-base text-muted-foreground mb-2">{discount.description}</div>
                            )}
                            <div className="grid grid-cols-2 md:grid-cols-4 gap-2 text-sm">
                              <div>
                                <span className="font-semibold">Discount: </span>
                                <span>{formatDiscountValue(discount.discount_type, Number(discount.discount_value))}</span>
                              </div>
                              <div>
                                <span className="font-semibold">Applicable To: </span>
                                <span className="capitalize">{discount.applicable_to.replace("_", " ")}</span>
                              </div>
                              <div>
                                <span className="font-semibold">Usage: </span>
                                <span>{discount.usage_count} / {discount.usage_limit || "∞"}</span>
                              </div>
                              <div>
                                <span className="font-semibold">Valid Until: </span>
                                <span>{new Date(discount.valid_until).toLocaleDateString()}</span>
                              </div>
                            </div>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                  {discounts.length === 0 && (
                    <p className="text-base text-muted-foreground text-center py-8">
                      No discount codes created yet
                    </p>
                  )}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Create Code Tab */}
          <TabsContent value="create" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Create Discount Code</CardTitle>
                <CardDescription className="text-lg">Create a new discount code for promotions</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label className="text-base font-semibold">Discount Code *</Label>
                    <Input
                      value={formData.code}
                      onChange={(e) => setFormData({ ...formData, code: e.target.value.toUpperCase() })}
                      placeholder="WELCOME10"
                      className="text-base h-12"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label className="text-base font-semibold">Name *</Label>
                    <Input
                      value={formData.name}
                      onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                      placeholder="Welcome 10% Off"
                      className="text-base h-12"
                    />
                  </div>

                  <div className="space-y-2 md:col-span-2">
                    <Label className="text-base font-semibold">Description</Label>
                    <Input
                      value={formData.description}
                      onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                      placeholder="10% off for first-time users"
                      className="text-base h-12"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label className="text-base font-semibold">Discount Type *</Label>
                    <Select
                      value={formData.discount_type}
                      onValueChange={(v) => setFormData({ ...formData, discount_type: v })}
                    >
                      <SelectTrigger className="text-base h-12">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="percentage" className="text-base">Percentage (%)</SelectItem>
                        <SelectItem value="fixed_amount" className="text-base">Fixed Amount (฿)</SelectItem>
                        <SelectItem value="free_item" className="text-base">Free Item</SelectItem>
                        <SelectItem value="buy_x_get_y" className="text-base">Buy X Get Y</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label className="text-base font-semibold">Discount Value *</Label>
                    <Input
                      type="number"
                      value={formData.discount_value}
                      onChange={(e) => setFormData({ ...formData, discount_value: parseFloat(e.target.value) || 0 })}
                      placeholder={formData.discount_type === "percentage" ? "10" : "100"}
                      className="text-base h-12"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label className="text-base font-semibold">Applicable To *</Label>
                    <Select
                      value={formData.applicable_to}
                      onValueChange={(v) => setFormData({ ...formData, applicable_to: v })}
                    >
                      <SelectTrigger className="text-base h-12">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="all" className="text-base">All</SelectItem>
                        <SelectItem value="trip" className="text-base">Trips</SelectItem>
                        <SelectItem value="activity" className="text-base">Activities</SelectItem>
                        <SelectItem value="media_service" className="text-base">Media Services</SelectItem>
                        <SelectItem value="digital_download" className="text-base">Digital Downloads</SelectItem>
                        <SelectItem value="subscription" className="text-base">Subscriptions</SelectItem>
                        <SelectItem value="credit" className="text-base">Credit Purchase</SelectItem>
                        <SelectItem value="content" className="text-base">Content Access</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label className="text-base font-semibold">Min Purchase Amount</Label>
                    <Input
                      type="number"
                      value={formData.min_purchase_amount}
                      onChange={(e) => setFormData({ ...formData, min_purchase_amount: e.target.value })}
                      placeholder="1000"
                      className="text-base h-12"
                    />
                  </div>

                  {formData.discount_type === "percentage" && (
                    <div className="space-y-2">
                      <Label className="text-base font-semibold">Max Discount Amount</Label>
                      <Input
                        type="number"
                        value={formData.max_discount_amount}
                        onChange={(e) => setFormData({ ...formData, max_discount_amount: e.target.value })}
                        placeholder="500"
                        className="text-base h-12"
                      />
                    </div>
                  )}

                  <div className="space-y-2">
                    <Label className="text-base font-semibold">Valid From *</Label>
                    <Input
                      type="datetime-local"
                      value={formData.valid_from}
                      onChange={(e) => setFormData({ ...formData, valid_from: e.target.value })}
                      className="text-base h-12"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label className="text-base font-semibold">Valid Until *</Label>
                    <Input
                      type="datetime-local"
                      value={formData.valid_until}
                      onChange={(e) => setFormData({ ...formData, valid_until: e.target.value })}
                      className="text-base h-12"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label className="text-base font-semibold">Usage Limit</Label>
                    <Input
                      type="number"
                      value={formData.usage_limit}
                      onChange={(e) => setFormData({ ...formData, usage_limit: e.target.value })}
                      placeholder="100 (leave empty for unlimited)"
                      className="text-base h-12"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label className="text-base font-semibold">User Limit</Label>
                    <Input
                      type="number"
                      value={formData.user_limit}
                      onChange={(e) => setFormData({ ...formData, user_limit: parseInt(e.target.value) || 1 })}
                      placeholder="1"
                      className="text-base h-12"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label className="text-base font-semibold">User Group</Label>
                    <Select
                      value={formData.user_group}
                      onValueChange={(v) => setFormData({ ...formData, user_group: v })}
                    >
                      <SelectTrigger className="text-base h-12">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="all" className="text-base">All Users</SelectItem>
                        <SelectItem value="member" className="text-base">Members</SelectItem>
                        <SelectItem value="premium" className="text-base">Premium Users</SelectItem>
                        <SelectItem value="staff" className="text-base">Staff</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="space-y-4 pt-4">
                  <div className="flex items-center gap-2">
                    <input
                      type="checkbox"
                      id="first_time_only"
                      checked={formData.first_time_only}
                      onChange={(e) => setFormData({ ...formData, first_time_only: e.target.checked })}
                      className="w-5 h-5"
                    />
                    <Label htmlFor="first_time_only" className="text-base font-semibold cursor-pointer">
                      First Time Only (สำหรับลูกค้าใหม่เท่านั้น)
                    </Label>
                  </div>

                  <div className="flex items-center gap-2">
                    <input
                      type="checkbox"
                      id="auto_apply"
                      checked={formData.auto_apply}
                      onChange={(e) => setFormData({ ...formData, auto_apply: e.target.checked })}
                      className="w-5 h-5"
                    />
                    <Label htmlFor="auto_apply" className="text-base font-semibold cursor-pointer">
                      Auto-Apply (ใช้ส่วนลดอัตโนมัติ)
                    </Label>
                  </div>

                  <div className="flex items-center gap-2">
                    <input
                      type="checkbox"
                      id="stackable"
                      checked={formData.stackable}
                      onChange={(e) => setFormData({ ...formData, stackable: e.target.checked })}
                      className="w-5 h-5"
                    />
                    <Label htmlFor="stackable" className="text-base font-semibold cursor-pointer">
                      Stackable (สามารถรวมกับส่วนลดอื่นได้)
                    </Label>
                  </div>
                </div>

                <div className="flex gap-4 pt-4">
                  <Button onClick={handleCreateDiscount} className="text-base">
                    Create Discount Code
                  </Button>
                  <Button variant="outline" onClick={resetForm} className="text-base">
                    Reset Form
                  </Button>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Analytics Tab */}
          <TabsContent value="analytics" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl font-bold">Discount Analytics</CardTitle>
                <CardDescription className="text-lg">View analytics for discount codes</CardDescription>
              </CardHeader>
              <CardContent>
                {selectedDiscount ? (
                  <div className="space-y-4">
                    <div>
                      <div className="text-xl font-bold mb-2">{selectedDiscount.code} - {selectedDiscount.name}</div>
                      <div className="text-base text-muted-foreground">
                        Usage: {selectedDiscount.usage_count} / {selectedDiscount.usage_limit || "∞"}
                      </div>
                    </div>
                    <p className="text-base text-muted-foreground">Analytics details will be displayed here</p>
                  </div>
                ) : (
                  <p className="text-base text-muted-foreground text-center py-8">
                    Select a discount code to view analytics
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

