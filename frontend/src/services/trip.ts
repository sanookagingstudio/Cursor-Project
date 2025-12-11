import { api } from "@/lib/api";
export const getTripList = () => api.get("/trip/list");
