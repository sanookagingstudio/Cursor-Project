"use client";
import { useEffect, useState } from "react";
import { getTripList } from "@/services/trip";

export default function TripPage() {
  const [data, setData] = useState<any>(null);

  useEffect(() => {
    getTripList().then(setData);
  }, []);

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">trip</h1>
      <pre className="bg-black/40 p-4 rounded-lg">{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}


