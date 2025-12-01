# คำแนะนำการตั้งค่า Environment Variables

## คำถามที่ 1: Environments

### เลือก "All Environments" ได้ไหม?

**คำตอบ: ได้!** ✅

**แนะนำ:**
- **All Environments** = ใช้ได้ทั้ง Production, Preview, และ Development
- **Production** = ใช้ได้เฉพาะ Production เท่านั้น

**สำหรับกรณีนี้:**
- เลือก **"All Environments"** ได้เลย ✅
- จะใช้ได้ทั้ง Production และ Preview
- สะดวกกว่า ไม่ต้องตั้งค่าซ้ำ

---

## คำถามที่ 2: ดู Value จากไหน?

### ดูจากไฟล์ `.env` ในโปรเจค

**ตำแหน่ง:**
```
D:\SanookAgingStudio\shadow project\sanook-master-v2-main\.env
```

**วิธีดู:**

### วิธีที่ 1: ใช้ Cursor (แนะนำ)
1. เปิด Cursor
2. เปิดโปรเจค `sanook-master-v2-main`
3. เปิดไฟล์ `.env` (อาจจะต้องแสดง hidden files)
4. หาบรรทัด:
   ```
   VITE_SUPABASE_PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```
5. Copy ค่าหลัง `=` (ไม่รวมเครื่องหมาย `=`)

### วิธีที่ 2: ใช้ Windows Explorer
1. เปิด Windows Explorer
2. ไปที่: `D:\SanookAgingStudio\shadow project\sanook-master-v2-main`
3. เปิดไฟล์ `.env` ด้วย Notepad หรือ Text Editor
4. หาบรรทัด `VITE_SUPABASE_PUBLISHABLE_KEY=`
5. Copy ค่าหลัง `=`

### วิธีที่ 3: ใช้ PowerShell (ใน Cursor Terminal)
```powershell
cd "d:\SanookAgingStudio\shadow project\sanook-master-v2-main"
Get-Content .env | Select-String "VITE_SUPABASE_PUBLISHABLE_KEY"
```

---

## สรุปการตั้งค่า

### Variable 1: VITE_SUPABASE_URL
- **Key:** `VITE_SUPABASE_URL`
- **Value:** `https://ypjqtvwwognszkrlytlb.supabase.co`
- **Environments:** ✅ **All Environments** (หรือ Production ก็ได้)

### Variable 2: VITE_SUPABASE_PUBLISHABLE_KEY
- **Key:** `VITE_SUPABASE_PUBLISHABLE_KEY`
- **Value:** (ดูจากไฟล์ `.env` ในโปรเจค)
- **Environments:** ✅ **All Environments** (หรือ Production ก็ได้)

---

## หมายเหตุ

- ไฟล์ `.env` อาจจะถูกซ่อน (hidden file)
- ใน Cursor: กด `Ctrl+Shift+P` → พิมพ์ "Show Hidden Files"
- ใน Windows Explorer: View → Show → Hidden items



