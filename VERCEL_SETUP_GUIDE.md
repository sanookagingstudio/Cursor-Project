# 🔧 Vercel Setup Guide - แก้ปัญหาเว็บว่างเปล่า

## 🔍 สาเหตุที่เว็บว่างเปล่า

### 1. ❌ Environment Variables ไม่ได้ตั้งค่า
- `VITE_SUPABASE_URL` - จำเป็น
- `VITE_SUPABASE_PUBLISHABLE_KEY` - จำเป็น
- `VITE_API_BASE_URL` - Optional

### 2. ❌ Routing ไม่ทำงาน (SPA)
- ต้องมี `vercel.json` สำหรับ SPA routing
- ✅ สร้างแล้ว

---

## ✅ วิธีแก้ไข

### Step 1: ตั้งค่า Environment Variables ใน Vercel

**1. ไปที่ Vercel Dashboard:**
- Project → Settings → Environment Variables

**2. เพิ่ม Environment Variables:**

```
VITE_SUPABASE_URL = your_supabase_url
VITE_SUPABASE_PUBLISHABLE_KEY = your_supabase_anon_key
VITE_API_BASE_URL = (optional - ถ้ามี Backend API)
```

**3. คลิก "Save"**

**4. Redeploy:**
- ไปที่ Deployments
- คลิก "..." → "Redeploy"
- หรือ Vercel จะ auto-redeploy เมื่อมี commit ใหม่

---

### Step 2: ตรวจสอบ Console Errors

**1. เปิด Browser Console:**
- กด F12
- ไปที่ tab "Console"
- ดู error messages

**2. Error ที่อาจเจอ:**
- `VITE_SUPABASE_URL is not defined` → ต้องตั้งค่า Environment Variables
- `Failed to fetch` → API URL ไม่ถูกต้อง
- `Cannot read property...` → JavaScript error

---

### Step 3: ตรวจสอบ Build Logs

**1. ไปที่ Vercel Dashboard:**
- Project → Deployments
- คลิก Deployment ล่าสุด
- ดู "Build Logs"

**2. ตรวจสอบ:**
- Build สำเร็จหรือไม่
- มี warnings หรือ errors หรือไม่

---

## 📋 Checklist

### ก่อน Deploy
- [x] vercel.json สร้างแล้ว (SPA routing)
- [ ] Environment Variables ตั้งค่าแล้ว
- [ ] Build สำเร็จใน local

### หลัง Deploy
- [ ] ตั้งค่า Environment Variables ใน Vercel
- [ ] Redeploy
- [ ] ตรวจสอบ Console Errors
- [ ] ทดสอบเว็บแอป

---

## 🚀 Quick Fix

### 1. ตั้งค่า Environment Variables
```
Vercel Dashboard → Settings → Environment Variables
→ เพิ่ม VITE_SUPABASE_URL และ VITE_SUPABASE_PUBLISHABLE_KEY
```

### 2. Redeploy
```
Deployments → ... → Redeploy
```

### 3. ตรวจสอบ
```
เปิด Browser Console (F12) → ดู errors
```

---

## 🎯 สรุป

**ปัญหา:** เว็บว่างเปล่า

**สาเหตุ:**
1. Environment Variables ไม่ได้ตั้งค่า
2. Routing ไม่ทำงาน (แก้แล้วด้วย vercel.json)

**วิธีแก้:**
1. ✅ สร้าง vercel.json แล้ว (push ไปแล้ว)
2. ⚠️ ตั้งค่า Environment Variables ใน Vercel
3. ⚠️ Redeploy

---

**Last Updated:** 2025-12-02  
**Status:** ✅ vercel.json Ready - ต้องตั้งค่า Environment Variables


