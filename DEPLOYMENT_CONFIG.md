# ⚙️ Deployment Configuration - Platform Agnostic

## 🎯 หลักการ: Platform Independent

ระบบออกแบบให้ **เปลี่ยน Platform ได้ง่าย** โดยไม่กระทบการทำงาน

---

## 📁 โครงสร้าง Configuration

```
project/
├── .env.example              # Environment variables template
├── .env.production          # Production config (ไม่ commit)
├── vite.config.ts          # Vite config (platform agnostic)
├── public/
│   ├── manifest.json       # PWA manifest (ทุก platform)
│   └── favicon.ico         # Icon (ทุก platform)
└── deploy.ps1              # Deployment script
```

---

## 🔧 Environment Variables

### Frontend (.env)

```env
# Base URLs (เปลี่ยนตาม Platform)
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key

# API URL (เปลี่ยนตาม Platform)
# Local
VITE_API_URL=http://localhost:8000

# Production - Lovable
# VITE_API_URL=https://your-project.lovable.dev/api

# Production - Vercel
# VITE_API_URL=https://your-project.vercel.app/api

# Production - Netlify
# VITE_API_URL=https://your-project.netlify.app/api

# Production - Custom Domain
# VITE_API_URL=https://funaging.studio/api
```

### Backend (.env)

```env
# Database (ไม่เปลี่ยน - ใช้ Supabase)
DATABASE_URL=postgresql://user:password@host:port/database

# Redis (เปลี่ยนตาม Platform)
# Local
REDIS_URL=redis://localhost:6379/0

# Production - Cloud Redis
# REDIS_URL=redis://your-redis-host:6379/0

# Celery
CELERY_BROKER_URL=redis://localhost:6379/0
CELERY_RESULT_BACKEND=redis://localhost:6379/0
```

---

## 🚀 Deployment Scripts

### 1. deploy.ps1 (Automated)

```powershell
# Deploy ทุก Platform
.\deploy.ps1

# Deploy เฉพาะ Vercel
.\deploy.ps1 -Platform vercel

# Deploy Production
.\deploy.ps1 -Platform vercel -Production
```

### 2. Manual Deploy

**Lovable:**
- ไปที่ Dashboard → Share → Publish

**Vercel:**
```powershell
vercel --prod
```

**Netlify:**
```powershell
netlify deploy --prod
```

---

## 🔄 เปลี่ยน Platform ได้ง่าย

### Scenario 1: เปลี่ยนจาก Lovable → Vercel

**ขั้นตอน:**
1. สร้าง Vercel account
2. รัน: `.\deploy.ps1 -Platform vercel`
3. ตั้งค่า Custom Domain ใน Vercel
4. **เสร็จ!** ไม่กระทบโค้ด

### Scenario 2: เปลี่ยนจาก Vercel → Netlify

**ขั้นตอน:**
1. สร้าง Netlify account
2. รัน: `.\deploy.ps1 -Platform netlify`
3. ตั้งค่า Custom Domain ใน Netlify
4. **เสร็จ!** ไม่กระทบโค้ด

### Scenario 3: ใช้หลาย Platform พร้อมกัน

**ขั้นตอน:**
1. Deploy ไปทุก Platform: `.\deploy.ps1`
2. ตั้งค่า Custom Domain ในแต่ละ Platform
3. ใช้ DNS Load Balancing (optional)

---

## 📋 Platform Comparison

| Feature | Lovable | Vercel | Netlify | VPS |
|---------|---------|--------|---------|-----|
| **Setup** | ⭐ ง่ายที่สุด | ⭐⭐ ง่าย | ⭐⭐ ง่าย | ⭐⭐⭐⭐ ยาก |
| **Custom Domain** | ✅ | ✅ | ✅ | ✅ |
| **SSL** | ✅ Auto | ✅ Auto | ✅ Auto | ⚠️ ต้องตั้งค่า |
| **CDN** | ✅ | ✅ | ✅ | ⚠️ ต้องตั้งค่า |
| **Auto Deploy** | ✅ | ✅ | ✅ | ⚠️ ต้องตั้งค่า |
| **ราคา** | ฟรี | ฟรี | ฟรี | ~120-180 บาท/เดือน |
| **เปลี่ยนได้ง่าย** | ✅ | ✅ | ✅ | ⚠️ ยาก |

---

## ✅ Best Practice

### 1. ใช้ Environment Variables

**ไม่ Hardcode URLs:**
```typescript
// ❌ ไม่ดี
const API_URL = "https://your-project.vercel.app/api"

// ✅ ดี
const API_URL = import.meta.env.VITE_API_URL
```

### 2. ใช้ Relative Paths

**ไม่ Hardcode Absolute Paths:**
```typescript
// ❌ ไม่ดี
fetch("https://your-domain.com/api/health")

// ✅ ดี
fetch("/api/health")  // หรือใช้ env variable
```

### 3. Platform Agnostic Config

**ใช้ Config File:**
```typescript
// config.ts
export const config = {
  apiUrl: import.meta.env.VITE_API_URL || "/api",
  supabaseUrl: import.meta.env.VITE_SUPABASE_URL,
  // ...
}
```

---

## 🔐 Security

### Environment Variables

**ไม่ Commit .env:**
```
.env
.env.local
.env.production
```

**Commit .env.example:**
```
.env.example  # Template only
```

### Secrets Management

**ใช้ Platform Secrets:**
- Vercel: Environment Variables
- Netlify: Site Settings → Environment Variables
- Lovable: Project Settings → Environment Variables

---

## 📊 Migration Guide

### จาก Platform A → Platform B

**1. Backup:**
```powershell
.\onepack.ps1 -Action backup -Message "Before migration"
```

**2. Deploy ไป Platform ใหม่:**
```powershell
.\deploy.ps1 -Platform [new-platform]
```

**3. ตั้งค่า Environment Variables:**
- Copy จาก Platform เก่า
- ตั้งค่าใน Platform ใหม่

**4. ตั้งค่า Custom Domain:**
- เปลี่ยน DNS ใน Domain Provider
- ตั้งค่าใน Platform ใหม่

**5. ทดสอบ:**
- ตรวจสอบ URL ใหม่
- ทดสอบทุก Features

**6. Switch DNS:**
- เปลี่ยน DNS → ชี้ไป Platform ใหม่
- รอ DNS Propagation (5-30 นาที)

**7. ตรวจสอบ:**
- ทดสอบ URL ใหม่
- ถ้าทุกอย่าง OK → ลบ Platform เก่า

---

## 🎯 Recommended Setup

### Development
- **Local:** `http://localhost:8080`
- **Backend:** `http://localhost:8000`

### Staging
- **Platform:** Vercel Preview
- **URL:** `https://your-project-git-branch.vercel.app`

### Production
- **Platform:** Vercel (แนะนำ) หรือ Lovable
- **Domain:** `https://funaging.studio`
- **Backup:** Netlify (optional)

---

**Last Updated:** 2025-12-02  
**Status:** ✅ Platform Agnostic Ready

