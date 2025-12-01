# อธิบาย Proxy Status ใน Cloudflare

## สัญลักษณ์ Proxy Status

### ❌ Proxy เปิด (Proxied) - ไม่ถูกต้อง
- **Icon:** สีเทา/สีส้ม cloud with arrow (☁️→)
- **ความหมาย:** Cloudflare proxy เปิดอยู่
- **ผลลัพธ์:** Vercel จะ verify domain ไม่ได้
- **ต้องปิด**

### ✅ Proxy ปิด (DNS only) - ถูกต้อง
- **Icon:** สีเทา cloud without arrow (☁️) หรือไม่มี icon
- **ความหมาย:** Cloudflare proxy ปิด (DNS only)
- **ผลลัพธ์:** Vercel จะ verify domain ได้
- **ต้องเป็นแบบนี้**

---

## วิธีตรวจสอบ

### ในตาราง DNS Records:
- ถ้าเห็น **cloud with arrow** (☁️→) = Proxy เปิด ❌
- ถ้าเห็น **cloud without arrow** (☁️) หรือไม่มี icon = Proxy ปิด ✅

### ใน Form แก้ไข:
- Toggle **"ON"** (สีส้ม) = Proxy เปิด ❌
- Toggle **"OFF"** (สีเทา) = Proxy ปิด ✅

---

## วิธีแก้ไข

1. คลิก **"Edit"** ที่ record
2. ใน form ด้านล่าง:
   - ตั้ง **Proxy status toggle** เป็น **"OFF"** (สีเทา)
3. คลิก **"Save"**

---

## สรุป

**Proxy status ต้องเป็น "OFF" (DNS only)** เพื่อให้ Vercel verify domain ได้



