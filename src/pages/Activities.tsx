import { PublicLayout } from "@/layouts/PublicLayout";
import { SectionHeader } from "@/components/ui/section-header";
import { FilterBar } from "@/components/ui/filter-bar";
import { ActivityCard } from "@/components/cards/ActivityCard";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useTranslation } from "react-i18next";
import { EditableText, Editable } from "@/components/editor/Editable";

const Activities = () => {
  const { t } = useTranslation();

  const activities = [
    {
      title: t('activitiesPage.activities.morningExercise.title'),
      description: t('activitiesPage.activities.morningExercise.description'),
      time: t('activitiesPage.activities.morningExercise.time'),
      duration: `1 ${t('common.hour')}`,
      capacity: 20,
      intensity: "Low" as const,
      tags: [t('activitiesPage.wellness'), t('activitiesPage.outdoor')],
      image: "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=2940&auto=format&fit=crop",
    },
    {
      title: t('activitiesPage.activities.artCraft.title'),
      description: t('activitiesPage.activities.artCraft.description'),
      time: t('activitiesPage.activities.artCraft.time'),
      duration: `2 ${t('common.hours')}`,
      capacity: 15,
      intensity: "Low" as const,
      tags: [t('activitiesPage.creative'), "Indoor"],
      image: "https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?q=80&w=2940&auto=format&fit=crop",
    },
    {
      title: t('activitiesPage.activities.brainGames.title'),
      description: t('activitiesPage.activities.brainGames.description'),
      time: t('activitiesPage.activities.brainGames.time'),
      duration: `1.5 ${t('common.hours')}`,
      capacity: 25,
      intensity: "Medium" as const,
      tags: ["Cognitive", t('activitiesPage.social')],
      image: "https://images.unsplash.com/photo-1611162617474-5b21e879e113?q=80&w=2940&auto=format&fit=crop",
    },
    {
      title: t('activitiesPage.activities.music.title'),
      description: t('activitiesPage.activities.music.description'),
      time: t('activitiesPage.activities.music.time'),
      duration: `1 ${t('common.hour')}`,
      capacity: 30,
      intensity: "Low" as const,
      tags: [t('activitiesPage.wellness'), t('activitiesPage.social')],
      image: "https://images.unsplash.com/photo-1507838153414-b4b713384ebd?q=80&w=2940&auto=format&fit=crop",
    },
    {
      title: t('activitiesPage.activities.garden.title'),
      description: t('activitiesPage.activities.garden.description'),
      time: t('activitiesPage.activities.garden.time'),
      duration: `2 ${t('common.hours')}`,
      capacity: 12,
      intensity: "Medium" as const,
      tags: ["Nature", t('activitiesPage.outdoor')],
      image: "https://images.unsplash.com/photo-1585320806297-11795182c6d7?q=80&w=2940&auto=format&fit=crop",
    },
    {
      title: t('activitiesPage.activities.cooking.title'),
      description: t('activitiesPage.activities.cooking.description'),
      time: t('activitiesPage.activities.cooking.time'),
      duration: `3 ${t('common.hours')}`,
      capacity: 10,
      intensity: "Medium" as const,
      tags: ["Food", t('activitiesPage.social')],
      image: "https://images.unsplash.com/photo-1556910103-1c02745a30bf?q=80&w=2940&auto=format&fit=crop",
    },
  ];

  return (
    <PublicLayout>
      <div className="section-padding">
        <div className="container-padding max-w-7xl mx-auto">
          <SectionHeader
            idPrefix="activities.header"
            title={t('activitiesPage.title')}
            description={t('activitiesPage.description')}
          />

          <FilterBar
            searchPlaceholder={t('activitiesPage.searchPlaceholder')}
            className="mb-8"
          >
            <Select>
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder={t('activitiesPage.filterIntensity')} />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="low">{t('activitiesPage.low')}</SelectItem>
                <SelectItem value="medium">{t('activitiesPage.medium')}</SelectItem>
                <SelectItem value="high">{t('activitiesPage.high')}</SelectItem>
              </SelectContent>
            </Select>
            <Select>
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder={t('activitiesPage.filterCategory')} />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="wellness">{t('activitiesPage.wellness')}</SelectItem>
                <SelectItem value="creative">{t('activitiesPage.creative')}</SelectItem>
                <SelectItem value="social">{t('activitiesPage.social')}</SelectItem>
                <SelectItem value="outdoor">{t('activitiesPage.outdoor')}</SelectItem>
              </SelectContent>
            </Select>
          </FilterBar>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {activities.map((activity, index) => (
              <ActivityCard 
                key={index} 
                idPrefix={`activities.item.${index}`}
                {...activity} 
              />
            ))}
          </div>
        </div>
      </div>
    </PublicLayout>
  );
};

export default Activities;
