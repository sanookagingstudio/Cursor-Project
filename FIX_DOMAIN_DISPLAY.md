# แก้ไขปัญหา Domain แสดงไม่ครบ

## ปัญหา
- Domain `funaging.club` ทำงานแล้ว (Status: 200)
- แต่แสดงไม่ครบ (อาจเป็นเพราะ Environment Variables ไม่ครบ)

## สาเหตุ
Vercel ไม่มี Environment Variables ที่จำเป็น:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_PUBLISHABLE_KEY`
- `VITE_API_BASE_URL` (ถ้ามี)

## วิธีแก้ไข

### 1. ตั้งค่า Environment Variables ใน Vercel

**วิธีที่ 1: ใช้ Vercel CLI**
```powershell
# เพิ่ม Supabase URL
vercel env add VITE_SUPABASE_URL production

# เพิ่ม Supabase Key
vercel env add VITE_SUPABASE_PUBLISHABLE_KEY production
```

**วิธีที่ 2: ใช้ Vercel Dashboard**
1. ไปที่: https://vercel.com/dashboard
2. เลือก project `sanook-master-v2-main`
3. ไปที่ **Settings** → **Environment Variables**
4. เพิ่ม:
   - `VITE_SUPABASE_URL` = `your_supabase_url`
   - `VITE_SUPABASE_PUBLISHABLE_KEY` = `your_supabase_key`
5. เลือก **Production** environment
6. คลิก **Save**

### 2. Redeploy

หลังจากตั้งค่า Environment Variables แล้ว:
```powershell
# Redeploy
vercel --prod
```

หรือ:
- ไปที่ Vercel Dashboard
- คลิก **Deployments**
- คลิก **Redeploy** ที่ deployment ล่าสุด

### 3. ตรวจสอบ

```powershell
# ตรวจสอบ Environment Variables
vercel env ls

# ตรวจสอบ domain
curl -I https://funaging.club
```

---

## Environment Variables ที่ต้องตั้งค่า

### Required:
- `VITE_SUPABASE_URL` - Supabase project URL
- `VITE_SUPABASE_PUBLISHABLE_KEY` - Supabase anon/public key

### Optional:
- `VITE_API_BASE_URL` - Backend API URL (default: `/api`)

---

## หมายเหตุ

- Environment Variables ต้องตั้งค่าใน **Production** environment
- หลังจากตั้งค่าแล้วต้อง **Redeploy** เพื่อให้มีผล
- ใช้เวลา 1-2 นาที หลังจาก redeploy



