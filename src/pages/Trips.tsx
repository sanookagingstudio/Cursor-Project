import { PublicLayout } from "@/layouts/PublicLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { FilterBar } from "@/components/ui/filter-bar";
import { TripCard } from "@/components/cards/TripCard";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useTranslation } from "react-i18next";

const Trips = () => {
  const { t } = useTranslation();

  const trips = [
    {
      title: t('tripsPage.trips.ayutthaya.title'),
      description: t('tripsPage.trips.ayutthaya.description'),
      location: t('tripsPage.trips.ayutthaya.location'),
      date: t('tripsPage.trips.ayutthaya.date'),
      duration: "Full Day",
      price: "฿1,500",
      difficulty: "Easy" as const,
      tags: ["Culture", "History"],
      image: "/placeholder.svg",
    },
    {
      title: t('tripsPage.trips.floatingMarket.title'),
      description: t('tripsPage.trips.floatingMarket.description'),
      location: t('tripsPage.trips.floatingMarket.location'),
      date: t('tripsPage.trips.floatingMarket.date'),
      duration: "Half Day",
      price: "฿1,200",
      difficulty: "Easy" as const,
      tags: ["Culture", "Food"],
      image: "/placeholder.svg",
    },
    {
      title: t('tripsPage.trips.mountain.title'),
      description: t('tripsPage.trips.mountain.description'),
      location: t('tripsPage.trips.mountain.location'),
      date: t('tripsPage.trips.mountain.date'),
      duration: "2 Days",
      price: "฿4,500",
      difficulty: "Moderate" as const,
      tags: ["Nature", "Relaxation"],
      image: "/placeholder.svg",
    },
    {
      title: t('tripsPage.trips.beach.title'),
      description: t('tripsPage.trips.beach.description'),
      location: t('tripsPage.trips.beach.location'),
      date: t('tripsPage.trips.beach.date'),
      duration: "2 Days",
      price: "฿3,800",
      difficulty: "Easy" as const,
      tags: ["Beach", "Relaxation"],
      image: "/placeholder.svg",
    },
    {
      title: t('tripsPage.trips.temple.title'),
      description: t('tripsPage.trips.temple.description'),
      location: t('tripsPage.trips.temple.location'),
      date: t('tripsPage.trips.temple.date'),
      duration: "Half Day",
      price: "฿900",
      difficulty: "Easy" as const,
      tags: ["Culture", "Nature"],
      image: "/placeholder.svg",
    },
    {
      title: t('tripsPage.trips.river.title'),
      description: t('tripsPage.trips.river.description'),
      location: t('tripsPage.trips.river.location'),
      date: t('tripsPage.trips.river.date'),
      duration: "Evening",
      price: "฿1,800",
      difficulty: "Easy" as const,
      tags: ["Culture", "Food"],
      image: "/placeholder.svg",
    },
  ];

  return (
    <PublicLayout>
      <div className="section-padding">
        <div className="container-padding max-w-7xl mx-auto">
          <SectionHeader
            title={t('tripsPage.title')}
            description={t('tripsPage.description')}
          />

          <FilterBar
            searchPlaceholder={t('tripsPage.searchPlaceholder')}
            className="mb-8"
          >
            <Select>
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder={t('tripsPage.filterDifficulty')} />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="easy">{t('tripsPage.easy')}</SelectItem>
                <SelectItem value="moderate">{t('tripsPage.moderate')}</SelectItem>
                <SelectItem value="challenging">{t('tripsPage.challenging')}</SelectItem>
              </SelectContent>
            </Select>
            <Select>
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder={t('tripsPage.filterDuration')} />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="half-day">{t('tripsPage.halfDay')}</SelectItem>
                <SelectItem value="full-day">{t('tripsPage.fullDay')}</SelectItem>
                <SelectItem value="multi-day">{t('tripsPage.multiDay')}</SelectItem>
              </SelectContent>
            </Select>
          </FilterBar>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {trips.map((trip, index) => (
              <TripCard key={index} {...trip} />
            ))}
          </div>
        </div>
      </div>
    </PublicLayout>
  );
};

export default Trips;
