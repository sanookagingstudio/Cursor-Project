import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { lazy, Suspense } from "react";
import { AuthProvider } from "@/contexts/AuthContext";
import { ThemeProvider } from "@/contexts/ThemeContext";
import { ProtectedRoute } from "@/components/ProtectedRoute";
import Index from "./pages/Index";
import NotFound from "./pages/NotFound";

const Activities = lazy(() => import("./pages/Activities"));
const Trips = lazy(() => import("./pages/Trips"));
const TripDetails = lazy(() => import("./pages/TripDetails"));
const ActivityDetails = lazy(() => import("./pages/ActivityDetails"));
const About = lazy(() => import("./pages/About"));
const Pricing = lazy(() => import("./pages/Pricing"));
const FAQ = lazy(() => import("./pages/FAQ"));
const HealthCheck = lazy(() => import("./pages/HealthCheck"));
const MediaDetail = lazy(() => import("./pages/MediaDetail"));
const FUNStore = lazy(() => import("./pages/FUNStore"));
const FUNCalendar = lazy(() => import("./pages/FUNCalendar"));
const CustomTripBuilder = lazy(() => import("./pages/CustomTripBuilder"));
const JoinNow = lazy(() => import("./pages/JoinNow"));
const Contact = lazy(() => import("./pages/Contact"));
const MediaLibrary = lazy(() => import("./pages/MediaLibrary"));
const SignIn = lazy(() => import("./pages/SignIn"));
const SignUp = lazy(() => import("./pages/SignUp"));
const Promotions = lazy(() => import("./pages/Promotions"));
const MembershipPlans = lazy(() => import("./pages/MembershipPlans"));
const FontPreview = lazy(() => import("./pages/FontPreview"));
const AdminSignIn = lazy(() => import("./pages/admin/AdminSignIn"));
const StaffSignIn = lazy(() => import("./pages/staff/StaffSignIn"));

// Staff Pages
const EmployeeManagement = lazy(() => import("./pages/staff/EmployeeManagement"));
const FUNHealth = lazy(() => import("./pages/staff/FUNHealth"));
const FUNCreatorBasic = lazy(() => import("./pages/staff/FUNCreatorBasic"));
const FUNCreatorPro = lazy(() => import("./pages/staff/FUNCreatorPro"));
const FUNSentinel = lazy(() => import("./pages/staff/FUNSentinel"));
const FUNTrip = lazy(() => import("./pages/staff/FUNTrip"));

// Admin Pages
const Dashboard = lazy(() => import("./pages/admin/Dashboard"));
const TripPlanner = lazy(() => import("./pages/admin/TripPlanner"));
const CustomerManagement = lazy(() => import("./pages/admin/CustomerManagement"));
const FinanceOverview = lazy(() => import("./pages/admin/FinanceOverview"));
const Scheduling = lazy(() => import("./pages/admin/Scheduling"));
const Billing = lazy(() => import("./pages/admin/Billing"));
const ClientMonitoring = lazy(() => import("./pages/admin/ClientMonitoring"));
const MediaCenter = lazy(() => import("./pages/admin/MediaCenter"));
const AIInsights = lazy(() => import("./pages/admin/AIInsights"));
const Settings = lazy(() => import("./pages/admin/Settings"));
const RoleManagement = lazy(() => import("./pages/admin/RoleManagement"));
const CoreFoundation = lazy(() => import("./pages/admin/CoreFoundation"));
const ProviderManagement = lazy(() => import("./pages/admin/ProviderManagement"));
const InputBrain = lazy(() => import("./pages/admin/InputBrain"));
const ImageEditor = lazy(() => import("./pages/admin/ImageEditor"));
const VideoEditor = lazy(() => import("./pages/admin/VideoEditor"));
const MusicLab = lazy(() => import("./pages/admin/MusicLab"));
const DashboardPublishing = lazy(() => import("./pages/admin/DashboardPublishing"));
const ThemeCustomization = lazy(() => import("./pages/admin/ThemeCustomization"));

// Member Pages
const MemberDashboard = lazy(() => import("./pages/member/Dashboard"));
const MemberProfile = lazy(() => import("./pages/member/Profile"));
const MemberMyActivities = lazy(() => import("./pages/member/MyActivities"));
const MemberMyTrips = lazy(() => import("./pages/member/MyTrips"));
const MemberDocuments = lazy(() => import("./pages/member/Documents"));
const Notifications = lazy(() => import("./pages/member/Notifications"));
const ProfileSettings = lazy(() => import("./pages/member/ProfileSettings"));

const queryClient = new QueryClient();

const App = () => (
      <QueryClientProvider client={queryClient}>
        <TooltipProvider>
          <Toaster />
          <Sonner />
          <BrowserRouter>
            <ThemeProvider>
              <AuthProvider>
          <Suspense fallback={<div className="min-h-screen flex items-center justify-center">
            <div className="text-center">
              <div className="w-16 h-16 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
              <p className="text-muted-foreground">Loading...</p>
            </div>
          </div>}>
            <Routes>
            {/* Public Routes */}
            <Route path="/" element={<Index />} />
            <Route path="/about" element={<About />} />
            <Route path="/activities" element={<Activities />} />
            <Route path="/activities/:id" element={<ActivityDetails />} />
            <Route path="/trips" element={<Trips />} />
            <Route path="/trips/:id" element={<TripDetails />} />
            <Route path="/pricing" element={<Pricing />} />
            <Route path="/faq" element={<FAQ />} />
            <Route path="/health-check" element={<HealthCheck />} />
            <Route path="/custom-trip-builder" element={<CustomTripBuilder />} />
            <Route path="/join-now" element={<JoinNow />} />
            <Route path="/contact" element={<Contact />} />
            <Route path="/media" element={<MediaLibrary />} />
            <Route path="/media/:id" element={<MediaDetail />} />
            <Route path="/fun-store" element={<FUNStore />} />
            <Route path="/fun-calendar" element={<FUNCalendar />} />
            <Route path="/promotions" element={<Promotions />} />
            <Route path="/membership" element={<MembershipPlans />} />
            <Route path="/sign-in" element={<SignIn />} />
            <Route path="/sign-up" element={<SignUp />} />
            <Route path="/admin/sign-in" element={<AdminSignIn />} />
            <Route path="/staff/sign-in" element={<StaffSignIn />} />
            <Route path="/font-preview" element={<FontPreview />} />

            {/* Staff Routes */}
            <Route path="/staff/employee" element={<ProtectedRoute requiredRole="staff"><EmployeeManagement /></ProtectedRoute>} />
            <Route path="/staff/fun-health" element={<ProtectedRoute requiredRole="staff"><FUNHealth /></ProtectedRoute>} />
            <Route path="/staff/fun-creator-basic" element={<ProtectedRoute requiredRole="staff"><FUNCreatorBasic /></ProtectedRoute>} />
            <Route path="/staff/fun-creator-pro" element={<ProtectedRoute requiredRole="staff"><FUNCreatorPro /></ProtectedRoute>} />
            <Route path="/staff/fun-sentinel" element={<ProtectedRoute requiredRole="staff"><FUNSentinel /></ProtectedRoute>} />
            <Route path="/staff/fun-trip" element={<ProtectedRoute requiredRole="staff"><FUNTrip /></ProtectedRoute>} />

            {/* Admin Routes */}
            <Route path="/admin/dashboard" element={<ProtectedRoute requiredRole="admin"><Dashboard /></ProtectedRoute>} />
            <Route path="/admin/staff" element={<ProtectedRoute requiredRole="admin"><EmployeeManagement /></ProtectedRoute>} />
            <Route path="/admin/customers" element={<ProtectedRoute requiredRole="admin"><CustomerManagement /></ProtectedRoute>} />
            <Route path="/admin/scheduling" element={<ProtectedRoute requiredRole="admin"><Scheduling /></ProtectedRoute>} />
            <Route path="/admin/finance" element={<ProtectedRoute requiredRole="admin"><FinanceOverview /></ProtectedRoute>} />
            <Route path="/admin/billing" element={<ProtectedRoute requiredRole="admin"><Billing /></ProtectedRoute>} />
            <Route path="/admin/clients" element={<ProtectedRoute requiredRole="admin"><ClientMonitoring /></ProtectedRoute>} />
            <Route path="/admin/trip-planner" element={<ProtectedRoute requiredRole="admin"><TripPlanner /></ProtectedRoute>} />
            <Route path="/admin/media" element={<ProtectedRoute requiredRole="admin"><MediaCenter /></ProtectedRoute>} />
            <Route path="/admin/ai-insights" element={<ProtectedRoute requiredRole="admin"><AIInsights /></ProtectedRoute>} />
            <Route path="/admin/settings" element={<ProtectedRoute requiredRole="admin"><Settings /></ProtectedRoute>} />
            <Route path="/admin/role-management" element={<ProtectedRoute requiredRole="admin"><RoleManagement /></ProtectedRoute>} />
            <Route path="/admin/core-foundation" element={<ProtectedRoute requiredRole="admin"><CoreFoundation /></ProtectedRoute>} />
            <Route path="/admin/provider-management" element={<ProtectedRoute requiredRole="admin"><ProviderManagement /></ProtectedRoute>} />
            <Route path="/admin/input-brain" element={<ProtectedRoute requiredRole="admin"><InputBrain /></ProtectedRoute>} />
            <Route path="/admin/image-editor" element={<ProtectedRoute requiredRole="admin"><ImageEditor /></ProtectedRoute>} />
            <Route path="/admin/video-editor" element={<ProtectedRoute requiredRole="admin"><VideoEditor /></ProtectedRoute>} />
            <Route path="/admin/music-lab" element={<ProtectedRoute requiredRole="admin"><MusicLab /></ProtectedRoute>} />
            <Route path="/admin/dashboard-publishing" element={<ProtectedRoute requiredRole="admin"><DashboardPublishing /></ProtectedRoute>} />
            <Route path="/admin/theme-customization" element={<ProtectedRoute requiredRole="admin"><ThemeCustomization /></ProtectedRoute>} />

            {/* Member Routes */}
            <Route path="/member/dashboard" element={<ProtectedRoute requiredRole="member"><MemberDashboard /></ProtectedRoute>} />
            <Route path="/member/profile" element={<ProtectedRoute requiredRole="member"><MemberProfile /></ProtectedRoute>} />
            <Route path="/member/activities" element={<ProtectedRoute requiredRole="member"><MemberMyActivities /></ProtectedRoute>} />
            <Route path="/member/trips" element={<ProtectedRoute requiredRole="member"><MemberMyTrips /></ProtectedRoute>} />
            <Route path="/member/documents" element={<ProtectedRoute requiredRole="member"><MemberDocuments /></ProtectedRoute>} />
            <Route path="/member/notifications" element={<ProtectedRoute requiredRole="member"><Notifications /></ProtectedRoute>} />
            <Route path="/member/settings" element={<ProtectedRoute requiredRole="member"><ProfileSettings /></ProtectedRoute>} />

            {/* Fallback */}
            <Route path="*" element={<NotFound />} />
          </Routes>
        </Suspense>
              </AuthProvider>
            </ThemeProvider>
          </BrowserRouter>
        </TooltipProvider>
      </QueryClientProvider>
);

export default App;
