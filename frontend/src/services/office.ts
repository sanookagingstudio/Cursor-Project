import { api } from "@/lib/api";
export const getOfficeList = () => api.get("/office/list");
