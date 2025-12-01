# Deploy ไป Production (funaging.club)

## ปัญหา
- แก้ไขไฟล์แล้ว แต่ไม่เห็นการเปลี่ยนแปลงที่ https://funaging.club
- เพราะการแก้ไขยังอยู่ใน local ยังไม่ได้ deploy ไป Vercel

## วิธีแก้ไข

### 1. Deploy ไป Vercel Production

```powershell
# ตรวจสอบ login
vercel whoami

# ถ้ายังไม่ได้ login
vercel login

# Deploy ไป production
vercel --prod
```

### 2. หรือใช้ Script อัตโนมัติ

```powershell
.\deploy-production.ps1
```

---

## สรุปการแก้ไขที่ต้อง Deploy

### ✅ 1. เมนูตัวหนังสือไม่หาย
- เปลี่ยน active menu styling
- ไฟล์: `src/layouts/AdminLayout.tsx`

### ✅ 2. เพิ่ม Visual Theme Editor
- เพิ่มในเมนู System Management
- ไฟล์: `src/layouts/AdminLayout.tsx`

### ✅ 3. ธงชาติและภาษา
- LanguageSwitcher แสดงธงชาติ
- ไฟล์: `src/components/LanguageSwitcher.tsx`

### ✅ 4. เมนูเปลี่ยนตามภาษา
- ใช้ useMemo เพื่อ re-render
- ไฟล์: `src/layouts/AdminLayout.tsx`

---

## หลังจาก Deploy

1. **รอ 1-2 นาที** ให้ Vercel build เสร็จ
2. **Hard Refresh:** `Ctrl + Shift + R`
3. **ตรวจสอบ:** https://funaging.club

---

## หมายเหตุ

- การแก้ไขใน local จะไม่เห็นผลใน production จนกว่าจะ deploy
- ต้อง deploy ทุกครั้งที่แก้ไข code
- Vercel จะ rebuild อัตโนมัติเมื่อ deploy


