import { api } from "@/lib/api";
export const getMediaList = () => api.get("/media/list");
