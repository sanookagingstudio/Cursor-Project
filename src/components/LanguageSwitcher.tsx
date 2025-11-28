import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu";
import { useTranslation } from "react-i18next";

const languages = [
  { code: "th", name: "ไทย", flag: "🇹🇭", region: "Popular" },
  { code: "en", name: "English", flag: "🇬🇧", region: "Popular" },
  { code: "zh", name: "中文", flag: "🇨🇳", region: "Popular" },
  { code: "ja", name: "日本語", flag: "🇯🇵", region: "Popular" },
  { code: "ko", name: "한국어", flag: "🇰🇷", region: "Popular" },
  { code: "ru", name: "Русский", flag: "🇷🇺", region: "Other" },
  { code: "fr", name: "Français", flag: "🇫🇷", region: "Other" },
];

export function LanguageSwitcher() {
  const { i18n } = useTranslation();

  const changeLanguage = (lng: string) => {
    i18n.changeLanguage(lng);
  };

  const getCurrentFlag = () => {
    const current = languages.find(lang => lang.code === i18n.language);
    return current?.flag || "🇹🇭";
  };

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="icon" className="relative text-2xl hover:scale-110 transition-transform">
          <span>{getCurrentFlag()}</span>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-48">
        {languages.filter(lang => lang.region === "Popular").map((lang) => (
          <DropdownMenuItem 
            key={lang.code}
            onClick={() => changeLanguage(lang.code)}
            className={i18n.language === lang.code ? "bg-accent" : ""}
          >
            <span className="mr-3 text-xl">{lang.flag}</span>
            <span className="font-medium">{lang.name}</span>
          </DropdownMenuItem>
        ))}
        <DropdownMenuSeparator />
        {languages.filter(lang => lang.region === "Other").map((lang) => (
          <DropdownMenuItem 
            key={lang.code}
            onClick={() => changeLanguage(lang.code)}
            className={i18n.language === lang.code ? "bg-accent" : ""}
          >
            <span className="mr-3 text-xl">{lang.flag}</span>
            <span className="font-medium">{lang.name}</span>
          </DropdownMenuItem>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
