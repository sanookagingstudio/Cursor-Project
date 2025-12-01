# แก้ไข Domain Configuration Error

## สถานะปัจจุบัน
- ✅ `funaging.club` - ถูกเพิ่มใน Vercel แล้ว
- ❌ `funaging.studio` - มี "Invalid Configuration" (DNS ยังไม่ได้ตั้งค่า)

## ปัญหา
Vercel แจ้งว่า `funaging.studio` มี "Invalid Configuration" เพราะ:
- DNS records ยังไม่ได้ตั้งค่าใน Cloudflare
- nslookup ไม่พบ domain (Non-existent domain)

## วิธีแก้ไข

### ตัวเลือก 1: ใช้ `funaging.club` (แนะนำ)
ถ้าคุณซื้อ domain `funaging.club` และต้องการใช้ domain นี้:

**1. ลบ `funaging.studio` ออกจาก Vercel:**
```powershell
vercel domains remove funaging.studio
```

**2. ตั้งค่า DNS สำหรับ `funaging.club` ใน Cloudflare:**
- Login: https://dash.cloudflare.com
- เลือก domain `funaging.club`
- ไปที่ **DNS** → **Records**
- เพิ่ม A Record:
  - Type: **A**
  - Name: **@**
  - IPv4: **76.76.21.21**
  - **Proxy: DNS only** (ปิด proxy - ไม่เปิดสีส้ม)
  - Save

**3. รอ 5-30 นาที แล้วตรวจสอบ:**
```powershell
vercel domains inspect funaging.club
nslookup funaging.club
```

---

### ตัวเลือก 2: ใช้ `funaging.studio`
ถ้าคุณต้องการใช้ `funaging.studio`:

**1. ตั้งค่า DNS สำหรับ `funaging.studio` ใน Cloudflare:**
- Login: https://dash.cloudflare.com
- เลือก domain `funaging.studio`
- ไปที่ **DNS** → **Records**
- เพิ่ม A Record:
  - Type: **A**
  - Name: **@**
  - IPv4: **76.76.21.21**
  - **Proxy: DNS only** (ปิด proxy)
  - Save

**2. ลบ `funaging.club` (ถ้าไม่ต้องการ):**
```powershell
vercel domains remove funaging.club
```

**3. รอ 5-30 นาที แล้วตรวจสอบ:**
```powershell
vercel domains inspect funaging.studio
nslookup funaging.studio
```

---

## ⚠️ หมายเหตุสำคัญ

1. **Proxy status ต้องเป็น DNS only** (ไม่เปิด proxy - ไม่มีสีส้ม)
   - ถ้าเปิด proxy (สีส้ม) Vercel จะ verify domain ไม่ได้

2. **ใช้เวลา 5-30 นาที** หลังจากตั้งค่า DNS

3. **Vercel จะส่ง email** เมื่อ domain พร้อมใช้งาน

---

## ตรวจสอบสถานะ

```powershell
# ดู domains ทั้งหมด
vercel domains ls

# ตรวจสอบ domain
vercel domains inspect funaging.club
vercel domains inspect funaging.studio

# ตรวจสอบ DNS
nslookup funaging.club
nslookup funaging.studio
```

---

## คำแนะนำ

**แนะนำให้ใช้ `funaging.club`** เพราะ:
- คุณบอกว่าซื้อ domain นี้
- ถูกเพิ่มใน Vercel แล้ว
- เพียงแค่ตั้งค่า DNS ใน Cloudflare

**ลบ `funaging.studio`** ถ้าไม่ต้องการใช้:
```powershell
vercel domains remove funaging.studio
```



