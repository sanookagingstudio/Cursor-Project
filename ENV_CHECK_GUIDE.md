# 🔍 คู่มือตรวจสอบและแก้ไข Environment Variables

## 📋 ปัญหาที่พบ

แสดง error: **"การตั้งค่าไม่ครบถ้วน - ไม่พบ Supabase configuration"**

---

## ✅ วิธีตรวจสอบ

### 1. ตรวจสอบไฟล์ `.env` ใน Local

**ตำแหน่งไฟล์:**
```
D:\SanookAgingStudio\shadow project\sanook-master-v2-main\.env
```

**คำสั่งตรวจสอบ:**
```powershell
cd "D:\SanookAgingStudio\shadow project\sanook-master-v2-main"
Get-Content .env
```

**ค่าที่ต้องมี:**
```env
VITE_SUPABASE_URL="https://ypjqtvwwognszkrlytlb.supabase.co"
VITE_SUPABASE_PUBLISHABLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**หมายเหตุ:** 
- มี quotes (`"..."`) รอบค่าก็ได้ - Vite จะตัดให้อัตโนมัติ
- หรือไม่มี quotes ก็ได้

---

### 2. ตรวจสอบใน Production (funaging.club)

**ปัญหาที่เป็นไปได้:**
- ❌ Environment variables ไม่ได้ตั้งค่าใน Vercel
- ❌ ตั้งค่าแต่ค่าผิด
- ❌ ตั้งค่าแต่ไม่ได้ Redeploy

**วิธีตรวจสอบและแก้ไข:**

#### ขั้นตอนที่ 1: ตรวจสอบใน Vercel Dashboard

1. ไปที่: https://vercel.com/dashboard
2. เลือก Project: `sanook-master-v2-main` (หรือชื่อ project ที่ deploy)
3. ไปที่ **Settings** → **Environment Variables**
4. ตรวจสอบว่ามีตัวแปรเหล่านี้หรือไม่:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_PUBLISHABLE_KEY`

#### ขั้นตอนที่ 2: ตั้งค่า Environment Variables

**ถ้ายังไม่มี ให้เพิ่ม:**

1. คลิก **"Add New"**
2. เพิ่มตัวแปรที่ 1:
   - **Key:** `VITE_SUPABASE_URL`
   - **Value:** `https://ypjqtvwwognszkrlytlb.supabase.co`
   - **Environments:** เลือก **"All Environments"** ✅
3. เพิ่มตัวแปรที่ 2:
   - **Key:** `VITE_SUPABASE_PUBLISHABLE_KEY`
   - **Value:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwanF0dnd3b2duc3prcmx5dGxiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwODUxOTMsImV4cCI6MjA3OTY2MTE5M30.VeZ-8pRiWTkWqMvP68ZUwxpvr41waTkv8B_28sJb5_c`
   - **Environments:** เลือก **"All Environments"** ✅
4. คลิก **"Save"**

#### ขั้นตอนที่ 3: Redeploy

**สำคัญมาก:** ต้อง Redeploy ถึงจะเห็นผล!

1. ไปที่ **Deployments** tab
2. คลิก **"..."** บน deployment ล่าสุด
3. เลือก **"Redeploy"**
4. รอให้ build เสร็จ (1-2 นาที)

---

### 3. ตรวจสอบผ่าน Browser Console

**ใน Production (funaging.club):**

1. เปิด Browser DevTools (F12)
2. ไปที่ **Console** tab
3. ดูว่ามี error message อะไรเกี่ยวกับ Supabase หรือไม่
4. พิมพ์ใน Console:
   ```javascript
   console.log('SUPABASE_URL:', import.meta.env.VITE_SUPABASE_URL);
   console.log('SUPABASE_KEY:', import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY ? '[SET]' : '[NOT SET]');
   ```

---

## 🔧 การแก้ไข

### สำหรับ Local Development

**ไฟล์ `.env` ต้องมี:**
```env
VITE_SUPABASE_URL="https://ypjqtvwwognszkrlytlb.supabase.co"
VITE_SUPABASE_PUBLISHABLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwanF0dnd3b2duc3prcmx5dGxiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwODUxOTMsImV4cCI6MjA3OTY2MTE5M30.VeZ-8pRiWTkWqMvP68ZUwxpvr41waTkv8B_28sJb5_c"
```

**หมายเหตุ:**
- สามารถมี quotes หรือไม่มี quotes ได้
- Vite จะอ่านค่าจาก `.env` อัตโนมัติ
- Restart dev server (`npm run dev`) หลังแก้ไข `.env`

---

### สำหรับ Production (Vercel)

**ต้องตั้งค่า Environment Variables ใน Vercel:**

1. **Key:** `VITE_SUPABASE_URL`
   - **Value:** `https://ypjqtvwwognszkrlytlb.supabase.co`
   - **Environments:** All Environments ✅

2. **Key:** `VITE_SUPABASE_PUBLISHABLE_KEY`
   - **Value:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwanF0dnd3b2duc3prcmx5dGxiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwODUxOTMsImV4cCI6MjA3OTY2MTE5M30.VeZ-8pRiWTkWqMvP68ZUwxpvr41waTkv8B_28sJb5_c`
   - **Environments:** All Environments ✅

3. **สำคัญ:** ต้อง **Redeploy** หลังจากตั้งค่า Environment Variables!

---

## 🎯 สรุป

### Local (Development):
- ✅ ไฟล์ `.env` มีอยู่และถูกต้อง
- ✅ Vite จะโหลดค่าจาก `.env` อัตโนมัติ
- ✅ Restart dev server หลังแก้ไข `.env`

### Production (funaging.club):
- ❌ ต้องตั้งค่า Environment Variables ใน Vercel Dashboard
- ❌ ต้อง Redeploy หลังจากตั้งค่า
- ❌ ไม่ได้ใช้ไฟล์ `.env` (Vercel จะอ่านจาก Environment Variables)

---

## ✅ วิธีแก้ไขสำหรับ Production

1. ไปที่ Vercel Dashboard
2. ตั้งค่า Environment Variables (ตามข้างบน)
3. Redeploy
4. รอ 1-2 นาที
5. Refresh หน้า funaging.club (Hard Refresh: Ctrl + Shift + R)

---

## 📝 Checklist

- [ ] ไฟล์ `.env` มีอยู่ใน local และมีค่าถูกต้อง
- [ ] Environment Variables ตั้งค่าใน Vercel แล้ว
- [ ] Redeploy ใน Vercel แล้ว
- [ ] รอ build เสร็จ (1-2 นาที)
- [ ] Hard Refresh หน้า funaging.club


