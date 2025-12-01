# แก้ไขปัญหา Domain แสดงไม่ครบ - Quick Fix

## ปัญหา
- Domain `funaging.club` แสดงไม่ครบ
- Vercel ไม่มี Environment Variables

## วิธีแก้ไข (เร็วที่สุด)

### 1. ไปที่ Vercel Dashboard
https://vercel.com/dashboard

### 2. เลือก Project
`sanook-master-v2-main`

### 3. ไปที่ Settings → Environment Variables

### 4. เพิ่ม Environment Variables:

**Variable 1:**
- **Key:** `VITE_SUPABASE_URL`
- **Value:** `https://ypjqtvwwognszkrlytlb.supabase.co`
- **Environment:** Production ✅
- คลิก **Save**

**Variable 2:**
- **Key:** `VITE_SUPABASE_PUBLISHABLE_KEY`
- **Value:** (ดูจากไฟล์ `.env` ในเครื่อง)
- **Environment:** Production ✅
- คลิก **Save**

### 5. Redeploy
1. ไปที่ **Deployments**
2. คลิก **...** ที่ deployment ล่าสุด
3. คลิก **Redeploy**
4. เลือก **Use existing Build Cache**
5. คลิก **Redeploy**

### 6. รอ 1-2 นาที
- Vercel จะ rebuild และ deploy ใหม่
- Domain จะแสดงครบแล้ว

---

## ตรวจสอบ

```powershell
# ตรวจสอบ Environment Variables
vercel env ls

# ตรวจสอบ domain
curl -I https://funaging.club
```

---

## สรุป

**ต้องทำ:**
1. ✅ เพิ่ม Environment Variables ใน Vercel Dashboard
2. ✅ Redeploy

**ไม่ต้องทำ:**
- ไม่ต้องแก้ไข code
- ไม่ต้องตั้งค่า DNS ใหม่



