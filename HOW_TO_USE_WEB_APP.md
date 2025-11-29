# 🌐 วิธีใช้งานเว็บแอป Master V2

## 📍 ตอนนี้ใช้งานได้ที่ไหน?

### ✅ 1. Local Development (ตอนนี้)

**สถานะ:** ระบบพร้อมใช้งานในเครื่องของคุณ (Local)

**URL:** `http://localhost:8080`

---

## 🚀 วิธีรันเว็บแอป (Local)

### Step 1: ตั้งค่า Frontend

```powershell
# ติดตั้ง dependencies (ครั้งแรกเท่านั้น)
npm install

# รัน development server
npm run dev
```

**Frontend จะรันที่:** `http://localhost:8080`

---

### Step 2: ตั้งค่า Backend (Optional - ถ้าต้องการใช้ API)

```powershell
# ไปที่ backend directory
cd backend

# ติดตั้ง dependencies (ครั้งแรกเท่านั้น)
pip install -r requirements.txt

# ตั้งค่า environment variables
# สร้างไฟล์ .env และใส่:
# DATABASE_URL=your_supabase_url
# REDIS_URL=your_redis_url

# รัน FastAPI server
uvicorn app.main:app --reload --port 8000
```

**Backend API จะรันที่:** `http://localhost:8000`

---

### Step 3: เปิดเว็บแอป

1. เปิด browser
2. ไปที่: **`http://localhost:8080`**
3. ใช้งานได้เลย!

---

## 📱 หน้าที่สามารถเข้าใช้งานได้

### Public Pages (ไม่ต้อง Login)
- `/` - หน้าหลัก
- `/about` - เกี่ยวกับเรา
- `/activities` - กิจกรรม
- `/trips` - ทริป
- `/pricing` - ราคา
- `/sign-in` - เข้าสู่ระบบ
- `/sign-up` - สมัครสมาชิก

### Member Pages (ต้อง Login)
- `/member/dashboard` - Dashboard สมาชิก
- `/member/media-creator` - 🎨 Media Creator
- `/member/profile` - โปรไฟล์
- `/member/activities` - กิจกรรมของฉัน
- `/member/trips` - ทริปของฉัน

### Admin Pages (ต้อง Login + Admin Role)
- `/admin/dashboard` - Dashboard Admin
- `/admin/core-foundation` - Core Foundation
- `/admin/input-brain` - Input Brain
- `/admin/image-editor` - Image Editor
- `/admin/video-editor` - Video Editor
- `/admin/music-lab` - Music Lab
- `/admin/dashboard-publishing` - Dashboard & Publishing
- `/admin/theme-customization` - Theme Customization
- `/admin/monetization` - Monetization
- `/admin/analytics` - Analytics
- `/admin/cost-management` - Cost Management
- `/admin/external-apps` - External Apps
- `/admin/discount-management` - Discount Management

---

## 🌍 Production Deployment (ใช้งานจากที่ไหนก็ได้)

### วิธีที่ 1: Deploy ผ่าน Lovable (แนะนำ - ง่ายที่สุด)

1. ไปที่: https://lovable.dev/projects/b1dcfbcc-757f-4cf7-a141-fc9cb774d4b9
2. คลิก **Share** → **Publish**
3. เลือก domain หรือใช้ domain ที่ Lovable ให้
4. **เสร็จ!** เว็บแอปจะใช้งานได้จาก URL ที่ได้

**ข้อดี:**
- ✅ ง่ายและเร็ว
- ✅ ไม่ต้องตั้งค่า server
- ✅ Auto-deploy เมื่อ push code

---

### วิธีที่ 2: Deploy ผ่าน Vercel (แนะนำสำหรับ Production)

```powershell
# ติดตั้ง Vercel CLI
npm i -g vercel

# Deploy
vercel

# หรือ Deploy production
vercel --prod
```

**URL ที่ได้:** `https://your-project.vercel.app`

**ข้อดี:**
- ✅ ฟรี (Free tier)
- ✅ Auto-deploy จาก GitHub
- ✅ Custom domain
- ✅ Fast CDN

---

### วิธีที่ 3: Deploy ผ่าน Netlify

```powershell
# ติดตั้ง Netlify CLI
npm i -g netlify-cli

# Build project
npm run build

# Deploy
netlify deploy --prod
```

**URL ที่ได้:** `https://your-project.netlify.app`

---

### วิธีที่ 4: Deploy ผ่าน Hosting เอง (VPS/Server)

#### Frontend Deployment

```powershell
# Build production
npm run build

# ไฟล์จะอยู่ใน dist/
# Upload dist/ ไปยัง web server (Nginx, Apache, etc.)
```

#### Backend Deployment

```powershell
# ตั้งค่า server
cd backend
pip install -r requirements.txt

# ใช้ Gunicorn สำหรับ production
pip install gunicorn

# รัน server
gunicorn app.main:app --workers 4 --bind 0.0.0.0:8000
```

---

## 🔧 Environment Variables

### Frontend (.env)

```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
VITE_API_URL=http://localhost:8000  # สำหรับ local
# หรือ
VITE_API_URL=https://your-api-domain.com  # สำหรับ production
```

### Backend (.env)

```env
DATABASE_URL=postgresql://user:password@host:port/database
REDIS_URL=redis://localhost:6379
CELERY_BROKER_URL=redis://localhost:6379/0
CELERY_RESULT_BACKEND=redis://localhost:6379/0
```

---

## 📊 สรุป

### ตอนนี้ใช้งานได้ที่:
- ✅ **Local:** `http://localhost:8080` (ต้องรัน `npm run dev`)

### หลัง Deploy จะใช้งานได้ที่:
- 🌐 **Production URL:** ขึ้นอยู่กับที่ deploy
  - Lovable: `https://your-project.lovable.dev`
  - Vercel: `https://your-project.vercel.app`
  - Netlify: `https://your-project.netlify.app`
  - Custom Domain: `https://yourdomain.com`

---

## 🎯 Quick Start (Local)

```powershell
# 1. ติดตั้ง dependencies
npm install

# 2. รัน development server
npm run dev

# 3. เปิด browser
# ไปที่: http://localhost:8080
```

**เสร็จ!** ใช้งานได้เลย 🎉

---

## 🚀 Quick Deploy (Production)

### Lovable (แนะนำ - ง่ายที่สุด)
1. ไปที่: https://lovable.dev/projects/b1dcfbcc-757f-4cf7-a141-fc9cb774d4b9
2. คลิก **Share** → **Publish**
3. **เสร็จ!**

### Vercel (แนะนำสำหรับ Production)
```powershell
npm i -g vercel
vercel --prod
```

---

**Last Updated:** 2025-12-02  
**Status:** ✅ Ready to Use


