import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import translationEN from './locales/en.json';
import translationTH from './locales/th.json';
import translationZH from './locales/zh.json';
import translationJA from './locales/ja.json';
import translationKO from './locales/ko.json';
import translationRU from './locales/ru.json';
import translationFR from './locales/fr.json';

const resources = {
  en: {
    translation: translationEN
  },
  th: {
    translation: translationTH
  },
  zh: {
    translation: translationZH
  },
  ja: {
    translation: translationJA
  },
  ko: {
    translation: translationKO
  },
  ru: {
    translation: translationRU
  },
  fr: {
    translation: translationFR
  }
};

i18n
  .use(initReactI18next)
  .init({
    resources,
    lng: 'th', // default language
    fallbackLng: 'en',
    interpolation: {
      escapeValue: false
    }
  });

export default i18n;
