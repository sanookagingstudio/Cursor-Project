import React, { Component, ErrorInfo, ReactNode } from 'react';
import { AlertTriangle } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface Props {
  children: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
  errorInfo: ErrorInfo | null;
}

export class ErrorBoundary extends Component<Props, State> {
  public state: State = {
    hasError: false,
    error: null,
    errorInfo: null,
  };

  public static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error, errorInfo: null };
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('ErrorBoundary caught an error:', error, errorInfo);
    this.setState({
      error,
      errorInfo,
    });
  }

  private handleReset = () => {
    this.setState({
      hasError: false,
      error: null,
      errorInfo: null,
    });
    window.location.href = '/';
  };

  public render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-muted p-4">
          <div className="max-w-2xl w-full bg-card rounded-lg shadow-lg p-8 text-center space-y-6">
            <div className="flex justify-center">
              <AlertTriangle className="h-16 w-16 text-destructive" />
            </div>
            <div>
              <h1 className="text-3xl font-bold mb-2">เกิดข้อผิดพลาด</h1>
              <p className="text-muted-foreground mb-4">
                มีปัญหาบางอย่างเกิดขึ้น กรุณาลองใหม่อีกครั้ง
              </p>
            </div>
            
            {this.state.error && (
              <div className="bg-muted rounded-lg p-4 text-left">
                <p className="text-sm font-mono text-destructive mb-2">
                  {this.state.error.toString()}
                </p>
                {this.state.errorInfo && (
                  <details className="text-xs text-muted-foreground">
                    <summary className="cursor-pointer mb-2">รายละเอียดข้อผิดพลาด</summary>
                    <pre className="overflow-auto max-h-48">
                      {this.state.errorInfo.componentStack}
                    </pre>
                  </details>
                )}
              </div>
            )}

            <div className="flex gap-4 justify-center">
              <Button onClick={this.handleReset} variant="default">
                กลับหน้าหลัก
              </Button>
              <Button onClick={() => window.location.reload()} variant="outline">
                รีเฟรชหน้า
              </Button>
            </div>

            <div className="text-sm text-muted-foreground space-y-2">
              <p>หากปัญหายังคงอยู่ กรุณาตรวจสอบ:</p>
              <ul className="list-disc list-inside space-y-1">
                <li>การเชื่อมต่ออินเทอร์เน็ต</li>
                <li>Environment variables ในไฟล์ .env</li>
                <li>Console ใน Developer Tools สำหรับรายละเอียดเพิ่มเติม</li>
              </ul>
            </div>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}

