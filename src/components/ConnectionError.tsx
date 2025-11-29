import { AlertTriangle, RefreshCw } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { isSupabaseConfigured } from '@/integrations/supabase/client';

export function ConnectionError() {
  const isConfigured = isSupabaseConfigured();

  if (isConfigured) {
    return null; // Don't show if configured
  }

  return (
    <div className="fixed bottom-4 right-4 z-50 max-w-md">
      <Card className="border-destructive shadow-lg">
        <CardHeader>
          <div className="flex items-center gap-2">
            <AlertTriangle className="h-5 w-5 text-destructive" />
            <CardTitle className="text-lg">การตั้งค่าไม่ครบถ้วน</CardTitle>
          </div>
          <CardDescription>
            ไม่พบ Supabase configuration
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="text-sm space-y-2">
            <p className="font-semibold">กรุณาตั้งค่า Environment Variables:</p>
            <div className="bg-muted p-3 rounded-md font-mono text-xs space-y-1">
              <div>VITE_SUPABASE_URL=your_url</div>
              <div>VITE_SUPABASE_PUBLISHABLE_KEY=your_key</div>
            </div>
            <p className="text-muted-foreground">
              สร้างไฟล์ <code className="bg-muted px-1 rounded">.env</code> ในโฟลเดอร์ root
            </p>
          </div>
          <Button
            onClick={() => window.location.reload()}
            variant="outline"
            size="sm"
            className="w-full"
          >
            <RefreshCw className="h-4 w-4 mr-2" />
            รีเฟรชหน้า
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}

