# แก้ไข Domain Configuration Error

## ปัญหา
Vercel แจ้งว่า `funaging.studio` มี "Invalid Configuration"

## สาเหตุที่เป็นไปได้
1. DNS records ยังไม่ได้ตั้งค่าใน Cloudflare
2. DNS records ตั้งค่าไม่ถูกต้อง
3. Domain name ไม่ตรงกัน (email บอก `funaging.studio` แต่เราเพิ่ม `funaging.club`)

## วิธีแก้ไข

### 1. ตรวจสอบ Domain ที่เพิ่มใน Vercel
```powershell
vercel domains inspect funaging.studio
vercel domains inspect funaging.club
```

### 2. ตั้งค่า DNS ใน Cloudflare

**สำหรับ `funaging.studio`:**
1. Login: https://dash.cloudflare.com
2. เลือก domain `funaging.studio`
3. ไปที่ **DNS** → **Records**
4. เพิ่ม A Record:
   - Type: **A**
   - Name: **@** (หรือ `funaging.studio`)
   - IPv4 address: **76.76.21.21**
   - **Proxy status: DNS only** (ปิด proxy - ไม่เปิดสีส้ม)
   - TTL: **Auto**
   - คลิก **Save**

5. เพิ่ม CNAME สำหรับ www (Optional):
   - Type: **CNAME**
   - Name: **www**
   - Target: **cname.vercel-dns.com**
   - **Proxy status: DNS only**
   - TTL: **Auto**
   - คลิก **Save**

### 3. ตรวจสอบ DNS Propagation
```powershell
nslookup funaging.studio
```

ควรเห็น:
```
Name:    funaging.studio
Address:  76.76.21.21
```

### 4. ลบ Domain ที่ไม่ต้องการ (ถ้ามี)
```powershell
# ถ้าเพิ่ม domain ผิด
vercel domains remove funaging.studio
```

### 5. เพิ่ม Domain ใหม่ (ถ้าจำเป็น)
```powershell
vercel domains add funaging.studio
```

### 6. ตรวจสอบอีกครั้ง
```powershell
vercel domains inspect funaging.studio
```

---

## หมายเหตุสำคัญ

⚠️ **Proxy status ต้องเป็น DNS only** (ไม่เปิด proxy - ไม่มีสีส้ม)
- ถ้าเปิด proxy (สีส้ม) Vercel จะ verify domain ไม่ได้
- ใช้เวลา 5-30 นาที หลังจากตั้งค่า DNS

---

## หลังจากแก้ไข

1. รอ 5-30 นาที
2. Vercel จะ verify domain อัตโนมัติ
3. Vercel จะส่ง email เมื่อ domain พร้อมใช้งาน
4. ตรวจสอบ: `vercel domains inspect funaging.studio`



