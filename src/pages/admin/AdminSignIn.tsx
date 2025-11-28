import { useState, useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { useAuth } from "@/contexts/AuthContext";
import { useToast } from "@/hooks/use-toast";
import { supabase } from "@/integrations/supabase/client";
import { Shield, AlertCircle, ArrowLeft } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { LanguageSwitcher } from "@/components/LanguageSwitcher";
import { useTranslation } from "react-i18next";

export default function AdminSignIn() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const { signIn, user, userRole } = useAuth();
  const { toast } = useToast();
  const navigate = useNavigate();
  const { t } = useTranslation();

  useEffect(() => {
    if (user && userRole) {
      // Check if user has admin role
      if (userRole === 'admin') {
        navigate('/admin/dashboard');
      } else {
        // User doesn't have admin role - show error and sign out
        toast({
          title: "Access Denied",
          description: "This account does not have administrator privileges.",
          variant: "destructive",
        });
        supabase.auth.signOut();
      }
    }
  }, [user, userRole, navigate, toast]);

  const handleSignIn = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    const { error } = await signIn(email, password);

    if (error) {
      toast({
        title: "Sign in failed",
        description: error.message,
        variant: "destructive",
      });
      setLoading(false);
    } else {
      // Wait for role to load
      setTimeout(async () => {
        const { data: roles } = await supabase
          .from('user_roles')
          .select('role')
          .eq('user_id', (await supabase.auth.getUser()).data.user?.id);
        
        if (roles && roles.length > 0) {
          const roleList = roles.map(r => r.role);
          if (roleList.includes('admin')) {
            toast({
              title: "Welcome Administrator",
              description: "You have successfully signed in.",
            });
            navigate('/admin/dashboard');
          } else {
            // Not an admin
            toast({
              title: "Access Denied",
              description: "This account does not have administrator privileges.",
              variant: "destructive",
            });
            await supabase.auth.signOut();
            setLoading(false);
          }
        } else {
          toast({
            title: "Access Denied",
            description: "No role assigned to this account.",
            variant: "destructive",
          });
          await supabase.auth.signOut();
          setLoading(false);
        }
      }, 500);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-red-50 via-rose-100 to-red-50 p-4 relative">
      <div className="absolute top-4 right-4 z-10">
        <LanguageSwitcher />
      </div>

      <Card className="w-full max-w-md shadow-2xl border-2 border-red-200">
        <CardHeader className="text-center space-y-6 pb-8">
          <Link to="/" className="inline-flex items-center gap-2 text-muted-foreground hover:text-foreground transition-colors">
            <ArrowLeft className="h-4 w-4" />
            <span className="text-sm">{t('auth.admin.backHome')}</span>
          </Link>
          
          <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-red-600 to-rose-600 flex items-center justify-center text-white mx-auto shadow-lg">
            <Shield className="h-10 w-10" />
          </div>
          
          <div>
            <div className="inline-block px-6 py-2 rounded-full bg-red-500/10 border-2 border-red-600 mb-4">
              <span className="text-2xl font-bold text-red-700">{t('auth.admin.title')}</span>
            </div>
            <CardDescription className="text-lg mt-2">
              {t('auth.admin.subtitle')}
            </CardDescription>
          </div>
        </CardHeader>
        
        <CardContent className="space-y-6">
          <Alert className="border-red-200 bg-red-50">
            <AlertCircle className="h-5 w-5 text-red-600" />
            <AlertDescription className="text-red-900 font-medium">
              {t('auth.admin.alertDescription')}
            </AlertDescription>
          </Alert>

          <form onSubmit={handleSignIn} className="space-y-5">
            <div className="space-y-2">
              <Label htmlFor="email" className="text-base font-semibold">
                {t('auth.admin.email')}
              </Label>
              <Input
                id="email"
                type="email"
                placeholder={t('auth.admin.emailPlaceholder')}
                className="text-lg h-12 border-2 border-red-200 focus:border-red-500"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="password" className="text-base font-semibold">
                {t('auth.admin.password')}
              </Label>
              <Input
                id="password"
                type="password"
                placeholder="••••••••"
                className="text-lg h-12 border-2 border-red-200 focus:border-red-500"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
            
            <Button 
              type="submit" 
              size="lg" 
              className="w-full h-14 text-lg font-semibold bg-red-600 hover:bg-red-700 shadow-lg hover:shadow-xl transition-all" 
              disabled={loading}
            >
              {loading ? t('auth.admin.verifying') : t('auth.admin.signInButton')}
            </Button>
          </form>

          <div className="space-y-4">
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <span className="w-full border-t-2" />
              </div>
              <div className="relative flex justify-center text-xs uppercase">
                <span className="bg-card px-4 text-muted-foreground font-medium">Other Portals</span>
              </div>
            </div>
            
            <div className="grid grid-cols-2 gap-3 text-center text-sm">
              <Link 
                to="/staff/sign-in" 
                className="p-3 rounded-lg border-2 border-blue-500/30 bg-blue-500/5 hover:bg-blue-500/10 hover:border-blue-500 transition-all"
              >
                <div className="font-semibold text-blue-600">{t('auth.admin.staffPortal')}</div>
                <div className="text-xs text-blue-500">{t('auth.admin.staffLink')}</div>
              </Link>
              
              <Link 
                to="/sign-in" 
                className="p-3 rounded-lg border-2 border-primary/30 bg-primary/5 hover:bg-primary/10 hover:border-primary transition-all"
              >
                <div className="font-semibold text-primary">{t('auth.admin.customerPortal')}</div>
                <div className="text-xs text-primary/80">{t('auth.admin.customerLink')}</div>
              </Link>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
