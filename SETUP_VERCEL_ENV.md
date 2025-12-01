# ตั้งค่า Environment Variables ใน Vercel

## ปัญหา
- Domain `funaging.club` แสดงไม่ครบ
- Vercel ไม่มี Environment Variables

## วิธีแก้ไข

### วิธีที่ 1: ใช้ Vercel CLI (แนะนำ)

```powershell
# 1. เพิ่ม VITE_SUPABASE_URL
vercel env add VITE_SUPABASE_URL production
# เมื่อถามค่า ให้ใส่: https://ypjqtvwwognszkrlytlb.supabase.co

# 2. เพิ่ม VITE_SUPABASE_PUBLISHABLE_KEY
vercel env add VITE_SUPABASE_PUBLISHABLE_KEY production
# เมื่อถามค่า ให้ใส่ค่า key จาก .env

# 3. Redeploy
vercel --prod
```

### วิธีที่ 2: ใช้ Vercel Dashboard

1. ไปที่: https://vercel.com/dashboard
2. เลือก project `sanook-master-v2-main`
3. ไปที่ **Settings** → **Environment Variables**
4. เพิ่ม:
   - **Key:** `VITE_SUPABASE_URL`
   - **Value:** `https://ypjqtvwwognszkrlytlb.supabase.co`
   - **Environment:** Production
   - คลิก **Save**
5. เพิ่ม:
   - **Key:** `VITE_SUPABASE_PUBLISHABLE_KEY`
   - **Value:** (ค่า key จาก .env)
   - **Environment:** Production
   - คลิก **Save**
6. ไปที่ **Deployments**
7. คลิก **Redeploy** ที่ deployment ล่าสุด

### วิธีที่ 3: ใช้ Script (Automated)

รันคำสั่งนี้:
```powershell
.\setup-vercel-env.ps1
```

---

## ตรวจสอบ

```powershell
# ตรวจสอบ Environment Variables
vercel env ls

# Redeploy
vercel --prod
```

---

## หมายเหตุ

- Environment Variables ต้องตั้งค่าใน **Production** environment
- หลังจากตั้งค่าแล้วต้อง **Redeploy** เพื่อให้มีผล
- ใช้เวลา 1-2 นาที หลังจาก redeploy



