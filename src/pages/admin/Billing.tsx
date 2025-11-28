import { AdminLayout } from "@/layouts/AdminLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { ActionBar } from "@/components/ui/action-bar";
import { DataTable } from "@/components/tables/DataTable";
import { Badge } from "@/components/ui/badge";

export default function Billing() {
  const columns = [
    { key: "invoiceNo", label: "Invoice #" },
    { key: "client", label: "Client" },
    { key: "date", label: "Date" },
    { key: "amount", label: "Amount" },
    { key: "status", label: "Status" },
  ];

  const invoices = [
    { invoiceNo: "INV-001", client: "John Doe", date: "2024-03-01", amount: "฿2,500", status: "Paid" },
    { invoiceNo: "INV-002", client: "Jane Smith", date: "2024-03-05", amount: "฿1,800", status: "Paid" },
    { invoiceNo: "INV-003", client: "Bob Wilson", date: "2024-03-10", amount: "฿3,200", status: "Pending" },
    { invoiceNo: "INV-004", client: "Alice Brown", date: "2024-03-15", amount: "฿1,500", status: "Overdue" },
  ];

  return (
    <AdminLayout>
      <SectionHeader
        title="Billing & Documents"
        description="Manage invoices, receipts, and financial documents"
      />

      <ActionBar
        actions={[
          { type: "add", label: "New Invoice" },
          { type: "export", label: "Export" },
          { type: "print", label: "Print" },
        ]}
        className="mb-6"
      />

      <DataTable columns={columns} data={invoices} />
    </AdminLayout>
  );
}
