# ตั้งค่า DNS สำหรับ funaging.studio

## สถานะ
✅ Domain `funaging.studio` ถูกเพิ่มใน Vercel แล้ว

## ต้องตั้งค่า DNS

### วิธีที่ 1: ตั้งค่า A Record (แนะนำ)

**ไปที่ Domain Registrar (ที่ซื้อ domain):**

1. เปิด DNS Management
2. เพิ่ม A Record:
   ```
   Type: A
   Name: @ (หรือ funaging.studio)
   Value: 76.76.21.21
   TTL: 3600 (หรือ Auto)
   ```

3. บันทึก

### วิธีที่ 2: เปลี่ยน Nameservers

**เปลี่ยน Nameservers เป็น:**
```
ns1.vercel-dns.com
ns2.vercel-dns.com
```

## ตรวจสอบ

หลังจากตั้งค่า DNS แล้ว:

```powershell
vercel domains inspect funaging.studio
```

รอ 5-30 นาที สำหรับ DNS propagation

## หลังจาก DNS ตั้งค่าเสร็จ

เว็บจะทำงานที่:
- https://funaging.studio
- https://www.funaging.studio (auto-redirect)

## หมายเหตุ

- DNS propagation ใช้เวลา 5-30 นาที
- Vercel จะส่ง email เมื่อ domain พร้อมใช้งาน
- ตรวจสอบ status: `vercel domains ls`

