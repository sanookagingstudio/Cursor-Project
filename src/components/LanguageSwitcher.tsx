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
  { code: "th", name: "ไทย", shortName: "TH", flag: "🇹🇭", region: "Popular" },
  { code: "en", name: "English", shortName: "EN", flag: "🇬🇧", region: "Popular" },
  { code: "zh", name: "中文", shortName: "ZH", flag: "🇨🇳", region: "Popular" },
  { code: "ja", name: "日本語", shortName: "JA", flag: "🇯🇵", region: "Popular" },
  { code: "ko", name: "한국어", shortName: "KO", flag: "🇰🇷", region: "Popular" },
  { code: "ru", name: "Русский", shortName: "RU", flag: "🇷🇺", region: "Other" },
  { code: "fr", name: "Français", shortName: "FR", flag: "🇫🇷", region: "Other" },
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

  const getCurrentLanguage = () => {
    const current = languages.find(lang => lang.code === i18n.language);
    return current || languages[0];
  };

  const getFlagUrl = (code: string) => {
    const map: Record<string, string> = {
      th: 'th',
      en: 'gb',
      zh: 'cn',
      ja: 'jp',
      ko: 'kr',
      ru: 'ru',
      fr: 'fr'
    };
    return `https://flagcdn.com/w40/${map[code] || 'th'}.png`;
  };

  const currentLang = getCurrentLanguage();

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="sm" className="relative gap-2 hover:scale-105 transition-transform min-w-[60px]">
          <img 
            src={getFlagUrl(currentLang.code)} 
            alt={currentLang.name} 
            className="w-6 h-4 object-cover rounded-sm shadow-sm" 
          />
          <span className="font-medium text-sm">{currentLang.shortName}</span>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-56">
        {languages.filter(lang => lang.region === "Popular").map((lang) => (
          <DropdownMenuItem 
            key={lang.code}
            onClick={() => changeLanguage(lang.code)}
            className={i18n.language === lang.code ? "bg-accent" : ""}
          >
            <img 
              src={getFlagUrl(lang.code)} 
              alt={lang.name} 
              className="w-6 h-4 mr-3 object-cover rounded-sm shadow-sm" 
            />
            <span className="font-medium flex-1">{lang.name}</span>
            <span className="text-xs text-muted-foreground ml-2">{lang.shortName}</span>
          </DropdownMenuItem>
        ))}
        <DropdownMenuSeparator />
        {languages.filter(lang => lang.region === "Other").map((lang) => (
          <DropdownMenuItem 
            key={lang.code}
            onClick={() => changeLanguage(lang.code)}
            className={i18n.language === lang.code ? "bg-accent" : ""}
          >
            <img 
              src={getFlagUrl(lang.code)} 
              alt={lang.name} 
              className="w-6 h-4 mr-3 object-cover rounded-sm shadow-sm" 
            />
            <span className="font-medium flex-1">{lang.name}</span>
            <span className="text-xs text-muted-foreground ml-2">{lang.shortName}</span>
          </DropdownMenuItem>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
