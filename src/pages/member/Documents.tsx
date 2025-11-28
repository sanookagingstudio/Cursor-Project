import { MemberLayout } from "@/layouts/MemberLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { FileText, Download, Calendar } from "lucide-react";

export default function Documents() {
  const documents = [
    { name: "Membership Agreement", date: "2024-01-15", type: "Contract", size: "245 KB" },
    { name: "Health Assessment Form", date: "2024-01-20", type: "Health", size: "120 KB" },
    { name: "Trip Receipt - Ayutthaya", date: "2024-02-10", type: "Receipt", size: "85 KB" },
    { name: "Monthly Activity Report", date: "2024-02-28", type: "Report", size: "350 KB" },
    { name: "Insurance Certificate", date: "2024-01-15", type: "Insurance", size: "180 KB" },
  ];

  return (
    <MemberLayout>
      <SectionHeader
        title="My Documents"
        description="Access your receipts, agreements, and health records"
      />

      <div className="grid gap-4">
        {documents.map((doc) => (
          <Card key={doc.name} className="hover:shadow-md transition-shadow">
            <CardContent className="flex items-center justify-between p-6">
              <div className="flex items-start gap-4 flex-1">
                <div className="p-3 bg-primary/10 rounded-lg">
                  <FileText className="h-6 w-6 text-primary" />
                </div>
                <div className="flex-1">
                  <h4 className="font-semibold mb-1">{doc.name}</h4>
                  <div className="flex flex-wrap items-center gap-3 text-sm text-muted-foreground">
                    <span className="flex items-center gap-1">
                      <Calendar className="h-4 w-4" />
                      {doc.date}
                    </span>
                    <Badge variant="secondary">{doc.type}</Badge>
                    <span>{doc.size}</span>
                  </div>
                </div>
              </div>
              <Button variant="outline" size="lg" className="ml-4">
                <Download className="h-5 w-5 mr-2" />
                Download
              </Button>
            </CardContent>
          </Card>
        ))}
      </div>
    </MemberLayout>
  );
}
