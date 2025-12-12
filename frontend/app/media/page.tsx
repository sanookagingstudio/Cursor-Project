"use client";
import { useEffect, useState } from "react";
import { getMediaList } from "@/services/media";

export default function MediaPage() {
  const [data, setData] = useState<any>(null);

  useEffect(() => {
    getMediaList().then(setData);
  }, []);

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">media</h1>
      <pre className="bg-black/40 p-4 rounded-lg">{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}



