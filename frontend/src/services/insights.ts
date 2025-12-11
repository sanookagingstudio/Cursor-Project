import { api } from "@/lib/api";
export const getInsightsSummary = () => api.get("/insights/summary");
